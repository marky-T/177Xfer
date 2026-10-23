# C7 survey: which R&D-converted runstreams call our 13 programs, and what they Xqt. Read-only.
$scripts = 'E:\Repos\Federale_InternalRelease\Scripts'
$out = 'E:\Repos\SsgTrial\_scratch\c7-survey'
New-Item -ItemType Directory -Force $out | Out-Null
$ours = 'CFH-COPY_ASCII', 'FUSBA2_ASCII', 'LECTIS_ASCII', 'LOADIS_ASCII', 'UNLOADIS_ASCII', 'LOADIS_MULTI', 'UNLOADIS_MULTI',
  'CHAB100_ASCII', 'CHABAN_ASCII', 'BABA_ASCII', 'FUSBA_ASCII', 'CONDIS2_ASCII', 'TABAN_ASCII'
$files = Get-ChildItem $scripts -Recurse -Filter *.ps1 -File
$hits = foreach ($f in $files) {
  $lines = [IO.File]::ReadAllLines($f.FullName)
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'Invoke-Ssg\b.*-Skeleton\s+"([^"]+)"') {
      $skel = Split-Path $Matches[1] -Leaf
      $key = $skel -replace '^UTILIT_', ''
      # the next Xqt after this call, within 60 lines
      $xqt = ''; $xl = 0
      for ($j = $i + 1; $j -lt [Math]::Min($lines.Count, $i + 60); $j++) { if ($lines[$j] -match '^\s*Xqt\b(.*)$') { $xqt = $Matches[1].Trim(); $xl = $j + 1; break } }
      $sgs = if ($lines[$i] -match '-SgsFile\s+"([^"]+)"') { $Matches[1] } else { '' }
      [pscustomobject]@{ Script = $f.FullName.Substring($scripts.Length + 1); Line = $i + 1; Skeleton = $skel; Key = $key; Ours = ($ours -contains $key); SgsFile = $sgs; XqtLine = $xl; Xqt = $xqt }
    }
  }
}
$hits | Export-Csv "$out\invoke-ssg-calls.csv" -NoTypeInformation
$mine = @($hits | Where-Object Ours)
"Scripts scanned: $($files.Count); Invoke-Ssg calls: $(@($hits).Count); on our 13: $($mine.Count) in $(@($mine | Select-Object -Unique Script).Count) scripts"
$mine | Group-Object Key | Sort-Object Name | ForEach-Object {
  $x = ($_.Group | Group-Object Xqt | ForEach-Object { '{0} x{1}' -f $_.Name, $_.Count }) -join '; '
  '{0,-16} {1,3} calls  Xqt: {2}' -f $_.Name, $_.Count, $x
} | Tee-Object "$out\summary.txt"
'Not called: ' + (($ours | Where-Object { $mine.Key -notcontains $_ }) -join ', ')
# Where would the Xqt target resolve? Look at the Xqt implementation in AmtPsEclLib.
$lib = Get-ChildItem 'E:\Repos\Federale_InternalRelease' -Recurse -Filter 'AmtPsEclLib.psm1' -File -ErrorAction SilentlyContinue | Select-Object -First 3 | ForEach-Object FullName
'AmtPsEclLib copies: ' + ($lib -join ' | ')
