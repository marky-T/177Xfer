param([Parameter(Mandatory)][String]$File)
# Applies the "define bodies assign in the caller's scope" change to SymstreamProcessor.cs. Idempotent.
$ErrorActionPreference = 'Stop'
$t = [System.IO.File]::ReadAllText($File)
if ($t.Contains('SetVariableInCallerScope')) { 'already patched'; return }
$nl = if ($t.Contains("`r`n")) { "`r`n" } else { "`n" }
function Fix([String]$s) { $s -replace "`r?`n", $nl }
function Replace-Once([String]$old, [String]$new) {
  $old = Fix $old; $new = Fix $new
  $i = $script:t.IndexOf($old)
  if ($i -lt 0) { throw "Anchor not found: $($old.Substring(0, [Math]::Min(60, $old.Length)))" }
  $script:t = $script:t.Substring(0, $i) + $new + $script:t.Substring($i + $old.Length)
}

Replace-Once @'
    private Stack<String> m_InnerMostLoopVariable = new Stack<String>();
    private String m_DirectivePrefix = "*";
'@ @'
    private Stack<String> m_InnerMostLoopVariable = new Stack<String>();
    private Int32 m_DefineDepth = 0;
    private String m_DirectivePrefix = "*";
'@

Replace-Once @'
    private static readonly DirectiveId[] m_DirectiveIds = (DirectiveId[])Enum.GetValues(typeof(DirectiveId));
'@ @'
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
'@

Replace-Once @'
              i++;
              DirectiveId endDefId;
              for (; i < lines.Count; i++) {
'@ @'
              i++;
              DirectiveId endDefId;
              m_DefineDepth++;
              for (; i < lines.Count; i++) {
'@

Replace-Once @'
                define.Body.AddInstrBlock(Convert(lines, ref i, globalVariables));
              }
'@ @'
                define.Body.AddInstrBlock(Convert(lines, ref i, globalVariables));
              }
              m_DefineDepth--;
'@

Replace-Once @'
              powerSkel.AddAssignment(
                new PsAstExprPrimitive(variableName, PsAstPrimitiveType.LocalObject),
                new PsAstExprPrimitive("0", false, PsAstPrimitiveType.Normal));
'@ @'
              if (m_DefineDepth > 0) {
                powerSkel.AddMethodInvoke("Set-Variable", SetVariableInCallerScope(variableName, new PsAstExprPrimitive("0", false, PsAstPrimitiveType.Normal)));
              } else {
                powerSkel.AddAssignment(
                  new PsAstExprPrimitive(variableName, PsAstPrimitiveType.LocalObject),
                  new PsAstExprPrimitive("0", false, PsAstPrimitiveType.Normal));
              }
'@

Replace-Once @'
              PsAstExprBase targetExpr = SymstreamExpressionToPowerShellExpression(target, globalVariables, localVariables);
              powerSkel.AddAssignment(targetExpr, sourceExpr);
'@ @'
              PsAstExprBase targetExpr = SymstreamExpressionToPowerShellExpression(target, globalVariables, localVariables);
              if (m_DefineDepth > 0 && IsVariableName(target)) {
                // SSG variables are global; a plain assignment inside a PowerShell function would only change a local copy.
                powerSkel.AddMethodInvoke("Set-Variable", SetVariableInCallerScope(target.ToUpperInvariant(), sourceExpr));
              } else {
                powerSkel.AddAssignment(targetExpr, sourceExpr);
              }
'@

[System.IO.File]::WriteAllText($File, $t)
'patched ' + $File
