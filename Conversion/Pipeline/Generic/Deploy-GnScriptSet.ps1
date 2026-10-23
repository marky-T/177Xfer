<#
.SYNOPSIS
  SSG-4 (MT-043): set up the script set under the environment's ScriptRoot (Basepath Script path + our folder):
  ASSURFED_F999\RUN (test jobs), ASSURFED_UTILIT (hand-off skeletons and includes), Settings\AmtSettings.xml.
.DESCRIPTION
  The settings are a copy of the Script path's Settings\AmtSettings.xml with AppName = the environment's application,
  UseUnicode = False (T3-039: True makes Asy-Cat pre-create UTF-16 files) and CloneReports: one entry per Xqt name of every
  utility in utilities.json (Clone = the Xqt name as AmtPsEclLib's Check-ReportName makes it, Name = the generic program; MT-044).
  -Remove takes the folder away again.
#>
param([String]$Environment = 'CC-Trial', [Switch]$Remove)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$dst = $ge.ScriptRoot
if ($Remove) { if (Test-Path $dst) { Remove-Item $dst -Recurse -Force; "removed $dst" }; return }
New-Item -ItemType Directory -Force "$dst\ASSURFED_F999\RUN", "$dst\ASSURFED_UTILIT", "$dst\Settings" | Out-Null

$x = [xml](Get-Content (Join-Path $ge.ScriptPath 'Settings\AmtSettings.xml') -Raw)
$x.Amt.AmtSettings.AppName = $ge.AppName
$x.Amt.AmtSettings.UseUnicode = 'False'
$clone = $x.CreateElement('CloneReports')
foreach ($u in (Get-Content "$PSScriptRoot\utilities.json" -Raw | ConvertFrom-Json).utilities) {
  foreach ($name in $u.xqt) {
    $o = $x.CreateElement('OrginalReport')
    $o.SetAttribute('Name', $u.program)
    $o.SetAttribute('Clone', $name)
    [void]$clone.AppendChild($o)
  }
}
[void]$x.Amt.AppendChild($clone)
$x.Save("$dst\Settings\AmtSettings.xml")

$check = [xml](Get-Content "$dst\Settings\AmtSettings.xml" -Raw)
'AppName      : ' + $check.Amt.AmtSettings.AppName
'UseUnicode   : ' + $check.Amt.AmtSettings.UseUnicode
'CloneReports : ' + (($check.Amt.CloneReports.OrginalReport | ForEach-Object { "$($_.Clone) -> $($_.Name)" }) -join ', ')
