using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using Avanade.LtCoE.MigSupport;
using Ecl.SsgConverter.Expressions;
using PowerShell.Generator;

namespace Ecl.SsgConverter {

  /// <summary>
  /// A processor that transforms SSG skeleton files.
  /// </summary>
  public sealed class SymstreamProcessor {

    private const String Unexpected = "This is unexpected. DirectiveId: {0}  Line: {1}";
    private const String DefinePrefix = "DEFINE_";
    private const String BooleanEvaluateFunctionName = "BooleanEvaluate";

    private static readonly DirectiveId[] m_DirectiveIds = (DirectiveId[])Enum.GetValues(typeof(DirectiveId));

    /// <summary>
    /// Arguments for: Set-Variable -Name "NAME" -Value (value) -Scope 1, i.e. assign in the scope that called the define function.
    /// </summary>
    private static List<PsAstExprBase> SetVariableInCallerScope (String variableName, PsAstExprBase value) {
      return new List<PsAstExprBase> {
        new PsAstExprPrimitive("-Name", false),
        new PsAstExprPrimitive(variableName, true),
        new PsAstExprPrimitive("-Value", false),
        new PsAstExprParenthesized(value),
        new PsAstExprPrimitive("-Scope", false),
        new PsAstExprPrimitive("1", false)
      };
    }
    
    private readonly IMigLogger m_LogObject;
    private readonly IContentLineConverter m_ContentLineConverter;
    private readonly SymstreamExpressionParser m_ExpressionParser;
    private readonly SymstreamExpressionMigrator m_ExpressionMigrator;
    private List<String> m_RunLog = new List<String>();
    private Stack<PsAstInstrIf> m_CurrentIfs = new Stack<PsAstInstrIf>();
    private String m_FileBeingMigrated = String.Empty;
    private String m_SkeletonFilePath = String.Empty;
    private Boolean m_EmbeddedInIpf = false;
    private List<PsAstInstrBlock> m_InstructionBlocksBeingBuilt = new List<PsAstInstrBlock>();
    private Stack<String> m_InnerMostLoopVariable = new Stack<String>();
    private Int32 m_DefineDepth = 0;
    private String m_DirectivePrefix = "*";
    private String m_EditSymbol = "&";
    private Boolean m_UsesEdit = false;
    private Dictionary<String, String> m_SystemVariables = new Dictionary<String, String>() {

      // note: Empy values have not been initialized because they are not supported yet.
      //       Once thay are encountered they should be set to the initial value as stated
      //       in the documentation and used in the converter.

      { "ACCSGS$", "" },
      { "ADD_GOS$", "" },
      { "CASE$", "" },
      { "CASECHAR$", "" },
      { "COLED$", "" },
      { "CONFLC$", "" },
      { "CSFSTA$", "" },
      { "EDITAB$", "" },
      { "EOF$", "" },
      { "ERRCNT$", "" },
      { "GOSCNT$", "" },
      { "IMGLEN$", "" },
      { "IOPT$", "" },
      { "LBRK$", "" },
      { "MOPT$", "" },
      { "NEW_BOOLEAN$", "" },
      { "NEW_PROCESS$", "" },
      { "NOFND$", "" },
      { "NOPT$", "" },
      { "NSIGN$", "0" },
      { "NSIGNCHAR$", "#" },
      { "PCFNAME$", "" },
      { "PILO$", "" },
      { "PRTOFF$", "" },
      { "RTC$", "" },
      { "SFLD$", "" },
      { "SGSADDCNT$", "" },
      { "SGSCNT$", "" },
      { "SKELINE$", "" },
      { "SKELINECNT$", "" },
      { "SOPT$", "" },
      { "SSGSGS$", "" },
      { "STARTCHAR$", "" },
      { "STMT$", "" },
      { "STOPCHAR$", "" },
      { "STRINGCHAR$", "" },
      { "TCFNAME$", "" },
      { "UNS_CONTROL$", "" },
      { "UNS_INPUT$", "" },
      { "WARNINGCNT$", "" },
      { "WARNINGFLG$", "" },
      { "ZOPT$", "" }
    };

    /// <summary>
    /// Initializes a new instance of the SymstreamProcessor class.
    /// </summary>
    /// <param name="logObject">Log object</param>
    /// <param name="contentLineConverter">Converter for non-directive content lines (ECL, SQL, etc.)</param>
    public SymstreamProcessor (IMigLogger logObject, IContentLineConverter contentLineConverter) {
      m_LogObject = logObject;
      m_ContentLineConverter = contentLineConverter;
      m_ExpressionParser = new SymstreamExpressionParser();
      m_ExpressionMigrator = new SymstreamExpressionMigrator(logObject);
    } // Constructor SymstreamProcessor

    /// <summary>
    /// Converts the provided skeleton to a PowerShell syntax tree.
    /// </summary>
    /// <param name="lines">The lines of the Symstream skeleton to be converted.</param>
    /// <param name="fileBeingMigrated">The name of the file currently being migrated.</param>
    /// <param name="skeletonFilePath">The file the lines to be converted were obtained from (if any).</param>
    /// <param name="embeddedInIpf">A value indicatng whether the Symstream to be converted is embedded in an IPF statement or not.</param>
    /// <returns>The resulting PowerShell syntax tree.</returns>
    public PsAstInstrBlock Convert (IReadOnlyList<String> lines, String fileBeingMigrated, String skeletonFilePath = "", Boolean embeddedInIpf = false) {
      if (lines == null) { throw new ArgumentNullException(nameof(lines)); }

      m_FileBeingMigrated = fileBeingMigrated;
      m_SkeletonFilePath = skeletonFilePath;
      m_EmbeddedInIpf = embeddedInIpf;

      List<String> globalVariables = new List<String>();
      PsAstInstrBlock powerSkel = new PsAstInstrBlock();

      lines = MergeContinuedLines(lines, m_DirectivePrefix);
      lines = ProcessComments(lines, m_DirectivePrefix);
      lines = CondenseDirectives(lines, m_DirectivePrefix);

      // T3-045: edit mode is switched on and off at run time (inside *IF / *LOOP), so its state lives in two generated variables.
      m_EditSymbol = "&";
      m_UsesEdit = false;
      Regex editOn = new Regex("^" + Regex.Escape(m_DirectivePrefix) + @"EDIT(,\S)?\s+ON\b", RegexOptions.IgnoreCase);
      for (Int32 e = 0; e < lines.Count; e++) {
        if (editOn.IsMatch(lines[e]) && EditBlockIsText(lines, e)) { m_UsesEdit = true; break; }
      }
      if (m_UsesEdit) {
        powerSkel.AddAssignment(EdtVar("Edt_On"), new PsAstExprPrimitive("0", false));
        powerSkel.AddAssignment(EdtVar("Edt_Buf"), new PsAstExprPrimitive("", true));
      }

      // A *DEFINE body may use a variable that is first *SET/*CLEARed further down (T3-036): register all targets first.
      Regex setTarget = new Regex("^" + Regex.Escape(m_DirectivePrefix) + @"(SET|CLEAR)\s+([^\s=]+)", RegexOptions.IgnoreCase);
      foreach (String line in lines) {
        Match m = setTarget.Match(line);
        if (m.Success && IsVariableName(m.Groups[2].Value) && !globalVariables.Contains(m.Groups[2].Value.ToUpperInvariant())) {
          globalVariables.Add(m.Groups[2].Value.ToUpperInvariant());
        }
      }

      // convert directives
      for (Int32 i = 0; i < lines.Count; i++) {
        powerSkel.AddInstrBlock(Convert(lines, ref i, globalVariables));
      }

      // not needed any longer, clear for next time around
      m_InstructionBlocksBeingBuilt.Clear();

      return powerSkel;
    } // Convert

    /// <summary>
    /// Converts a Symstream expression to a PowerShell expression,
    /// wrapping any bracketed references in function calls to be
    /// resolved later.
    /// </summary>
    /// <param name="expression">The Symstream condition.</param>
    /// <param name="globalVariables">The current set of global variables if there is one.</param>
    /// <param name="localVariables">The current set of local variables if there is one.</param>
    /// <param name="identifierOverString">If it is hard to determine whether we are dealing with an identifier or a an unquoted string, choose identifier.</param>
    /// <returns>A PowerShell expression object that represents the provided Symstream expression.</returns>
    private PsAstExprBlock SymstreamExpressionToPowerShellExpression (String expression, List<String> globalVariables, List<String> localVariables, Boolean identifierOverString = false) {

      try {
        SymstreamExpression ssExpression = m_ExpressionParser.Parse(expression, globalVariables, localVariables, identifierOverString);
        return m_ExpressionMigrator.Migrate(ssExpression);
      } catch (Exception ex) {
        // rethrow with the expression text and file context so failures are diagnosable
        throw new SymstreamException(
          String.Format("Expression parse/migrate failed in '{0}'.\r\n  Expression: [{1}]\r\n  Cause: {2}",
            m_FileBeingMigrated, expression, ex.Message));
      }
    } // SymstreamExpressionToPowerShellExpression

    /// <summary>
    /// Converts a Symstream output/data line to a PowerShell expression that yields the line's text.
    /// Literal text is emitted verbatim as double-quoted string segments (never parsed as arithmetic
    /// operators), while only [bracketed] references are converted - with variable context - so a data
    /// line such as "06 FILLER PIC X([FILLCTR])." becomes ("06 FILLER PIC X(" + ($FILLCTR) + ".")
    /// rather than a broken operator expression.
    /// </summary>
    /// <param name="line">The Symstream output/data line.</param>
    /// <param name="globalVariables">The current set of global variables if there is one.</param>
    /// <param name="localVariables">The current set of local variables if there is one.</param>
    /// <returns>A PowerShell expression object that yields the output line's text.</returns>
    private PsAstExprBase OutputLineToPowerShellExpression (String line, List<String> globalVariables, List<String> localVariables) {

      List<String> parts = m_ExpressionMigrator.SplitBracketedReferencesAndLiteralParts(line);
      PsAstExprBase result = null;

      foreach (String part in parts) {
        PsAstExprBase segment;
        if (part.Length > 0 && part[0] == '[') {
          // a [bracketed] reference: convert with variable context ($var, GetSgsValue(...), $Parameters[n], ...)
          segment = new PsAstExprParenthesized(SymstreamExpressionToPowerShellExpression(part, globalVariables, localVariables));
        } else {
          // literal text: emit verbatim as a double-quoted PowerShell string
          segment = new PsAstExprPrimitive(QuoteForPowerShellDoubleQuotedString(part), false);
        }

        result = (result == null) ? segment : new PsAstExprBinaryOperator(result, PSAstOperatorType.Add, segment);
      }

      // an empty line still needs to be a valid PowerShell expression
      if (result == null) {
        result = new PsAstExprPrimitive("\"\"", false);
      }

      return new PsAstExprParenthesized(result);
    } // OutputLineToPowerShellExpression

