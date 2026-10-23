using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using Avanade.LtCoE.MigSupport;
using Ecl.SsgConverter.Expressions;
using PowerShell.Generator;

namespace Ecl.SsgConverter {

  /// <summary>
  /// A Symstream expression migrator.
  /// </summary>
  public sealed class SymstreamExpressionMigrator {

    private readonly IMigLogger m_LogObject;

    public SymstreamExpressionMigrator (IMigLogger logObject) {
      m_LogObject = logObject;
    }

    /// <summary>
    /// Migrates a Symstream expression.
    /// </summary>
    /// <param name="expression">The Symstream expression to migrate to PowerShell.</param>
    /// <returns>A SymstreamExpression object.</returns>
    public PsAstExprBlock Migrate (SymstreamExpression expression) {

      if (expression == null) {
        throw new ArgumentNullException(nameof(expression));
      }

      PsAstExprBlock powerShellExpressionBlock = new PsAstExprBlock();

      // do not wrap in curly braces
      powerShellExpressionBlock.SkipSurroundingBlock = true;

      // migrate search conditional expression
      SymstreamExpressionSearchConditional sce = expression as SymstreamExpressionSearchConditional;
      if (sce != null) {

        PsAstExprMethod method = new PsAstExprMethod("SearchConditional",
          new PsAstExprPrimitive(sce.SearchObject.ToString(), true),
          new PsAstExprPrimitive(sce.SearchDirection.ToString(), true),
          new PsAstExprPrimitive(sce.FromClause.ToString(), true),
          new PsAstExprParenthesized(Migrate(sce.ForExpressionObject))
        );

        // note: We may have comment text in sce.Comments but we have no place to put it so it will be lost.

        powerShellExpressionBlock.AddExpression(method);
        return powerShellExpressionBlock;
      }

      // migrate binary expression
      SymstreamExpressionBinary be = expression as SymstreamExpressionBinary;
      if (be != null) {
        SymstreamExpression left = be.Left;
        PSAstOperatorType binaryOperator = SymstreamBinaryOperatorToPowerShellBinaryOperator(be.BinaryOperator);
        SymstreamExpression right = be.Right;
<<<<<<< ours

        // note: "VALUE OF [x]" asks for the numeric value of x. The parser sees the words as a text operand joined to the
        //       reference with +, which made the comparison string-vs-number and never true. Keep only the reference.
        SymstreamExpressionPrimitive valueOfWord = left as SymstreamExpressionPrimitive;
        if (binaryOperator == PSAstOperatorType.Add && valueOfWord != null && valueOfWord.PrimitiveType == PrimitiveType.LiteralString
            && String.Equals(valueOfWord.Image.Trim(), "VALUE OF", StringComparison.OrdinalIgnoreCase)) {
          return Migrate(right);
        }
=======
>>>>>>> rd
        if (IsComparisonOperator(binaryOperator)) {
          // note: We have to do the comparison at runtime because left may be "12" (a string) and right may be 3 (an integer), in which case
          //       (left -gt right) would yield false because PowerShell will is convert 3 to a string to enable a comparison. If both operands
          //       can be interpreted a numbers they should be compared as such. We can only know this for sure at runtime.

          PsAstExprMethod compareMethod = new PsAstExprMethod("CompareTypeSafe", Migrate(left), new PsAstExprPrimitive(binaryOperator.ToString(), true), Migrate(right));
          powerShellExpressionBlock.AddExpression(new PsAstExprParenthesized(compareMethod));
        } else {
<<<<<<< ours
          PsAstExprBinaryOperator bo = new PsAstExprBinaryOperator(MigrateOperand(left, right, binaryOperator), binaryOperator, MigrateOperand(right, left, binaryOperator));
=======
          PsAstExprBinaryOperator bo = new PsAstExprBinaryOperator(Migrate(left), binaryOperator, Migrate(right));
>>>>>>> rd
          powerShellExpressionBlock.AddExpression(new PsAstExprParenthesized(bo));
        }
        return powerShellExpressionBlock;
      }

      // migrate unary expression
      SymstreamExpressionUnary ue = expression as SymstreamExpressionUnary;
      if (ue != null) {
        SymstreamExpression operand = ue.Operand;

        // note: Unary operators do not map that nicely to PSAstOperatorType, the latter does not support sign operators.
        switch (ue.UnaryOperator) {
          case UnaryOperator.Negative:
          case UnaryOperator.Positive:
<<<<<<< ours
            SymstreamExpressionPrimitive primitiveOperand = operand as SymstreamExpressionPrimitive;
            if (primitiveOperand != null) {
              String sign = String.Empty;
              if (ue.UnaryOperator == UnaryOperator.Negative) {
                sign = "-";
              }
              if (primitiveOperand.PrimitiveType == PrimitiveType.Identifier) {
                powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(sign + primitiveOperand.Image, PsAstPrimitiveType.LocalObject));
              } else {
                powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(sign + primitiveOperand.Image));
              }
            } else {
              // non-primitive operand: emit (0 - expr) or (0 + expr)
              PsAstExprBlock migratedOperand = Migrate(operand);
              PSAstOperatorType op = ue.UnaryOperator == UnaryOperator.Negative ? PSAstOperatorType.Substract : PSAstOperatorType.Add;
              powerShellExpressionBlock.AddExpression(new PsAstExprParenthesized(new PsAstExprBinaryOperator(new PsAstExprPrimitive("0"), op, migratedOperand)));
            }
=======
            // operand shoud be a primitive
            SymstreamExpressionPrimitive primitiveOperand = operand as SymstreamExpressionPrimitive;
            if (primitiveOperand == null) {
              throw new SymstreamException("SymstreamExpressionPrimitive expected.");
            }

            String sign = String.Empty;
            if (ue.UnaryOperator == UnaryOperator.Negative) {
              sign = "-";
            }

            if (primitiveOperand.PrimitiveType == PrimitiveType.Identifier) {
              powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(sign + primitiveOperand.Image, PsAstPrimitiveType.LocalObject));
            } else {
              powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(sign + primitiveOperand.Image));
            }

>>>>>>> rd
            break;
          case UnaryOperator.Not:
            powerShellExpressionBlock.AddExpression(new PsAstExprUnary(PSAstOperatorType.Not, Migrate(operand)));
            break;
          default:
            throw new SymstreamException(String.Format("Unknown operator type encountered: {0}", ue.UnaryOperator));
        }

        return powerShellExpressionBlock;
      }

      // migrate primitive expression
      SymstreamExpressionPrimitive pe = expression as SymstreamExpressionPrimitive;
      if (pe != null) {
        switch (pe.PrimitiveType) {

          case PrimitiveType.SystemVariable: {
              powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive("Rgv_" + pe.Image.TrimEnd('$'), PsAstPrimitiveType.LocalObject));
              break;
            }

          case PrimitiveType.LiteralNumber: {
              powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(pe.Image, false, PsAstPrimitiveType.Normal));
              break;
            }

          case PrimitiveType.LiteralString: {
              // note: This could still have nested bracketed references in it, => create the desired PowerShell by wrapping them in function calls.
              String expanded = WrapSgsReferencesInFunctionCalls(pe.Image);
              powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(expanded, false));

              // this would do for strings without bracketed references:
              // powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(pe.Image, true, PsAstPrimitiveType.Normal));
              break;
            }

          case PrimitiveType.Identifier: {
              powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(pe.Image, PsAstPrimitiveType.LocalObject));
              break;
            }

          case PrimitiveType.BracketedReference: {
              // note: This could still have nested bracketed references in it, => create the desired PowerShell by wrapping them in function calls.
              String expanded = WrapSgsReferencesInFunctionCalls(pe.Image);

              // note: Sometimes we may end up with some redundant parentheses but other times
              //       they will be necessary to make a valid complex expression. Please do not
              //       remove them!

              powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(expanded, false));
              break;
            }
        }

        return powerShellExpressionBlock;
      }

      throw new SymstreamException("Apparently we missed something.");
    } // Migrate

    /// <summary>
