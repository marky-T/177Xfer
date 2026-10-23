<#
.SYNOPSIS
  SSG-4 (MT-043): deploy a generic-program hand-off into one converted skeleton under Basepaths\Scripts\SSG4.
.DESCRIPTION
  Copies GnHandoff.ps1 and the skeleton's parameter writer (-ParmScript) as .inc files (the CC job scan does not
  register .inc), and writes the converted skeleton with the hand-off inserted right after its param() line, followed by
  `return`: the generic program does not use the skeleton's expansion. Returns one status object.
.EXAMPLE
  Deploy-GnSkeleton.ps1 -Skeleton UTILIT_FUSBA2_ASCII -ParmScript .\FUSBA\gen\FusbaParm.ps1 -Call 'Invoke-FusbaHandoff -Variant FUSBA2'
#>
param(
  [Parameter(Mandatory)][String]$Skeleton,
  [Parameter(Mandatory)][String]$ParmScript,
  [Parameter(Mandatory)][String]$Call,
  [String]$Environment = 'CC-Trial',
  [String]$SkeletonSource = "$PSScriptRoot\skeletons",
  [String]$Target
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\GnEnvironment.ps1"
if (-not $Target) { $Target = Join-Path (Get-GnEnvironment $Environment).ScriptRoot 'ASSURFED_UTILIT' }
New-Item -ItemType Directory -Force $Target | Out-Null
$inc = [IO.Path]::GetFileNameWithoutExtension($ParmScript) + '.inc'
Copy-Item (Join-Path $PSScriptRoot 'GnHandoff.ps1') (Join-Path $Target 'GnHandoff.inc') -Force
Copy-Item $ParmScript (Join-Path $Target $inc) -Force
$skel = Get-Content (Join-Path $SkeletonSource "$Skeleton.ps1") -Raw
$handoff = "# SSG-4 hand-off (MT-043): the generic program replaces this skeleton's expansion`r`n" +
  ". ([ScriptBlock]::Create((Get-Content -Raw (Join-Path `$PSScriptRoot 'GnHandoff.inc'))))`r`n" +
  ". ([ScriptBlock]::Create((Get-Content -Raw (Join-Path `$PSScriptRoot '$inc'))))`r`n" +
  "$Call`r`nreturn`r`n"
$skel = [regex]::Replace($skel, '(?m)^(param\(\[string\[\]\]\$Parameters\)\r?\n)', { param($m) $m.Value + $handoff }, 'IgnoreCase')
if ($skel -notmatch 'SSG-4 hand-off') { throw "$Skeleton : param() line not found; hand-off not inserted" }
$out = Join-Path $Target "$Skeleton.ps1"
[IO.File]::WriteAllText($out, $skel)
$errs = @()
foreach ($f in $out, (Join-Path $Target 'GnHandoff.inc'), (Join-Path $Target $inc)) {
  $e = $null; [void][System.Management.Automation.Language.Parser]::ParseInput((Get-Content $f -Raw), [ref]$null, [ref]$e); $errs += $e
}
if ($errs.Count) { throw "$Skeleton : $($errs.Count) parse errors after deploy: $($errs[0].Message)" }
[pscustomobject]@{ Skeleton = $Skeleton; Include = $inc; Call = $Call; ParseErrors = 0 }
