<#
.SYNOPSIS
  Stages the delivery package for AFBUS_2200COBOL_AMT in a local folder (nothing is copied into Federale's folders).
.DESCRIPTION
  Takes the set rebuilt against Federale's 177a runtime (Rebuild-SetAgainstRuntime.ps1), leaves out programs that are not
  deliverable yet (default: RECAP, T3-027), and writes the same layout the first release used:
    Binaries\Programs     <PROGRAM>.dll, <PROGRAM>.deps.json, <APP>.Application.dll, <APP>.Database.dll
    Binaries\Application  <APP>.Application.dll, <APP>.Database.dll (+ deps), Newtonsoft.Json.dll
  plus REBUILT-FOR-177A.csv/.txt, manifest.csv (SHA256 of every file) and DELIVERY-NOTES.txt.
.EXAMPLE
  pwsh -NoProfile -File New-DeliveryPackage.ps1
#>
param(
  [String]$Rebuilt = 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries',
  [String[]]$Exclude = @('ASSURFED_UTILIT_RECAP'),
  [String]$OutRoot = 'E:\AMT_Work\Delivery',
  [String]$App = 'AFBUS_2200COBOL'
)
$ErrorActionPreference = 'Stop'
$Exclude = @($Exclude | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
if ($OutRoot -notlike 'E:\AMT_Work\*') { throw 'OutRoot must be under E:\AMT_Work.' }
$stamp = Get-Date -Format 'yyyyMMdd-HHmm'
$pkg = Join-Path $OutRoot "AFBUS_2200COBOL_AMT-$stamp"
$prg = "$pkg\Binaries\Programs"; $appDir = "$pkg\Binaries\Application"
New-Item -ItemType Directory -Force $prg, $appDir | Out-Null

$skip = { param($n) foreach ($x in $Exclude) { if ($n -like "$x*") { return $true } }; $false }
Get-ChildItem "$Rebuilt\Programs" -File | Where-Object { -not (& $skip $_.Name) -and $_.Name -notmatch '^Newtonsoft' } | Copy-Item -Destination $prg
Get-ChildItem "$Rebuilt\Application" -File | Copy-Item -Destination $appDir

$rows = Get-ChildItem $pkg -Recurse -File | ForEach-Object {
  [pscustomobject]@{ Path = $_.FullName.Substring($pkg.Length + 1); Bytes = $_.Length; Sha256 = (Get-FileHash $_.FullName).Hash }
}
$rows | Export-Csv "$pkg\manifest.csv" -NoTypeInformation -Encoding utf8
@"
Delivery package for Federale application AFBUS_2200COBOL_AMT, staged $stamp (local copy only; nothing has been copied into Federale).
Built from LionDev 177 (8.0.26230.0) output, rebuilt against Federale's 177a runtime (8.0.26230.50): see REBUILT-FOR-177A.txt.
Programs: $((Get-ChildItem $prg -Filter 'ASSURFED_UTILIT_*.dll' | ForEach-Object { $_.BaseName }) -join ', ')
Left out: $($Exclude -join ', ') (database access not converted, T3-027; next phase).
C# namespace is Company.$App.BusinessLogic.* (same as the first release, which is registered as AFBUS_2200COBOL_AMT).
Needs on the application database before running: the 177 reorganise (DMS schema revision 1.1).
First release (to restore): E:\AMT_Backup\FirstRelease-20261013.
"@ | Set-Content "$pkg\DELIVERY-NOTES.txt"
"Staged: $pkg"
$rows | Where-Object Path -match '\.dll$' | Format-Table Path, Bytes -AutoSize | Out-String
