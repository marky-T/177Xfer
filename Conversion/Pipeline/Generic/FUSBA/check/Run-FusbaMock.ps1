# FUSBA diagnosis: run the delivered generic DLL in the mock system on chosen cases (parameter file with the fixed names).
# The mock passes no task values, so output records are 4,000 B: each record is cut to the output length before comparing.
param([String[]]$Cases = @('D2', 'U2'), [String]$Environment = 'Mock', [String]$Binaries)
$ErrorActionPreference = 'Continue'
$Cases = @($Cases | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
if (-not $Binaries) { $Binaries = $ge.MockRebuild }
$work = "$($ge.GenericWork)\FUSBA"
$mt = "$repo\Conversion\Pipeline\MockTest"
. "$mt\MockFc.ps1"
. "$PSScriptRoot\FusbaModel.ps1"
. "$PSScriptRoot\..\cc\FusbaCases.ps1"
$root = "$work\cases"
$tmp = "$work\mock"
New-Item -ItemType Directory -Force $tmp | Out-Null
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
try {
  foreach ($case in $Cases) {
    $lines = Get-Content "$work\parm\$($FusbaCases[$case]).parm"
    $p = Read-FusbaParm $lines
    $ni = 0; $no = 0
    $fixed = foreach ($l in $lines) {
      if ($l.StartsWith('IN')) { $ni++; 'IN' + "FUSIN$ni".PadRight(30) + $l.Substring(32) }
      elseif ($l.StartsWith('OU')) { $no++; 'OU' + "FUSOUT$no".PadRight(30) + $l.Substring(32) }
      else { $l }
    }
    [IO.File]::WriteAllLines("$tmp\$case.parm", [String[]]($fixed | ForEach-Object { $_.PadRight(80) }), $latin1)
    Start-MockFc
    $r = & "$mt\Run-ProgramCase.ps1" -Case "FUSBA_GN_$case" -Dll ASSURFED_UTILIT_FUSBA_GN.dll -Inputs @{ SGSPARM = "$tmp\$case.parm"; FUSIN1 = "$root\$case\input\$($p.Ins[0][0])"; FUSIN2 = "$root\$case\input\$($p.Ins[1][0])" } -KeepOutputAs FUSOUT1 -KeepOutputTo "$tmp\$case.out1" -Binaries $Binaries
    Stop-MockFc
    $len = $p.Outs[0][1]
    $act = if (Test-Path "$tmp\$case.out1") { @(Get-Content "$tmp\$case.out1" -Encoding Latin1 | ForEach-Object { $_.Substring(0, [Math]::Min($len, $_.Length)).PadRight($len) }) } else { @() }
    $exp = @(Get-Content "$root\$case\expected\$($p.Outs[0][0])" -Encoding Latin1)
    $diff = 0; for ($i = 0; $i -lt [Math]::Min($act.Count, $exp.Count); $i++) { if ($act[$i] -cne $exp[$i]) { $diff++ } }
    '{0} output 1: {1} records (model {2}), {3} differ  [{4} {5}]' -f $case, $act.Count, $exp.Count, $diff, $r.Result, $r.Detail
  }
} finally { Stop-MockFc }
