# SSG-4 (MT-043): shared skeleton hand-off for the generic programs (CFH-COPY, BABA, FUSBA, ...). Deployed as
# GnHandoff.inc next to the converted skeletons; each skeleton's own <Name>Parm.inc builds the parameter lines and
# calls Invoke-GnHandoff. Runs inside R&D's Invoke-Ssg (AmtPsEclLib, StrictMode 2).

# The call's SGS images from the raw card file (Invoke-Ssg's $SgsFilePath), for cards AddTo-SgsList cannot split
# (quoted subfields with spaces, T3-028). SSG manual 3.1.1: ' ;' or ',;' outside quotes continues the image on the next
# line (the rest of the line is ignored); a semicolon after any other character is data. A continued last line is dropped.
function Read-GnSgsImages([String]$CardFile) {
  $images = New-Object System.Collections.Generic.List[String]
  $cur = ''
  foreach ($line in [IO.File]::ReadAllLines($CardFile, [System.Text.Encoding]::GetEncoding('iso-8859-1'))) {
    $cut = -1; $single = $false; $pair = $false
    for ($i = 0; $i -lt $line.Length; $i++) {
      $c = $line[$i]
      if (-not $single -and $c -eq "'" -and $i + 1 -lt $line.Length -and $line[$i + 1] -eq "'") { $pair = -not $pair; $i++; continue }
      if (-not $pair -and $c -eq "'") { $single = -not $single; continue }
      if (-not $single -and -not $pair -and $c -eq ';' -and $i -gt 0 -and ($line[$i - 1] -eq ' ' -or $line[$i - 1] -eq ',')) { $cut = $i; break }
    }
    if ($cut -ge 0) { $cur += $line.Substring(0, $cut).TrimEnd() + $(if ($line[$cut - 1] -eq ',') { '' } else { ' ' }); continue }
    $images.Add(($cur + $line.Trim()).TrimEnd()); $cur = ''
  }
  return , $images.ToArray()
}

# One SGS image -> fields, each an array of subfields. 'x' (method 1) keeps its quotes, ''x'' (method 2) does not.
function Split-GnSgsImage([String]$Image) {
  $fields = New-Object System.Collections.Generic.List[Object]
  $subs = New-Object System.Collections.Generic.List[String]
  $buf = New-Object System.Text.StringBuilder
  $pair = $false; $quote = $false; $any = $false
  for ($i = 0; $i -lt $Image.Length; $i++) {
    $c = $Image[$i]
    if (-not $quote -and $c -eq "'" -and $i + 1 -lt $Image.Length -and $Image[$i + 1] -eq "'") { $pair = -not $pair; $any = $true; $i++; continue }
    if (-not $pair -and $c -eq "'") { $quote = -not $quote; [void]$buf.Append($c); $any = $true; continue }
    if (-not $pair -and -not $quote -and ($c -eq ' ' -or $c -eq ',')) {
      if ($c -eq ',' -or $any) { $subs.Add($buf.ToString()); [void]$buf.Clear(); $any = $c -eq ',' }
      if ($c -eq ' ' -and $subs.Count) { $fields.Add($subs.ToArray()); $subs.Clear(); $any = $false }
      continue
    }
    [void]$buf.Append($c); $any = $true
  }
  if ($any) { $subs.Add($buf.ToString()) }
  if ($subs.Count) { $fields.Add($subs.ToArray()) }
  return , $fields.ToArray()
}

# The images of one label (first field, case-insensitive), each split into fields.
function Get-GnSgsCards([String]$CardFile, [String]$Label) {
  $out = New-Object System.Collections.Generic.List[Object]
  foreach ($img in (Read-GnSgsImages $CardFile)) {
    $f = Split-GnSgsImage $img
    if ($f.Count -and $f[0][0] -eq $Label) { $out.Add($f) }
  }
  return , $out.ToArray()
}

