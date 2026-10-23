# SSG-4 (MT-043): LOADIS / UNLOADIS without a program of their own. Both are a whole-record copy, done by the generic
# CFH-COPY program (INPUT/OUTPUT cards are the same as CFH-COPY's); LOADIS also writes the output's .Index here, before
# the Xqt, from the input file and the KEYIS card. Needs AMT's GetSgsValue in scope, plus GnHandoff.inc.
# Job files are reached through the file controller ($global:AmtFile), with the paths Get-AssignedFile gives.
# AMT .Index layout (decoded from runtime-written files; one primary key):
#   '=W*2', Int32 6, Int64 DAT length, DAT path padded to 255, 01 01, Int32 key count 1, Int32 key offset, Int32 key length,
#   Int32 0, 'Al', Int32 entry count, then per record in key order: key bytes + Int64 record number (0-based).

# Keys of a line-sequential file read the way LOADIS reads it (READ INTO a record of RecordLength, so short lines are
# space-padded). ACCESS SEQUENTIAL: a key not above the previous one is INVALID KEY, which stops the load.
function Get-AmtIndexKeys([Byte[]]$Bytes, [Int32]$RecordLength, [Int32]$KeyOffset, [Int32]$KeyLength) {
  $enc = [Text.Encoding]::GetEncoding(28591)
  $lines = [Collections.Generic.List[String]]::new([String[]]($enc.GetString($Bytes) -split "`r`n"))
  if ($lines[$lines.Count - 1] -eq '') { $lines.RemoveAt($lines.Count - 1) }
  $r = [pscustomobject]@{ Keys = [Collections.Generic.List[String]]::new(); Records = [Collections.Generic.List[String]]::new(); ErrorKey = $null; ErrorRecord = 0 }
  foreach ($l in $lines) {
    $rec = if ($l.Length -ge $RecordLength) { $l.Substring(0, $RecordLength) } else { $l.PadRight($RecordLength) }
    $key = $rec.Substring($KeyOffset, $KeyLength)
    if ($r.Keys.Count -gt 0 -and [String]::CompareOrdinal($key, $r.Keys[$r.Keys.Count - 1]) -le 0) {
      $r.ErrorKey = $key; $r.ErrorRecord = $r.Keys.Count + 1; break
    }
    $r.Keys.Add($key); $r.Records.Add($rec)
  }
  $r
}

function Get-AmtIndexBytes([String]$HeaderPath, [Int64]$DatLength, [Int32]$KeyOffset, [Int32]$KeyLength, $Keys) {
  if ($HeaderPath.Length -gt 255) { throw "LOADIS: path longer than 255 characters: $HeaderPath" }
  $enc = [Text.Encoding]::GetEncoding(28591)
  $ms = [IO.MemoryStream]::new()
  $w = [IO.BinaryWriter]::new($ms)
  $w.Write($enc.GetBytes('=W*2')); $w.Write([Int32]6); $w.Write([Int64]$DatLength)
  $w.Write($enc.GetBytes($HeaderPath.PadRight(255)))
  $w.Write([byte[]](1, 1)); $w.Write([Int32]1); $w.Write([Int32]$KeyOffset); $w.Write([Int32]$KeyLength); $w.Write([Int32]0)
  $w.Write($enc.GetBytes('Al')); $w.Write([Int32]$Keys.Count)
  for ($i = 0; $i -lt $Keys.Count; $i++) { $w.Write($enc.GetBytes($Keys[$i])); $w.Write([Int64]$i) }
  $w.Flush()
  , $ms.ToArray()
}

# File-controller path of a call's file name (use name or assigned file); a staged file may have no .DAT.
function Get-GnFcPath([String]$Name) {
  $keep = $global:FileObject
  try { $p = Get-AssignedFile $Name } finally { $global:FileObject = $keep }
  if (-not $global:AmtFile.FileExists($p) -and $p.EndsWith('.DAT') -and $global:AmtFile.FileExists($p.Substring(0, $p.Length - 4))) { $p = $p.Substring(0, $p.Length - 4) }
  $p
}

function Read-GnFcBytes([String]$FcPath) {
  $fi = $global:AmtFile.GetFileInfo($FcPath, 10)
  if (-not $fi -or -not $fi.Exists) { throw "LOADIS: $FcPath not found ($($global:AmtFile.ErrorDescription))" }
  if ($fi.FileSize -eq 0) { return , [byte[]]@() }
  $bs = $global:AmtFile.OpenBinaryFile($FcPath, $global:Const_Exclusive)
  if (-not $bs) { throw "LOADIS: cannot open $FcPath ($($global:AmtFile.ErrorDescription))" }
  try { , [byte[]]$bs.Read(0, [Int32]$fi.FileSize) } finally { [void]$bs.Close() }
}

