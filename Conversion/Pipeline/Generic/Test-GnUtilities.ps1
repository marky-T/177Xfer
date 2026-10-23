<#
.SYNOPSIS
  SSG-4: check utilities.json against the repo: every named file exists, each include and program source matches the name it
  claims, each skeleton is in skeletons\, and each hand-off's defaults (program, Xqt name, parameter file, record length)
  agree with the entry. Exit code = number of problems.
#>
param([String]$Environment = 'CC-Trial', [Switch]$SkipSettings)
$ErrorActionPreference = 'Stop'
$g = $PSScriptRoot
$u = Get-Content "$g\utilities.json" -Raw | ConvertFrom-Json
$bad = [Collections.Generic.List[String]]::new()
function Need([String]$what, [String]$rel) { if (-not $rel) { return }; if (-not (Test-Path "$g\$rel")) { $bad.Add("$what : missing $rel") } }
foreach ($e in $u.utilities) {
  $k = $e.utility
  Need "$k includeSource" $e.includeSource; Need "$k programSource" $e.programSource
  foreach ($s in $e.skeletons) { Need "$k skeleton" "skeletons\$($s.skeleton).ps1" }
  foreach ($p in 'parameterCheck', 'offline', 'check') { Need "$k tests.$p" $e.tests.$p }
  foreach ($p in $e.tests.prepare) { Need "$k prepare" $p }
  if ($e.includeSource) {
    $inc = [IO.Path]::GetFileNameWithoutExtension($e.includeSource)
    if ($inc -ne $e.include) { $bad.Add("$k : include '$($e.include)' vs file $inc") }
    $t = Get-Content "$g\$($e.includeSource)" -Raw
    $own = -not $e.usesProgramOf
    if ($own -or $e.utility -eq 'LOADIS') {
      if ($t -notmatch [regex]::Escape("'$($e.program)'") -and -not (@($e.skeletons | Where-Object { $_.call -match [regex]::Escape($e.program) }))) { $bad.Add("$k : program $($e.program) is neither the include default nor in a skeleton call") }
      if ($t -notmatch [regex]::Escape("'$($e.parmFile)'")) { $bad.Add("$k : parm file $($e.parmFile) not in the include") }
      if ($t -notmatch "-ParmRecLen $($e.parmRecordLength)\b") { $bad.Add("$k : ParmRecLen $($e.parmRecordLength) not in the include") }
    }
    foreach ($x in $e.xqt) { if ($e.utility -ne 'LOADIS' -and $t -notmatch [regex]::Escape("'$x'")) { $bad.Add("$k : Xqt name '$x' not in the include") } }
    foreach ($f in $e.fixedFiles) { if ($t -notmatch [regex]::Escape($f) -and $e.utility -notin 'FUSBA', 'BABA') { $bad.Add("$k : fixed name $f not in the include") } }
  }
  if ($e.programSource -and (Test-Path "$g\$($e.programSource)")) {
    $srcId = [regex]::Match((Get-Content "$g\$($e.programSource)" -Raw), "PROGRAM-ID\.\s+'?([\w-]+)'?").Groups[1].Value -replace '-', '_'
    if ($srcId -ne $e.program) { $bad.Add("$k : source PROGRAM-ID $srcId vs program $($e.program)") }
  }
}
foreach ($p in $u.shared.PSObject.Properties) { Need "shared.$($p.Name)" $p.Value }
# the Xqt -> program map the hand-offs check (MT-044): the deployed AmtSettings.xml must hold exactly utilities.json's entries
. "$g\GnEnvironment.ps1"
$settings = (Get-GnEnvironment $Environment).SettingsFile
if ($SkipSettings) { } elseif (Test-Path $settings) {
  $have = @(([xml](Get-Content $settings -Raw)).Amt.CloneReports.OrginalReport | ForEach-Object { "$($_.Clone)=$($_.Name)" } | Sort-Object)
  $want = @($u.utilities | ForEach-Object { $n = $_.program; $_.xqt | ForEach-Object { "$_=$n" } } | Sort-Object)
  foreach ($d in Compare-Object $want $have) { $bad.Add("settings CloneReports $($d.InputObject): $(if ($d.SideIndicator -eq '<=') { 'missing from' } else { 'not in utilities.json, found in' }) $settings") }
} else { $bad.Add("no deployed settings file $settings") }
"$($u.utilities.Count) utilities, $((@($u.utilities.skeletons)).Count) skeleton entries checked, problems: $($bad.Count)"
$bad | ForEach-Object { "  $_" }
exit $bad.Count
