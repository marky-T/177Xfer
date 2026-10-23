$ErrorActionPreference = 'Stop'
# Scratch build of the SsgConverter library with two fixes: T3-018 (NOT before a relation) and T3-033 (variable names in SGS references).
$repo = 'E:\Repos\SsgTrial'
$work = "$repo\_scratch\ssgfix3"
$srcDir = "$work\src"
Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
robocopy "$repo\SsgConverter\Source\SsgConverter" "$srcDir\SsgConverter" /E /XD bin obj /NFL /NDL /NJH /NJS | Out-Null
robocopy "$repo\SsgConverter\Source\_deps" "$srcDir\_deps" /E /NFL /NDL /NJH /NJS | Out-Null

function Crlf([String]$s) { $s -replace "`r?`n", "`r`n" }
function ReplaceOnce([String]$text, [String]$old, [String]$new) {
  $old = Crlf $old; $new = Crlf $new
  $first = $text.IndexOf($old)
  if ($first -lt 0) { throw "Not found: $($old.Substring(0, [Math]::Min(70, $old.Length)))" }
  if ($text.IndexOf($old, $first + 1) -ge 0) { throw "More than once: $($old.Substring(0, [Math]::Min(70, $old.Length)))" }
  return $text.Substring(0, $first) + $new + $text.Substring($first + $old.Length)
}
function Patch([String]$file, [ScriptBlock]$edit) {
  $bytes = [IO.File]::ReadAllBytes($file)
  $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
  $text = & $edit ([IO.File]::ReadAllText($file))
  [IO.File]::WriteAllText($file, $text, (New-Object Text.UTF8Encoding($bom)))
  "patched $file ($((Get-Item $file).Length) bytes)"
}

Patch "$srcDir\SsgConverter\SymstreamExpressionMigrator.cs" {
  param($t)
  # T3-018: NOT is a Boolean operator on the whole relation (manual 5.2, Tables 5-2/5-3): NOT [A] > 0 means NOT ([A] > 0)
  $t = ReplaceOnce $t @'
          PsAstExprMethod compareMethod = new PsAstExprMethod("CompareTypeSafe", Migrate(left), new PsAstExprPrimitive(binaryOperator.ToString(), true), Migrate(right));
          powerShellExpressionBlock.AddExpression(new PsAstExprParenthesized(compareMethod));
'@ @'
          // NOT applies to the whole relation (manual Table 5-3): NOT [A] > 0 means NOT ([A] > 0)
          SymstreamExpressionUnary notLeft = left as SymstreamExpressionUnary;
          Boolean negate = notLeft != null && notLeft.UnaryOperator == UnaryOperator.Not;
          if (negate) {
            left = notLeft.Operand;
          }

          PsAstExprMethod compareMethod = new PsAstExprMethod("CompareTypeSafe", Migrate(left), new PsAstExprPrimitive(binaryOperator.ToString(), true), Migrate(right));
          if (negate) {
            PsAstExprBlock comparison = new PsAstExprBlock();
            comparison.SkipSurroundingBlock = true;
            comparison.AddExpression(new PsAstExprParenthesized(compareMethod));
            powerShellExpressionBlock.AddExpression(new PsAstExprParenthesized(new PsAstExprUnary(PSAstOperatorType.Not, comparison)));
          } else {
            powerShellExpressionBlock.AddExpression(new PsAstExprParenthesized(compareMethod));
          }
'@
  # a bare -not as a command argument is read as a parameter name, so always parenthesize it
  $t = ReplaceOnce $t @'
            powerShellExpressionBlock.AddExpression(new PsAstExprUnary(PSAstOperatorType.Not, Migrate(operand)));
'@ @'
            powerShellExpressionBlock.AddExpression(new PsAstExprParenthesized(new PsAstExprUnary(PSAstOperatorType.Not, Migrate(operand))));
'@
  # T3-033: the trailing , or ] must not be consumed, else the next of two adjacent names ([KEYS,RQS,REQ,2]) is missed
  $t = ReplaceOnce $t @'
      Regex regex = new Regex(@",[A-Za-z][A-Za-z0-9]*(,|\])");
'@ @'
      Regex regex = new Regex(@",[A-Za-z][A-Za-z0-9]*(?=,|\])");
'@
  $t
}

dotnet build "$srcDir\SsgConverter\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-Object -Last 6
