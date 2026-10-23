<#
.SYNOPSIS
  Repair the T3-003 *CLEAR handler in SymstreamProcessor.cs (garbled by an editor-buffer flush),
  then rebuild + redeploy + verify. MUST run with VS Code CLOSED (it write-locks the .cs / DLLs / goldens).
.DESCRIPTION
  Anchor-based repair: replaces everything from the CLEAR handler's `String variableName = ...Substring(7)...`
  line through its `globalVariables.Add(variableName);` line with one clean, null-safe assignment block
  (`$name = 0`). Idempotent + deterministic regardless of the current garble.
.EXAMPLE
  # close VS Code first:
  E:\Repos\SsgTrial\SsgConverter\Trials\Deploy-T3-003.ps1
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$src = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs'

$L = [System.Collections.Generic.List[string]](Get-Content -LiteralPath $src)

$start = -1
for ($i = 0; $i -lt $L.Count; $i++) {
  if ($L[$i] -match 'String variableName = lines\[i\]\.Substring\(7\)') { $start = $i; break }
}
if ($start -lt 0) { throw 'CLEAR handler variableName line not found.' }

$end = -1
for ($i = $start; $i -lt $L.Count; $i++) {
  if ($L[$i] -match 'globalVariables\.Add\(variableName\);') { $end = $i; break }
}
if ($end -lt 0) { throw 'globalVariables.Add(variableName) line not found after start.' }

$clean = @(
  '              String variableName = lines[i].Substring(7).Trim().ToUpperInvariant();',
  '              // SSG *CLEAR sets the (local or global) variable to 0; emit a null-safe assignment',
  '              // instead of Clear-Variable of the value, which threw on null. Issue T3-003.',
  '              powerSkel.AddAssignment(',
  '                new PsAstExprPrimitive(variableName, PsAstPrimitiveType.LocalObject),',
  '                new PsAstExprPrimitive("0", false, PsAstPrimitiveType.Normal));',
  '              globalVariables.Add(variableName);'
)

$new = @()
if ($start -gt 0) { $new += $L[0..($start - 1)] }
$new += $clean
if ($end -lt $L.Count - 1) { $new += $L[($end + 1)..($L.Count - 1)] }
Set-Content -LiteralPath $src -Value $new -Encoding UTF8
Write-Host "Repaired CLEAR handler (lines $($start+1)..$($end+1) -> clean assignment block)." -ForegroundColor Green

# rebuild library + refresh Build\Console&Gui DLL + regenerate goldens + parse-check + harness-run all 5
& (Join-Path $PSScriptRoot 'Reconvert-And-Verify.ps1') -Rebuild -RefreshDll -UpdateGoldens

Remove-Item 'E:\Repos\SsgTrial\SsgConverter\Examples\_FixVerify2','E:\Repos\SsgTrial\SsgConverter\Examples\_FixVerify3' -Recurse -Force -ErrorAction SilentlyContinue
