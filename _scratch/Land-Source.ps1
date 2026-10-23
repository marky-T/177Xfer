$ssg = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
$m = 'E:\Repos\SsgTrial\_scratch\ssgmerge2'
$em = [string][char]0x2014
function ToCrlf([string]$t) { ($t -replace "`r`n", "`n") -replace "`n", "`r`n" }

# Processor: merged (ours + R&D *INCREMENT change) + manual-faithful blank-line rule + ASCII dashes in our text
$t = [IO.File]::ReadAllText("$m\SymstreamProcessor.resolved.cs")
$old = "      } else if (!String.IsNullOrWhiteSpace(lines[i])) {`n        // Plain text output line (not a directive, not ECL, not a standalone bracket reference).`n        // In Symstream, any non-directive line is an output statement written to the generated stream.`n"
$new = "      } else if (!String.IsNullOrEmpty(lines[i])) {`n        // Plain text output line (not a directive, not ECL, not a standalone bracket reference).`n        // In Symstream, any non-directive line is an output statement written to the generated stream`n        // (SSG manual 78311784-010 sec 4.3), including whitespace-only (blank) images - see T3-001.`n"
if (-not $t.Contains($old)) { throw 'blank-line rule text not found in merged file' }
$t = $t.Replace($old, $new)
$lines = $t -split "`n"
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Contains($em) -and $lines[$i] -match 'Not implemented|Emitted as a comment|IMPORTANT-WORKAROUND|R&D fix required') { $lines[$i] = $lines[$i].Replace($em, '-') }
}
$t = $lines -join "`n"
[IO.File]::WriteAllText("$ssg\SymstreamProcessor.cs", (ToCrlf $t), (New-Object Text.UTF8Encoding($false)))

# Parser: only our two comment dashes
$p = [IO.File]::ReadAllText("$ssg\SymstreamExpressionParser.cs") -replace "`r`n", "`n"
$pl = $p -split "`n"
for ($i = 0; $i -lt $pl.Count; $i++) { if ($pl[$i].Contains($em) -and $pl[$i] -match 'guard: operand empty') { $pl[$i] = $pl[$i].Replace($em, '-') } }
[IO.File]::WriteAllText("$ssg\SymstreamExpressionParser.cs", (ToCrlf ($pl -join "`n")), (New-Object Text.UTF8Encoding($false)))
'written'
