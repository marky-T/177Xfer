$ErrorActionPreference = 'Stop'
# Scratch build of the SsgConverter library with two fixes (T3-030 data-line comment handling, T3-031 *DIVIDE).
$repo = 'E:\Repos\SsgTrial'
$work = "$repo\_scratch\ssgfix2"
$srcDir = "$work\src"
Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
robocopy "$repo\SsgConverter\Source\SsgConverter" "$srcDir\SsgConverter" /E /XD bin obj /NFL /NDL /NJH /NJS | Out-Null
robocopy "$repo\SsgConverter\Source\_deps" "$srcDir\_deps" /E /NFL /NDL /NJH /NJS | Out-Null

$file = "$srcDir\SsgConverter\SymstreamProcessor.cs"
$bytes = [IO.File]::ReadAllBytes($file)
$hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
$text = [IO.File]::ReadAllText($file)
function Crlf([String]$s) { $s -replace "`r?`n", "`r`n" }
function ReplaceOnce([String]$text, [String]$old, [String]$new) {
  $old = Crlf $old; $new = Crlf $new
  $first = $text.IndexOf($old)
  if ($first -lt 0) { throw "Not found: $($old.Substring(0, [Math]::Min(60, $old.Length)))" }
  if ($text.IndexOf($old, $first + 1) -ge 0) { throw "More than once: $($old.Substring(0, [Math]::Min(60, $old.Length)))" }
  return $text.Substring(0, $first) + $new + $text.Substring($first + $old.Length)
}

# 1. comments are only recognised on directive images
$text = ReplaceOnce $text @'
        // separate any comment from the line being evaluated
        Int32 commentStart = line.IndexOf(" . ");
'@ @'
        // separate any comment from the line being evaluated (directive and ECL images only, manual 4.3: other images are output text)
        Int32 commentStart = (CarriesComment(line, directivePrefix) || mergedLine.Length > 0) ? line.IndexOf(" . ") : -1;
'@

$text = ReplaceOnce $text @'
      foreach (String line in lines) {
        if (!line.StartsWith(prefixDotSpace) && !line.StartsWith(prefixSpaceDot) && line.Contains(" . ")) {
'@ @'
      foreach (String line in lines) {
        if (!CarriesComment(line, directivePrefix)) {
          // an image that is neither a directive nor an ECL image is output text and stays unchanged (manual 4.3)
          processedLines.Add(line);
        } else if (!line.StartsWith(prefixDotSpace) && !line.StartsWith(prefixSpaceDot) && line.Contains(" . ")) {
'@

# 2. *DIVIDE: quotient to the first variable, remainder to the second (manual 5.2.12)
$start = $text.IndexOf("String[] splitVariables = variables.Split(',');")
$dloc = $text.IndexOf('// DLOC []')
if ($start -lt 0 -or $dloc -lt 0) { throw 'DIVIDE block not found' }
$brk = $text.LastIndexOf('break;', $dloc)
$new = Crlf @'
String[] splitVariables = variables.Split(',');
              for (Int32 v = 0; v < splitVariables.Length; v++) {
                splitVariables[v] = splitVariables[v].Trim();
              }

              // First variable = quotient, second (if any) = remainder; both integers. The numbers go into temporaries first,
              // so a target may also occur in the numbers, and the second target may repeat the first (then only the remainder is kept).
              PsAstExprPrimitive dividend = new PsAstExprPrimitive("SsgDividend", PsAstPrimitiveType.LocalObject);
              PsAstExprPrimitive divisor = new PsAstExprPrimitive("SsgDivisor", PsAstPrimitiveType.LocalObject);
              powerSkel.AddAssignment(dividend, SymstreamExpressionToPowerShellExpression(number1, globalVariables, localVariables));
              powerSkel.AddAssignment(divisor, SymstreamExpressionToPowerShellExpression(number2, globalVariables, localVariables));

              // (dividend - remainder) is an exact multiple of the divisor, so the division needs no floor.
              PsAstExprBinaryOperator remainder = new PsAstExprBinaryOperator(dividend, PSAstOperatorType.Modulo, divisor);
              PsAstExprBinaryOperator quotient = new PsAstExprBinaryOperator(
                new PsAstExprParenthesized(new PsAstExprBinaryOperator(dividend, PSAstOperatorType.Substract, new PsAstExprParenthesized(remainder))),
                PSAstOperatorType.Divide,
                divisor);

              AssignSsgVariable(powerSkel, splitVariables[0], quotient);
              globalVariables.Add(splitVariables[0].ToUpperInvariant());
              if (splitVariables.Length > 1) {
                AssignSsgVariable(powerSkel, splitVariables[1], remainder);
                globalVariables.Add(splitVariables[1].ToUpperInvariant());
              }

              
'@
$text = $text.Substring(0, $start) + $new + $text.Substring($brk)

# helper next to EmitNotImplemented
$text = ReplaceOnce $text @'
    } // EmitNotImplemented
'@ @'
    } // EmitNotImplemented

    /// <summary>
    /// Tells whether the image may end in a " . " comment: a directive or an embedded ECL image (# or @). Output text may not.
    /// </summary>
    private static Boolean CarriesComment (String line, String directivePrefix) {
      return line.StartsWith(directivePrefix) || line.StartsWith("#") || line.StartsWith("@");
    } // CarriesComment

    /// <summary>
    /// Assigns an SSG variable. SSG variables are global, so inside a define the assignment goes to the caller's scope.
    /// </summary>
    private void AssignSsgVariable (PsAstInstrBlock block, String name, PsAstExprBase value) {
      if (m_DefineDepth > 0) {
        block.AddMethodInvoke("Set-Variable", SetVariableInCallerScope(name.ToUpperInvariant(), value));
      } else {
        block.AddAssignment(new PsAstExprPrimitive(name, PsAstPrimitiveType.LocalObject), value);
      }
    } // AssignSsgVariable
'@

[IO.File]::WriteAllText($file, $text, (New-Object Text.UTF8Encoding($hasBom)))
"patched $file  bom=$hasBom  bytes=$((Get-Item $file).Length)"

dotnet build "$srcDir\SsgConverter\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-Object -Last 6
