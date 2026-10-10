<#
.SYNOPSIS
  Strips SSG directives and substitutes inline SSG [param] tokens with
  stub COBOL literals so the output file can be parsed by CobolConverter.

.DESCRIPTION
  Two classes of SSG constructs are handled:

    1. Whole-line SSG control lines — stripped entirely:
         Lines whose trimmed content starts with:
           *DEFINE  *SET  *END  *INCREMENT  *LOOP  *PROCESS
           *IF  *ELSE  *CLEAR  *MULTIPLY  *DIVIDE  *ADD  *SUBTRACT
           @UCOB    #ucob,is    #ERS    #ACOB

         Note: #ucob,is is the ARCHITAB1-style inline COBOL compile header (OS2200
         UCOBol inline directive).  It is stripped so that CobolConverter sees plain
         COBOL starting at the Identification Division.

    2. Inline SSG tokens embedded in COBOL — replaced with stub literals.
         Default substitutions (MONTANT_SIGNE baseline):
           [*I]           → 1        (loop subscript, part of identifier name)
           [*FILLUN]      → 1        (computed filler from FILUN macro)
           [*FILLDEU]     → 1        (computed filler from FILDEU macro)
           [*FIL1]        → 1        (COMPARE2 family)
           [*FIL2]        → 1        (COMPARE2 family)
           [*PAS]         → 1        (PAS macro result)
           [INPUT,1,1,1]  → FILEIN-1 (input file designator)
           [INPUT,1,1,2]  → 80       (input record length)
           [INPUT,1,1,3]  → 1        (input block factor)
           [OUTPUT,1,1,1] → FILEOUT-1 (output file designator)
           [OUTPUT,1,1,2] → 80       (output record length)
           [OUTPUT,1,1,3] → 1        (output block factor)
           [MONTANT,I,1,1]→ 1        (field start position stub)
           [MONTANT,I,1,2]→ 9        (field length stub)
           [MONTANT]      → 1        (loop count stub)
           Generic [WORD,N,N,N] → 1  (catch-all numeric)
           Generic [WORD]       → 1  (catch-all word-token)

         Use -ParamOverrides to supply program-specific values that replace
         or extend the defaults before the generic catch-alls run.

  When -ConditionValues is also supplied, *IF/*ELSE/*END blocks are evaluated
  and only the winning branch is emitted — no duplicate field definitions.
  Without -ConditionValues the legacy "emit all branches" behaviour applies.

.PARAMETER InputFile
  Raw SSG-COBOL source file (.txt).

.PARAMETER OutputFile
  Destination — clean COBOL file (.txt).

.PARAMETER ParamOverrides
  Optional hashtable of program-specific [TOKEN] = value pairs for inline
  COBOL text substitution.  Keys are plain tokens with brackets.

.PARAMETER ConditionValues
  Optional hashtable of param-name = numeric-value pairs used to evaluate
  *IF conditions.  Keys are bare names WITHOUT brackets.
  When supplied, only the true branch of each *IF is emitted.
  Also suppresses *INCREMENT loop bodies when the count param = 0.

.PARAMETER AnnotateStubs
  Switch.  When set, each output line that had one or more inline token
  substitutions will have   *> SSG-STUB [original-token]  appended.
  This marks every ECL-parameter-derived literal so it can be located and
  replaced with real production values.  Mandatory from Trial 07 (ARCHITAB1)
  onwards.  Not applied to Trials 03-06 (direct substitution only).
  Stub names used as substitution VALUES should be ECL-prefixed COBOL
  identifiers e.g. ECL-FNAME, ECL-TNAME1 — supplied via -ParamOverrides.

  Example for LECTIS_MULT (sequential stub):
    -ParamOverrides @{
        '[INPUT,1,1,1]' = 'FICHIN-1'
        '[INPUT,1,1,2]' = '120'
        '[INPUT,1,1,3]' = '1'
        '[LKEY,1,1,2]'  = '8'
        '[LKEY,2,1,2]'  = '4'
    } `
    -ConditionValues @{
        'ASCII'   = 1
        'LKEY'    = 2
        'KEYS'    = 0
        'NOLIST'  = 0
        'UN'      = 1
        'DEUX'    = 0
        'TROIS'   = 0
        'Y2K'     = 0
        'COND,1'  = 0
    }

.EXAMPLE
  .\Remove-SsgDirectives.ps1 -InputFile "...\MONTANT_SIGNE(P).TXT" -OutputFile "...\candidates\trial-04-montant\MONTANT.TXT"

.EXAMPLE
  # LECTIS with full branch evaluation — no duplicate definitions:
  .\Remove-SsgDirectives.ps1 `
    -InputFile "...\ASSURFED_UTILIT_LECTIS_MULT(P).TXT" `
    -OutputFile "...\candidates\trial-05-lectis\LECTIS.TXT" `
    -ParamOverrides @{ '[INPUT,1,1,1]'='FICHIN-1'; '[INPUT,1,1,2]'='120'; '[LKEY,1,1,2]'='8'; '[LKEY,2,1,2]'='4' } `
    -ConditionValues @{ 'ASCII'=1; 'LKEY'=2; 'KEYS'=0; 'NOLIST'=0; 'UN'=1; 'DEUX'=0; 'TROIS'=0; 'Y2K'=0; 'COND,1'=0 }
#>
param(
    [Parameter(Mandatory)][string]$InputFile,
    [Parameter(Mandatory)][string]$OutputFile,
    [hashtable]$ParamOverrides   = @{},
    [hashtable]$ConditionValues  = @{},   # bare param names → numeric values for *IF evaluation
    [switch]$AnnotateStubs               # when set, append  *> SSG-STUB [token]  to substituted lines
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Evaluate a *SET expression: literal or [token] values with + or - ──────────────────
# Returns [int]. Handles: [param] OP [param], literal OP [param], [param] alone.
function Eval-SsgSetExpr([string]$expr, [hashtable]$pOvr, [hashtable]$cVals) {
    $expr = $expr.Trim()
    function Resolve-T([string]$tok) {
        $tok = $tok.Trim()
        if ($tok -match '^\[\*([A-Za-z][A-Za-z0-9_-]*)\]$') {
            if ($cVals.ContainsKey($matches[1])) { return [int]$cVals[$matches[1]] }
            return 0
        }
        if ($tok -match '^\[([^\]]+)\]$') {
            if ($pOvr.ContainsKey($tok)) { return [int]$pOvr[$tok] }
            return 0
        }
        if ($tok -match '^[0-9]+$') { return [int]$tok }
        return 0
    }
    # Tokenise by splitting on + / - outside brackets, then fold left.
    $tokens = [System.Collections.Generic.List[string]]::new()
    $ops    = [System.Collections.Generic.List[string]]::new()
    $depth  = 0; $cur = ''
    for ($i = 0; $i -lt $expr.Length; $i++) {
        $c = $expr[$i]
        if     ($c -eq '[')                             { $depth++; $cur += $c }
        elseif ($c -eq ']')                             { $depth--; $cur += $c }
        elseif (($c -eq '+' -or $c -eq '-') -and $depth -eq 0) {
            $tokens.Add($cur.Trim()); $ops.Add([string]$c); $cur = ''
        }
        else                                            { $cur += $c }
    }
    $tokens.Add($cur.Trim())
    $result = Resolve-T $tokens[0]
    for ($i = 0; $i -lt $ops.Count; $i++) {
        $v = Resolve-T $tokens[$i + 1]
        if ($ops[$i] -eq '+') { $result += $v } else { $result -= $v }
    }
    return $result
}

if (-not (Test-Path $InputFile)) {
    Write-Error "Input file not found: $InputFile"
    exit 1
}

$lines    = Get-Content $InputFile -Encoding UTF8
$out      = [System.Collections.Generic.List[string]]::new()
$stripped = 0
$replaced = 0

# ── Build ordered token map: program-specific overrides merge before catch-alls ─
$specificMap = [ordered]@{
    '\[\*I\]'              = '1'          # [*I]
    '\[\*FILLUN\]'         = '1'          # [*FILLUN]
    '\[\*FILLDEU\]'        = '1'          # [*FILLDEU]
    '\[\*FIL1\]'           = '1'          # [*FIL1]
    '\[\*FIL2\]'           = '1'          # [*FIL2]
    '\[\*PAS\]'            = '1'          # [*PAS]
    '\[INPUT,1,1,1\]'      = 'FILEIN-1'
    '\[INPUT,1,1,2\]'      = '80'
    '\[INPUT,1,1,3\]'      = '1'
    '\[INPUT,1,1,4\]'      = '80'
    '\[OUTPUT,1,1,1\]'     = 'FILEOUT-1'
    '\[OUTPUT,1,1,2\]'     = '80'
    '\[OUTPUT,1,1,3\]'     = '1'
    '\[OUTPUT,1,1,4\]'     = '80'
    '\[MONTANT,I,1,1\]'    = '1'
    '\[MONTANT,I,1,2\]'    = '9'
    '\[MONTANT\]'          = '1'
    '\[ASCII\]'            = '1'
    '\[LABELOMIT\]'        = '0'
}
# Merge caller overrides into the specific map (keys supplied as plain [TOKEN]).
# Escape only [ and ] — commas are not regex metacharacters in our token patterns.
foreach ($kvp in $ParamOverrides.GetEnumerator()) {
    $escapedKey = $kvp.Key -replace '\[', '\[' -replace '\]', '\]'
    $specificMap[$escapedKey] = $kvp.Value
}
# Pre-pass: evaluate *SET computed-var directives so [*varname] tokens resolve correctly
# Must run AFTER ParamOverrides are merged into specificMap but BEFORE tokenMap is built.
$computedVarValues = @{}
foreach ($preLine in $lines) {
    $pt = $preLine.TrimStart()
    if ($pt -match '^\*[Ss][Ee][Tt]\s+([A-Za-z][A-Za-z0-9_-]*)\s*=\s*(.+)$') {
        $vn  = $matches[1]
        $val = Eval-SsgSetExpr $matches[2].Trim() $ParamOverrides $computedVarValues
        $computedVarValues[$vn] = $val
        $specificMap['\[\*' + $vn + '\]'] = "$val"
    }
}

# Final token map: specifics first, then generic catch-alls
$tokenMap = [ordered]@{}
foreach ($kvp in $specificMap.GetEnumerator()) { $tokenMap[$kvp.Key] = $kvp.Value }
# Case-insensitive: ARCHITAB1 and other programs use lowercase token names e.g. [fname,1,1,1]
$tokenMap['\[[A-Za-z][A-Za-z0-9_-]*,[0-9],[0-9],[0-9]\]'] = '1'
$tokenMap['\[[A-Za-z][A-Za-z0-9_-]*,[0-9],[0-9]\]']       = '1'
$tokenMap['\[[A-Za-z][A-Za-z0-9_-]*,[0-9]\]']             = '1'
# Broader catch-all: tokens with mixed alphanumeric/comma segments (e.g. [COND,1,I,1])
$tokenMap['\[[A-Za-z][A-Za-z0-9_-]*(?:,[A-Za-z0-9_]+)+\]'] = '1'
$tokenMap['\[\*[A-Za-z][A-Za-z0-9_-]*\]']                 = '1'
$tokenMap['\[[A-Za-z][A-Za-z0-9_-]*\]']                   = '1'

# ── Condition stack helpers (used when -ConditionValues is supplied) ──────────────────
function Resolve-SsgCondition([string]$ifLine) {
    # Evaluates:  *IF [PARAM] OP VALUE   (OP = > >= = <= <> <)
    if ($ifLine -match '^\*IF\s+\[([^\]]+)\]\s*(>|>=|=|<=|<>|<)\s*([0-9]+)') {
        $name  = $matches[1]
        $op    = $matches[2]
        $rhs   = [int]$matches[3]
        $lhs   = if ($ConditionValues.ContainsKey($name)) { [int]$ConditionValues[$name] } else { 0 }
        switch ($op) {
            '>'  { return $lhs -gt $rhs }
            '>=' { return $lhs -ge $rhs }
            '='  { return $lhs -eq $rhs }
            '<=' { return $lhs -le $rhs }
            '<>' { return $lhs -ne $rhs }
            '<'  { return $lhs -lt $rhs }
        }
    }
    # String-string OR: *IF [P1] = WORD1 OR [P2] = WORD2  (must precede single-string handler)
    if ($ifLine -match '^\*IF\s+\[([^\]]+)\]\s*=\s*([A-Z][A-Z0-9_-]*)\s+OR\s+\[([^\]]+)\]\s*=\s*([A-Z][A-Z0-9_-]*)') {
        $p1 = $matches[1]; $w1 = $matches[2]
        $p2 = $matches[3]; $w2 = $matches[4]
        $l1 = if ($ParamOverrides.ContainsKey("[$p1]")) { $ParamOverrides["[$p1]"] } else { '' }
        $l2 = if ($ParamOverrides.ContainsKey("[$p2]")) { $ParamOverrides["[$p2]"] } else { '' }
        return ($l1 -eq $w1 -or $l2 -eq $w2)
    }
    # String equality: *IF [PARAM] = WORD  (e.g. *IF [INPUT,1,A,1] = CARDREADER)
    if ($ifLine -match '^\*IF\s+\[([^\]]+)\]\s*=\s*([A-Z][A-Z0-9_-]*)') {
        $paramName = $matches[1]
        $rhs       = $matches[2]
        $paramKey  = "[$paramName]"
        $lhsVal    = if ($ParamOverrides.ContainsKey($paramKey)) { $ParamOverrides[$paramKey] } else { '' }
        return ($lhsVal -eq $rhs)
    }
    # OR condition: *IF [P1] OP V OR [P2] OP V  (e.g. *IF [UN] > 0 OR [DEUX] > 0)
    if ($ifLine -match '^\*IF\s+\[([^\]]+)\]\s*(>|>=|=|<=|<>|<)\s*([0-9]+)\s+OR\s+\[([^\]]+)\]\s*(>|>=|=|<=|<>|<)\s*([0-9]+)') {
        $n1 = $matches[1]; $op1 = $matches[2]; $v1 = [int]$matches[3]
        $l1 = if ($ConditionValues.ContainsKey($n1)) { [int]$ConditionValues[$n1] } else { 0 }
        $r1 = switch ($op1) { '>' { $l1 -gt $v1 } '>=' { $l1 -ge $v1 } '=' { $l1 -eq $v1 } '<=' { $l1 -le $v1 } '<>' { $l1 -ne $v1 } '<' { $l1 -lt $v1 } default { $false } }
        $n2 = $matches[4]; $op2 = $matches[5]; $v2 = [int]$matches[6]
        $l2 = if ($ConditionValues.ContainsKey($n2)) { [int]$ConditionValues[$n2] } else { 0 }
        $r2 = switch ($op2) { '>' { $l2 -gt $v2 } '>=' { $l2 -ge $v2 } '=' { $l2 -eq $v2 } '<=' { $l2 -le $v2 } '<>' { $l2 -ne $v2 } '<' { $l2 -lt $v2 } default { $false } }
        return ($r1 -or $r2)
    }
    # Bare condition: *IF [PARAM]  (no operator — tests if PARAM is non-zero / set)
    if ($ifLine -match '^\*IF\s+\[([^\]]+)\]\s*$') {
        $name = $matches[1]
        if ($ConditionValues.ContainsKey($name)) { return ([int]$ConditionValues[$name] -ne 0) }
        return $true   # not in conditionValues: safe-emit (treat as set)
    }
    return $true   # unparseable condition: safe-emit
}

# Stack entries: @{ parentEmitting=[bool]; conditionTrue=[bool] }
$condStack         = [System.Collections.Generic.Stack[hashtable]]::new()
$suppressIncrement = 0   # nesting depth of 0-count *INCREMENT blocks
$inDefineBlock     = $false   # true while processing a *DEFINE macro body (suppress content)
$defineIfDepth     = 0         # nesting depth of *IF within the current *DEFINE block

function Get-IsEmitting {
    if ($condStack.Count -eq 0) { return $true }
    $t = $condStack.Peek()
    return $t.parentEmitting -and $t.conditionTrue
}

$useCondEval = ($ConditionValues.Count -gt 0)
$inLinkBlock = $false

foreach ($line in $lines) {
    $trimmed = $line.TrimStart()

    # ── 1. Whole-line SSG control directives ───────────────────────────────

    # *DEFINE — start of macro definition; suppress all content until matching *END
    if ($trimmed -match '^\*DEFINE\b') {
        $inDefineBlock = $true
        $defineIfDepth = 0
        $stripped++; continue
    }
    # While inside a *DEFINE block, strip everything (track nested *IF for correct *END matching)
    if ($inDefineBlock) {
        if    ($trimmed -match '^\*IF\b')  { $defineIfDepth++ }
        elseif ($trimmed -match '^\*END(?:IF)?\b') {
            if ($defineIfDepth -gt 0) { $defineIfDepth-- }
            else                      { $inDefineBlock = $false }
        }
        $stripped++; continue
    }

    # *IF — push condition onto stack (or just strip if not doing branch eval)
    if ($trimmed -match '^\*IF\b') {
        if ($useCondEval) {
            $parent  = Get-IsEmitting
            $result  = Resolve-SsgCondition $trimmed
            $condStack.Push(@{ parentEmitting = $parent; conditionTrue = $result; branchTaken = $result })
        }
        $stripped++; continue
    }
    # *ELSEIF — evaluate only if no branch has been taken yet on this *IF
    if ($trimmed -match '^\*ELSEIF\b') {
        if ($useCondEval -and $condStack.Count -gt 0) {
            $top = $condStack.Pop()
            if ($top.branchTaken) {
                $condStack.Push(@{ parentEmitting = $top.parentEmitting; conditionTrue = $false; branchTaken = $true })
            } else {
                $cond = Resolve-SsgCondition ($trimmed -replace '^\*ELSEIF\b', '*IF')
                $condStack.Push(@{ parentEmitting = $top.parentEmitting; conditionTrue = $cond; branchTaken = $cond })
            }
        }
        $stripped++; continue
    }
    # *ELSE — take branch only if no branch has been taken yet on this *IF
    if ($trimmed -match '^\*ELSE\b') {
        if ($useCondEval -and $condStack.Count -gt 0) {
            $top = $condStack.Pop()
            if ($top.branchTaken) {
                $condStack.Push(@{ parentEmitting = $top.parentEmitting; conditionTrue = $false; branchTaken = $true })
            } else {
                $condStack.Push(@{ parentEmitting = $top.parentEmitting; conditionTrue = $true; branchTaken = $true })
            }
        }
        $stripped++; continue
    }
    # *END / *ENDIF — pop stack  (ECLAT uses *ENDIF; other programs use *END)
    if ($trimmed -match '^\*END(?:IF)?\b') {
        if ($useCondEval -and $condStack.Count -gt 0) { $condStack.Pop() | Out-Null }
        $stripped++; continue
    }
    # *INCREMENT — suppress body if count param = 0
    if ($trimmed -match '^\*INCREMENT\b') {
        if ($useCondEval -and $trimmed -match 'TO\s+\[([^\]]+)\]') {
            $countName = $matches[1]
            $countVal  = if ($ConditionValues.ContainsKey($countName)) { [int]$ConditionValues[$countName] } else { 1 }
            if ($countVal -eq 0) { $suppressIncrement++ }
        }
        $stripped++; continue
    }
    # *LOOP — end of *INCREMENT body
    if ($trimmed -match '^\*LOOP\b') {
        if ($suppressIncrement -gt 0) { $suppressIncrement-- }
        $stripped++; continue
    }
    # All other directive lines — strip unconditionally
    if ($trimmed -match '^\*(DEFINE|SET|PROCESS|CLEAR|MULTIPLY|DIVIDE|ADD|SUBTRACT|EDIT)\b' -or
        $trimmed -match '^\*(BRKPT|SORT|EXIT|ITERATE|ABORT|DISPLAY|MESSAGE)\b' -or
        $trimmed -match '^\*\.'  -or     # SSG comment lines (*. text)
        $trimmed -match '^@UCOB\b' -or
        $trimmed -match '^#ucob\b' -or    # #ucob,is — ARCHITAB1 inline COBOL compile header
        $trimmed -match '^#(ERS|ACOB|MAP|HDG|ASG|USE|LINK|FREE|DELETE|CAT|XQT|TIME)\b') {
        # #LINK transitions us into/out of linker-control-statement territory
        if ($trimmed -match '^#LINK\b')  { $inLinkBlock = $true  }
        if ($trimmed -match '^#FREE\b' -or $trimmed -match '^#(XQT|DELETE)\b') { $inLinkBlock = $false }
        $stripped++; continue
    }
    # Strip linker-control lines (INCLUDE, OUTPUT, RESOLVE, SET, DELETE, PROCESS) inside #LINK...#FREE
    if ($inLinkBlock) { $stripped++; continue }

    # ── Skip lines inside false branches or suppressed *INCREMENT bodies ──────────────
    if ($useCondEval -and (-not (Get-IsEmitting) -or $suppressIncrement -gt 0)) {
        $stripped++; continue
    }

    # ── 2. Inline SSG token substitution ────────────────────────────────────
    $orig     = $line
    $stubList = [System.Collections.Generic.List[string]]::new()
    foreach ($kvp in $tokenMap.GetEnumerator()) {
        if ($line -match $kvp.Key) {
            if ($AnnotateStubs) {
                # Collect the literal text of every match before replacing
                [regex]::Matches($line, $kvp.Key) | ForEach-Object { $stubList.Add($_.Value) }
            }
            $line = $line -replace $kvp.Key, $kvp.Value
        }
    }
    if ($line -ne $orig) { $replaced++ }
    if ($AnnotateStubs -and $stubList.Count -gt 0) {
        $line = $line.TrimEnd() + '  *> SSG-STUB ' + ($stubList -join ', ')
    }
    $out.Add($line)
}

# ── Write output ─────────────────────────────────────────────────────────────
$outDir = Split-Path $OutputFile -Parent
if ($outDir -and -not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Force $outDir | Out-Null
}

$out | Set-Content $OutputFile -Encoding UTF8

Write-Host "  Source  : $InputFile"
Write-Host "  Output  : $OutputFile"
Write-Host "  Lines   : $($lines.Count) in  →  $($out.Count) out"
Write-Host "  Stripped: $stripped SSG control lines"
Write-Host "  Replaced: $replaced lines with inline token substitutions"
