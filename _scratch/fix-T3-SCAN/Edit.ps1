# Converter fix T3-SCAN (SCAN/TAPELD/CONDIS2 group), applied to the scratch source copy by New-ConverterFix.ps1:
#   T3-035  a directive continued with ';' followed by blanks was not merged (EndsWith(";") on the untrimmed line).
#   T3-043  '+'/'-' were split at the FIRST operator with '-' before '+', i.e. right-associative: a-b+c -> a-(b+c).
#           SSG evaluates left to right: split at the LAST binary +/- outside brackets and quotes.
#   T3-036  a variable used in a *DEFINE body before its first *SET/*CLEAR was converted as a string (TAPELD CADR):
#           pre-register every *SET/*CLEAR target before converting.
param([Parameter(Mandatory)][String]$SrcDir)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path 'E:\Repos\SsgTrial\SsgConverter\Trials\ConverterFix' 'ConverterFixLib.psm1') -Force
$proc = Join-Path $SrcDir 'SsgConverter\SymstreamProcessor.cs'
$pars = Join-Path $SrcDir 'SsgConverter\SymstreamExpressionParser.cs'

# T3-035
Edit-SourceFile -Path $proc -Old @'
        if (lineWithoutComment.StartsWith(directivePrefix) && lineWithoutComment.EndsWith(";")) {
'@ -New @'
        if ((lineWithoutComment.StartsWith(directivePrefix) || mergedLine.Length > 0) && lineWithoutComment.TrimEnd().EndsWith(";")) {
          // blanks after the continuation ';' are allowed, and a continuation line may continue again (T3-035)
          lineWithoutComment = lineWithoutComment.TrimEnd();
'@

# T3-036
Edit-SourceFile -Path $proc -Old @'
      lines = CondenseDirectives(lines, m_DirectivePrefix);

      // convert directives
'@ -New @'
      lines = CondenseDirectives(lines, m_DirectivePrefix);

      // A *DEFINE body may use a variable that is first *SET/*CLEARed further down (T3-036): register all targets first.
      Regex setTarget = new Regex("^" + Regex.Escape(m_DirectivePrefix) + @"(SET|CLEAR)\s+([^\s=]+)", RegexOptions.IgnoreCase);
      foreach (String line in lines) {
        Match m = setTarget.Match(line);
        if (m.Success && IsVariableName(m.Groups[2].Value) && !globalVariables.Contains(m.Groups[2].Value.ToUpperInvariant())) {
          globalVariables.Add(m.Groups[2].Value.ToUpperInvariant());
        }
      }

      // convert directives
'@

# T3-043: replace the two additive blocks ('-' then '+') with one left-to-right split.
$text = Get-Content -Raw $pars
$start = $text.IndexOf('      // -' + "`r`n" + '      if (text.Contains("-")) {')
$end = $text.IndexOf('      // some string containing bracketed parts')
if ($start -lt 0 -or $end -lt $start) { throw 'T3-043: additive blocks not found' }
$new = @'
      // + and - (one precedence level, evaluated left to right as in SSG: split at the LAST binary operator, T3-043)
      if (text.Contains("-") || text.Contains("+")) {
        Int32 split = FindLastAdditiveOperator(text);
        if (split > -1) {
          String left = text.Substring(0, split);
          String right = text.Substring(split + 1);
          if (!String.IsNullOrWhiteSpace(left) && !String.IsNullOrWhiteSpace(right)) {
            SymstreamExpression exprLeft = Parse(left.Trim(), globalVariables, localVariables, identifierOverString);
            SymstreamExpression exprRight = Parse(right.Trim(), globalVariables, localVariables, identifierOverString);
            return new SymstreamExpressionBinary(exprLeft, text[split] == '-' ? BinaryOperator.Minus : BinaryOperator.Plus, exprRight);
          }
        }
      }

'@
$text = $text.Substring(0, $start) + $new.Replace("`n", "`r`n").Replace("`r`r`n", "`r`n") + $text.Substring($end)
# helper: last '+'/'-' outside brackets and single quotes that has an operand on its left (not unary)
$helper = @'

    /// <summary>
    /// Position of the last binary '+' or '-' outside brackets and single quotes, or -1 (T3-043).
    /// A sign is binary when the nearest non-blank character before it is not an operator or an opening bracket.
    /// </summary>
    private static Int32 FindLastAdditiveOperator (String text) {
      Int32 depth = 0;
      Boolean quoted = false;
      Int32 found = -1;
      Char previous = '\0';
      for (Int32 i = 0; i < text.Length; i++) {
        Char c = text[i];
        if (c == '\'') { quoted = !quoted; }
        else if (!quoted && c == '[') { depth++; }
        else if (!quoted && c == ']') { depth--; }
        else if (!quoted && depth == 0 && (c == '+' || c == '-') && previous != '\0' && "+-*/=<>(,".IndexOf(previous) < 0) { found = i; }
        if (!Char.IsWhiteSpace(c)) { previous = c; }
      }
      return found;
    } // FindLastAdditiveOperator
'@
$anchor = '    public SymstreamExpression Parse (String text'
$i = $text.IndexOf($anchor)
$doc = $text.LastIndexOf('    /// <summary>', $i)
if ($i -lt 0 -or $doc -lt 0) { throw 'T3-043: Parse() not found' }
$text = $text.Insert($doc, $helper.TrimStart("`r", "`n").Replace("`n", "`r`n").Replace("`r`r`n", "`r`n") + "`r`n`r`n")
[IO.File]::WriteAllText($pars, $text)
'T3-035, T3-036, T3-043 edits applied'
