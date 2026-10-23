# LOADIS/UNLOADIS via CFH-COPY-GN + index (MT-043): one case per real call (10 LOADIS, 5 UNLOADIS), each in its own
# qualifier LDnn, with generated data in the call's layout. Writes job SSG4_LOADIS_ALL and all-cases.json for
# Check-LoadisAll.ps1. Expected data files come from the model below; LOADIS indexes are checked by a separate validator.
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\LOADIS"
$scripts = $ge.ScriptRoot
$x = $ge.ExtractPath
$cardRoot = $ge.SgsCards
$root = "$work\expected"
$enc = [Text.Encoding]::GetEncoding(28591)
$rnd = [Random]::new(2026102107)
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/'
function Get-Card([String[]]$Lines, [String]$Label) {
  $l = $Lines | Where-Object { $_ -match "^$Label\s" } | Select-Object -First 1
  if (-not $l) { throw "no $Label card" }
  , (($l -replace "^$Label\s+", '').Trim() -split ',')
}
function New-Records([Int32]$Len, [Int32]$KeyOff, [Int32]$KeyLen, [Int32]$Count) {
  $recs = [Collections.Generic.List[String]]::new()
  for ($i = 0; $i -lt $Count; $i++) {
    $body = -join (1..$Len | ForEach-Object { $chars[$rnd.Next($chars.Length)] })
    # ascending unique keys: a fixed-width counter at the end of a random prefix that grows with $i
    $key = ('K' + ('{0:D6}' -f (($i + 1) * 37))).PadLeft($KeyLen, '0')
    if ($key.Length -gt $KeyLen) { $key = $key.Substring($key.Length - $KeyLen) }
    $rec = $body.Substring(0, $KeyOff) + $key + $body.Substring($KeyOff + $KeyLen)
    # every 7th record ends in spaces after the key (trailing blanks must survive the copy)
    if ($i % 7 -eq 3) { $b = [Math]::Max($KeyOff + $KeyLen, $Len - 20); $rec = $rec.Substring(0, $b) + (' ' * ($Len - $b)) }
    $recs.Add($rec)
  }
  , $recs
}
$calls = Import-Csv "$cardRoot\sgs-calls.csv" | Where-Object { $_.ProgramKey -match '^(UN)?LOADIS_' } | Sort-Object { $_.ProgramKey -like 'UN*' }, RunId, { [Int32]$_.Line }
New-Item -ItemType Directory -Force "$x\P`$SGS" | Out-Null
$cases = @(); $r = @(); $n = 0
$body = foreach ($c in $calls) {
  $n++
  $q = 'LD{0:D2}' -f $n
  $cardLines = Get-Content (Join-Path $cardRoot $c.CardFile)
  $in = Get-Card $cardLines 'INPUT'; $out = Get-Card $cardLines 'OUTPUT'; $key = Get-Card $cardLines 'KEYIS'
  $inName = $in[0].Trim(); $outName = $out[0].Trim(); $len = [Int32]$in[1]; $outLen = [Int32]$out[1]
  if ($len -ne $outLen) { throw "$($c.RunId) L$($c.Line): input $len <> output $outLen (model assumes equal)" }
  $ko = [Int32]$key[0]; $kl = [Int32]$key[1]
  $mode = if ($c.ProgramKey -like 'UN*') { 'UNLOADIS' } else { 'LOADIS' }
  $skel = 'UTILIT_' + $c.ProgramKey
  $recs = New-Records $len $ko $kl (20 + $n)
  $text = (($recs | ForEach-Object { "$_`r`n" }) -join '')
  $dir = "$root\$q"
  New-Item -ItemType Directory -Force $dir, "$x\$q" | Out-Null
  Get-ChildItem "$x\$q" -File | Remove-Item -Force
  [IO.File]::WriteAllBytes("$dir\input", $enc.GetBytes($text))
  [IO.File]::WriteAllBytes("$dir\expected", $enc.GetBytes($text))
  Copy-Item "$dir\input" "$x\$q\$inName" -Force
  Copy-Item (Join-Path $cardRoot $c.CardFile) "$x\P`$SGS\LDC$n" -Force
  $cases += [pscustomobject]@{ Case = $q; Mode = $mode; Call = "$($c.RunId) L$($c.Line)"; Qual = $q; Out = $outName; Len = $len; KeyOff = $ko; KeyLen = $kl; Records = $recs.Count; Expected = "$dir\expected" }
  $r += '{0} {1,-8} {2,-12} {3,-13} -> {4,-13} len {5,3} key {6},{7} records {8}' -f $q, $mode, "$($c.RunId) L$($c.Line)", $inName, $outName, $len, $ko, $kl, $recs.Count
  "  Msg `"`" (`"LOADIS-ALL case $q`: $mode $($c.RunId) L$($c.Line)`")"
  "  Qual `"D`" `"$q`""
  "  Asg `"A`" (`"$inName`")"
  "  Delete `"C`" (`"$outName`")"
  "  Asg `"P, U`" (`"$outName`")"
  "  Invoke-Ssg -Options `"IA`" -Skeleton `"../../ASSURFED_UTILIT/$skel`" -SgsFile `"P```$SGS\LDC$n`""
  "  Xqt `"`" (`"TPF```$.$mode`")"
  "  Msg `"`" (`"LOADIS-ALL case $q done`")"
  "  Free `"`" (`"$inName`")"
  "  Free `"`" (`"$outName`")"
  ''
}
$job = @"
# SSG-4 (MT-043): every LOADIS/UNLOADIS call's layout through CFH-COPY-GN + the hand-off's index writer (Prepare-LoadisAll.ps1).
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "LOADALL"
Initialize `$AmtSettingsFile

Try {
  Qual "" "LOADALL"
$($body -join "`r`n")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
$path = "$scripts\ASSURFED_F999\RUN\SSG4_LOADIS_ALL.ps1"
[IO.File]::WriteAllText($path, $job)
$e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$e)
$r += "SSG4_LOADIS_ALL.ps1 written, $n cases, parse errors: $($e.Count)"
$cases | ConvertTo-Json | Set-Content "$work\all-cases.json"
$r | Out-File "$work\prepare-all.txt"
$r