<<<<<<< ours
    /// Migrates one operand of a binary operator. A define parameter ([#1]) arrives as a string in PowerShell, and
    /// "6" + 1 is "61" there, so an arithmetic operand that is a define parameter is converted to a number first.
    /// </summary>
    private PsAstExprBase MigrateOperand (SymstreamExpression operand, SymstreamExpression otherOperand, PSAstOperatorType binaryOperator) {
      Boolean arithmetic = binaryOperator == PSAstOperatorType.Add || binaryOperator == PSAstOperatorType.Substract
        || binaryOperator == PSAstOperatorType.Multiply || binaryOperator == PSAstOperatorType.Divide || binaryOperator == PSAstOperatorType.Modulo;
      SymstreamExpressionPrimitive primitive = operand as SymstreamExpressionPrimitive;
      SymstreamExpressionPrimitive otherPrimitive = otherOperand as SymstreamExpressionPrimitive;
      Boolean otherIsText = otherPrimitive != null && otherPrimitive.PrimitiveType == PrimitiveType.LiteralString;
      if (arithmetic && !otherIsText && primitive != null && primitive.PrimitiveType == PrimitiveType.BracketedReference) {
        Match parameterReference = Regex.Match(primitive.Image, @"^\[#(\d+)\]$");
        if (parameterReference.Success && Int32.Parse(parameterReference.Groups[1].Value) > 0) {
          return new PsAstExprPrimitive("[Int64]$Parameters[" + (Int32.Parse(parameterReference.Groups[1].Value) - 1) + "]", false);
        }
      }

      return Migrate(operand);
    } // MigrateOperand
    /// <summary>
