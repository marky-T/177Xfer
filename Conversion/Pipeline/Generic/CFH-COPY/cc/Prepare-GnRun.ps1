# CFH-COPY-GN (MT-043): script set + the fixed-names hand-off in UTILIT_CFH-COPY_ASCII, the pilot jobs (jobs\), and inputs
# and cards for AFPH12, VIRM01, NEWNAME (AFPH12's data under names no program knows) and VIRM01UL. Writes cc-cases.json.
# Delivery of the DLL is separate (Deliver-GnPrograms.ps1).
# JobPrefix: the jobs are deployed as <JobPrefix><call>_CFH_COPY, so a second application on the same Basepaths gets its own job names.
param([String]$Environment = 'CC-Trial', [String]$JobPrefix = 'SSG4_')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
$gn = Split-Path $utility
. "$gn\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\CFH-COPY"
$x = $ge.ExtractPath
$mock = $ge.MockRoot
$cards = "$($ge.SgsCards)\calls"
$r = @()
$r += & "$gn\Deploy-GnScriptSet.ps1" -Environment $Environment
Get-ChildItem "$PSScriptRoot\jobs" -Filter 'SSG4_*_CFH_COPY.ps1' | ForEach-Object { Copy-Item $_.FullName (Join-Path "$($ge.ScriptRoot)\ASSURFED_F999\RUN" ($JobPrefix + $_.Name.Substring(5))) -Force }
$d = & "$gn\Deploy-GnSkeleton.ps1" -Skeleton 'UTILIT_CFH-COPY_ASCII' -ParmScript "$utility\gen\CfhCopyParm.ps1" -Call "Invoke-CfhCopyHandoff -Program 'ASSURFED_UTILIT_CFH_COPY_GN' -FixedNames" -Target "$($ge.ScriptRoot)\ASSURFED_UTILIT"
$r += "$($d.Skeleton).ps1 hand-off deployed, parse errors: $($d.ParseErrors)"
New-Item -ItemType Directory -Force "$x\ASSURFED", "$x\P`$SGS", $work | Out-Null
Copy-Item "$mock\AFPH12_L427\input\INASC" "$x\ASSURFED\IAFB011FAI" -Force
Copy-Item "$mock\AFPH12_L427\input\INASC" "$x\ASSURFED\ZZTESTIN" -Force
Copy-Item "$mock\VIRM01\input\INB" "$x\ASSURFED\I006VRM01ATT" -Force
Copy-Item "$cards\ASSURFED_F999RUN_AFPH12__L427.sgs" "$x\P`$SGS\AFPH12" -Force
Copy-Item "$cards\ASSURFED_F999RUN_VIRM01_CO__L484.sgs" "$x\P`$SGS\VIRM01" -Force
$nn = (Get-Content -Raw "$cards\ASSURFED_F999RUN_AFPH12__L427.sgs") -replace '\bINASC\b', 'ZZNEWIN' -replace '\bOUTASC\b', 'ZZNEWOUT'
[IO.File]::WriteAllText("$x\P`$SGS\NEWNAME", $nn)
Copy-Item "$mock\VIRM01_UL\input\I006KTMAJ1" "$x\ASSURFED\I006KTMAJ1" -Force
Copy-Item "$cards\ASSURFED_F999RUN_VIRM01_UL__L160.sgs" "$x\P`$SGS\VIRM01UL" -Force
foreach ($old in 'IAFB012FAI.DAT', 'I006VRM01ATC', 'I006VRM01ATC.DAT', 'ZZTESTOUT', 'ZZTESTOUT.DAT', 'F006KTMAJ3', 'F006KTMAJ3.DAT', 'CFHPARM') { if (Test-Path "$x\ASSURFED\$old") { Remove-Item "$x\ASSURFED\$old" -Force; $r += "removed old ASSURFED\$old" } }
$r += Get-ChildItem "$x\ASSURFED", "$x\P`$SGS" -File | ForEach-Object { 'staged {0} {1:N0} B' -f $_.FullName.Substring($x.Length + 1), $_.Length }
$cc = @(
  [pscustomobject]@{ Case = 'AFPH12'; Actual = "$x\ASSURFED\IAFB012FAI"; Expected = "$mock\AFPH12_L427\expected\OUTASC" }
  [pscustomobject]@{ Case = 'VIRM01'; Actual = "$x\ASSURFED\I006VRM01ATC"; Expected = "$mock\VIRM01\expected\INC" }
  [pscustomobject]@{ Case = 'NEWNAME'; Actual = "$x\ASSURFED\ZZTESTOUT"; Expected = "$mock\AFPH12_L427\expected\OUTASC" }
  [pscustomobject]@{ Case = 'VIRM01UL'; Actual = "$x\ASSURFED\F006KTMAJ3"; Expected = "$mock\VIRM01_UL\expected\F006KTMAJ3" })
$cc | ConvertTo-Json | Set-Content "$work\cc-cases.json"
# One file per job: Test-CcJob reports every listed output that the job did not write.
foreach ($c in $cc) { ConvertTo-Json -InputObject @($c) | Set-Content "$work\cc-case-$($c.Case).json" }
$r | Out-File "$work\prepare-gn.txt"
$r