# Use-name entry $Alias that follows $Target (a use name or an assigned file's short name) at Xqt time, so End-Xqt
# gives the program's fixed name the same physical file as the call's real one. Writes from Asg are ignored.
# Target '*ACCEPT*': the run's Xqt data lines (card-reader input). End-Xqt sends a use name that matches no assigned
# file as Add-FileExtension(FileName), the same path Accept-Write builds; the Accept file is closed before the program runs.
function Add-GnUseAlias([String]$Alias, [String]$Target) {
  for ($i = $global:UseNamesList.Count - 1; $i -ge 0; $i--) { if ($global:UseNamesList[$i].Usename -eq $Alias) { $global:UseNamesList.RemoveAt($i) } }
  $find = if ($Target -eq '*ACCEPT*') {
    # No data lines: no Accept file is open (an older one may still be on disk), so point at a fresh empty file.
    [ScriptBlock]::Create('if ($global:AcceptOpen) { $p = "$global:TempFolder\Accept_File" } else { $p = "$global:TempFolder\GN_NO_DATA"; [IO.File]::WriteAllText((Add-FileExtension $p $global:UseExtension), '''') }; [pscustomobject]@{ Filename = $p; FileObject = $null }')
  }
  else { [ScriptBlock]::Create("
    `$u = @(`$global:UseNamesList | Where-Object { `$_.Usename -eq '$Target' }) | Select-Object -First 1
    if (`$u) { return `$u }
    @(`$global:FilesList | Where-Object { `$_.ShortName -eq '$Target' }) | Select-Object -First 1") }
  $o = New-Object PSObject
  $o | Add-Member -Name Usename -Value $Alias -MemberType NoteProperty
  $o | Add-Member -Name Target -Value $find -MemberType NoteProperty
  $o | Add-Member -Name FileObject -MemberType ScriptProperty -Value { $t = & $this.Target; if ($t -and $t.PSObject.Properties['Usename']) { $t.FileObject } else { $t } } -SecondValue { }
  $o | Add-Member -Name Filename -MemberType ScriptProperty -Value { $t = & $this.Target; if ($t) { $t.Filename } } -SecondValue { }
  $o | Add-Member -Name IsSentToProgram -Value $false -MemberType NoteProperty
  $global:UseNamesList.Add($o)
}

# -Files: one entry per program file, @{ Fixed = name the program opens; Call = the call's use name or file; RecSize = output
# record length (outputs only) }, as hashtables (index access: StrictMode 2 throws on a missing key with dot access).
# Fixed = Call means no alias (the program opens the call's own name).
function Invoke-GnHandoff {
  param(
    [Parameter(Mandatory)][String]$Program,
    [Parameter(Mandatory)][String]$XqtName,
    [Parameter(Mandatory)][String]$ParmFile,
    [Parameter(Mandatory)][Int32]$ParmRecLen,
    [Parameter(Mandatory)][AllowEmptyCollection()][Object[]]$ParmLines,
    [Parameter(Mandatory)][Object[]]$Files,
    [String]$Label = $XqtName
  )
  $dir = Join-Path $global:AmtPath.ExtractPath $global:DefaultQual
  # A qualifier's folder exists only once a file has been written there (Asg alone does not create it).
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
  # T3-040: lines padded to the record length, else the line-sequential reader can merge several lines into one record.
  [IO.File]::WriteAllLines((Join-Path $dir $ParmFile), [String[]]($ParmLines | ForEach-Object { ([String]$_).PadRight($ParmRecLen) }), [System.Text.Encoding]::GetEncoding('iso-8859-1'))
  # T3-041: an earlier call (another qualifier) may still hold the names; Asg would then keep the old file.
  Free "" ("SGSPARM")
  Free "" ($ParmFile)
  Asg "A" ($ParmFile)
  Use ("SGSPARM") $ParmFile
  # The runtime sets a file's record size from task value RECSIZE<name> at open (AmtFileId.GetPhysicalFile);
  # Check-ClearTaskObject first, so the Xqt that follows does not clear the values again.
  $task = Get-TaskObject $null
  Check-ClearTaskObject -TaskObj $task
  foreach ($f in $Files) { if ($f['RecSize']) { $task.SetTVCustom("RECSIZE$($f['Fixed'])", [String][Int32]$f['RecSize']) } }
  foreach ($f in $Files) { if ($f['Fixed'] -ne $f['Call']) { Add-GnUseAlias $f['Fixed'] $f['Call'] } }
  # MT-044: the Xqt name -> program map is AMT's CloneReports in the script set's AmtSettings.xml (Deploy-GnScriptSet writes it
  # from utilities.json); End-Xqt reads it. Stop here rather than let End-Xqt run a different program.
  $entry = @($global:CloneReports | Where-Object { $_ -and $_.Clone -eq $XqtName }) | Select-Object -First 1
  if (-not $entry) { Abort "SSG-4 hand-off ($Label): no CloneReports entry for Xqt '$XqtName' (expected -> $Program) in AmtSettings.xml" }
  if ($entry.Name -ne $Program) { Abort "SSG-4 hand-off ($Label): CloneReports maps Xqt '$XqtName' to '$($entry.Name)', expected '$Program'" }
  Msg "" ("SSG-4 hand-off ($Label): SGSPARM -> $dir\$ParmFile ($($ParmLines.Count) lines); " + (($Files | ForEach-Object { "$($_['Fixed'])=$($_['Call'])" }) -join ' ') + "; Xqt $XqtName -> $Program")
}
