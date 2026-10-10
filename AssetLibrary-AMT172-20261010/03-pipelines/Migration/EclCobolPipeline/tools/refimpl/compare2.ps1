<#
.SYNOPSIS
  Tier-1 PowerShell reference oracle for SSG-COBOL program COMPARE2 (COMPARE2_ASCII).
.PARAMETER InFile
  Path to IN1 (fixtures/compare2/input.dat).  IN2 is derived: same dir, file "input2.dat".
.PARAMETER OutFile
  Path for LISTING printer output (compared to expected.dat).
  Simplified: ASCII=1, 100-char records, no INDIC/EXCLUDE/LIST. AIMPRIMER=0.
  Output: 9 x 132-char CRLF records = 1206 bytes for 3 identical input records.
#>
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$enc     = [System.Text.Encoding]::ASCII
$recLen  = 100
$listLen = 132
$InFile2 = Join-Path (Split-Path $InFile -Parent) 'input2.dat'
function Read-Recs([string]$path) {
    $raw  = [System.IO.File]::ReadAllBytes($path)
    $recs = [System.Collections.Generic.List[string]]::new()
    $i = 0
    while ($i -lt $raw.Length) {
        $j = $i
        while ($j -lt $raw.Length -and $raw[$j] -ne 13 -and $raw[$j] -ne 10) { $j++ }
        if ($j -gt $i) { $recs.Add($enc.GetString($raw, $i, $j - $i).PadRight($recLen)) }
        $i = $j
        if ($i -lt $raw.Length -and $raw[$i] -eq 13) { $i++ }
        if ($i -lt $raw.Length -and $raw[$i] -eq 10) { $i++ }
    }
    $recs
}
$recs1 = Read-Recs $InFile
$recs2 = Read-Recs $InFile2
$CT1=0; $CT2=0; $NB_TOT_DIFFERENCE=0
$HIGH_VALUES = [string]::new([char]0xFF, 4)
$WS_INDIC1='    '; $WS_INDIC2='    '; $WS_IN1=''; $WS_IN2=''
$idx1=0; $idx2=0
$output = [System.Collections.Generic.List[string]]::new()
$output.Add(' ' * $listLen)
:mainLoop while ($true) {
    if ($idx1 -lt $recs1.Count) { $WS_IN1=$recs1[$idx1]; $idx1++; $CT1++; $WS_INDIC1='    ' } else { $WS_INDIC1=$HIGH_VALUES }
    if ($idx2 -lt $recs2.Count) { $WS_IN2=$recs2[$idx2]; $idx2++; $CT2++; $WS_INDIC2='    ' } else { $WS_INDIC2=$HIGH_VALUES }
    if ($WS_INDIC1 -eq $WS_INDIC2) {
        if ($WS_INDIC1 -eq $HIGH_VALUES) { break mainLoop }
        if ($WS_IN1 -ne $WS_IN2) { $NB_TOT_DIFFERENCE++ }
        continue mainLoop
    }
    if ([string]::Compare($WS_INDIC1,$WS_INDIC2,[System.StringComparison]::Ordinal) -gt 0) {
        if ($idx2 -lt $recs2.Count) { $WS_IN2=$recs2[$idx2]; $idx2++; $CT2++; $WS_INDIC2='    ' } else { $WS_INDIC2=$HIGH_VALUES }
    } else {
        if ($idx1 -lt $recs1.Count) { $WS_IN1=$recs1[$idx1]; $idx1++; $CT1++; $WS_INDIC1='    ' } else { $WS_INDIC1=$HIGH_VALUES }
    }
}
$ct1str  = $CT1.ToString().PadLeft(10,'0')
$ct2str  = $CT2.ToString().PadLeft(10,'0')
$diffStr = $NB_TOT_DIFFERENCE.ToString().PadLeft(6,'0')
$output.Add(('*'*30).PadRight($listLen))
$output.Add(('NOMBRE ENREGISTREMENTS INPUT FICHIER 1 = '+$ct1str).PadRight($listLen))
$output.Add(('NOMBRE ENREGISTREMENTS INPUT FICHIER 2 = '+$ct2str).PadRight($listLen))
$output.Add(('NOMBRE ENREGISTREMENTS DIFFERENTS = '+$diffStr).PadRight($listLen))
$output.Add(('*'*30).PadRight($listLen))
$output.Add(('*'*46).PadRight($listLen))
if ($NB_TOT_DIFFERENCE -gt 0) { $output.Add(('* TOUTES LES DIFFERENCES NE SONT PAS LISTEES *').PadRight($listLen)) }
else                           { $output.Add(('*    TOUTES LES DIFFERENCES SONT LISTEES     *').PadRight($listLen)) }
$output.Add(('*'*46).PadRight($listLen))
[System.IO.File]::WriteAllLines($OutFile,$output,$enc)
