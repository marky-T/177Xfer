#-------------------------------------------------------------------------------
# SsgPsMockLib - Tier-1 mock-shell for SsgConverter-generated PowerShell scripts
#-------------------------------------------------------------------------------
# Stands in for the real AMT PowerShell ECL runtime (AmtPsEclLib.psm1) so a
# converted .ps1 can run standalone against a mocked SGS parameter table, with
# no live AMT/COM/BatchController connection. Mirrors the "Tier 1 - mock-shell"
# concept already proven for the COBOL->C# stream (see
# docs/SSG-ECL-PowerShell-Reference.html #execution-model).
#
# Only implements the small set of runtime primitives SsgConverter's generated
# scripts actually call: GetSgsValue, DataLineOrNoStatement, CompareTypeSafe,
# Process-Skip, Call-ExternalProgram, Fin, Abort, AddTo-SgsList,
# RemoveFrom-SgsList, Sort-SgsList.
#-------------------------------------------------------------------------------

# Reset-SgsMock must be called before each run so results never leak between trials.
function Reset-SgsMock {
  param(
    [Hashtable]$Values = @{}
  )

  # PowerShell hashtables are case-insensitive for string keys by default -
  # matches the generated scripts' inconsistent key casing (e.g. "Y2K" vs "y2k,$a,$B,2").
  $global:SgsValues        = @{}
  foreach ($key in $Values.Keys) {
    $global:SgsValues[$key] = $Values[$key]
  }

  $global:EmittedLines      = New-Object System.Collections.Generic.List[string]
  $global:SgsMockWarnings   = New-Object System.Collections.Generic.List[string]
  $global:ExternalCalls     = New-Object System.Collections.Generic.List[string]
  $global:SgsList           = New-Object System.Collections.Generic.List[string]
} # Reset-SgsMock


function GetSgsValue {
  <#
    .SYNOPSIS
      Mock stand-in for the real SGS parameter lookup. Returns the mocked value
      for $Key from the table set by Reset-SgsMock, defaulting to 0 (and recording
      a warning) for any key the trial's value table doesn't cover. Numeric-looking
      values are coerced to [int]/[double] (not left as strings) so PowerShell's
      "+" operator does arithmetic instead of string concatenation, matching the
      real typed SGS store.
  #>

  param (
    [Parameter(Mandatory=$true)][String]$Key
  )

  if ($global:SgsValues.ContainsKey($Key)) {
    $value = $global:SgsValues[$Key]
    if ($value -is [String]) {
      [Int64]$asInt = 0
      if ([Int64]::TryParse($value, [ref]$asInt)) { return $asInt }
      [Double]$asDouble = 0
      if ([Double]::TryParse($value, [ref]$asDouble)) { return $asDouble }
    }
    return $value
  }

  [void]$global:SgsMockWarnings.Add("GetSgsValue: no mock value for '$Key' - defaulted to 0")
  return 0
} # GetSgsValue


function DataLineOrNoStatement {
  <#
    .SYNOPSIS
      Mock stand-in for the real "emit a COBOL candidate line" primitive.
      Captures every emitted line in order for later diffing against a golden.
  #>

  param (
    $Line
  )

  if ($null -eq $Line) {
    return
  }

  [void]$global:EmittedLines.Add([string]$Line)
} # DataLineOrNoStatement


