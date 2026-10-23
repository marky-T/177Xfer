foreach ($f in Get-ChildItem E:\Amt\Lion -Filter *.dll) {
  $b = [IO.File]::ReadAllBytes($f.FullName)
  foreach ($enc in [Text.Encoding]::Unicode, [Text.Encoding]::ASCII) {
    $s = $enc.GetString($b)
    if ($s -notmatch 'is generating application|LIONGENERATES|at the moment\. Generator') { continue }
    $all = [regex]::Matches($s, '[\x20-\x7E]{4,}') | ForEach-Object Value
    for ($k = 0; $k -lt $all.Count; $k++) {
      if ($all[$k] -match 'is generating application|LIONGENERATES|at the moment\. Generator') {
        "== $($f.Name) [$($enc.EncodingName)] #$k"
        ($k - 10)..($k + 10) | Where-Object { $_ -ge 0 -and $_ -lt $all.Count } | ForEach-Object { '{0,6}: {1}' -f $_, $all[$_] }
      }
    }
  }
}
