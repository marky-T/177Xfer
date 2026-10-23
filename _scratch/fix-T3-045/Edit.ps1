# Converter fix T3-045: *EDIT ON ... *EDIT OFF blocks of plain text images were dropped (SCAN's IF statement, 12 of 19 calls).
#   Manual 78311784-010 sec 5.2.16 (format 1, EDITAB$ = 0): in edit mode every nondirective image is cut at the edit symbol
#   (default &) and appended to one output image; an image without the edit symbol is appended whole and ends edit mode;
#   *EDIT OFF outputs the image built so far; directives (*IF, *INCREMENT, *EDIT OFF ...) run while editing, so edit mode is
#   switched on and off at run time. Generated: $Edt_On / $Edt_Buf, and every data line of such a skeleton tests $Edt_On.
#   Blocks that contain ECL images (#ACOB ... &) keep the old behaviour (consumed, nothing emitted), so BABA, CFH-COPY, FUSBA and
#   FUSBA2 are unchanged. Not done: IMGLEN$ overflow (automatic ';' split), format 2 (EDITAB$ nonzero), edit-mode *CREATE images.
param([Parameter(Mandatory)][String]$SrcDir)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path 'E:\Repos\SsgTrial\SsgConverter\Trials\ConverterFix' 'ConverterFixLib.psm1') -Force
$proc = Join-Path $SrcDir 'SsgConverter\SymstreamProcessor.cs'

Edit-SourceFile -Path $proc -Old @'
private String m_DirectivePrefix = "*";
'@ -New @'
private String m_DirectivePrefix = "*";
    private String m_EditSymbol = "&";
    private Boolean m_UsesEdit = false;
'@

Edit-SourceFile -Path $proc -Old @'
      lines = CondenseDirectives(lines, m_DirectivePrefix);
'@ -New @'
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
'@

Edit-SourceFile -Path $proc -Old @'
} // IsEditOffDirective
'@ -New @'
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
'@

Edit-SourceFile -Path $proc -Old @'
              String line = lines[i];
              String s;

              // note: We are assuming EDITAB$ to be zero (no tabs)
'@ -New @'
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
'@

Edit-SourceFile -Path $proc -Old @'
              StringBuilder sb = new StringBuilder();
              i++;
'@ -New @'
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
'@

Edit-SourceFile -Path $proc -Old @'
        PsAstExprBase psOutputLine = OutputLineToPowerShellExpression(lines[i], globalVariables, localVariables);
        powerSkel.AddMethodInvoke("DataLineOrNoStatement", psOutputLine);
'@ -New @'
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
'@
