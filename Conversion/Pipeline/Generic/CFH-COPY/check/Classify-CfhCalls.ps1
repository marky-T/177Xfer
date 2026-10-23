# Spike step 0: classify every expanded CFH-COPY call by the statements it generates. Writes inventory.csv; prints a summary and the odd ones.
param([String]$Environment = 'CC-Trial')
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$e = "$($ge.WorkRoot)\allcalls\expanded"
$out = "$($ge.GenericWork)\CFH-COPY"
New-Item -ItemType Directory -Force $out | Out-Null
$rows = foreach ($f in Get-ChildItem $e -Filter 'CFH-COPY_ASCII__*.cob') {
  $t = Get-Content $f.FullName
  $p = [Array]::IndexOf($t, ($t | Where-Object { $_ -match 'PROCEDURE DIVISION' } | Select-Object -First 1))
  $proc = $t[$p..($t.Count - 1)] | ForEach-Object { ($_ -replace '\s+', ' ').Trim() } | Where-Object { $_ }
  # shape of the procedure with names and numbers abstracted away
  $shape = ($proc | ForEach-Object { $_ -replace 'ZONE\d+', 'ZONE#' -replace 'ZONO\d+', 'ZONO#' -replace 'FIXED\d+', 'FIXED#' -replace 'FIXDATA\d+', 'FIXDATA#' } | Select-Object -Unique) -join ' / '
  $raw = $t -join "`n"
  [pscustomobject]@{
    Call     = $f.BaseName -replace 'CFH-COPY_ASCII__', ''
    In       = [regex]::Match($raw, 'RECIN\s+PIC\s+X\((\d+)\)').Groups[1].Value
    Out      = [regex]::Match($raw, 'RECOUT\s+PIC\s+X\((\d+)\)').Groups[1].Value
    InName   = [regex]::Match($raw, 'TAPEIN\s+ASSIGN\s+TO\s+DISC\s+(\S+?)\.').Groups[1].Value
    OutName  = [regex]::Match($raw, 'TAPEOUT\s+ASSIGN\s+TO\s+DISC\s+(\S+?)\.').Groups[1].Value
    Moves    = ([regex]::Matches($raw, 'MOVE\s+ZONE\d+')).Count
    Fixe     = ([regex]::Matches($raw, 'MOVE\s+FIXED\d+')).Count
    Whole    = [bool]($raw -match 'MOVE\s+RECIN\s+TO\s+RECOUT')
    Shape    = $shape
  }
}
$rows | Export-Csv "$out\inventory.csv" -NoTypeInformation
"calls: $($rows.Count); distinct procedure shapes: $(@($rows | Group-Object Shape).Count)"
$rows | Group-Object Shape | Sort-Object Count -Descending | ForEach-Object {
  "--- $($_.Count) call(s), e.g. $($_.Group[0].Call) (in $($_.Group[0].In), out $($_.Group[0].Out), moves $($_.Group[0].Moves), fixe $($_.Group[0].Fixe), whole $($_.Group[0].Whole))"
  '    ' + ($_.Name.Substring(0, [Math]::Min(700, $_.Name.Length)))
} | Tee-Object "$out\shapes.txt"
