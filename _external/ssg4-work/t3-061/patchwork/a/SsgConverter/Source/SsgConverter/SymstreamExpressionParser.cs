using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using Ecl.SsgConverter.Expressions;

namespace Ecl.SsgConverter {

  /// <summary>
  /// A Symstream expression parser.
  /// </summary>
  public sealed class SymstreamExpressionParser {

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

    /// <summary>
    /// Parses a Symstream expression.
    /// </summary>
    /// <param name="text">The Symstream expression as source text.</param>
    /// <param name="globalVariables">The current set of global variables if there is one.</param>
    /// <param name="localVariables">The current set of local variables if there is one.</param>
    /// <param name="identifierOverString">If it is hard to determine whether we are dealing with an identifier or a an unquoted string, choose identifier.</param>
    /// <returns>A SymstreamExpression object.</returns>
    public SymstreamExpression Parse (String text, List<String> globalVariables, List<String> localVariables, Boolean identifierOverString) {

      if (String.IsNullOrEmpty(text)) {
        throw new ArgumentException("The expression text may not be null or empty.");
      }

      text = text.Trim();

      // guard: whitespace-only input trims to empty
      if (String.IsNullOrEmpty(text)) {
        throw new ArgumentException("The expression text may not be null or empty.");
      }

      // note: We would start with parenthesized parts but these do not
      //       occur in STA sources so we can skip them for now.

      Regex regex;
      Match match;

      //////////////////////////////////////
      // parse search conditional expression

      // note: This is a special type of Symstream expression that queries SGS data.
      //       It only occurs on its own, not as part of a more complex expression.

      if (IsSearchConditional(text)) {
        SymstreamExpressionSearchConditional expression = new SymstreamExpressionSearchConditional(text);
        expression.ForExpressionObject = Parse(expression.ForExpression, globalVariables, localVariables, identifierOverString);
        return expression;
      }

      //////////////////////////
      // parse binary expression

      // This positive lookahead says "what follows must be an even number of single quotes"   //
      // It effectively makes it not match any occurrences within quotes, assuming the total   //
      // number of quotes will always be even.                                                 //
      const String notInSingleQuotes = "(?=([^']*'[^']*')*[^']*$)";

      const String notPrecededByOpeningBracket = @"(?<!\[[^\[\]]*)";
      const String notFollowedByClosingBracket = @"(?![^\[\]]*\])";

      // XOR
      if (text.IndexOf("XOR", StringComparison.OrdinalIgnoreCase) > -1) {
        regex = new Regex(@"[ \t]+XOR[ \t]+" + notInSingleQuotes, RegexOptions.IgnoreCase);
        match = regex.Match(text);
        if (match.Success && NotInPairsOfSingleQuotes(text, "XOR", StringComparison.OrdinalIgnoreCase)) {
          String left = text.Substring(0, match.Index);
          String right = text.Substring(match.Index + match.Length);
          SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
          SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
          SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.Xor, exprRight);
          return expression;
        }
      }

      // OR
      if (text.IndexOf("OR", StringComparison.OrdinalIgnoreCase) > -1) {
        regex = new Regex(@"[ \t]+OR[ \t]+" + notInSingleQuotes, RegexOptions.IgnoreCase);
        match = regex.Match(text);
        if (match.Success && NotInPairsOfSingleQuotes(text, "OR", StringComparison.OrdinalIgnoreCase)) {
          String left = text.Substring(0, match.Index);
          String right = text.Substring(match.Index + match.Length);
          SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
          SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
          SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.Or, exprRight);
          return expression;
        }
      }

