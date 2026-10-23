# BABA diagnosis: run the delivered generic DLL in the mock system on one case (parameter file with the fixed names).
# The mock passes no task values, so output records are 4,000 B; only routing (record counts per output) is compared.
param([String[]]$Cases = @('E1', 'RB2'), [String]$Environment = 'Mock')
$ErrorActionPreference = 'Continue'
$Cases = @($Cases | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\BABA"
$mt = "$repo\Conversion\Pipeline\MockTest"
. "$mt\MockFc.ps1"
. "$PSScriptRoot\BabaModel.ps1"
$calls = @{ E1 = '2PPJ11_L74'; R2 = '-d_AFID01_L76'; RB2 = 'PAIJ01_PP_L69'; E19 = 'SINM05_L211' }
$root = "$work\cases"
$tmp = "$work\mock"
New-Item -ItemType Directory -Force $tmp | Out-Null
try {
  foreach ($case in $Cases) {
    $lines = Get-Content "$work\parm\$($calls[$case]).parm"
    $p = Read-BabaParm $lines
    $fixed = for ($i = 0; $i -lt $lines.Count; $i++) {
      $l = $lines[$i]
      if ($l.StartsWith('IN')) { 'IN' + 'BABIN'.PadRight(30) + $l.Substring(32) }
      elseif ($l.StartsWith('OU')) { $script:o = 1 + [Int32]($script:o); 'OU' + "BABOUT$($script:o)".PadRight(30) + $l.Substring(32) }
      else { $l }
    }
    $script:o = 0
    [IO.File]::WriteAllLines("$tmp\$case.parm", [String[]]$fixed, [System.Text.Encoding]::GetEncoding('iso-8859-1'))
    Start-MockFc
    $r = & "$mt\Run-ProgramCase.ps1" -Case "BABA_GN_$case" -Dll ASSURFED_UTILIT_BABA_GN.dll -Inputs @{ SGSPARM = "$tmp\$case.parm"; BABIN = "$root\$case\input\$($p.InName)" } -ExpectedName BABOUT1 -ExpectedFile "$root\$case\expected\$($p.Outs[0][0])" -KeepOutputAs BABOUT1 -KeepOutputTo "$tmp\$case.out1" -Binaries $ge.MockRebuild
    Stop-MockFc
    $n = if (Test-Path "$tmp\$case.out1") { @(Get-Content "$tmp\$case.out1").Count } else { -1 }
    $e = @(Get-Content "$root\$case\expected\$($p.Outs[0][0])").Count
    '{0,-4} records in output 1: {1} (model {2})   [{3} {4}]' -f $case, $n, $e, $r.Result, $r.Detail
  }
} finally { Stop-MockFc }

