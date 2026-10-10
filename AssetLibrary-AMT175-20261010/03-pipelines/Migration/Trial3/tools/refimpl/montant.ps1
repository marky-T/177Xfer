<#
.SYNOPSIS
  Tier-1 PowerShell reference oracle for SSG-COBOL program MONTANT (MONTANT_SIGNE).

.DESCRIPTION
  Faithful stand-in for the converted MONTANT logic, used as the Tier-1 golden
  generator / executor in the SSG-COBOL -> C# proof harness. It does NOT use the
  AMT runtime; it reproduces the cleaned-COBOL semantics directly so report
  contents can be proven with no PowerShell/AMT stack dependency. The real
  generated C# is validated against this oracle at Tier 2 (P4).

  Cleaned COBOL (candidates/trial-03-montant) semantics reproduced:
    * Record = 80 chars fixed.
    * WS-IN1 REDEFINES WS-IN:  FILLER X(1) | MONTANT1 PIC S9(9) | FILLER X(1)
      => MONTANT1 occupies columns 2..10 (0-based index 1..9).
    * MOVE WS-IN TO WS-OUT (whole record copied).
    * COMPUTE MONTANT1 OF WS-OUT1 = MONTANT1 OF WS-IN1 * +1
      => decode signed zoned-decimal value, multiply by +1 (magnitude + sign
         preserved), re-encode canonically (explicit overpunch on trailing digit).
    * READ ... AT END -> stop; WRITE REC-OUT loop.

  OS2200 / IBM zoned-decimal sign convention (verified vs the Phase-14 C# run,
  FILEOUT-1.DAT: 4->D, 9->I, 1->A):
    positive trailing digit  0={ 1=A 2=B 3=C 4=D 5=E 6=F 7=G 8=H 9=I
    negative trailing digit  0=} 1=J 2=K 3=L 4=M 5=N 6=O 7=P 8=Q 9=R
    plain digit '0'..'9' on input = positive.

.PARAMETER InFile
  Path to the assigned FILEIN-1 data file (80-char fixed records, CRLF-delimited).

.PARAMETER OutFile
  Path to write the assigned FILEOUT-1 data file.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RECLEN  = 80
$FLD_OFF = 1   # 0-based column of MONTANT1
$FLD_LEN = 9   # PIC S9(9)

$posOverpunch = @{ '0'='{'; '1'='A'; '2'='B'; '3'='C'; '4'='D'; '5'='E'; '6'='F'; '7'='G'; '8'='H'; '9'='I' }
$negOverpunch = @{ '0'='}'; '1'='J'; '2'='K'; '3'='L'; '4'='M'; '5'='N'; '6'='O'; '7'='P'; '8'='Q'; '9'='R' }
# Reverse map: overpunch / plain char -> @{ digit; sign }
$decode = @{}
foreach ($d in @('0','1','2','3','4','5','6','7','8','9')) {
    $decode[$d]                 = @{ digit = $d; sign =  1 }   # plain digit = positive
    $decode[$posOverpunch[$d]]  = @{ digit = $d; sign =  1 }
    $decode[$negOverpunch[$d]]  = @{ digit = $d; sign = -1 }
}

function Convert-Field([string]$field) {
    # field is exactly $FLD_LEN chars (zoned-decimal, sign on trailing char).
    $lead = $field.Substring(0, $FLD_LEN - 1)
    $last = $field.Substring($FLD_LEN - 1, 1)
    if (-not $decode.ContainsKey($last)) {
        throw "MONTANT: unrecognised sign/digit character '$last' in field '$field'"
    }
    $sign  = $decode[$last].sign
    $digit = $decode[$last].digit
    $magStr = ($lead + $digit)
    if ($magStr -notmatch '^[0-9]{9}$') {
        throw "MONTANT: non-numeric digits in field '$field'"
    }
    $value = [int64]$magStr * $sign            # COMPUTE = * +1 (sign + magnitude preserved)

    $mag = [math]::Abs($value)
    $out = ('{0:D9}' -f $mag)                  # 9-digit zero-padded magnitude
    $oLead = $out.Substring(0, $FLD_LEN - 1)
    $oLast = $out.Substring($FLD_LEN - 1, 1)
    $enc   = if ($value -lt 0) { $negOverpunch[$oLast] } else { $posOverpunch[$oLast] }
    return ($oLead + $enc)
}

$lines = [IO.File]::ReadAllLines($InFile)
$outLines = New-Object System.Collections.Generic.List[string]
foreach ($raw in $lines) {
    if ($raw.Length -eq 0) { continue }              # AT END / blank tail guard
    $rec = $raw.PadRight($RECLEN).Substring(0, $RECLEN)
    $field = $rec.Substring($FLD_OFF, $FLD_LEN)
    $newField = Convert-Field $field
    # MOVE WS-IN TO WS-OUT then overwrite only MONTANT1 (FILLER + tail preserved).
    $outRec = $rec.Substring(0, $FLD_OFF) + $newField + $rec.Substring($FLD_OFF + $FLD_LEN)
    $outLines.Add($outRec)
}

[IO.File]::WriteAllText($OutFile, (($outLines -join "`r`n") + "`r`n"))
