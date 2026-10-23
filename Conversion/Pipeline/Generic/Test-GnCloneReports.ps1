# MT-044: Invoke-GnHandoff must stop (Abort) when the Xqt name has no CloneReports entry, or maps to another program; and
# pass when the entry matches. AMT's job functions are stubbed; StrictMode 2 as in a job.
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\GnHandoff.ps1"
$global:log = [Collections.Generic.List[String]]::new()
function global:Abort { param($m) throw "ABORT: $m" }
function global:Msg { param($o, $t) $global:log.Add("Msg $t") }
function global:Free { param($o, $n) }
function global:Asg { param($o, $n) }
function global:Use { param($u, $n) }
function global:Check-ClearTaskObject { param($TaskObj) }
function global:Get-TaskObject { param($x) [pscustomobject]@{} | Add-Member -MemberType ScriptMethod -Name SetTVCustom -Value { param($k, $v) } -PassThru }
function global:Add-GnUseAlias { param($f, $c) }
$tmp = Join-Path $env:TEMP 'gn-clone-test'; New-Item -ItemType Directory -Force "$tmp\Q" | Out-Null
$global:AmtPath = [pscustomobject]@{ ExtractPath = $tmp }; $global:DefaultQual = 'Q'
$run = { Set-StrictMode -Version 2; Invoke-GnHandoff -Program 'ASSURFED_UTILIT_X_GN' -XqtName 'X' -ParmFile 'XPARM' -ParmRecLen 10 -ParmLines @('A') -Files @(@{ Fixed = 'F'; Call = 'F' }) }
$cases = [ordered]@{
  'no entries (null)'      = $null
  'other Xqt only'         = @([pscustomobject]@{ Name = 'ASSURFED_UTILIT_X_GN'; Clone = 'Y' })
  'wrong program'          = @([pscustomobject]@{ Name = 'ASSURFED_UTILIT_OTHER_GN'; Clone = 'X' })
  'matching entry'         = @([pscustomobject]@{ Name = 'ASSURFED_UTILIT_X_GN'; Clone = 'X' })
  'XmlElement entry (as AMT loads it)' = @(([xml]'<CloneReports><OrginalReport Name="ASSURFED_UTILIT_X_GN" Clone="X"/></CloneReports>').CloneReports.OrginalReport)
}
foreach ($k in $cases.Keys) {
  $global:CloneReports = $cases[$k]
  $r = try { & $run; 'passed' } catch { ($_.Exception.Message -replace '\s+', ' ') }
  '{0,-36} {1}' -f $k, $r.Substring(0, [Math]::Min(150, $r.Length))
}
