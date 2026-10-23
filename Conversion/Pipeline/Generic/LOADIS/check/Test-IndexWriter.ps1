# Index writer vs the files the static LOADIS programs wrote in CC (DAT model + .Index, byte compare), plus the
# INVALID KEY check on a reversed input.
param([String]$Environment = 'CC-Trial')
. "$PSScriptRoot\..\gen\LoadisParm.ps1"
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
# CC-written outputs of the static LOADIS programs (2026-10-20) and their inputs
$cc = "$($ge.GenericWork)\LOADIS\ref"
$work = "$($ge.GenericWork)\LOADIS\check-out"
New-Item -ItemType Directory -Force $work | Out-Null
$ext = $ge.ExtractPath
$enc = [Text.Encoding]::GetEncoding(28591)
$cases = @(
  @{ Name = 'ASCII'; In = "$cc\B010SINAUTCL.DAT"; Ref = "$cc\OUTCLOA49.DAT"; Out = 'OUTCLOA49.DAT'; Len = 204; Off = 6; KLen = 8 }
  @{ Name = 'MULTI'; In = "$cc\INVIGA50.DAT"; Ref = "$cc\F006GRS.DAT"; Out = 'F006GRS.DAT'; Len = 200; Off = 164; KLen = 26 }
)
foreach ($c in $cases) {
  $dat = Join-Path $work $c['Out']
  $k = Get-AmtIndexKeys ([IO.File]::ReadAllBytes($c['In'])) $c['Len'] $c['Off'] $c['KLen']
  [IO.File]::WriteAllBytes($dat, $enc.GetBytes((($k.Records | ForEach-Object { "$_`r`n" }) -join '')))
  [IO.File]::WriteAllBytes("$dat.Index", (Get-AmtIndexBytes (Join-Path $ext $c['Out']) ([Int64]$k.Keys.Count * ($c['Len'] + 2)) $c['Off'] $c['KLen'] $k.Keys))
  $d = if ((Get-FileHash $dat).Hash -eq (Get-FileHash $c['Ref']).Hash) { 'DAT same' } else { 'DAT DIFF' }
  $x = if ((Get-FileHash "$dat.Index").Hash -eq (Get-FileHash "$($c['Ref']).Index").Hash) { 'Index same' } else { 'Index DIFF' }
  '{0}: {1} keys | {2} | {3}' -f $c['Name'], $k.Keys.Count, $d, $x
}
$rev = Join-Path $work 'reversed.dat'
$l = [IO.File]::ReadAllLines($cases[0]['In'], $enc); [Array]::Reverse($l); [IO.File]::WriteAllLines($rev, $l, $enc)
$k = Get-AmtIndexKeys ([IO.File]::ReadAllBytes($rev)) 204 6 8
'reversed: {0} keys accepted, INVALID KEY at record {1} ({2})' -f $k.Keys.Count, $k.ErrorRecord, $k.ErrorKey