function Write-GnFcBytes([String]$FcPath, [Byte[]]$Bytes) {
  $bs = $global:AmtFile.CreateBinaryFile($FcPath, $global:Const_Exclusive, $true)
  if (-not $bs) { throw "LOADIS: cannot create $FcPath ($($global:AmtFile.ErrorDescription))" }
  try { if (-not $bs.Write($Bytes, $Bytes.Length, $true, $false)) { throw "LOADIS: write $FcPath failed ($($global:AmtFile.ErrorDescription))" } } finally { [void]$bs.Close() }
}

# Called at the top of the converted LOADIS / UNLOADIS skeletons (ASCII and MULTI), before the runstream's
# @XQT TPF$.LOADIS / TPF$.UNLOADIS (Check-ReportName makes that LOADIS / UNLOADIS).
function Invoke-LoadisHandoff {
  param([ValidateSet('LOADIS', 'UNLOADIS')][String]$Mode = 'LOADIS', [String]$Program = 'ASSURFED_UTILIT_CFH_COPY_GN', [String]$ParmFile = 'CFHPARM')
  $callIn = ([String](GetSgsValue 'INPUT,1,1,1')).Trim()
  $callOut = ([String](GetSgsValue 'OUTPUT,1,1,1')).Trim()
  $inLen = [Int32](GetSgsValue 'INPUT,1,1,2')
  $outLen = [Int32](GetSgsValue 'OUTPUT,1,1,2')
  if ($Mode -eq 'LOADIS') {
    $keyOff = [Int32](GetSgsValue 'KEYIS,1,1,1')
    $keyLen = [Int32](GetSgsValue 'KEYIS,1,1,2')
    $inFc = Get-GnFcPath $callIn
    $outFc = Get-GnFcPath $callOut
    if (-not $outFc.EndsWith('.DAT')) { $outFc += '.DAT' }
    $k = Get-AmtIndexKeys (Read-GnFcBytes $inFc) $inLen $keyOff $keyLen
    if ($null -ne $k.ErrorKey) {
      Msg "" ("IS.ERROR         : " + $k.ErrorKey)
      Msg "" ("RECORD EN ERREUR : $($k.ErrorRecord) EME")
      Abort "LOADIS: key of record $($k.ErrorRecord) is not above the previous key (INVALID KEY)"
    }
    # the runtime writes the DAT's full path (upper case) in the header
    $header = if ($outFc.StartsWith('\')) { $global:ExtractPath.Substring(0, $global:ExtractPath.LastIndexOf('\')) + $outFc } else { $outFc }
    $ix = Get-AmtIndexBytes $header.ToUpperInvariant() ([Int64]$k.Keys.Count * ($outLen + 2)) $keyOff $keyLen $k.Keys
    Write-GnFcBytes "$outFc.Index" $ix
    # An assigned output lives in the job's TPF$ folder until Free, which moves only the DAT of a file the file
    # controller did not itself open as indexed; so the index is also written where Free puts the DAT.
    $final = $outFc -replace '\\TPF\$[^\\]+\\', '\'
    if ($final -ne $outFc) { Write-GnFcBytes "$final.Index" $ix }
    $global:LoadisIndexFc = "$outFc.Index"
    $global:LoadisIndexFinal = "$final.Index"
    Msg "" ("NB.RECORDS ECRITS $($k.Keys.Count); index $outFc.Index and $final.Index (key $keyOff,$keyLen) from $inFc")
  }
  $lines = [Collections.Generic.List[String]]::new()
  $lines.Add('IN' + 'CFHIN'.PadRight(30) + ('{0:D5}' -f $inLen))
  $lines.Add('OU' + 'CFHOUT'.PadRight(30) + ('{0:D5}' -f $outLen))
  $files = @(@{ Fixed = 'CFHIN'; Call = $callIn }, @{ Fixed = 'CFHOUT'; Call = $callOut; RecSize = $outLen })
  Invoke-GnHandoff -Program $Program -XqtName $Mode -ParmFile $ParmFile -ParmRecLen 250 -ParmLines $lines -Files $files -Label $Mode
}
