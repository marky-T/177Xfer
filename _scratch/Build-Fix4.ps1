$ErrorActionPreference = 'Stop'
# Scratch build: T3-034 *CREATE SGS image is literal text with [..] references (like an output line), not an expression.
$repo = 'E:\Repos\SsgTrial'
$work = "$repo\_scratch\ssgfix4"
$srcDir = "$work\src"
Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
robocopy "$repo\SsgConverter\Source\SsgConverter" "$srcDir\SsgConverter" /E /XD bin obj /NFL /NDL /NJH /NJS | Out-Null
robocopy "$repo\SsgConverter\Source\_deps" "$srcDir\_deps" /E /NFL /NDL /NJH /NJS | Out-Null

function Crlf([String]$s) { $s -replace "`r?`n", "`r`n" }
function ReplaceOnce([String]$text, [String]$old, [String]$new) {
  $old = Crlf $old; $new = Crlf $new
  $first = $text.IndexOf($old)
  if ($first -lt 0) { throw "Not found: $($old.Substring(0, [Math]::Min(70, $old.Length)))" }
  if ($text.IndexOf($old, $first + 1) -ge 0) { throw "More than once: $($old.Substring(0, [Math]::Min(70, $old.Length)))" }
  return $text.Substring(0, $first) + $new + $text.Substring($first + $old.Length)
}
$file = "$srcDir\SsgConverter\SymstreamProcessor.cs"
$bytes = [IO.File]::ReadAllBytes($file)
$bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
$t = [IO.File]::ReadAllText($file)
$t = ReplaceOnce $t @'
                  // it's an SGS image
                  List<PsAstExprBase> psParameters = new List<PsAstExprBase>();
                  psParameters.Add(SymstreamExpressionToPowerShellExpression(s, globalVariables, localVariables));
'@ @'
                  // it's an SGS image: literal text with [..] references, like an output line (manual 5.2.10), not an expression
                  List<PsAstExprBase> psParameters = new List<PsAstExprBase>();
                  psParameters.Add(OutputLineToPowerShellExpression(s, globalVariables, localVariables));
'@
[IO.File]::WriteAllText($file, $t, (New-Object Text.UTF8Encoding($bom)))
"patched $file ($((Get-Item $file).Length) bytes)"
dotnet build "$srcDir\SsgConverter\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-Object -Last 4
