$f = 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic\ARCHIFORMAT\gen\ARCHIFORMAT-GN.cob'
$latin1 = [Text.Encoding]::GetEncoding('iso-8859-1')
$head = $latin1.GetString((& git -C E:\Repos\SsgTrial show 'HEAD:Conversion/Pipeline/Generic/ARCHIFORMAT/gen/ARCHIFORMAT-GN.cob' | Out-String).ToCharArray().ForEach({ [byte][int]$_ })) 2>$null
$headBytes = [IO.File]::ReadAllBytes($f) # placeholder, replaced below
$tmp = Join-Path $env:TEMP 'archiformat-head.cob'
& git -C E:\Repos\SsgTrial show 'HEAD:Conversion/Pipeline/Generic/ARCHIFORMAT/gen/ARCHIFORMAT-GN.cob' > $null
cmd /c "git -C E:\Repos\SsgTrial show HEAD:Conversion/Pipeline/Generic/ARCHIFORMAT/gen/ARCHIFORMAT-GN.cob > `"$tmp`""
$headBytes = [IO.File]::ReadAllBytes($tmp)
$headNonAscii = @($headBytes | Where-Object { $_ -gt 127 } | ForEach-Object { '0x{0:X2}' -f $_ })
"HEAD non-ASCII bytes: $($headNonAscii -join ',')"
$text = [IO.File]::ReadAllText($f, [Text.Encoding]::UTF8)
$n = ([regex]::Matches($text, [string][char]0xFFFD)).Count
if ($n -ne 1 -or $headNonAscii.Count -ne 1 -or $headNonAscii[0] -ne '0xE9') { throw "unexpected: replacement chars $n, HEAD non-ASCII $($headNonAscii -join ',')" }
$text = $text.Replace([string][char]0xFFFD, [string][char]0xE9)
[IO.File]::WriteAllBytes($f, $latin1.GetBytes($text))
$a = $latin1.GetString($headBytes) -split "`r?`n"; $b = $latin1.GetString([IO.File]::ReadAllBytes($f)) -split "`r?`n"
$d = Compare-Object $a $b
"diff lines vs HEAD: $($d.Count)"; $d | ForEach-Object { "$($_.SideIndicator) $($_.InputObject)" }
"non-ASCII now: " + ((([IO.File]::ReadAllBytes($f)) | Where-Object { $_ -gt 127 } | ForEach-Object { '0x{0:X2}' -f $_ }) -join ',')
Remove-Item $tmp
