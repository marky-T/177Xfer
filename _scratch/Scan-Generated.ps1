$dev = 'E:\AMT_Work\Apps177\Development\Programs'
foreach ($d in Get-ChildItem $dev -Directory) {
  $cs = Get-ChildItem $d.FullName -Filter *.cs | Where-Object { $_.Name -notmatch '^Fd_|Definitions|_Info' }
  $txt = ($cs | ForEach-Object { Get-Content $_.FullName -Raw }) -join "`n"
  $empty = [regex]::Matches($txt, '(?m)^\s*private void (\w+) \(\) \{\s*\r?\n\s*\} // \1') | ForEach-Object { $_.Groups[1].Value }
  $ext = [regex]::Matches($txt, 'CallProgram\(\s*"([^"]+)"|CallExternal\w*\(\s*"([^"]+)"|\.Call\(\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value + $_.Groups[2].Value + $_.Groups[3].Value } | Sort-Object -Unique
  $todo = ([regex]::Matches($txt, '(?i)not (converted|supported|implemented)|TODO|UNSUPPORTED')).Count
  '{0}: lines={1} emptyMethods={2} [{3}] externalCalls=[{4}] notConvertedMarkers={5}' -f $d.Name, ($txt -split "`n").Count, $empty.Count, ($empty -join ','), ($ext -join ','), $todo
}
'--- RSA$ usage'
Get-ChildItem $dev -Recurse -Filter *.cs | Select-String -Pattern 'RSA\$|RSA_' -SimpleMatch:$false | Select-Object -First 6 | ForEach-Object { '{0}:{1}: {2}' -f $_.Filename, $_.LineNumber, $_.Line.Trim() }
