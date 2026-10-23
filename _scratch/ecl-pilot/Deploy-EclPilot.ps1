<#
.SYNOPSIS
  MT-043 quick try: put the ECL pilot into a NEW folder AmtTools\Basepaths\Scripts\SSG4 (nothing existing is changed).
.DESCRIPTION
  Script     _scratch\ecl-pilot\SSG4\ASSURFED_F999\RUN\SSG4_AFPH12_CFH_COPY.ps1 (LAB146 of R&D's AFPH12 script, unchanged statements)
  Skeleton   our ECL-converter output with our SSG library (_scratch\ecl-cmp3\out\UTILIT_CFH-COPY_ASCII.ps1, no Fin)
  Settings   copy of Scripts\Settings\AmtSettings.xml with AppName = AFBUS_2200COBOL_AMT, UseUnicode = False and CloneReports CFH_COPY -> ASSURFED_UTILIT_CFH_COPY_ASCII
  -Remove takes the SSG4 folder away again.
#>
param(
  [String]$Scripts = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Scripts',
  [String]$App = 'AFBUS_2200COBOL_AMT',
  [Switch]$Generic,
  [String]$Program = 'ASSURFED_UTILIT_CFH_COPY_GF',
  [Switch]$FixedNames,
  [Switch]$Remove
)
$ErrorActionPreference = 'Stop'
$dst = Join-Path $Scripts 'SSG4'
if ($Remove) { if (Test-Path $dst) { Remove-Item $dst -Recurse -Force; "removed $dst" }; return }

$src = Join-Path $PSScriptRoot 'SSG4'
New-Item -ItemType Directory -Force "$dst\ASSURFED_F999\RUN", "$dst\ASSURFED_UTILIT", "$dst\Settings" | Out-Null
Copy-Item "$src\ASSURFED_F999\RUN\SSG4_*.ps1" "$dst\ASSURFED_F999\RUN\" -Force
$skel = Get-Content 'E:\Repos\SsgTrial\_scratch\ecl-cmp3\out\UTILIT_CFH-COPY_ASCII.ps1' -Raw
if ($Generic) {
  $fixed = if ($FixedNames) { ' -FixedNames' } else { '' }
  $null = & E:\Repos\SsgTrial\Conversion\Pipeline\Generic\Deploy-GnSkeleton.ps1 -Skeleton 'UTILIT_CFH-COPY_ASCII' -ParmScript 'E:\Repos\SsgTrial\_scratch\spike-cfh\gen\CfhCopyParm.ps1' -Call "Invoke-CfhCopyHandoff -Program '$Program'$fixed" -Target "$dst\ASSURFED_UTILIT"
} else {
  [IO.File]::WriteAllText("$dst\ASSURFED_UTILIT\UTILIT_CFH-COPY_ASCII.ps1", $skel)
}

$x = [xml](Get-Content (Join-Path $Scripts 'Settings\AmtSettings.xml') -Raw)
$x.Amt.AmtSettings.AppName = $App
# T3-039: the application does not define Unicode extract files; True makes Asy-Cat pre-create UTF-16 files.
$x.Amt.AmtSettings.UseUnicode = 'False'
$clone = $x.CreateElement('CloneReports')
$o = $x.CreateElement('OrginalReport')
$o.SetAttribute('Name', 'ASSURFED_UTILIT_CFH_COPY_ASCII')
$o.SetAttribute('Clone', 'CFH_COPY')
[void]$clone.AppendChild($o)
[void]$x.Amt.AppendChild($clone)
$x.Save("$dst\Settings\AmtSettings.xml")

$check = [xml](Get-Content "$dst\Settings\AmtSettings.xml" -Raw)
'AppName      : ' + $check.Amt.AmtSettings.AppName
'UseUnicode   : ' + $check.Amt.AmtSettings.UseUnicode
'CloneReports : ' + (($check.Amt.CloneReports.OrginalReport | ForEach-Object { "$($_.Clone) -> $($_.Name)" }) -join ', ')
Get-ChildItem $dst -Recurse -File | ForEach-Object { '{0} {1:N0} B' -f $_.FullName.Substring($Scripts.Length + 1), $_.Length }