    /// <summary>
    /// Wraps literal text as a PowerShell double-quoted string, escaping the characters that are
    /// special inside such a string (backtick, double quote, dollar).
    /// </summary>
    /// <param name="s">The literal text.</param>
    /// <returns>A PowerShell double-quoted string literal.</returns>
    private static String QuoteForPowerShellDoubleQuotedString (String s) {
      StringBuilder sb = new StringBuilder();
      sb.Append('"');
      foreach (Char c in s) {
        if (c == '`' || c == '"' || c == '$') {
          sb.Append('`');
        }
        sb.Append(c);
      }
      sb.Append('"');
      return sb.ToString();
    } // QuoteForPowerShellDoubleQuotedString

    /// <summary>
    /// Gets a directive's options as a string of option characters.
    /// </summary>
    /// <param name="line">The SymStream line possibly containing directive options.</param>
    /// <param name="directivePrefix">The current directive prefix (normally "*").</param>
    /// <param name="directiveId">The id of the directive on the line.</param>
    /// <returns>A string of concatenated option characters.</returns>
    private static String GetOptions (String line, String directivePrefix, DirectiveId directiveId) {

      String directive = String.Format("{0}{1}", directivePrefix, directiveId);

      if (line.StartsWith(directive, StringComparison.OrdinalIgnoreCase)) {
        if (line.StartsWith(directive + ",", StringComparison.OrdinalIgnoreCase)) {
          Int32 lengthOfDirectivePlusComma = directive.Length + 1;
          Int32 firstSpace = line.IndexOf(" ");
          if (firstSpace > -1) {
            // grab characters in between comma and first space
            return line.Substring(lengthOfDirectivePlusComma, firstSpace - lengthOfDirectivePlusComma);
          } else {
            // grab everything after first comma
            return line.Substring(lengthOfDirectivePlusComma);
          }
        } else {
          return String.Empty;
        }
      } else {
        throw new SymstreamException("Unexpected directive on line to obtain options from.");
      }
    } // GetOptions

    /// <summary>
    /// Return true if variable has a valid variable name
    /// </summary>
    /// <param name="variable">Variable to check</param>
    /// <returns>True if variable has valid variable name</returns>
    private static Boolean IsVariableName (String variable) {
      Boolean result = false;
      Regex regex = new Regex(@"^[a-zA-Z][a-zA-Z0-9_]*$");
      result = regex.IsMatch(variable);
      return result;
    } // IsVariableName