=======
>>>>>>> rd
    /// Returns the provided string with any bracketed references replaced
    /// by those references wrapped in GetSgsValue function calls. String
    /// expressions are concatenated as needed.
    /// </summary>
    /// <param name="s">A string that may contain bracketed references.</param>
    /// <param name="parenthesize">A value indicating whether to parenthesize the result or not.</param>
    /// <param name="escapeDollarInNonBracketedParts">A value indicating whether to escape $ signs in non-bracketed parts with ` or not.</param>
    /// <returns>
    /// A PowerShell expression that yields the result of the original Symstream expression containing bracketed references.
    /// </returns>
    public String WrapSgsReferencesInFunctionCalls (String s, Boolean parenthesize = false, Boolean escapeDollarInNonBracketedParts = true) {

      List<String> parts = SplitBracketedReferencesAndLiteralParts(s);
      String expanded = String.Empty;

      // concatenate
      foreach (String part in parts) {
        if (part[0] == '[') {
          expanded += ExpandSinglePossiblyNestedBracketedReference(part) + " + ";
        } else {
          String p;
          if (escapeDollarInNonBracketedParts) {
            p = EscapeDollar(part);
          } else {
            p = part;
          }

          expanded += String.Format("\"{0}\" + ", p);
        }
      } // namespace Ecl.SsgConverter

      // strip last +
      expanded = expanded.TrimEnd().TrimEnd('+').TrimEnd();

      // if we have nothing, create a pair of double quotes (we want a proper PowerShell expression)
      if (String.IsNullOrEmpty(expanded)) {
        expanded = "\"\"";
      }

      // fix up any # and * parts
      expanded = ReplaceOctothorpeAndAsteriskParts(expanded);

      // parenthesize (or not)
      if (parenthesize) {
        expanded = "(" + expanded + ")";
      }

      return expanded;
    } // WrapSgsReferencesInFunctionCalls

    /// <summary>
    /// Replace parts that are really function parameter references and veriable references
    /// with the appropriate code.
    /// </summary>
    /// <param name="s">The string to fix up.</param>
    /// <returns>A fixed up string that has any occurrences of octothorpe and asterisk parts replaced with the appropriate code.</returns>
    private static String ReplaceOctothorpeAndAsteriskParts (String s) {

      Regex regex;
      Match match;
      Int32 remainingPartIndex;
      String result;

      // look for (GetSgsValue ("#...")) where ... contains one or more digits
      result = String.Empty;
      remainingPartIndex = 0;
      regex = new Regex(@"\(GetSgsValue \(" + "\"" + "#[0-9]+" + "\"" + @"\)\)");
      match = regex.Match(s);
      while (match.Success) {
        String partBeforeMatch = s.Substring(remainingPartIndex, match.Index - remainingPartIndex);
        String strippedMatch = match.Value.Substring(16).TrimEnd(')').TrimEnd('"');
        Int32 number = Int32.Parse(strippedMatch);
        String replacement = String.Format("$Parameters[{0}]", number - 1);
        result += partBeforeMatch + replacement;
        // note: [#1] does not mean GetSgsValue, it only tells to use the parameter value rather than the parameter identifier image
        //       See section 3.2.2.1 in "Symbolic Stream Generator (SSG) - Programming Reference Manual"

        remainingPartIndex = match.Index + match.Length;
        match = match.NextMatch();
      }

      result += s.Substring(remainingPartIndex);

      s = result;

      // look for (GetSgsValue ("*...")) where ... contains one or more letters
      result = String.Empty;
      remainingPartIndex = 0;
      regex = new Regex(@"\(GetSgsValue \(" + "\"" + @"\*[A-Za-z][A-Za-z0-9]*" + "\"" + @"\)\)");
      match = regex.Match(s);
      while (match.Success) {
        String partBeforeMatch = s.Substring(remainingPartIndex, match.Index - remainingPartIndex);
        String strippedMatch = match.Value.Substring(16).TrimEnd(')').TrimEnd('"');

        // map an occurrence of RUNID to $global:JobName
        if (strippedMatch.Equals("RUNID", StringComparison.OrdinalIgnoreCase)) {
          strippedMatch = "global:JobName";
        }

        String replacement = String.Format("${0}", strippedMatch);
        result += partBeforeMatch + replacement;
        // note: [*A] does not mean GetSgsValue, it only tells to use the variable value rather than the variable identifier image
        //       See section 3.2.2.1 in "Symbolic Stream Generator (SSG) - Programming Reference Manual"

        remainingPartIndex = match.Index + match.Length;
        match = match.NextMatch();
      }

      result += s.Substring(remainingPartIndex);

      return result;
    } // ReplaceOctothorpeAndAsteriskParts

    /// <summary>
    /// Prefixes any $ signs in the provided string with ` characters.
    /// </summary>
    /// <param name="s">The input string.</param>
    /// <returns>The escaped result string.</returns>
    private static String EscapeDollar (String s) {
      StringBuilder result = new StringBuilder();
      foreach (Char c in s) {
        if (c == '$') {
          result.Append('`');
        }
        result.Append(c);
      }
      return result.ToString();
    } // EscapeDollar

    /// <summary>
    /// Separates literal string parts and bracketed references.
    /// </summary>
    /// <param name="s">The string to be split.</param>
    /// <returns>A list of separated parts.</returns>