      // AND
      if (text.IndexOf("AND", StringComparison.OrdinalIgnoreCase) > -1) {
        regex = new Regex(@"[ \t]+AND[ \t]+" + notInSingleQuotes, RegexOptions.IgnoreCase);
        match = regex.Match(text);
        if (match.Success && NotInPairsOfSingleQuotes(text, "AND", StringComparison.OrdinalIgnoreCase)) {
          String left = text.Substring(0, match.Index);
          String right = text.Substring(match.Index + match.Length);
          SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
          SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
          SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.And, exprRight);
          return expression;
        }
      }

      // <=
      if (text.Contains("<=")) {
        regex = new Regex(@"[ \t]*<=[ \t]*" + notInSingleQuotes);
        match = regex.Match(text);
        if (match.Success && NotInPairsOfSingleQuotes(text, "<=")) {
          String left = text.Substring(0, match.Index);
          String right = text.Substring(match.Index + match.Length);
          if (!String.IsNullOrEmpty(left) && !String.IsNullOrWhiteSpace(right)) {
            SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
            SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
            SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.LessThanOrEqualTo, exprRight);
            return expression;
          }
        }
      }

      // <>
      if (text.Contains("<>")) {
        regex = new Regex(@"[ \t]*<>[ \t]*" + notInSingleQuotes);
        match = regex.Match(text);
        if (match.Success && NotInPairsOfSingleQuotes(text, "<>")) {
          String left = text.Substring(0, match.Index);
          String right = text.Substring(match.Index + match.Length);
          if (!String.IsNullOrEmpty(left) && !String.IsNullOrWhiteSpace(right)) {
            SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
            SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
            SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.UnequalTo, exprRight);
            return expression;
          }
        }
      }

      // >=
      if (text.Contains(">=")) {
        regex = new Regex(@"[ \t]*>=[ \t]*" + notInSingleQuotes);
        match = regex.Match(text);
        if (match.Success && NotInPairsOfSingleQuotes(text, ">=")) {
          String left = text.Substring(0, match.Index);
          String right = text.Substring(match.Index + match.Length);
          if (!String.IsNullOrEmpty(left) && !String.IsNullOrWhiteSpace(right)) {
            SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
            SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
            SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.GreaterThanOrEqualTo, exprRight);
            return expression;
          }
        }
      }

      // <
      if (text.Contains("<")) {
        regex = new Regex(@"[ \t]*<[ \t]*" + notInSingleQuotes);
        match = regex.Match(text);
        if (match.Success && NotInPairsOfSingleQuotes(text, "<")) {
          String left = text.Substring(0, match.Index);
          String right = text.Substring(match.Index + match.Length);
          if (!String.IsNullOrEmpty(left) && !String.IsNullOrWhiteSpace(right)) {
            SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
            SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
            SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.LessThan, exprRight);
            return expression;
          }
        }
      }

      // =
      if (text.Contains("=")) {
        regex = new Regex(@"[ \t]*=[ \t]*" + notInSingleQuotes);
        match = regex.Match(text);
        if (match.Success && NotInPairsOfSingleQuotes(text, "=")) {
          String left = text.Substring(0, match.Index);
          String right = text.Substring(match.Index + match.Length);
          if (!String.IsNullOrEmpty(left) && !String.IsNullOrWhiteSpace(right)) {
            SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
            SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
            SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.EqualTo, exprRight);
            return expression;
          }
        }
      }

      // >
      if (text.Contains(">")) {
        regex = new Regex(@"[ \t]*>[ \t]*" + notInSingleQuotes);
        match = regex.Match(text);
        if (match.Success && NotInPairsOfSingleQuotes(text, ">")) {
          String left = text.Substring(0, match.Index);
          String right = text.Substring(match.Index + match.Length);
          if (!String.IsNullOrEmpty(left) && !String.IsNullOrWhiteSpace(right)) {
            SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
            SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
            SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.GreaterThan, exprRight);
            return expression;
          }
        }
      }

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
      // some string containing bracketed parts (which may be anywhere in the string)
      // this will root out any sneeky embedded bracketed references
      if (text.Contains("[") && !text.Contains("'") && !(text[0].Equals('[') && text[text.Length - 1].Equals(']'))) {
        // split text in three parts:
        // 1. anything up until the first [
        // 2. a balanced bracheted reference
        // 3. the remaining part (which may contain more bracketed stuff)
        Int32 opening = -1;
        Int32 closing = -1;
        Int32 nestLevel = 0;
        for (Int32 i = 0; i < text.Length; i++) {

          if (text[i].Equals('[')) {
            if (nestLevel == 0) {
              opening = i;
            }
            nestLevel++;
          }

          if (text[i].Equals(']')) {
            nestLevel--;
            if (nestLevel == 0) {
              closing = i;
              break;
            }
          }
        }

        if ((opening == -1) || (closing == -1) || (closing < opening)) {
          throw new SymstreamException(String.Format("Splitting on bracketed part failed for this text: \"{0}\".", text));
        }

        String left = text.Substring(0, opening);
        String bracketed = text.Substring(opening, closing - opening + 1);
        String right = text.Substring(closing + 1);

        if (String.IsNullOrEmpty(left)) {
          left = bracketed;
          // if right starts with a digit it will be treated as a number further
          // down, we do not want that, => quote it if needed
          if (!String.IsNullOrEmpty(right) && Char.IsDigit(right[0])) {
            right = String.Format("'{0}'", right);
          }
        } else {
          right = bracketed + right;
        }

        // note: left may be a unary operator, we do not want to treat those as strings so cancel the whole thing if this is the case
        if (!left.StartsWith("NOT", StringComparison.OrdinalIgnoreCase) && !left.StartsWith("-") && !left.StartsWith("+")) {
          SymstreamExpression exprLeft = Parse(left, globalVariables, localVariables, identifierOverString);
          if (String.IsNullOrEmpty(right)) { return exprLeft; }
          SymstreamExpression exprRight = Parse(right, globalVariables, localVariables, identifierOverString);
          SymstreamExpressionBinary expression = new SymstreamExpressionBinary(exprLeft, BinaryOperator.Plus, exprRight, true);
          return expression;
        }
      }

      //// if we make it here the expression has no binary operator and must be simple (unary or primitive)

      /////////////////////////
      // parse unary expression

      // NOT
      if (text.IndexOf("NOT", StringComparison.OrdinalIgnoreCase) > -1) {
        regex = new Regex(@"^NOT[ \t]+", RegexOptions.IgnoreCase);
        match = regex.Match(text);
        if (match.Success) {
          String operand = text.Substring(match.Index + match.Length);
          SymstreamExpression exprOperand = Parse(operand, globalVariables, localVariables, identifierOverString);
          SymstreamExpressionUnary expression = new SymstreamExpressionUnary(UnaryOperator.Not, exprOperand);
          return expression;
        }
      }

      // -
      if (text.Contains("-")) {
        regex = new Regex(@"^\-[ \t]*");
        match = regex.Match(text);
        if (match.Success) {
          String operand = text.Substring(match.Index + match.Length);
          // guard: operand empty after unary strip (e.g. standalone '-' or '---') — treat as literal
          if (!String.IsNullOrWhiteSpace(operand)) {
            SymstreamExpression exprOperand = Parse(operand, globalVariables, localVariables, identifierOverString);
            SymstreamExpressionUnary expression = new SymstreamExpressionUnary(UnaryOperator.Negative, exprOperand);
            return expression;
          }
        }
      }

      // +
      if (text.Contains("+")) {
        regex = new Regex(@"^\+[ \t]*");
        match = regex.Match(text);
        if (match.Success) {
          String operand = text.Substring(match.Index + match.Length);
          // guard: operand empty after unary strip — treat as literal
          if (!String.IsNullOrWhiteSpace(operand)) {
            SymstreamExpression exprOperand = Parse(operand, globalVariables, localVariables, identifierOverString);
            SymstreamExpressionUnary expression = new SymstreamExpressionUnary(UnaryOperator.Positive, exprOperand);
            return expression;
          }
        }
      }

      //// if we make it here the expression must be primitive (a literal number, a literal string, a variable or a bracketed reference)

      //////////////////
      // parse primitive

      // reserved global variable
      if (char.IsLetter(text[0]) && text.EndsWith("$")) {
        SymstreamExpressionPrimitive expression = new SymstreamExpressionPrimitive(text, PrimitiveType.SystemVariable);
        return expression;
      }

      // literal number
      if (char.IsDigit(text[0])) {
        SymstreamExpressionPrimitive expression = new SymstreamExpressionPrimitive(text, PrimitiveType.LiteralNumber);
        return expression;
      }

      // identifier
      if (char.IsLetter(text[0])) {
        // note: This could be a variable identifier or an unquoted string.
        SymstreamExpressionPrimitive expression = null;
        if ((globalVariables != null) && (globalVariables.Contains(text.ToUpperInvariant()))) {
          expression = new SymstreamExpressionPrimitive(text.ToUpperInvariant(), PrimitiveType.Identifier);
        } else if (localVariables != null && (localVariables.Contains(text.ToUpperInvariant()))) {
          expression = new SymstreamExpressionPrimitive(text.ToUpperInvariant(), PrimitiveType.Identifier);
        } else {
          if (identifierOverString) {
            expression = new SymstreamExpressionPrimitive(text, PrimitiveType.Identifier);
          } else {
            expression = new SymstreamExpressionPrimitive(text, PrimitiveType.LiteralString);
          }
        }

        return expression;
      }

      // literal string
      if (text[0] == '\'') {
        // take off the single quotes
        String unquoted = text.Trim('\'');
        // replace and escaped quotes with just the quotes
        unquoted = unquoted.Replace("''", "'");
        SymstreamExpressionPrimitive expression = new SymstreamExpressionPrimitive(unquoted, PrimitiveType.LiteralString);
        return expression;
      }

      // bracketed reference
      if (text[0] == '[') {

        // note: Some "SGS labels" may not be SGS labels but variable names instead.
        //       If so, it will be a variable and we must prefix it with $.
        //       The variable may be the only bracketed item (e.g. "[variable]", "[*variable]")
        //       or the first item (e.g "[variable,H]"). There may also be a label
        //       (e.g. "[LABEL,variable,H]").

        // Get text between [ and ]
        if (text.EndsWith("]")) {
          String variable = text.Substring(1, text.Length - 2).Trim();
          String[] parts = variable.Split(',');

          if (parts.Length > 1) {
            // Try to find each part in the local or global variables.
            for (Int32 i = 0; i < parts.Length; i++) {
              String varName = parts[i].ToUpperInvariant();
              if (varName.StartsWith("*")) {
                varName = varName.Substring(1);
              }

              if ((localVariables != null) && (localVariables.Contains(varName))) {
                parts[i] = "$" + varName;
              }

              if ((globalVariables != null) && (globalVariables.Contains(varName))) {
                parts[i] = "$" + varName;
              }
            } //~ for
          }

          // Check if it is a reference to a process parameter.
          // These are used to specify a parameter in a *DEFINE (defines a function).
          // E.g: [#,PROCESS_LEVEL$,2,1] specifies the 2nd parameter.
          SymstreamExpressionPrimitive expression = null;
          if ((parts[0] == "#") && (parts[1] == "PROCESS_LEVEL$")) {
            Int32 idx = 0;
            if (Int32.TryParse(parts[2], out idx)) {
              idx = idx - 1;
              expression = new SymstreamExpressionPrimitive("Parameters[" + idx + "]", PrimitiveType.Identifier);
            }
          } else {
            // Reconstruct the bracketed reference (migrator will deal with [#1] and [*ABC])
            text = "[" + String.Join(",", parts) + "]";
            expression = new SymstreamExpressionPrimitive(text, PrimitiveType.BracketedReference);
          }

          return expression;
        } else {
          // text begins with '[' but does not end with a ']', this should never be
          throw new SymstreamException("This is not primitive: " + text);
        }
      }

      // Treat any remaining unrecognized text as an unquoted literal string.
      // This handles characters like *, ., ?, _, and comma-separated continuations
      // that Symstream allows without quoting in expressions and data lines.
      SymstreamExpressionPrimitive literalExpression = new SymstreamExpressionPrimitive(text, PrimitiveType.LiteralString);
      return literalExpression;
    } // Parse

    /// <summary>
    /// Returns a value indicating whether the specified text is a search conditional or not.
    /// </summary>
    /// <param name="text">The text to be tested.</param>
    /// <returns>A value indicating whether the specified text is a search conditional or not.</returns>
    private Boolean IsSearchConditional (String text) {

      // require both the object keyword AND the SEARCH keyword to avoid false positives
      // on COBOL identifiers that happen to start with ROW/COLUMN/KEYWORD after a binary split
      if (text.StartsWith("ROW ", StringComparison.OrdinalIgnoreCase) ||
          text.StartsWith("COLUMN ", StringComparison.OrdinalIgnoreCase) ||
          text.StartsWith("KEYWORD ", StringComparison.OrdinalIgnoreCase)) {
        return text.IndexOf(" SEARCH ", StringComparison.OrdinalIgnoreCase) > -1 ||
               text.IndexOf("\tSEARCH ", StringComparison.OrdinalIgnoreCase) > -1;
      }
      return false;
    } // IsSearchConditional

    /// <summary>
    /// Tells whether s is enclosed in pairs of single quotes or not.
    /// </summary>
    /// <param name="text">The string containing s.</param>
    /// <param name="s">The string for which to tell.</param>
    /// <param name="comparison">The string comparison method to use.</param>
    /// <returns>A value indicating whether s is enclosed in pairs of single quotes or not.</returns>
    private Boolean NotInPairsOfSingleQuotes (String text, String s, StringComparison comparison = StringComparison.Ordinal) {

      Boolean inPairs = false;
      for (Int32 i = 0; i < text.Length; i++) {
        if (text.Substring(i, s.Length).Equals(s, comparison)) {
          return !inPairs;
        }

        if ((text[i] == '\'') && (text.Length > (i + 1) && (text[i + 1] == '\''))) {
          inPairs = !inPairs;
          i++;
          continue;
        }
      }

      throw new SymstreamException("String text does not contain an occurrence of s.");
    } // NotInPairsOfSingleQuotes
  } // Class SymstreamExpressionParser
} // namespace Ecl.SsgConverter