function CompareTypeSafe {
  <#
    .SYNOPSIS
      Mock stand-in for the real type-safe comparison helper. Compares
      numerically if both sides parse as numbers, otherwise does a
      case-insensitive string comparison.
  #>

  param (
    $Left,
    [String]$Operator,
    $Right
  )

  [Double]$LeftNum  = 0
  [Double]$RightNum = 0
  [Boolean]$IsNumeric = [Double]::TryParse([String]$Left, [ref]$LeftNum) -and [Double]::TryParse([String]$Right, [ref]$RightNum)

  switch ($Operator) {
    "EqualTo"          { if ($IsNumeric) { return $LeftNum -eq $RightNum } else { return ([String]$Left) -ieq ([String]$Right) } }
    "NotEqualTo"       { if ($IsNumeric) { return $LeftNum -ne $RightNum } else { return ([String]$Left) -ine ([String]$Right) } }
    "GreaterThan"      { if ($IsNumeric) { return $LeftNum -gt $RightNum } else { return ([String]$Left) -cgt ([String]$Right) } }
    "LessThan"         { if ($IsNumeric) { return $LeftNum -lt $RightNum } else { return ([String]$Left) -clt ([String]$Right) } }
    "GreaterOrEqualTo" { if ($IsNumeric) { return $LeftNum -ge $RightNum } else { return ([String]$Left) -cge ([String]$Right) } }
    "LessOrEqualTo"    { if ($IsNumeric) { return $LeftNum -le $RightNum } else { return ([String]$Left) -cle ([String]$Right) } }
    default            { throw "CompareTypeSafe: unrecognised operator '$Operator'" }
  }
} # CompareTypeSafe


function Process-Skip {
  <#
    .SYNOPSIS
      Mock stand-in for ECL job-control skip/jump handling. The Tier-1 harness
      has no JUMP/label state to simulate, so every statement is always taken.
  #>

  param (
    [String]$Statement
  )

  return $false
} # Process-Skip


function Call-ExternalProgram {
  <#
    .SYNOPSIS
      Mock stand-in for @UCOB/@MAP/@ACOB-style "unknown processor" calls.
      Records the call for review instead of invoking anything.
  #>

  param (
    [String]$Program,
    [String]$Options,
    [String]$Arguments
  )

  [void]$global:ExternalCalls.Add("$Program [$Options] $Arguments")
} # Call-ExternalProgram


function Fin {
  <#
    .SYNOPSIS
      Mock stand-in for the ECL @FIN statement. No job-control state to close
      in the Tier-1 harness, so this is a no-op.
  #>
} # Fin


function Abort {
  <#
    .SYNOPSIS
      Mock stand-in for the real Abort. Throws so a trial run fails loudly and
      visibly instead of silently continuing past an unexpected condition.
  #>

  param (
    [String]$Message
  )

  throw "Abort: $Message"
} # Abort


function AddTo-SgsList {
  <#
    .SYNOPSIS
      Mock stand-in for *CREATE SGS-style list mutation. Recorded, not enforced.
  #>

  param (
    $Value
  )

  [void]$global:SgsList.Add([string]$Value)
} # AddTo-SgsList


function RemoveFrom-SgsList {
  <#
    .SYNOPSIS
      Mock stand-in for *REMOVE VARIABLE-style list mutation. Recorded, not enforced.
  #>

  param (
    [String]$Name,
    $Start,
    $Count
  )

  [void]$global:SgsList.Add("REMOVE $Name $Start..$Count")
} # RemoveFrom-SgsList


function Sort-SgsList {
  <#
    .SYNOPSIS
      Mock stand-in for *SORT. Not exercised by the current trial subset;
      recorded for visibility if a future program calls it.
  #>

  param (
    $Keys
  )

  [void]$global:SgsList.Add("SORT $Keys")
} # Sort-SgsList


function Hdg {
  <#
    .SYNOPSIS
      Mock stand-in for the ECL #HDG page-heading directive. No paging in the Tier-1 harness,
      so recorded (for visibility) and otherwise a no-op.
  #>

  param (
    [Parameter(ValueFromRemainingArguments = $true)] [Object[]]$Rest
  )

  [void]$global:ExternalCalls.Add("Hdg $($Rest -join ' ')")
} # Hdg


function SetC {
  <#
    .SYNOPSIS
      Mock stand-in for the ECL @SETC-style condition/character-set primitive. No control-statement
      state in the Tier-1 harness, so recorded (for visibility) and otherwise a no-op.
  #>

  param (
    [Parameter(ValueFromRemainingArguments = $true)] [Object[]]$Rest
  )

  [void]$global:ExternalCalls.Add("SetC $($Rest -join ' ')")
} # SetC


Export-ModuleMember -Function * -Variable *
