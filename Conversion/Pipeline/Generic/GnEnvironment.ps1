# Get-GnEnvironment: one profile of environments.psd1 with every path expanded, plus the paths AMT derives from them.
function Get-GnEnvironment {
  param([String]$Name = $(if ($env:GN_ENVIRONMENT) { $env:GN_ENVIRONMENT } else { 'CC-Trial' }))
  $cfg = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'environments.psd1')
  if (-not $cfg.Profiles.ContainsKey($Name)) { throw "Unknown environment '$Name' (known: $($cfg.Profiles.Keys -join ', '))" }
  $p = $cfg.Profiles[$Name]
  $vars = @{ SYSROOT = $p['SYSROOT']; APPROOT = $p['AppBasepath']; WORKROOT = $cfg.Work['WorkRoot'] }
  $expand = { param($s) foreach ($k in $vars.Keys) { $s = $s.Replace("%$k%", $vars[$k]) }; $s }
  $e = [ordered]@{ Name = $Name; Description = $p['Description']; SYSROOT = $p['SYSROOT']; AppName = $p['AppName']; AppBasepath = $p['AppBasepath'] }
  foreach ($k in $p['Basepath'].Keys) { $e[$k] = & $expand $p['Basepath'][$k] }
  foreach ($k in $cfg.Work.Keys) { $e[$k] = & $expand $cfg.Work[$k] }
  if ($p['LionDevelopment']) { $e['LionDevelopment'] = & $expand $p['LionDevelopment'] }
  if (-not $p['LionApp']) { throw "Environment '$Name' has no LionApp." }
  $e['LionApp'] = $p['LionApp']
  $e['RebuildPrograms'] = Join-Path $e['RebuildRoot'] "$($p['LionApp'])\Binaries\Programs"
  $e['ProgramsPath'] = Join-Path $p['AppBasepath'] 'Programs'
  $e['ScriptRoot'] = Join-Path $e['ScriptPath'] $p['ScriptFolder']
  $e['SettingsFile'] = Join-Path $e['ScriptRoot'] 'Settings\AmtSettings.xml'
  [pscustomobject]$e
}
