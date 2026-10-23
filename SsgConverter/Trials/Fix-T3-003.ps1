<#
.SYNOPSIS
  One-shot: apply the T3-003 converter fix to source, then rebuild + redeploy + verify.
.DESCRIPTION
  MUST be run with VS Code CLOSED. While VS Code is open its C# service write-locks
  SymstreamProcessor.cs (and the PowerShell service locks the goldens), so neither the source
  patch nor the DLL/golden refresh can be written from an external process.

  T3-003: the *CLEAR directive emitted `Clear-Variable $name` (the variable's VALUE as -Name),
  which threw on null. SSG *CLEAR sets the variable to 0 (creating it if needed), so we emit a
  null-safe assignment `$name = 0` instead. This reuses the existing `parameter` node
  ($name as a LocalObject) as the assignment target.

  Idempotent: skips the patch if already applied; re-runnable.
.EXAMPLE
  # close VS Code first, then from an external PowerShell:
  E:\Repos\SsgTrial\SsgConverter\Trials\Fix-T3-003.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$src = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs'

$old = 'powerSkel.AddMethodInvoke("Clear-Variable", parameter);'
$new = 'powerSkel.AddAssignment(parameter, new PsAstExprPrimitive("0", false, PsAstPrimitiveType.Normal)); // T3-003: *CLEAR sets var to 0 (was Clear-Variable $name)'

$text = [System.IO.File]::ReadAllText($src)
if ($text.Contains('// T3-003')) {
  Write-Host 'Source already patched for T3-003.' -ForegroundColor DarkYellow
} elseif ($text.Contains($old)) {
  [System.IO.File]::WriteAllText($src, $text.Replace($old, $new))
  Write-Host 'Patched SymstreamProcessor.cs (*CLEAR -> assignment).' -ForegroundColor Green
} else {
  throw "Could not find the Clear-Variable emit line to patch; check the source manually."
}

# rebuild library + refresh Build\Console&Gui DLL + regenerate goldens + parse-check + harness-run all 5
& (Join-Path $PSScriptRoot 'Reconvert-And-Verify.ps1') -Rebuild -RefreshDll -UpdateGoldens

# tidy any leftover scratch verify folders
Remove-Item 'E:\Repos\SsgTrial\SsgConverter\Examples\_FixVerify2','E:\Repos\SsgTrial\SsgConverter\Examples\_FixVerify3' -Recurse -Force -ErrorAction SilentlyContinue