<<<<<<< ours
    public List<String> SplitBracketedReferencesAndLiteralParts (String s) {
=======
    private List<String> SplitBracketedReferencesAndLiteralParts (String s) {
>>>>>>> rd

      List<String> parts = new List<String>();

      Int32 bracketLevel = 0;
      Int32 partStart = 0;
      for (Int32 i = 0; i < s.Length; i++) {

        if (s[i] == '[') {
          bracketLevel++;
          if (bracketLevel == 1) {
            if (i > partStart) {
              parts.Add(s.Substring(partStart, i - partStart));
            }
            partStart = i;
            continue;
          }
        }

        if (s[i] == ']') {
          bracketLevel--;
          if (bracketLevel == 0) {
            parts.Add(s.Substring(partStart, i - partStart + 1));
            partStart = i + 1;
            continue;
          }
          if (bracketLevel < 0) {
            // Stray trailing ']' — treat remaining text (including this ']') as a literal part
            m_LogObject.Warning(0, $"  SSG source bug: stray trailing ']' in expression '{s}' — tolerating as literal character.");
            bracketLevel = 0;
            break;
          }
        }
      }

      if (bracketLevel != 0) {
        String fmt = "Unbalanced brackets encountered in string value:\r\n{0}";
        throw new SymstreamException(String.Format(fmt, s));
      }

      // grab final part
      if (partStart < s.Length) {
        parts.Add(s.Substring(partStart));
      }

      return parts;
    } // SplitBracketedReferencesAndLiteralParts

    /// <summary>
    /// Maps a Symstream BinaryOperator type to PowerShell PSAstOperatorType type.
    /// </summary>
    /// <param name="binaryOperator">The enum to be mapped.</param>
    /// <returns>The target PSAstOperatorType.</returns>
    private PSAstOperatorType SymstreamBinaryOperatorToPowerShellBinaryOperator (BinaryOperator binaryOperator) {

      switch (binaryOperator) {
        case BinaryOperator.And:
          return PSAstOperatorType.And;
        case BinaryOperator.Or:
          return PSAstOperatorType.Or;
        case BinaryOperator.Xor:
          throw new SymstreamException("Binary operator XOR not supported as PSAstOperatorType.");
        case BinaryOperator.Plus:
          return PSAstOperatorType.Add;
        case BinaryOperator.Minus:
          return PSAstOperatorType.Substract;
        case BinaryOperator.GreaterThan:
          return PSAstOperatorType.GreaterThan;
        case BinaryOperator.GreaterThanOrEqualTo:
          return PSAstOperatorType.GreaterThanOrEqual;
        case BinaryOperator.EqualTo:
          return PSAstOperatorType.EqualTo;
        case BinaryOperator.UnequalTo:
          return PSAstOperatorType.NotEqualTo;
        case BinaryOperator.LessThanOrEqualTo:
          return PSAstOperatorType.LessThanOrEqual;
        case BinaryOperator.LessThan:
          return PSAstOperatorType.LessThan;
        default:
          throw new SymstreamException(String.Format("Unknown operator type encountered: {0}", binaryOperator));
      }
    } // SymstreamBinaryOperatorToPowerShellBinaryOperator

    /// <summary>
    /// Tells whether there are an equal number of ( and ) in the provided string and the outer ones are a pair.
    /// </summary>
    /// <param name="s">The string to be assessed.</param>
    /// <returns>A value indicating whether there are as many ( in the provided string as there are ) and the outer ones are a pair.</returns>
    private Boolean OuterParenthesesAreBalancedAndPaired (String s) {

      Int32 nestLevel = 0;
      Int32 hitZeroCount = 0;

      foreach (Char c in s) {
        if (c == '(') {
          nestLevel++;
        }

        if (c == ')') {
          nestLevel--;
          if (nestLevel == 0) {
            hitZeroCount++;
          }
        }
      }

      return (nestLevel == 0) && (hitZeroCount == 1);
    } // OuterParenthesesAreBalancedAndPaired

    /// <summary>
    /// Creates a concatenation PowerShell expression from the contents of a once bracketed reference
    /// that had sub-references in it which werre replaced with GetSgsValue (...) calls.
    /// </summary>
    /// <param name="s">The string to turn into a PowerShell expression.</param>
    /// <param name="partsConcatenated">The number of parts concatenated.</param>
    /// <returns>The PowerShell concatenation expression.</returns>
    private static String ConcatenateParenthesizedPartsAndNonParenthesizedParts (String s, out Int32 partsConcatenated) {

      List<String> parts = new List<String>();

      Int32 parenthesizeLevel = 0;
      Int32 start = 0;

      // collect parts
      for (Int32 i = 0; i < s.Length; i++) {

        if (s[i] == '(') {

          if (parenthesizeLevel == 0 && i > 0) {
            parts.Add(s.Substring(start, i - start));
            start = i;
          }

          parenthesizeLevel++;
        }

        if (s[i] == ')') {
          parenthesizeLevel--;

          if (parenthesizeLevel == 0) {
            parts.Add(s.Substring(start, i - start + 1));
            start = i + 1;
          }
        }
      }

      if (start < s.Length) {
        parts.Add(s.Substring(start));
      }

      String result = String.Empty;

      // concatenate
      foreach (String part in parts) {
        if (part.Length > 0 && part[0] == '(') {
          result += part + " + ";
        } else {
          result += "\"" + part + "\" + ";
        }
      }

      partsConcatenated = parts.Count;

      // strip last + and return
      return result.TrimEnd().TrimEnd('+').TrimEnd();
    } // ConcatenateParenthesizedPartsAndNonParenthesizedParts

    /// <summary>
    /// Convert SGS references that have GetSgsValue function call parts
    /// and literal parts into valid PowerShell expressions by creating
    /// a concatenation of string expressions.
    /// </summary>
    /// <param name="s">The string to cbe converted.</param>
    /// <param name="foundWork">On return, a value indicating whether there has been something to quote and concatenate.</param>
    /// <returns>A valid PowerShell expression.</returns>
    private String QuoteAndConcatenate (String s, out Boolean foundWork) {

      // look for (GetSgsValue (...)) without any + in the ... part
      Regex regex = new Regex(@"\(GetSgsValue \([^\+]+\)\)");

      Int32 remainingPartIndex = 0;
      String expanded = String.Empty;
      Match match = regex.Match(s);
      foundWork = false;

      while (match.Success) {
        // we only want the parts that still do have at least one GetSgsValue part
        // we also do not want lazy hits, parentheses must be balanced and paired
        if (match.Length > 16 && match.Value.Substring(14).Contains("GetSgsValue") && OuterParenthesesAreBalancedAndPaired(match.Value)) {
          String partBeforeParenthesizedExpression = s.Substring(remainingPartIndex, match.Index - remainingPartIndex + 14);
          String partToBeSplit = match.Value.Substring(14, match.Length - 16);
          String closingParentheses = s.Substring(match.Index + match.Length - 2, 2);

          // split & concatenate
          Int32 partsConcatenated;
          String concatenatedParts = ConcatenateParenthesizedPartsAndNonParenthesizedParts(partToBeSplit, out partsConcatenated);
          if (partsConcatenated > 1) {
            foundWork = true;
          }

          expanded += partBeforeParenthesizedExpression + concatenatedParts + closingParentheses;
          remainingPartIndex = match.Index + match.Length;
        }

        match = match.NextMatch();
      }

      expanded += s.Substring(remainingPartIndex);

      return expanded;
    } // QuoteAndConcatenate

    /// <summary>
    /// Escapes $ characters that are in the middle of an identifier.
    /// </summary>
    /// <param name="s">The string to modify.</param>
    /// <returns>The provided string, possibly with escaped dollar characters.</returns>
    private String EscapeEmbeddedDollars (String s) {

      String result = s;
      Regex regex = new Regex(@"(?<=\w)\$(?=\w)");

      Match match = regex.Match(result);
      while (match.Success) {
        result = String.Format("{0}{1}{2}", result.Substring(0, match.Index), "`", result.Substring(match.Index));
        match = regex.Match(result);
      }

      return result;
    } // EscapeEmbeddedDollars

    /// <summary>
    /// Returns the provided string with a single bracketed reference replaced
    /// by that reference wrapped in GetSgsValue function calls. String
    /// expressions are concatenated as needed.
    /// </summary>
    /// <param name="s">A string that may contain bracketed references.</param>
    /// <returns>
    /// A PowerShell expression that yields the result of the original
    /// Symstream expression containing brackeis references.
    /// </returns>
    private String ExpandSinglePossiblyNestedBracketedReference (String s) {

      // Match stuff enclosed in brackets (including the brackets) that have no [ or ] in it
      // so we will not get one match for "[..]  [..]" but two separate matches instead.
      Regex regex = new Regex(@"\[[^\[\]]+\]");

      Int32 remainingPartIndex = 0;
      String expanded = String.Empty;
      Match match = regex.Match(s);
      while (match.Success) {
        String unbracketedMatch = PrefixLoneIdentifiersWithDollar(match.Value).TrimStart('[').TrimEnd(']');
        String partBeforeOpeningBracket = s.Substring(remainingPartIndex, match.Index - remainingPartIndex);

        String doubleQuoteOrNothing = String.Empty;
        if (unbracketedMatch.IndexOf("GetSgsValue") == -1) {
          doubleQuoteOrNothing = "\"";
        }

        expanded += partBeforeOpeningBracket + String.Format("(GetSgsValue ({0}{1}{2}))", doubleQuoteOrNothing, unbracketedMatch, doubleQuoteOrNothing);
        remainingPartIndex = match.Index + match.Length;
        match = match.NextMatch();
      }

      expanded += s.Substring(remainingPartIndex);

      // it is possibly nested stuff, we only got matches for the inner ones
      // => repeat until we hit everything
      if (regex.Match(expanded).Success) {
        return EscapeEmbeddedDollars(ExpandSinglePossiblyNestedBracketedReference(expanded));
      } else {
        // There is nothing more to expand as far as substituting [...] with (GetSgsValue(...)) is concerned,
        // => next: create string concatenations.
        //
        // 1. Match on "(GetSgsValue(...))" with at least one "GetSgsValue" and no + sign within the ... part.
        // 2. Split the ... part into parenthesized parts and non-parenthesized parts.
        // 3. Double quote the non-parenthesized parts and concatenate them with the parenthesized parts using the + operator.
        // 4. Repeat steps 1 to 3 until there are no matches left.

        Boolean foundMatch;
        expanded = QuoteAndConcatenate(expanded, out foundMatch);
        while (foundMatch) {
          expanded = QuoteAndConcatenate(expanded, out foundMatch);
        }

        return EscapeEmbeddedDollars(expanded);
      }
    } // ExpandSinglePossiblyNestedBracketedReference

    /// <summary>
    /// Prefix any lone identifiers (that is, identifiers not prefixed with # or *) with a $.
    /// </summary>
    /// <param name="s">The string to process.</param>
    /// <returns>The processed and possibly modified input string.</returns>
    private String PrefixLoneIdentifiersWithDollar (String s) {

      Regex regex = new Regex(@",[A-Za-z][A-Za-z0-9]*(,|\])");

      Int32 remainingPartIndex = 0;
      String expanded = String.Empty;
      Match match = regex.Match(s);
      while (match.Success) {
        expanded += s.Substring(remainingPartIndex, match.Index - remainingPartIndex + 1) + "$" + s.Substring(match.Index + 1, match.Length - 1);
        remainingPartIndex = match.Index + match.Length;
        match = match.NextMatch();
      }

      expanded += s.Substring(remainingPartIndex);
      return expanded;
    } // PrefixLoneIdentifiersWithDollar

    /// <summary>
    /// Tells whetehr the provided operator type is a comparison operator or not.
    /// </summary>
    /// <param name="op">The operator to be tested.</param>
    /// <returns>A value indicating whether the provided operator type is a comparison operator or not.</returns>
    private static Boolean IsComparisonOperator (PSAstOperatorType op) {

      switch (op) {

        case PSAstOperatorType.LessThan:
        case PSAstOperatorType.LessThanOrEqual:
        case PSAstOperatorType.EqualTo:
        case PSAstOperatorType.NotEqualTo:
        case PSAstOperatorType.GreaterThanOrEqual:
        case PSAstOperatorType.GreaterThan: {
            return true;
          }

        default:
          return false;
      }
    } // IsComparisonOperator
  } // Class SymstreamExpressionMigrator
} // namespace Ecl.SsgConverter
