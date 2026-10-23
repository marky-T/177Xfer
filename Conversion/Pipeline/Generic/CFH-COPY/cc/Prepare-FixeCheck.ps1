# CFH-COPY-GN check for figurative FIXE values (VIRJ01_PP_L89: FIXE ... 20,1,ZERO ...): stage input + cards, expected
# file from the CFH-COPY model, one CC script job SSG4_VIRJ01PP_CFH_COPY under qualifier CFHFIX, and cc-cases json.
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
. "$(Split-Path $utility)\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\CFH-COPY"
$x = $ge.ExtractPath
$scripts = $ge.ScriptRoot
$root = "$($ge.MockRoot)\CFH_VIRJ01PP"
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
New-Item -ItemType Directory -Force "$root\input", "$root\expected", "$x\CFHFIX", "$x\P`$SGS" | Out-Null
Get-ChildItem "$x\CFHFIX" -File | Remove-Item -Force
$rnd = [Random]::new(2026102189)
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/'
$recs = foreach ($n in 1..12) { -join (1..1000 | ForEach-Object { $chars[$rnd.Next($chars.Length)] }) }
[IO.File]::WriteAllText("$root\input\ina", ($recs -join "`r`n") + "`r`n", $latin1)
Copy-Item "$($ge.SgsCards)\calls\ASSURFED_F999RUN_VIRJ01_PP__L89.sgs" "$x\P`$SGS\VIRJ01PP" -Force
Copy-Item "$root\input\ina" "$x\CFHFIX\INA" -Force
# model: Parse-Parm / Invoke-CfhModel from the cross-check script, on the parameter file it wrote for this call
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$utility\check\Test-CfhParm.ps1", [ref]$null, [ref]$null)
foreach ($f in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -in 'Parse-Parm', 'Set-Slice', 'Invoke-CfhModel' }, $false)) { . ([ScriptBlock]::Create($f.Extent.Text)) }
$p = Parse-Parm (Get-Content "$work\parm\VIRJ01_PP_L89.parm")
Invoke-CfhModel $p "$root\input\ina" "$root\expected\OUTA"
$job = @"
# SSG-4: CFH-COPY-GN on VIRJ01_PP_L89 (figurative FIXE SPACE/ZERO), runstream-style step (Prepare-FixeCheck.ps1).
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'
Set-Jobname "CFHFIX"
Initialize `$AmtSettingsFile
Try {
  Qual "" "CFHFIX"
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_CFH-COPY_ASCII" -SgsFile "P```$SGS\VIRJ01PP"
  Asg "A" ("INA")
  Delete "C" ("OUTA")
  Asg "P, U" ("OUTA")
  Xqt "" (".CFH-COPY")
  Free "" ("INA")
  Free "" ("OUTA")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
[IO.File]::WriteAllText("$scripts\ASSURFED_F999\RUN\SSG4_VIRJ01PP_CFH_COPY.ps1", $job)
ConvertTo-Json @([pscustomobject]@{ Case = 'VIRJ01PP'; Actual = "$x\CFHFIX\OUTA"; Expected = "$root\expected\OUTA" }) | Set-Content "$work\cc-case-VIRJ01PP.json"
$fx = ($p.Fixe | Where-Object { $_[0] -eq 20 }); "model: $((Get-Content "$root\expected\OUTA").Count) records; FIXE 20,1 -> [$($fx[2])]"
