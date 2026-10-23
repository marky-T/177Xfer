<#
.SYNOPSIS
  T3-009 fix: strip a leading '+' from *INCREMENT loop variable names before use.
.DESCRIPTION
  Some SSG sources write "*INCREMENT +I FROM 1 BY 1 TO [...]" with a leading '+' on the
  variable name token itself (not an operator) - e.g. CONDIS2_ASCII.TXT. Every other reference
  to the same loop variable in the source (bracketed [PG,I,1,1] etc.) omits the '+'. The
  converter previously used the raw captured token (including the '+') to build both the
  For-loop declaration and its condition/increment; the vendored AST writer sanitises the
  condition/increment reference (leading '+' -> '_') but not the plain declare, producing two
  different, mismatched PowerShell variable names ($+I invalid syntax vs $_I unassigned).
  Fix: strip the leading '+' right after the token is captured, so every use is consistent.
  Idempotent: skips if already applied; must be run with VS Code CLOSED (write-locked .cs file).
.EXAMPLE
  E:\Repos\SsgTrial\SsgConverter\Trials\Fix-T3-009.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$src = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs'

$old = @'
              regex = new Regex(@"(?<=INCREMENT\s+(VARNAME(\s*=\s*|\s+))?)\S+");
              match = regex.Match(s);
              if (match.Success) {
                incrementVariable = match.Value;
                m_InnerMostLoopVariable.Push(incrementVariable);
              } else {
                throw new SymstreamException("No INCREMENT variable found after *INCREMENT.");
              }
'@

$new = @'
              regex = new Regex(@"(?<=INCREMENT\s+(VARNAME(\s*=\s*|\s+))?)\S+");
              match = regex.Match(s);
              if (match.Success) {
                incrementVariable = match.Value;
                if (incrementVariable.StartsWith("+")) {
                  // T3-009: some SSG sources write "*INCREMENT +I ..." with a leading '+' on the
                  // variable name itself; every other reference to the same loop variable omits
                  // it, so strip it here too (otherwise the declare and the condition/increment
                  // end up as two different, mismatched names).
                  incrementVariable = incrementVariable.Substring(1);
                }
                m_InnerMostLoopVariable.Push(incrementVariable);
              } else {
                throw new SymstreamException("No INCREMENT variable found after *INCREMENT.");
              }
'@

$text = [System.IO.File]::ReadAllText($src)
if ($text.Contains('// T3-009')) {
  Write-Host 'Source already patched for T3-009.' -ForegroundColor DarkYellow
} elseif ($text.Contains($old)) {
  [System.IO.File]::WriteAllText($src, $text.Replace($old, $new))
  Write-Host 'Patched SymstreamProcessor.cs (*INCREMENT +I -> strip leading +).' -ForegroundColor Green
} else {
  throw "Could not find the INCREMENT variable capture block to patch; check the source manually."
}
