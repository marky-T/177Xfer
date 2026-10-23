$ssg = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
$m = 'E:\Repos\SsgTrial\_scratch\ssgmerge2'
$em = [string][char]0x2014
$t = [IO.File]::ReadAllText("$m\SymstreamProcessor.resolved.cs")
$old = "      } else if (!String.IsNullOrWhiteSpace(lines[i])) {`n        // Plain text output line (not a directive, not ECL, not a standalone bracket reference).`n        // In Symstream, any non-directive line is an output statement written to the generated stream.`n"
$new = "      } else if (!String.IsNullOrEmpty(lines[i])) {`n        // Plain text output line (not a directive, not ECL, not a standalone bracket reference).`n        // In Symstream, any non-directive line is an output statement written to the generated stream`n        // (SSG manual 78311784-010 sec 4.3), including whitespace-only (blank) images - see T3-001.`n"
$t = $t.Replace($old, $new)
$lines = $t -split "`n"
for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i].Contains($em) -and $lines[$i] -match 'Not implemented|Emitted as a comment|IMPORTANT-WORKAROUND|R&D fix required') { $lines[$i] = $lines[$i].Replace($em, '-') } }
$intended = $lines -join "`n"
$disk = [IO.File]::ReadAllText("$ssg\SymstreamProcessor.cs") -replace "`r`n", "`n"
'Processor on disk == intended: ' + ($disk -ceq $intended) + "   (disk $($disk.Length), intended $($intended.Length))"
if ($disk -cne $intended) { [IO.File]::WriteAllText("$m\intended.cs", $intended); git diff --no-index --ignore-space-at-eol "$m\intended.cs" "$ssg\SymstreamProcessor.cs" | Select-Object -First 60 }
$b = [IO.File]::ReadAllBytes("$ssg\SymstreamProcessor.cs"); $crlf = 0; $lf = 0; for ($i = 0; $i -lt $b.Length; $i++) { if ($b[$i] -eq 10) { if ($i -gt 0 -and $b[$i - 1] -eq 13) { $crlf++ } else { $lf++ } } }
'line endings: CRLF={0} bare-LF={1}' -f $crlf, $lf
$pp = [IO.File]::ReadAllText("$ssg\SymstreamExpressionParser.cs")
'Parser em-dash lines remaining: ' + (($pp -split "`n") | Where-Object { $_.Contains($em) }).Count