    /// <summary>
    /// Emits a warning log entry and a PS comment for a directive that is recognised but not yet implemented.
    /// Use instead of throwing so the file conversion continues rather than failing.
    /// </summary>
    private void EmitNotImplemented (PsAstInstrBlock block, String sourceLine) {
      String trimmed = sourceLine.Trim();
      m_LogObject.Warning(0, String.Format("  Not implemented — emitted as comment: {0}", trimmed));
      block.AddComment(String.Format(" NOT IMPLEMENTED: {0}", trimmed));
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

    /// <summary>
    /// Converts continued lines (broken by ";") to single lines.
    /// </summary>
    /// <param name="lines">The collection of lines to be converted.</param>
    /// <param name="directivePrefix">The current directive prefix (normally "*").</param>
    /// <returns>The resulting collection of complete lines.</returns>
    private static IReadOnlyList<String> MergeContinuedLines (IReadOnlyList<String> lines, String directivePrefix) {

      List<String> mergedLines = new List<String>();
      String mergedLine = String.Empty;

      foreach (String line in lines) {

        String lineWithoutComment;

        // separate any comment from the line being evaluated (directive and ECL images only, manual 4.3: other images are output text)
        Int32 commentStart = (CarriesComment(line, directivePrefix) || mergedLine.Length > 0) ? line.IndexOf(" . ") : -1;
        if (commentStart > -1) {
          mergedLines.Add(String.Format("* . {0}", line.Substring(commentStart + 3).TrimStart()));
          lineWithoutComment = line.Substring(0, commentStart).TrimEnd();
        } else {
          lineWithoutComment = line;
        }

        if ((lineWithoutComment.StartsWith(directivePrefix) || mergedLine.Length > 0) && lineWithoutComment.TrimEnd().EndsWith(";")) {
          // blanks after the continuation ';' are allowed, and a continuation line may continue again (T3-035)
          lineWithoutComment = lineWithoutComment.TrimEnd();
          if (lineWithoutComment.StartsWith(String.Format("{0}. ", directivePrefix))) {
            // Just add comment lines containing a ';'.
            mergedLines.Add(lineWithoutComment);
          } else if (lineWithoutComment.StartsWith("SQL ")) {
            if (!String.IsNullOrEmpty(mergedLine)) {
              mergedLines.Add(mergedLine);
              mergedLine = String.Empty;
            }
            mergedLines.Add(lineWithoutComment);
          } else {
            mergedLine += lineWithoutComment.Substring(0, lineWithoutComment.Length - 1);
          }
        } else {
          // the line does not end with ';', => add it.
          if (!String.IsNullOrEmpty(mergedLine)) {
            // the continued line may start with a directive prefix (typically the *)
            if (lineWithoutComment.StartsWith(directivePrefix)) {
              lineWithoutComment = lineWithoutComment.Substring(directivePrefix.Length);
            }

            mergedLine += lineWithoutComment;

            mergedLines.Add(mergedLine);
            mergedLine = String.Empty;
          } else {
            mergedLines.Add(lineWithoutComment);
          }
        }
      } // ~ foreach

      return mergedLines.AsReadOnly();
    } // MergeContinuedLines

    /// <summary>
    /// Removes any space in between the leading * and directive word.
    /// </summary>
    /// <param name="lines">The collection of lines to be converted.</param>
    /// <param name="directivePrefix">The current directive prefix (normally "*").</param>
    /// <returns>The resulting collection of condensed lines.</returns>
    private static IReadOnlyList<String> CondenseDirectives (IReadOnlyList<String> lines, String directivePrefix) {

      List<String> condensedLines = new List<String>();

      foreach (String line in lines) {
        if (line.Length > 1 && line.StartsWith(directivePrefix) && Char.IsWhiteSpace(line[1])) {
          String condensedLine = String.Format("{0}{1}", directivePrefix, line.Substring(1).TrimStart());
          DirectiveId id;
          if (IsDirective(condensedLine, directivePrefix, out id)) {
            // remove whitespace and add, then evaluate next line
            condensedLines.Add(condensedLine);
            continue;
          }
        }

        // the line does not have a slipt directive, just add it
        condensedLines.Add(line);
      } // ~ foreach

      return condensedLines.AsReadOnly();
    } // CondenseDirectives

    /// <summary>
    /// Process comments at the end of the line (starting with ". "). These
    /// comments are inserted before the statement that contained it.
    /// </summary>
    /// <param name="lines">The collection of lines to be processed.</param>
    /// <param name="directivePrefix">The current directive prefix (normally "*").</param>
    /// <returns>The resulting collection of lines.</returns>
    private static IReadOnlyList<String> ProcessComments (IReadOnlyList<String> lines, String directivePrefix) {

      List<String> processedLines = new List<String>();
      Int32 commentPos = 0;

      String prefixDotSpace = String.Format("{0}. ", directivePrefix);
      String prefixSpaceDot = String.Format("{0} .", directivePrefix);

      foreach (String line in lines) {
        if (!CarriesComment(line, directivePrefix)) {
          // an image that is neither a directive nor an ECL image is output text and stays unchanged (manual 4.3)
          processedLines.Add(line);
        } else if (!line.StartsWith(prefixDotSpace) && !line.StartsWith(prefixSpaceDot) && line.Contains(" . ")) {
          commentPos = line.IndexOf(" . ");
          processedLines.Add(prefixDotSpace + line.Substring(commentPos + 2).Trim());
          processedLines.Add(line.Substring(0, commentPos).Trim());
        } else if (line.EndsWith(" .")) {
          processedLines.Add(line.Substring(0, line.Length - 2).TrimEnd());
        } else {
          processedLines.Add(line);
        }
      } // ~ foreach

      return processedLines.AsReadOnly();
    } // ProcessComments

    /// <summary>
    /// Tells whether the provided line is a comment line or not.
    /// </summary>
    /// <param name="line">The line to be tested.</param>
    /// <param name="directivePrefix">The current directive prefix (normally "*").</param>
    /// <param name="textStart">The zero based index pointing to the start of the comment text.</param>
    /// <returns>True if the line is a comment, false if not.</returns>
    private static Boolean IsComment (String line, String directivePrefix, out Int32 textStart) {

      textStart = -1;
      // apparently comments with (white)space between the * and the . are legal (though the documentation suggests otherwise)
      Regex regex = new Regex(@"( |\t)*\.");
      Match match = regex.Match(line);
      if (match.Success && match.Index.Equals(directivePrefix.Length)) {
        textStart = match.Index + match.Length;
        return true;
      } else {
        return false;
      }
    } // IsComment

    /// <summary>
    /// Tells whether the provided line is a Symstream directive or not and sets directiveId if it is.
    /// </summary>
    /// <param name="line">The line to be tested.</param>
    /// <param name="directivePrefix">The current directive prefix (normally "*").</param>
    /// <param name="directiveId">The directive's id.</param>
    /// <returns>True if the line is a Symstream directive, false if not.</returns>
    private static Boolean IsDirective (String line, String directivePrefix, out DirectiveId directiveId) {

      directiveId = DirectiveId.None;
      foreach (DirectiveId id in m_DirectiveIds) {
        String stringToMatch = String.Format("{0}{1}", directivePrefix, id);
        if (line.StartsWith(stringToMatch, StringComparison.OrdinalIgnoreCase) && id != DirectiveId.None) {
          // it could be an identifier that starts as a directive
          if (line.Length > stringToMatch.Length
            && !Char.IsWhiteSpace(line[stringToMatch.Length])
            && line[stringToMatch.Length] != ','
            && line[stringToMatch.Length] != '.') {
            // it is, => false positive, ignore it
            continue;
          }

          directiveId = id;
          return true;
        }
      }

      return false;
    } // IsDirective

    /// <summary>
    /// Removes empty strings from an array of strings.
    /// </summary>
    /// <param name="strings">The array to remove empty strings from.</param>
    /// <returns>A new array that equals the original without the empty strings.</returns>
    private static String[] RemoveEmpty (String[] strings) {

      List<String> newList = new List<String>();
      foreach (String s in strings) {
        if (!String.IsNullOrWhiteSpace(s)) {
          newList.Add(s);
        }
      }

      return newList.ToArray();
    } // RemoveEmpty

    /// <summary>
    /// Splits a string into parts that are separated by space(s), keeping parts enclosed in single quotes together.
    /// </summary>
    /// <param name="s">The string that may contain parts.</param>
    /// <returns>An array of resulting parts.</returns>
    private static String[] SplitValuesKeepingSingleQuotedStringsTogether (String s) {
      List<String> splitValues = new List<String>();
      Int32 start = -1;
      Boolean inQuotes = false;
      Int32 i;
      for (i = 0; i < s.Length; i++) {
        if (s[i] == '\'') {
          if (inQuotes && s.Length > i + 1 && s[i + 1] == '\'') {
            i++;
          } else {
            inQuotes = !inQuotes;
          }
        }

        if (inQuotes) {
          continue;
        }

        if (Char.IsWhiteSpace(s[i])) {
          String value = s.Substring(start + 1, i - start - 1);
          if (!String.IsNullOrEmpty(value)) {
            splitValues.Add(value);
          }
          start = i;
        }
      }
      splitValues.Add(s.Substring(start + 1, i - start - 1));
      return splitValues.ToArray();
    } // SplitValuesKeepingSingleQuotedStringsTogether

    /// <summary>
    /// Tells whether a line contains an *EDIT terminating directive or not.
    /// </summary>
    /// <param name="line">The line to be tested.</param>
    /// <param name="directivePrefix">The current directive prefix (normally "*").</param>
    /// <returns>A value indicating whether a line contains an *EDIT terminating directive or not.</returns>
    private static Boolean IsEditOffDirective (String line, String directivePrefix) {

      if (line.StartsWith(String.Format("{0}EDIT", directivePrefix), StringComparison.OrdinalIgnoreCase)) {
        String editCutOff = line.Substring(5).Trim();
        if (editCutOff[0].Equals(',')) {
          // it has an option too, cut that off as well
          editCutOff = editCutOff.Substring(2).Trim();
        }

        if (editCutOff.StartsWith("OFF", StringComparison.OrdinalIgnoreCase)) {
          return true;
        }
      }

      return false;
    } // IsEditOffDirective

    private static PsAstExprPrimitive EdtVar (String name) {
      return new PsAstExprPrimitive(name, PsAstPrimitiveType.LocalObject);
    } // EdtVar

    /// <summary>
    /// Tells whether the *EDIT ON block starting at onIndex holds only plain text images (up to the first *EDIT OFF):
    /// blocks with ECL images (# or @) are not converted (T3-045).
    /// </summary>
    private Boolean EditBlockIsText (IReadOnlyList<String> lines, Int32 onIndex) {
      for (Int32 j = onIndex + 1; j < lines.Count && !IsEditOffDirective(lines[j], m_DirectivePrefix); j++) {
        if (lines[j].StartsWith("#") || lines[j].StartsWith("@")) { return false; }
      }
      return true;
    } // EditBlockIsText

    /// <summary>
    /// Gets the first word found in the specified string.
    /// </summary>
    /// <param name="s">The string to obtain the word from.</param>
    /// <param name="start">The character index to start the search (if it points to a non-whitespace character, it is assumed to be the word's first character).</param>
    /// <param name="charBehindWord">The character poisition immediately following the found word or the length of the string if the are no more characters following the word.</param>
    /// <returns>The extracted word or an empty string if no word could be found.</returns>
    private static String GetWord (String s, Int32 start, out Int32 charBehindWord) {

      Int32 len = s.Length;

      // flush any whitespace before word
      Int32 charIndex = start;
      while (charIndex < len && Char.IsWhiteSpace(s[charIndex])) {
        charIndex++;
      }

      Int32 firstWordChar = charIndex;

      // step to end of word
      while (charIndex < len && !Char.IsWhiteSpace(s[charIndex])) {
        charIndex++;
      }

      charBehindWord = charIndex;
      return s.Substring(firstWordChar, charIndex - firstWordChar);
    } // GetWord

    /// <summary>
    /// Collects text that possibly spans multiple lines.
    /// </summary>
    /// <param name="lines">The Symstream code being processed.</param>
    /// <param name="start">The start index of the text to be collected.</param>
    /// <param name="i">The current line index.</param>
    /// <returns>A single line constructed from the current line plus any continued lines.</returns>
    private static String CollectContinued (IReadOnlyList<String> lines, Int32 start, ref Int32 i) {

      String text = lines[i].Substring(start);

      // while text ends with a "trailing semicolon", strip it and concatenate
      while (text.EndsWith(" ;") || text.EndsWith(",;")) {
        i++;
        text = text.Substring(0, text.Length - 2) + " " + lines[i];
      }

      return text;
    } // CollectContinued

    /// <summary>
    /// Converts the provided Symstream line and generates PowerShell code from it.
    /// </summary>
    /// <param name="lines">The collection of lines from which to produce PowerShell code.</param>
    /// <param name="i">The zero based line index of the first line to be converted.</param>
    /// <param name="globalVariables">The current set of global variables if there is one.</param>
    /// <param name="localVariables">The current set of local variables if there is one.</param>
    /// <returns>The resulting PowerShell code.</returns>
    private PsAstInstrBlock Convert (IReadOnlyList<String> lines, ref Int32 i, List<String> globalVariables, List<String> localVariables = null) {

      PsAstInstrBlock powerSkel = new PsAstInstrBlock();
      m_InstructionBlocksBeingBuilt.Add(powerSkel);

      Int32 commentTextStart;

      DirectiveId directiveId;

      if (IsDirective(lines[i], m_DirectivePrefix, out directiveId)) {
        switch (directiveId) {
          case DirectiveId.Abort: {
              powerSkel.AddExit();
              break;
            }

          // ACCEPT []
          case DirectiveId.Accept: {
              //
              // The *ACCEPT directive allows SSG to function interactively.
              //
              // Format 1:
              //   *ACCEPT(,options) variable-name val (val val...)
              // Format 2:
              //   *ACCEPT,S(options) val (val val...)
              // Format 3:
              //   *ACCEPT,L(options) label val (val val...)
              //
              String acceptLine = lines[i].Trim();
              Int32 spacePos = acceptLine.IndexOf(" ");
              //String accept = acceptLine.Substring(0, spacePos);
              acceptLine = acceptLine.Substring(spacePos + 1).Trim();

              spacePos = acceptLine.IndexOf(" ");
              String variable;
              String message;
              if (spacePos == -1) {
                // No message — just a variable name (e.g. *ACCEPT lab)
                variable = acceptLine;
                message = String.Empty;
              } else {
                variable = acceptLine.Substring(0, spacePos);
                message = acceptLine.Substring(spacePos + 1).Trim();
              }

              List<PsAstExprBase> pars = new List<PsAstExprBase>();
              pars.Add(new PsAstExprNamed("Message", new PsAstExprPrimitive(message, true, PsAstPrimitiveType.Normal), true));
              powerSkel.AddAssignment(new PsAstExprPrimitive(variable, PsAstPrimitiveType.LocalObject), new PsAstExprMethod("Accept", pars.ToArray()));
              break;
            }

          // ADD []
          case DirectiveId.Add: {
              //
              // The *ADD directive performs dynamic expansion of the SGS chain.
              //
              // Format:
              //   *ADD(,opts) SGS(,options) specification
              //
              Int32 indexOfSgs = lines[i].IndexOf("SGS", StringComparison.OrdinalIgnoreCase);
              if (indexOfSgs == -1) {
                throw new SymstreamException(String.Format("SGS keyword expected in *ADD directive (line {0}).", i));
              }

              Int32 firstSpaceAfterSgs = lines[i].IndexOf(' ', indexOfSgs);
              String fileReference = lines[i].Substring(firstSpaceAfterSgs + 1);

              if (fileReference.EndsWith(".", StringComparison.OrdinalIgnoreCase)) {
                fileReference = fileReference.Substring(0, fileReference.Length - 1);
              }

              fileReference = fileReference.Replace('.', '\\');

              powerSkel.AddMethodInvoke("Add-Sgs", new PsAstExprPrimitive(fileReference, true, true));

              break;
            }

          // BRKPT []
          case DirectiveId.Brkpt: {
              // note: not equivalent to ECL @BRKPT, can probably be ignored
              break;
              //throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // CLEAR []
          case DirectiveId.Clear: {
              // - If a local variable of that name exists, SSG sets the value to zero.
              // - If no local variable of that name exists, SSG searches the global variable chain
              //   for that name, and if that name exists, sets it to 0.
              // - If SSG finds no global variable with that name, it creates one and gives it the
              //   value of 0. Once created, this global variable exists for the remainder of skeleton
              //   processing, unless it is removed (*REMOVE).
              //
              // Example 1
              //   *CLEAR VAR
              // Example 2
              //   *CLEAR [VAR,1,1,1]
              // Example 3
              //   *CLEAR [#P]
              //
              // note: Only example type 1 is used in STA sources (only in P$JOBC\UBOOT._SYM)
              //       and the created variables are never referenced so supporting the creation
              //       of plain global variables should suffice for now.
              String variableName = lines[i].Substring(7).Trim().ToUpperInvariant();
              // *CLEAR sets the (local or global) variable to 0, creating it if it does not exist.
              // Emit a null-safe assignment rather than `Clear-Variable $name` (which passed the
              // variable's value as -Name and threw when the variable was unset - issue T3-003).
              if (m_DefineDepth > 0) {
                powerSkel.AddMethodInvoke("Set-Variable", SetVariableInCallerScope(variableName, new PsAstExprPrimitive("0", false, PsAstPrimitiveType.Normal)));
              } else {
                powerSkel.AddAssignment(
                  new PsAstExprPrimitive(variableName, PsAstPrimitiveType.LocalObject),
                  new PsAstExprPrimitive("0", false, PsAstPrimitiveType.Normal));
              }
              globalVariables.Add(variableName);
              break;
            }

          // COPY
          case DirectiveId.Copy: {
              //
              // The *COPY directive adds skeleton images from other files or elements into the SSG skeleton.
              //
              // Format:
              //   *COPY(,options) (file.)(element)
              //
              // TODO: Implement (occurs in 2 files only: system\install and system\patch, perhaps we can ignore it).
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // CORRECT
          case DirectiveId.Correct: {
              // not used in STA sources
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // CREATE
          case DirectiveId.Create: {
              //
              // The *CREATE directive performs dynamic expansion of internal chains.
              //
              // Formats:
              //   *CREATE SGS(:) sgs-image
              //   *CREATE {PERM:|TEMP:}element-name(/version-name)
              //   *CREATE SGS filename./label
              //

              String line = lines[i];
              String s = line.Substring(8).ToUpperInvariant().Trim();

              if (s.StartsWith("SGS")) {
                s = s.Substring(3).Trim(':', ' ');
                if (s.Contains(".")) {
                  // it's a file reference
                  s = m_ExpressionMigrator.WrapSgsReferencesInFunctionCalls(s, true, true);

                  powerSkel.AddMethodInvoke("AddTo-SgsListFromFile", new PsAstExprPrimitive(s, false, false, false));
                } else {
                  // it's an SGS image: literal text with [..] references, like an output line (manual 5.2.10), not an expression
                  List<PsAstExprBase> psParameters = new List<PsAstExprBase>();
                  psParameters.Add(OutputLineToPowerShellExpression(s, globalVariables, localVariables));

                  powerSkel.AddMethodInvoke("AddTo-SgsList", psParameters);
                }
              } else {
                throw new SymstreamException(String.Format("*CREATE PERM/TEMP has not been implemented yet. Line: {0}", line));
              }

              break;
            }

          // CSF []
          case DirectiveId.Csf: {
              // Format:
              //   *CSF(,options) image
              //
              // The *CSF directive submits Exec control statement images (see 5.2.9).

              String csfLine = lines[i].Substring(5).Trim();
              List<String> csfLines = new List<String> { csfLine };
              PsAstInstrBlock csfBlock = m_ContentLineConverter.Convert(csfLines.AsReadOnly(), m_FileBeingMigrated);
              if (csfBlock != null) {
                powerSkel.AddInstrBlock(csfBlock);
              } else {
                powerSkel.AddComment(" *CSF (unconverted): " + csfLine);
              }

              break;
            }

          // DEFINE
          case DirectiveId.Define: {
              String defineName = lines[i].Substring(8).Trim().ToUpperInvariant();

              // We want this:
              //   function DefineName([string[]]$parameters) {

              List<PsAstExprParam> parameters = new List<PsAstExprParam>();
              PsAstExprParam parameter = new PsAstExprParam("Parameters", PsAstVariableType.Array, PsAstVariableType.StringType, String.Empty, false);
              parameters.Add(parameter);
              PsAstInstrFunction define = powerSkel.AddFunction(DefinePrefix + defineName, parameters);

              // Add Process-Skip call at the top of each define.
              // This is to check whether a call to the define should be skipped or not. It will look as follows:
              //
              // if (Process-Skip "Define_<define name>") {
              //   return
              // }
              define.Body.AddEmptyLine();
              PsAstExprBase paramDefineName = new PsAstExprPrimitive(DefinePrefix + defineName, true);

              PsAstExprMethod processSkip = new PsAstExprMethod("Process-Skip", paramDefineName);

              PsAstInstrIf instrIf = define.Body.AddIf(processSkip);
              PsAstInstrBlock ifBody = new PsAstInstrBlock();
              m_InstructionBlocksBeingBuilt.Add(ifBody);
              ifBody.AddReturn();
              instrIf.IfPart = ifBody;
              define.Body.AddEmptyLine();

              i++;
              DirectiveId endDefId;
              m_DefineDepth++;
              for (; i < lines.Count; i++) {
                if (lines[i].Trim().StartsWith(String.Format("{0}ENDDEFINE", m_DirectivePrefix), StringComparison.OrdinalIgnoreCase)) break;
                // accept deprecated *End as *ENDDEFINE terminator
                if (IsDirective(lines[i], m_DirectivePrefix, out endDefId) && endDefId == DirectiveId.End) break;
                define.Body.AddInstrBlock(Convert(lines, ref i, globalVariables));
              }
              m_DefineDepth--;

              if (i == lines.Count) {
                // no more lines and no *ENDDEFINE encountered
                StringBuilder sb = new StringBuilder();
                foreach (String line in lines) {
                  sb.AppendLine(line);
                }

                throw new SymstreamException("No *ENDDEFINE encountered after *DEFINE. See lines below.\r\n\r\n" + sb.ToString());
              }

              break;
            }

          // DISPLAY []
          case DirectiveId.Display: {

              // note: Used but without options so for now we will not bother looking for options.

              // Format:
              //   *DISPLAY(,options) val (val...)

              Int32 firstSpace = lines[i].IndexOf(' ');
              if (firstSpace == -1) {
                m_RunLog.Add(String.Empty);
              } else {
                String arguments = lines[i].Substring(firstSpace + 1).Trim();
                String[] splitValues = SplitValuesKeepingSingleQuotedStringsTogether(arguments);
                String messages = String.Empty;
                foreach (String part in splitValues) {
                  String unquotedAndExpandedPart = m_ExpressionMigrator.WrapSgsReferencesInFunctionCalls(part.Trim('\''), true, true);
                  messages += String.Format("{0}, ", unquotedAndExpandedPart);
                }

                // strip last ", "
                messages = messages.TrimEnd().TrimEnd(',');

                powerSkel.AddMethodInvoke("Log-Message", new PsAstExprPrimitive(messages, false), new PsAstExprLiteralString("([LogMessageType]::Information)"));
              }

              break;
            }

          // DIVIDE
          case DirectiveId.Divide: {
              // Format:
              //   *DIVIDE number1 BY number2 GIVING variable-name-1(,variable-name-2)
              //   *DIVIDE number1 / number2 GIVING variable-name-1(,variable-name-2)
              String upperedLine = lines[i].ToUpperInvariant();
              Int32 indexBy = upperedLine.IndexOf(" BY ");
              Int32 separatorLength = 4;
              if (indexBy < 0) {
                indexBy = upperedLine.IndexOf(" / ");
                separatorLength = 3;
              }
              Int32 indexGiving = upperedLine.IndexOf(" GIVING ");
              String number1 = lines[i].Substring(8, indexBy - 8);
              String number2 = lines[i].Substring(indexBy + separatorLength, indexGiving - indexBy - separatorLength);
              String variables = lines[i].Substring(indexGiving + 8);
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

              break;
            }

          // DLOC []
          case DirectiveId.Dloc: {

              // Format:
              //   *DLOC {ON|OFF}
              //
              // The *DLOC directive obtains or releases secure privileges. We can safely ignore it.
              break;
            }

          // DO
          case DirectiveId.Do: {

              // Format:
              //   *DO (VARNAME=)variable-name (FROM(=)from-value) (TO(=)to-value) (BY(=)by-value) (WHILE(=)variable-name IS {SET|CLEAR})
              //     (skeleton images)
              //   *ENDDO

              // note: Everything DO should be on the same line.

              String doVariable = String.Empty;
              String fromValue = String.Empty;
              String toValue = String.Empty;
              String byValue = String.Empty;
              String whileVariable = String.Empty;
              Boolean? whileCondition = null;

              String s = lines[i].ToUpperInvariant();
              Regex regex;
              Match match;

              regex = new Regex(@"(?<=DO\s+(VARNAME(\s*=\s*|\s+))?)\S+");
              match = regex.Match(s);
              if (match.Success) {
                doVariable = match.Value;
                m_InnerMostLoopVariable.Push(doVariable);
              } else {
                throw new SymstreamException("No DO variable found after *DO.");
              }

              regex = new Regex(@"(?<=\s+FROM(\s*=\s*|\s+))\S+");
              match = regex.Match(s);
              if (match.Success) {
                fromValue = match.Value;
              } else {
                fromValue = "1";
              }

              regex = new Regex(@"(?<=\s+TO(\s*=\s*|\s+))\S+");
              match = regex.Match(s);
              if (match.Success) {
                toValue = match.Value;
              } else {
                toValue = "1";
              }

              regex = new Regex(@"(?<=\s+BY(\s*=\s*|\s+))\S+");
              match = regex.Match(s);
              if (match.Success) {
                byValue = match.Value;
              } else {
                byValue = "1";
              }

              regex = new Regex(@"(?<=\s+WHILE(\s*=\s*|\s+))\S+");
              match = regex.Match(s);
              if (match.Success) {
                whileVariable = match.Value;
              }

              regex = new Regex(@"\s+IS\s+CLEAR(?=\s|$)");
              match = regex.Match(s);
              if (match.Success) {
                whileCondition = false;
              }

              regex = new Regex(@"\s+IS\s+SET(?=\s|$)");
              match = regex.Match(s);
              if (match.Success) {
                whileCondition = true;
              }

              if (!String.IsNullOrEmpty(doVariable)) {
                m_InnerMostLoopVariable.Push(doVariable);
              }

              PsAstExprBase psDoVariable = new PsAstExprPrimitive(doVariable, PsAstPrimitiveType.LocalObject);

              PsAstInstrBlock initBlock = new PsAstInstrBlock();
              m_InstructionBlocksBeingBuilt.Add(initBlock);

              PsAstExprBlock psFromValue = SymstreamExpressionToPowerShellExpression(fromValue, globalVariables, localVariables, true);
              initBlock.AddVarDeclare(doVariable, PsAstVariableType.IntType, psFromValue, false);  // [int]$I = $fromValue

              PsAstExprBlock psToValue = SymstreamExpressionToPowerShellExpression(toValue, globalVariables, localVariables, true);
              PsAstExprBase condition = new PsAstExprBinaryOperator(psDoVariable, PSAstOperatorType.LessThanOrEqual, psToValue);  // $I -le $toValue

              if (!String.IsNullOrEmpty(whileVariable)) {
                // we have a WHILE clause, => add WHILE condition
                PsAstExprBase psWhileCondition = new PsAstExprPrimitive(whileVariable);
                if (!whileCondition.Value) {
                  psWhileCondition = new PsAstExprUnary(PSAstOperatorType.Not, psWhileCondition);
                }

                condition = new PsAstExprBinaryOperator(condition, PSAstOperatorType.And, psWhileCondition);
              }

              PsAstInstrBlock stepBlock = new PsAstInstrBlock();
              m_InstructionBlocksBeingBuilt.Add(stepBlock);

              Int32 byValueAsInt;
              if (Int32.TryParse(byValue, out byValueAsInt)) {
                stepBlock.AddIncrement(psDoVariable, byValueAsInt);  // $I = $I + literal
              } else {
                PsAstExprBlock psByValue = SymstreamExpressionToPowerShellExpression(byValue, globalVariables, localVariables, true);
                stepBlock.AddAssignment(psDoVariable, psByValue, PSAstOperatorType.Add);  // $I += <expression>
              }

              PsAstInstrFor forInstruction = powerSkel.AddFor(initBlock, condition, stepBlock);

              if (localVariables == null) {
                localVariables = new List<String>();
              }

              localVariables.Add(doVariable);

              // convert lines in loop
              i++;
              DirectiveId loopId;
              for (; (i < lines.Count); i++) {
                // accept deprecated *End as *ENDDO terminator
                if ((IsDirective(lines[i], m_DirectivePrefix, out loopId)) && (loopId == DirectiveId.EndDo || loopId == DirectiveId.End)) {
                  break;
                }

                forInstruction.Body.AddInstrBlock(Convert(lines, ref i, globalVariables, localVariables));
              }

              if (i == lines.Count) {
                // no more lines and no *ENDDO encountered
                StringBuilder sb = new StringBuilder();
                foreach (String line in lines) {
                  sb.AppendLine(line);
                }

                throw new SymstreamException("No *ENDDO encountered after *DO. See lines below.\r\n\r\n" + sb.ToString());
              }

              localVariables.Remove(doVariable);
              m_InnerMostLoopVariable.Pop();

              break;
            }

          // DUMP
          case DirectiveId.Dump: {
              // not used in STA sources
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // EDIT
          case DirectiveId.Edit: {
              // Format 1: EDITAB$ has (or will have using the C option) a value of 0.
              //   *EDIT(,options) ON [{edtsym|edtsym.comment|.comment}]
              //
              // Format 2: EDITAB$ has (or will have, using the S option) a nonzero value.
              //   *EDIT(,options) ON (edtsym(edtimg(edtsym(coled ... ))))
              //
              // Format 3: unconditionally terminate edit mode.
              //   *EDIT(,options) OFF
              //
              // The *EDIT directive concatenates nondirective images.

              String line = lines[i];
              String s;

              if (m_UsesEdit && IsEditOffDirective(line, m_DirectivePrefix)) {
                // *EDIT OFF outputs the image built so far; outside edit mode it is ignored (manual 5.2.16).
                PsAstInstrIf offIf = powerSkel.AddIf(EdtVar("Edt_On"));
                offIf.IfPart.AddMethodInvoke("DataLineOrNoStatement", EdtVar("Edt_Buf"));
                offIf.IfPart.AddAssignment(EdtVar("Edt_On"), new PsAstExprPrimitive("0", false));
                offIf.IfPart.AddAssignment(EdtVar("Edt_Buf"), new PsAstExprPrimitive("", true));
                break;
              }

              // note: We are assuming EDITAB$ to be zero (no tabs)

              // get option
              //Char option = ' ';
              if (line[5].Equals(',')) {
                //option = line[6];
                if (!Char.IsWhiteSpace(line[7])) {
                  throw new SymstreamException(String.Format("Unexpected format of *EDIT directive. Line: {0}", line));
                }

                s = line.Substring(8).Trim();
              } else {
                s = line.Substring(5).Trim();
              }

              // s must start with ON now
              if (!s.StartsWith("ON", StringComparison.OrdinalIgnoreCase)) {
                throw new SymstreamException(String.Format("*EDIT must have ON parameter. Line: {0}", line));
              }

              // strip off ON (there may or may not be an edit symbol definition following on the same line)
              s = s.Substring(2).Trim();

              //String edtsym = "&";
              //String comment = String.Empty;

              if (!String.IsNullOrEmpty(s)) {
                // there should be an edit symbol definition
                //edtsym = s.Substring(0, 1);

                // We only support a plain literal character for an edit symbol so if we
                // have more, the character following the edit symbol should be a space.
                if (s.Length > 1) {

                  if (!Char.IsWhiteSpace(s[1])) {
                    throw new SymstreamException("Only a literal character is supported as an edit symbol.");
                  }

                  // and there may be comment text
                  if (s.Substring(1).StartsWith(" . ")) {
                    //comment = s.Substring(4);
                  }
                }
              }

              if (m_UsesEdit && EditBlockIsText(lines, i)) {
                // T3-045: the edit symbol ends the used part of an image (default &); *EDIT ON starts a new image
                // (an *EDIT ON in edit mode destroys a partially edited image).
                m_EditSymbol = String.IsNullOrEmpty(s) ? "&" : s.Substring(0, 1);
                powerSkel.AddAssignment(EdtVar("Edt_On"), new PsAstExprPrimitive("1", false));
                powerSkel.AddAssignment(EdtVar("Edt_Buf"), new PsAstExprPrimitive("", true));
                break;
              }

              StringBuilder sb = new StringBuilder();
              i++;
              while (i < lines.Count && !IsEditOffDirective(lines[i], m_DirectivePrefix)) {
                sb.AppendLine(lines[i]);
                i++;
              }

              if (i == lines.Count) {
                throw new SymstreamException("Unterminated *EDIT directive encountered.");
              }

              // we have the data, now what?
              //throw new SymstreamException("*EDIT is not done yet, we need to figure out what to do with *EDIT data.");

              // TODO: Check out what to do with *EDIT data.

              break;
            }

          // EJECT
          case DirectiveId.Eject: {
              // not used in STA sources
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // ELSE
          case DirectiveId.Else: {

              PsAstInstrBlock currentBlock;

              if (m_CurrentIfs.Count > 0) {
                PsAstInstrIf currentIf = m_CurrentIfs.Peek();
                currentBlock = currentIf.ElsePart;
              } else {
                throw new SymstreamException(String.Format("This is wrong, we should have a current if statement (line {0}).", i));
              }

              i++;
              DirectiveId endId;
              for (; (i < lines.Count); i++) {
                if (IsDirective(lines[i], m_DirectivePrefix, out endId)) {
                  if (endId == DirectiveId.EndIf ||
                      endId == DirectiveId.End) {
                    break;
                  }
                }
                currentBlock.AddInstrBlock(Convert(lines, ref i, globalVariables));
              }

              if (i == lines.Count) {
                // no more lines and no *ENDIF encountered
                StringBuilder sb = new StringBuilder();
                foreach (String line in lines) {
                  sb.AppendLine(line);
                }

                throw new SymstreamException("No *ENDIF encountered after *ELSE. See lines below.\r\n\r\n" + sb.ToString());
              }

              // caller (case If/ElseIf) will increment i, thus skipping the *ENDIF, => put it one back
              i--;

              break;
            }

          // ELSEIF
          case DirectiveId.ElseIf:
          case DirectiveId.Elsf: {

              // grab condition
              Int32 firstSpace = lines[i].IndexOf(' ');
              String expression = lines[i].Substring(firstSpace + 1).Trim();

              PsAstExprBlock condition = SymstreamExpressionToPowerShellExpression(expression, globalVariables, localVariables);
              //PsAstExprMethod wrappedCondition = new PsAstExprMethod(BooleanEvaluateFunctionName, condition);

              PsAstInstrBlock currentBlock;

              if (m_CurrentIfs.Count > 0) {
                PsAstInstrIf currentIf = m_CurrentIfs.Peek();
                currentBlock = currentIf.AddIfElseIf(condition);
              } else {
                throw new SymstreamException(String.Format("This is wrong, we should have a current if statement (line {0}).", i));
              }

              i++;
              DirectiveId endId;
              for (; (i < lines.Count); i++) {
                if (IsDirective(lines[i], m_DirectivePrefix, out endId)) {
                  if (endId == DirectiveId.Else ||
                      endId == DirectiveId.EndIf ||
                      endId == DirectiveId.End) {
                    break;
                  }
                }
                currentBlock.AddInstrBlock(Convert(lines, ref i, globalVariables));
              }

              if (i == lines.Count) {
                // no more lines and no *ELSE or *ENDIF encountered
                StringBuilder sb = new StringBuilder();
                foreach (String line in lines) {
                  sb.AppendLine(line);
                }

                throw new SymstreamException("No *ELSE or *ENDIF encountered after *ELSEIF. See lines below.\r\n\r\n" + sb.ToString());
              }

              // caller (case If) will increment i, thus skipping the *ENDIF, => put it one back
              i--;

              break;
            }

          // ENDCORRECT
          case DirectiveId.EndCorrect: {
              // not used in STA sources
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // ENDDEFINE
          case DirectiveId.EndDefine: {
              // We should not encounter an ENDDEFINE directive in this switch,
              // processing DEFINE should process the entire DEFINE statement.
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // ENDDO
          case DirectiveId.EndDo: {
              // We should not encounter an ENDDO directive in this switch,
              // processing DO should process the entire DO statement.
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // ENDIF
          case DirectiveId.EndIf:
          case DirectiveId.End: {
              // We should not encounter an ENDIF directive in this switch,
              // processing IF should process the entire IF statement.
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // EXIT []
          case DirectiveId.Exit: {
              powerSkel.AddExit();
              break;
            }

          // IF
          case DirectiveId.If: {
              // Format 1
              //   *IF condition-1
              //     (skeleton images)
              //   *ELSEIF condition-2)
              //     (skeleton images)
              //     .
              //     .
              //     .
              //   *ELSEIF condition-n)
              //     (skeleton images)
              //   *ELSE
              //     (skeleton images)
              //   *ENDIF

              // grab condition
              Int32 firstSpace = lines[i].IndexOf(' ');
              String expression = CollectContinued(lines, firstSpace + 1, ref i);

              Regex regex;

              // IS SET ?
              regex = new Regex(@"(?i)\sIS\s+SET(?=\s|\)|$)");
              Match matchSet = regex.Match(expression);

              // IS CLEAR ?
              regex = new Regex(@"(?i)\sIS\s+CLEAR(?=\s|\)|$)");
              Match matchClear = regex.Match(expression);

              PsAstExprBase condition;

              if (matchSet.Success) {
                expression = expression.Replace(matchSet.Value, String.Empty);
                condition = SymstreamExpressionToPowerShellExpression(expression, globalVariables, localVariables, true);
              } else if (matchClear.Success) {
                expression = expression.Replace(matchClear.Value, String.Empty);
                condition = SymstreamExpressionToPowerShellExpression(expression, globalVariables, localVariables, true);
                condition = new PsAstExprUnary(PSAstOperatorType.Not, condition);
              } else {
                condition = SymstreamExpressionToPowerShellExpression(expression, globalVariables, localVariables);
                //PsAstExprMethod wrappedCondition = new PsAstExprMethod(BooleanEvaluateFunctionName, condition);
              }

              PsAstInstrBlock currentBlock;

              PsAstInstrIf newIf = powerSkel.AddIf(condition);
              m_CurrentIfs.Push(newIf);
              currentBlock = newIf.IfPart;

              i++;
              DirectiveId endId;
              for (; (i < lines.Count); i++) {
                if (IsDirective(lines[i], m_DirectivePrefix, out endId)) {
                  if (endId == DirectiveId.EndIf ||
                      endId == DirectiveId.End) {
                    break;
                  }
                }
                currentBlock.AddInstrBlock(Convert(lines, ref i, globalVariables));
              }

              if (i == lines.Count) {
                // no more lines and no *ENDIF encountered
                StringBuilder sb = new StringBuilder();
                foreach (String line in lines) {
                  sb.AppendLine(line);
                }

                throw new SymstreamException("No *ENDIF encountered after *IF. See lines below.\r\n\r\n" + sb.ToString());
              }

              m_CurrentIfs.Pop();

              break;
            }

          // INCREMENT
          case DirectiveId.Increment: {

              // Format:
              //   *INCREMENT variable-name (FROM from-value) (TO to-value) (BY by-value) (WHILE variable-name IS {SET|CLEAR})
              //     (skeleton images)
              //   *LOOP

              // note: This is the same as (actually a sub-set of) *DO *ENDDO. The code
              //       is almost the same apart from a couple of tweaks (like looking
              //       for *LOOP rather than *ENDDO).
              //
              //       Everything INCREMENT should be on the same line.

              String incrementVariable = String.Empty;
              String fromValue = String.Empty;
              String toValue = String.Empty;
              String byValue = String.Empty;
              String whileVariable = String.Empty;
              Boolean? whileCondition = null;
              Boolean hasExplicitFrom = false;
              Boolean hasExplicitTo = false;

              String s = lines[i].ToUpperInvariant();
              Regex regex;
              Match match;

              regex = new Regex(@"(?<=INCREMENT\s+(VARNAME(\s*=\s*|\s+))?)\S+");
              match = regex.Match(s);
              if (match.Success) {
                incrementVariable = match.Value;
                if (incrementVariable.StartsWith("+")) {
                  // some SSG sources write "*INCREMENT +I ..." with a leading '+' on the variable
                  // name itself (not an operator); every other reference to the same loop variable
                  // in the source (e.g. bracketed [PG,I,1,1]) omits the '+', so strip it here too -
                  // otherwise the declare ($+I, invalid PowerShell) and the condition/increment
                  // (sanitised to $_I by the AST writer) end up as two different, mismatched names.
                  incrementVariable = incrementVariable.Substring(1);
                }
                m_InnerMostLoopVariable.Push(incrementVariable);
              } else {
                throw new SymstreamException("No INCREMENT variable found after *INCREMENT.");
              }

              regex = new Regex(@"(?<=\s+FROM(\s*=\s*|\s+))\S+");
              match = regex.Match(s);
              if (match.Success) {
                fromValue = match.Value;
                hasExplicitFrom = true;
              } else {
                fromValue = "1";
              }

              regex = new Regex(@"(?<=\s+TO(\s*=\s*|\s+))\S+");
              match = regex.Match(s);
              if (match.Success) {
                toValue = match.Value;
                hasExplicitTo = true;
              } else {
                toValue = "1";
              }

              regex = new Regex(@"(?<=\s+BY(\s*=\s*|\s+))\S+");
              match = regex.Match(s);
              if (match.Success) {
                byValue = match.Value;
              } else {
                byValue = "1";
              }

              regex = new Regex(@"(?<=\s+WHILE(\s*=\s*|\s+))\S+");
              match = regex.Match(s);
              if (match.Success) {
                whileVariable = match.Value;
              }

              regex = new Regex(@"\s+IS\s+CLEAR(?=\s|$)");
              match = regex.Match(s);
              if (match.Success) {
                whileCondition = false;
              }

              regex = new Regex(@"\s+IS\s+SET(?=\s|$)");
              match = regex.Match(s);
              if (match.Success) {
                whileCondition = true;
              }

              if (!String.IsNullOrEmpty(incrementVariable)) {
                m_InnerMostLoopVariable.Push(incrementVariable);
              }

              PsAstExprBase psIncrementVariable = new PsAstExprPrimitive(incrementVariable, PsAstPrimitiveType.LocalObject);

              PsAstInstrBlock initBlock = new PsAstInstrBlock();
              m_InstructionBlocksBeingBuilt.Add(initBlock);

              PsAstExprBlock psFromValue = SymstreamExpressionToPowerShellExpression(fromValue, globalVariables, localVariables, true);
              initBlock.AddVarDeclare(incrementVariable, PsAstVariableType.IntType, psFromValue, false);  // [int]$I = $fromValue

              PsAstExprBlock psToValue = SymstreamExpressionToPowerShellExpression(toValue, globalVariables, localVariables, true);
              PsAstExprBase condition = new PsAstExprBinaryOperator(psIncrementVariable, PSAstOperatorType.LessThanOrEqual, psToValue);  // $I -le $toValue

              if (!String.IsNullOrEmpty(whileVariable)) {
                // we have a WHILE clause, => add WHILE condition
                PsAstExprBase psWhileCondition = new PsAstExprPrimitive(whileVariable);
                if (!whileCondition.Value) {
                  psWhileCondition = new PsAstExprUnary(PSAstOperatorType.Not, psWhileCondition);
                }

                condition = new PsAstExprBinaryOperator(condition, PSAstOperatorType.And, psWhileCondition);
              }

              PsAstInstrBlock stepBlock = new PsAstInstrBlock();
              m_InstructionBlocksBeingBuilt.Add(stepBlock);

              Int32 byValueAsInt;
              if (Int32.TryParse(byValue, out byValueAsInt)) {
                stepBlock.AddIncrement(psIncrementVariable, byValueAsInt);  // $I = $I + literal
              } else {
                PsAstExprBlock psByValue = SymstreamExpressionToPowerShellExpression(byValue, globalVariables, localVariables, true);
                stepBlock.AddAssignment(psIncrementVariable, psByValue, PSAstOperatorType.Add);  // $I += <expression>
              }

              PsAstInstrFor forInstruction = powerSkel.AddFor(initBlock, condition, stepBlock);

              if (localVariables == null) {
                localVariables = new List<String>();
              }

              localVariables.Add(incrementVariable);

              // convert lines in loop
              i++;
              DirectiveId loopId;
              for (; (i < lines.Count); i++) {
                if ((IsDirective(lines[i], m_DirectivePrefix, out loopId)) && (loopId == DirectiveId.Loop)) {
                  break;
                }

                forInstruction.Body.AddInstrBlock(Convert(lines, ref i, globalVariables, localVariables));
              }

              if (i == lines.Count && !(hasExplicitFrom && hasExplicitTo)) {
                // no more lines and no *LOOP encountered, and the *INCREMENT is not self-bounded
                StringBuilder sb = new StringBuilder();
                foreach (String line in lines) {
                  sb.AppendLine(line);
                }

                throw new SymstreamException("No *LOOP encountered after *INCREMENT. See lines below.\r\n\r\n" + sb.ToString());
              }

              // A self-bounded *INCREMENT (explicit FROM/TO) needs no closing *LOOP: the
              // FROM/TO bounds define the iteration count and the consumed lines form the body.

              localVariables.Remove(incrementVariable);
              m_InnerMostLoopVariable.Pop();

              break;
            }

          // ITERATE []
          case DirectiveId.Iterate: {
              // Format:
              //   *ITERATE (varname)
              //
              // The *ITERATE directive allows the next iteration of a loop to take place at any point in the loop.
              //
              // - If varname is not specified, the iteration takes place on the innermost loop.
              // - If varname is specified, the loop using the loop control variable specified is iterated.
              //
              // This sucks... There is no PowerShell equivalent, there is only "continue" without specification of
              // the loop to continue. This always continues the inner most loop.

              String variableName = lines[i].Substring(8).ToUpperInvariant().Trim();

              if (String.IsNullOrEmpty(variableName) || variableName.Equals(m_InnerMostLoopVariable.Peek())) {
                powerSkel.AddMethodInvoke("continue");
              } else {
                // *ITERATE on an outer loop variable has no direct PowerShell equivalent (no labelled continue)
                // Emitted as a comment — see SsgConverter-Fix-20260820.md Fix 11 for R&D notes
                m_LogObject.Error(0, String.Format(
                  "  IMPORTANT-WORKAROUND applied: *ITERATE {0} targets an outer loop — PowerShell has no labelled continue. " +
                  "The iterate directive is emitted as a comment; the loop body will NOT skip remaining statements. " +
                  "See SsgConverter-Fix-20260820.md Fix 11 for the proper R&D fix.", variableName));
                powerSkel.AddComment(String.Format(
                  " IMPORTANT-WORKAROUND: *ITERATE {0} skips to the next iteration of an outer loop." +
                  " PowerShell 'continue' only affects the innermost loop, so this is a no-op here." +
                  " R&D fix required — see SsgConverter-Fix-20260820.md Fix 11.", variableName));
              }

              break;
            }

          // LIST
          case DirectiveId.List: {
              // not used in STA sources
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // LOOP
          case DirectiveId.Loop: {
              // We should not encounter a LOOP directive in this switch,
              // processing INCREMENT should process the entire INCREMENT statement.
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // MERGE
          case DirectiveId.Merge: {
              // not used in STA sources
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // MESSAGE []
          case DirectiveId.Message: {

              // Format:
              //   *MESSAGE(,options) text

              String text = String.Empty;
              String options = "Options: " + GetOptions(lines[i], m_DirectivePrefix, directiveId);

              Int32 firstSpace = lines[i].IndexOf(" ");
              if (firstSpace > -1) {
                text += lines[i].Substring(firstSpace + 1).Trim();
              }

              powerSkel.AddMethodInvoke("Log-Message", new PsAstExprPrimitive(text, true), new PsAstExprLiteralString("([LogMessageType]::Information)"));
              if (!String.IsNullOrEmpty(options)) {
                PsAstExprBase psOptions = new PsAstExprParenthesized(SymstreamExpressionToPowerShellExpression(options, globalVariables, localVariables));
                powerSkel.AddMethodInvoke("Log-Message", psOptions, new PsAstExprLiteralString("([LogMessageType]::Information)"));
              }

              break;
            }

          // MULTIPLY
          case DirectiveId.Multiply: {
              // Format:
              //   *MULTIPLY number1 BY number2 GIVING variable-name
              String mulLine = lines[i].ToUpperInvariant();
              Int32 mulBy = mulLine.IndexOf(" BY ");
              Int32 mulGiving = mulLine.IndexOf(" GIVING ");
              if (mulBy > -1 && mulGiving > -1 && mulGiving > mulBy) {
                String mulNum1 = lines[i].Substring(10, mulBy - 10).Trim();
                String mulNum2 = lines[i].Substring(mulBy + 4, mulGiving - mulBy - 4).Trim();
                String mulVar  = lines[i].Substring(mulGiving + 8).Trim();
                PsAstExprPrimitive mulTarget = new PsAstExprPrimitive(mulVar, PsAstPrimitiveType.LocalObject);
                PsAstExprBinaryOperator mulOp = new PsAstExprBinaryOperator(
                  SymstreamExpressionToPowerShellExpression(mulNum1, globalVariables, localVariables),
                  PSAstOperatorType.Multiply,
                  SymstreamExpressionToPowerShellExpression(mulNum2, globalVariables, localVariables));
                powerSkel.AddAssignment(mulTarget, mulOp);
                globalVariables.Add(mulVar.ToUpperInvariant());
              } else {
                EmitNotImplemented(powerSkel, lines[i]);
              }
              break;
            }

          // PCONTROL []
          case DirectiveId.Pcontrol: {
              // Format:
              //   *PCONTROL ‘APRTCN$ image‘
              //
              // After all bracketed references have been satisfied, use the image enclosed in quotation
              // marks as the print control image for an ER APRTCN$. To obtain a single quotation mark in
              // the print control image, use pairs of single quotation marks.

              //PsAstExprBase psPrintControlImage = new PsAstExprParenthesized(SymstreamExpressionToPowerShellExpression(lines[i].Substring(10), globalVariables, localVariables));
              // TODO: check out this ER APRTCN$ thingy and do what is needed.
              break;
              //throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // PROCESS
          case DirectiveId.Process: {

              // Format 1
              //   *PROCESS(,option) define-name (proc-para-1 proc-para-2 ...)
              //
              // Format 2
              //   *define-name (proc-para-1 proc-para-2 ...)

              // note: Format 2 will be dealt with in an "else if" below.

              Int32 firstSpace = lines[i].IndexOf(' ');
              String directiveAndAnyOptions = lines[i].Substring(0, firstSpace).Trim();
              Int32 firstComma = directiveAndAnyOptions.IndexOf(',');
              //String directive;
              String option = String.Empty;
              if (firstComma == -1) {
                //directive = directiveAndAnyOptions;
              } else {
                //directive = directiveAndAnyOptions.Substring(0, firstComma);
                option = directiveAndAnyOptions.Substring(firstComma + 1);
                if (!String.IsNullOrEmpty(option) && option != "A") {
                  throw new SymstreamException(String.Format("Unexpected option encountered on PROCESS directive: \"{0}\" (line {1}).", option, i));
                }
              }

              String name;
              String parameters = String.Empty;
              String[] splitParameters = Array.Empty<String>(); // new String[0];
              String nameAndParameters = lines[i].Substring(firstSpace + 1).Trim();
              firstSpace = nameAndParameters.IndexOf(' ');
              if (firstSpace == -1) {
                // no parameters
                name = nameAndParameters.Trim().ToUpperInvariant();
              } else {
                // it has parameters
                name = nameAndParameters.Substring(0, firstSpace).Trim().ToUpperInvariant();
                parameters = nameAndParameters.Substring(firstSpace + 1).Trim();
                if (!String.IsNullOrEmpty(parameters)) {
                  splitParameters = RemoveEmpty(parameters.Split(null));
                }
              }

              List<PsAstExprBase> parametersAsExpressions = new List<PsAstExprBase>();

              foreach (String parameter in splitParameters) {
                parametersAsExpressions.Add(new PsAstExprParenthesized(SymstreamExpressionToPowerShellExpression(parameter, globalVariables, localVariables)));
              }

              // it may be just a * in which case name will be empty, then ignore
              if (!String.IsNullOrEmpty(name)) {
                powerSkel.AddMethodInvoke(DefinePrefix + name, parametersAsExpressions);
              }

              break;
            }

          // REMOVE
          case DirectiveId.Remove: {
              //
              // The *REMOVE directive performs dynamic contraction of internal chains.
              //
              // Format 1:
              //   *REMOVE SGS sgs-label(,sgs-start-stmt(,number-to-remove))
              //
              // Format 2:
              //   *REMOVE {PERM|TEMP} element-name(/version-name) (FROM set-name)
              //
              // Format 3:
              //   *REMOVE VARIABLE variable-name
              //

              // note: Only format 1 is used in MW code.

              Int32 charBehindWord;
              String target = GetWord(lines[i], 8, out charBehindWord).ToUpperInvariant();

              if (target.Equals("SGS")) {

                String s = lines[i].Substring(charBehindWord).Trim();
                String[] parts = s.Split(',');

                List<PsAstExprBase> psParameters = new List<PsAstExprBase>();

                if (parts.Length > 0) {
                  psParameters.Add(SymstreamExpressionToPowerShellExpression(parts[0], globalVariables, localVariables));
                } else {
                  throw new SymstreamException(String.Format("No SGS label specified in *REMOVE directive (line {0}: {1}).", i, lines[i]));
                }

                if (parts.Length > 1) {
                  psParameters.Add(SymstreamExpressionToPowerShellExpression(parts[1], globalVariables, localVariables));
                } else {
                  psParameters.Add(SymstreamExpressionToPowerShellExpression("1", globalVariables, localVariables));
                }

                if (parts.Length > 2) {
                  psParameters.Add(SymstreamExpressionToPowerShellExpression(parts[2], globalVariables, localVariables));
                } else {
                  psParameters.Add(SymstreamExpressionToPowerShellExpression("1", globalVariables, localVariables));
                }

                powerSkel.AddMethodInvoke("RemoveFrom-SgsList", psParameters);
              } else if (target.Equals("VARIABLE")) {
                // remove the named variable from scope; subsequent references treat it as an unquoted string
                String varName = lines[i].Substring(charBehindWord).Trim().ToUpperInvariant();
                globalVariables.Remove(varName);
                powerSkel.AddComment(" Removed variable: " + varName);
              } else {
                throw new SymstreamException(String.Format("Target {0} for *REMOVE directive is not supported (line {1}).", target, i));
              }

              break;
            }

          // RESTORE []
          case DirectiveId.Restore: {
              // not used in STA sources
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // RETURN []
          case DirectiveId.Return: {
              // Format:
              //   *RETURN (STOP)
              //
              // If *RETURN is encountered in a define packet, control is returned to the statement
              // following the define packet call (*PROCESS). If *RETURN or *RETURN STOP is
              // encountered in the main skeleton or if *RETURN STOP is encountered in a define
              // packet, normal skeleton termination takes place. All remaining directives are skipped
              // and the generated output stream is handled as described in 2.4.
              //
              // note: Just a (PowerShell) return statement seems to do the right thing. It jumps out
              //       of any function if it is in a function and continue after the function call. It
              //       will also jump out of a dot-sourced code file and continue after the dot-source
              //       statement if it is not in a function.
              //
              powerSkel.AddMethodInvoke("return");
              break;
              //throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // SAVE []
          case DirectiveId.Save: {
              // not used in STA sources
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // SET []
          case DirectiveId.Set: {

              // Format 1
              //   *SET variable-name (TO number)
              //
              // Format 2
              //   *SET variable-name (TO 'string')
              //
              // An equal sign (=) can be used instead of the keyword TO.
              // *SET variable-name=number or SET variable-name='string' without spaces is possible.
              // If the TO or = phrase is omitted, number is assumed to be 1.

              String[] parts = SplitValuesKeepingSingleQuotedStringsTogether(lines[i]);

              if (parts.Length < 2) {
                throw new SymstreamException("Missing variable name on SET directive.");
              }

              // grab the variable identifier and the expression...
              String variableIdentifierAndExpression = lines[i].Substring(5).Trim();

              // ... and split them
              String target;
              String source = String.Empty;
              Int32 firstEqualSign = variableIdentifierAndExpression.IndexOf('=');
              Int32 firstTo = variableIdentifierAndExpression.IndexOf(" TO ", StringComparison.OrdinalIgnoreCase);
              if (firstEqualSign > -1) {
                target = variableIdentifierAndExpression.Substring(0, firstEqualSign).Trim();
                source = variableIdentifierAndExpression.Substring(firstEqualSign + 1).Trim();
              } else if (firstTo > -1) {
                target = variableIdentifierAndExpression.Substring(0, firstTo).Trim();
                source = variableIdentifierAndExpression.Substring(firstTo + 4).Trim();
              } else {
                target = variableIdentifierAndExpression;
              }

              // target may be a system variable
              if (IsSystemVariable(target)) {
                // it is, => update Symstream processor's status in addition to generating the assignment
                target = target.ToUpperInvariant();
                m_SystemVariables[target] = source;
              }

              // Target and/or Source can be a variable and both can also be an expression...
              if (IsVariableName(target)) {
                globalVariables.Add(target.ToUpperInvariant());
              }

              if (IsVariableName(source)) {
                globalVariables.Add(source.ToUpperInvariant());
              }

              // convert the source expression
              PsAstExprBase sourceExpr;
              if (String.IsNullOrEmpty(source)) {
                // it is a plain SET without explicit value, => variable must get integer value 1
                sourceExpr = new PsAstExprPrimitive("1");
              } else {
                sourceExpr = SymstreamExpressionToPowerShellExpression(source, globalVariables, localVariables);
              }

              // convert the target expression
              PsAstExprBase targetExpr = SymstreamExpressionToPowerShellExpression(target, globalVariables, localVariables);
              if (m_DefineDepth > 0 && IsVariableName(target)) {
                // SSG variables are global; a plain assignment inside a PowerShell function would only change a local copy.
                powerSkel.AddMethodInvoke("Set-Variable", SetVariableInCallerScope(target.ToUpperInvariant(), sourceExpr));
              } else {
                powerSkel.AddAssignment(targetExpr, sourceExpr);
              }
              break;
            }

          // SORT []
          case DirectiveId.Sort: {

              // Format:
              //   *SORT(,options) {SGS|TCF|PCF} (name)

              String s = String.Empty;

              // SORT options:
              //  A  Do not terminate in error if the item to sort does not exist.
              //  D  Sort the values in descending order.
              //  L  Sort across all fields.
              //  X  Sort numerically. The subfield values must be numeric characters.

              String options = String.Empty;
              if (lines[i][5].Equals(',')) {
                Int32 firstSpace = lines[i].IndexOf(' ', 6);
                options = lines[i].Substring(6, firstSpace - 6).ToUpperInvariant();
                s = lines[i].Substring(firstSpace).Trim();
              } else {
                s = lines[i].Substring(5).Trim();
              }

              String whatToSort = String.Empty;
              String name = String.Empty;
              Int32 followingSpace = s.IndexOf(' ');
              if (followingSpace > -1) {
                whatToSort = s.Substring(0, followingSpace).Trim().ToUpperInvariant();
                name = s.Substring(followingSpace).Trim();
              } else {
                whatToSort = s.Trim().ToUpperInvariant();
              }

              // we have options, whatToSort and name, => go
              switch (whatToSort) {

                case "SGS": {

                    // name format:
                    //   (label(,start-sgs(,start-field(,start-subfield))))

                    String[] subnames = name.Split(',');

                    // initialize parameters to default values
                    String label = String.Empty;
                    String startSgs = "0";
                    String startField = "0";
                    String startSubfield = "0";

                    // override default values with what was found
                    if (subnames.Length > 0) {
                      label = subnames[0];
                    }

                    if (subnames.Length > 1) {
                      startSgs = subnames[1];
                    }

                    if (subnames.Length > 2) {
                      startField = subnames[2];
                    }

                    if (subnames.Length > 3) {
                      startSubfield = subnames[3];
                    }

                    // generate function call
                    List<PsAstExprBase> psParameters = new List<PsAstExprBase>();
                    psParameters.Add(SymstreamExpressionToPowerShellExpression(options, globalVariables, localVariables));
                    psParameters.Add(SymstreamExpressionToPowerShellExpression(label, globalVariables, localVariables));
                    psParameters.Add(SymstreamExpressionToPowerShellExpression(startSgs, globalVariables, localVariables));
                    psParameters.Add(SymstreamExpressionToPowerShellExpression(startField, globalVariables, localVariables));
                    psParameters.Add(SymstreamExpressionToPowerShellExpression(startSubfield, globalVariables, localVariables));

                    powerSkel.AddMethodInvoke("Sort-SgsList", psParameters);

                    break;
                  }

                case "TCF": {
                    throw new SymstreamException(String.Format("Unsupported SORT target: {0}", whatToSort));
                    //break;
                  }

                case "PCF": {
                    throw new SymstreamException(String.Format("Unsupported SORT target: {0}", whatToSort));
                    //break;
                  }

                default: {
                    throw new SymstreamException(String.Format("Unrecognized SORT target: {0}", whatToSort));
                  }
              }

              break;
            }

          // UNLIST
          case DirectiveId.Unlist: {
              // not used in STA sources
              throw new SymstreamException(String.Format(Unexpected, directiveId, i));
            }

          // WAIT []
          case DirectiveId.Wait: {

              // Format:
              //   *WAIT arithmetic-expression
              //
              // The *WAIT directive allows delays to occur in skeleton processing.
              PsAstExprBase psSeconds = new PsAstExprParenthesized(SymstreamExpressionToPowerShellExpression(lines[i].Substring(6), globalVariables, localVariables));
              powerSkel.AddMethodInvoke("Start-Sleep", psSeconds);
              break;
            }

          default: {
              EmitNotImplemented(powerSkel, lines[i]);
              break;
            }
        }
      } else if (lines[i].StartsWith(String.Format("{0}/", m_DirectivePrefix))) {
        // note: This should be a change of the directive signifying character. We expect a single character
        //       behind the slash. This may be a space but we would probably have problems if it were so let
        //       us assume it must be a non-space character (no one would be as evil to use a space, right?).
        if (lines[i].Length < 3) {
          throw new SymstreamException(String.Format("Missing new directive signifying character behind slash."));
        } else {
          // we have at least one character behind the slash
          if (lines[i][2].Equals(' ')) {
            throw new SymstreamException(String.Format("You have got to be kidding (the new directive signifying character is a space)."));
          } else {
            // we should not have more than one character behind the slash
            String trimmed = lines[i].Trim();
            if (!trimmed.Length.Equals(3)) {
              throw new SymstreamException(String.Format("Additional non-whitespace characters found after new directive signifying character."));
            }

            // we're good
            m_DirectivePrefix = lines[i].Substring(2, 1);
          }
        }
      } else if (lines[i].StartsWith(m_SystemVariables["NSIGNCHAR$"]) && m_SystemVariables["NSIGN$"].Equals("0")) {
        // it is ECL, => read everything until the next directive and delegate the conversion to context
        List<String> eclLines = new List<String>();
        while (i < lines.Count && ((!lines[i].StartsWith(m_DirectivePrefix) && !lines[i].StartsWith("[")) || IsComment(lines[i], m_DirectivePrefix, out commentTextStart))) {

          if (lines[i].StartsWith(m_SystemVariables["NSIGNCHAR$"])) {
            eclLines.Add(lines[i]);

            // if this is the start of an @IPF command, read everything until LOGOFF
            if (lines[i].StartsWith(String.Format("{0}IPF", m_SystemVariables["NSIGNCHAR$"])) && (lines[i].Length == 4 || !Char.IsLetter(lines[i][4]))) {
              Int32 ipfLineIndex = i;
              while (!lines[i].Trim().StartsWith("LOGOFF", StringComparison.OrdinalIgnoreCase)) {
                i++;

                if (i == lines.Count) {
                  throw new SymstreamException(String.Format("Unterminated IPF statement encountered on line {0} (a LOGOFF is expected somewhere down).", ipfLineIndex));
                }

                eclLines.Add(lines[i].Trim());
              }
            }
          } else if (IsComment(lines[i], m_DirectivePrefix, out commentTextStart)) {
            // it is a Symstream comment, we want to replace that with an ECL comment
            String line = "@ . " + lines[i].Substring(commentTextStart).Trim();
            eclLines.Add(line);
          } else {
            eclLines.Add(lines[i].Trim());
          }
          i++;
        }

        PsAstInstrBlock eclBlock = m_ContentLineConverter.Convert(eclLines.AsReadOnly(), m_FileBeingMigrated);
        if (eclBlock != null) {
          powerSkel.AddInstrBlock(eclBlock);
        } else {
          powerSkel.AddComment(" Embedded content (unconverted):");
          foreach (String eclLine in eclLines) {
            powerSkel.AddComment("   " + eclLine);
          }
        }

        // caller will increment i thus skipping the next directive, => set i one back
        i--;
      } else if (lines[i].StartsWith("[")) {
        powerSkel.AddComment(" This was a stand-alone bracketed reference line.");
        PsAstExprBase psDataLine = OutputLineToPowerShellExpression(lines[i], globalVariables, localVariables);

        powerSkel.AddMethodInvoke("DataLineOrNoStatement", psDataLine);

      } else if (IsComment(lines[i], m_DirectivePrefix, out commentTextStart)) {
        powerSkel.AddComment(lines[i].Substring(commentTextStart));
      } else if (lines[i].StartsWith(m_DirectivePrefix)) {
        // it should be a DEFINE call (*PROCESS) without the explicit *PROCESS directive:
        //
        // Format 2
        //   *define-name (proc-para-1 proc-para-2 ...)
        // .
        String name = String.Empty;
        String parameters = String.Empty;
        String[] splitParameters = Array.Empty<String>(); // new String[0];
        String nameAndParameters = lines[i].Substring(1).Trim();
        Int32 firstSpace = nameAndParameters.IndexOf(' ');
        if (firstSpace == -1) {
          // no parameters
          name = DefinePrefix + nameAndParameters.Trim().ToUpperInvariant();
        } else {
          // it has parameters
          name = DefinePrefix + nameAndParameters.Substring(0, firstSpace).Trim().ToUpperInvariant();
          parameters = nameAndParameters.Substring(firstSpace + 1).Trim();
          if (!String.IsNullOrEmpty(parameters)) {
            splitParameters = RemoveEmpty(parameters.Split(null));
          }
        }

        List<PsAstExprBase> parametersAsExpressions = new List<PsAstExprBase>();

        foreach (String parameter in splitParameters) {
          parametersAsExpressions.Add(new PsAstExprParenthesized(SymstreamExpressionToPowerShellExpression(parameter, globalVariables, localVariables)));
        }

        // it may be just a * in which case name will be just the define prefix, then ignore
        if (!name.Equals(DefinePrefix)) {
          powerSkel.AddMethodInvoke(name, parametersAsExpressions);
        }
      } else if (!String.IsNullOrEmpty(lines[i])) {
        // Plain text output line (not a directive, not ECL, not a standalone bracket reference).
        // In Symstream, any non-directive line is an output statement written to the generated stream
        // (SSG manual 78311784-010 sec 4.3), including whitespace-only (blank) images - see T3-001.
        // Emit it as literal text with only [bracketed] references substituted - never parse the
        // COBOL/text as an arithmetic expression (that produced invalid PowerShell).
        PsAstExprBase psOutputLine = OutputLineToPowerShellExpression(lines[i], globalVariables, localVariables);
        if (!m_UsesEdit) {
          powerSkel.AddMethodInvoke("DataLineOrNoStatement", psOutputLine);
        } else {
          // T3-045: in edit mode the part before the edit symbol is appended to the image being built; an image without the
          // edit symbol is appended whole, output, and ends edit mode. Outside edit mode the image is output as is.
          Int32 symPos = lines[i].IndexOf(m_EditSymbol, StringComparison.Ordinal);
          PsAstInstrIf editIf = powerSkel.AddIf(EdtVar("Edt_On"));
          if (symPos >= 0) {
            if (symPos > 0) {
              editIf.IfPart.AddAssignment(EdtVar("Edt_Buf"), OutputLineToPowerShellExpression(lines[i].Substring(0, symPos), globalVariables, localVariables), PSAstOperatorType.Add);
            }
          } else {
            editIf.IfPart.AddAssignment(EdtVar("Edt_Buf"), OutputLineToPowerShellExpression(lines[i], globalVariables, localVariables), PSAstOperatorType.Add);
            editIf.IfPart.AddMethodInvoke("DataLineOrNoStatement", EdtVar("Edt_Buf"));
            editIf.IfPart.AddAssignment(EdtVar("Edt_On"), new PsAstExprPrimitive("0", false));
            editIf.IfPart.AddAssignment(EdtVar("Edt_Buf"), new PsAstExprPrimitive("", true));
          }
          editIf.ElsePart.AddMethodInvoke("DataLineOrNoStatement", psOutputLine);
        }
      }

      return powerSkel;
    } // Convert

    /// <summary>
    /// Tells whether the provided identifier denotes a reserved global variable or not.
    /// </summary>
    /// <param name="identifier">The identifier for which to assess whether it is the name of a known reserved global variable or not.</param>
    /// <returns>A value indicating whether the provided identifier denotes a reserved global variable or not.</returns>
    private Boolean IsSystemVariable (String identifier) {
      return m_SystemVariables.ContainsKey(identifier.ToUpperInvariant());
    } // IsSystemVariable
  } // Class SymstreamProcessor
} // namespace Ecl.SsgConverter
