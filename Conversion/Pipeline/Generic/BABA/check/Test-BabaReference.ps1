# BABA reference check: run the real static BABA DLL (built from 2PPJ11_L74's cards) in the mock system on synthetic
# data, and compare byte for byte with the PowerShell model of the generic program (BabaModel.ps1) on the same data.
param([String]$Environment = 'Mock', [String]$Binaries)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
if (-not $Binaries) { $Binaries = $ge.MockRebuild }
$mt = "$repo\Conversion\Pipeline\MockTest"
$root = "$($ge.MockRoot)\BABA_2PPJ11_L74"
$chk = "$($ge.GenericWork)\BABA"
. "$PSScriptRoot\BabaModel.ps1"
New-Item -ItemType Directory -Force "$root\input", "$root\model" | Out-Null
$rnd = [Random]::new(2026102074)
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/'
$heads = 'CONTROLE', 'CONTROLX', 'AAAAAAAA', 'CONTROLE', 'ZZZZZZZZ', 'control ', 'CONTROL;', 'CONTROLE'
$recs = foreach ($n in 1..30) { $heads[$rnd.Next($heads.Count)] + ('{0:D4}' -f $n) + (-join (1..354 | ForEach-Object { $chars[$rnd.Next($chars.Length)] })) }
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
[IO.File]::WriteAllText("$root\input\I001MSG054", ($recs -join "`r`n") + "`r`n", $latin1)
$p = Read-BabaParm (Get-Content "$chk\parm\2PPJ11_L74.parm")
$m = Invoke-BabaModel $p "$root\input\I001MSG054" @("$root\model\I006MSG054")
'model: written {0}, dropped {1} (CONTROLE records in input: {2})' -f ($m.Written -join '/'), $m.Dropped, @($recs | Where-Object { $_.StartsWith('CONTROLE') }).Count
. "$mt\MockFc.ps1"
try {
  Start-MockFc
  $r = & "$mt\Run-ProgramCase.ps1" -Case BABA_STATIC_2PPJ11 -Dll ASSURFED_UTILIT_BABA_ASCII.dll -Inputs @{ I001MSG054 = "$root\input\I001MSG054" } -ExpectedName I006MSG054 -ExpectedFile "$root\model\I006MSG054" -Binaries $Binaries
  'static DLL vs model: {0} {1}' -f $r.Result, $r.Detail
} finally { Stop-MockFc }
