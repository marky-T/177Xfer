<#
.SYNOPSIS
  T3-046 workaround: R&D's ECL converter writes `@HDG,P text` as  Hdg "P     text"  (options and heading in one string), which the
  runtime rejects ("Invalid options for HdgOptions", CC job 723). The valid form is  Hdg "P" ("text").
.DESCRIPTION
  Writes patched copies of every script under -Source that has such a line to -OutDir (same relative path; -Source is never changed).
  Encoding and line endings are kept. Each patched file is parse-checked. Lines that are already valid (Hdg "N", Hdg "P" ("x")) are left alone.
  Deploy the patched copies (Step 3 of the plan) instead of the released ones; drop this step once R&D fixes the ECL converter.
.EXAMPLE
  Patch-HdgOptions.ps1 -OutDir E:\Repos\SsgTrial\_scratch\hdg-patched
#>
param(
  [String]$Source = 'E:\Repos\Federale_InternalRelease\Scripts',
  [Parameter(Mandatory)][String]$OutDir
)
$ErrorActionPreference = 'Stop'
$bad = '(?m)^([ \t]*)Hdg[ \t]+"([A-Z]+)[ \t]+([^"\r\n]*?)[ \t]*"[ \t]*(?=\r?$)'
$srcRoot = (Resolve-Path $Source).Path.TrimEnd('\')
$files = 0; $lines = 0; $parseErrors = 0
foreach ($f in Get-ChildItem $srcRoot -Recurse -Filter *.ps1) {
  $bytes = [IO.File]::ReadAllBytes($f.FullName)
  $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
  $text = [IO.File]::ReadAllText($f.FullName)
  $n = [regex]::Matches($text, $bad).Count
  if (-not $n) { continue }
  $patched = [regex]::Replace($text, $bad, '$1Hdg "$2" ("$3")')
  $dest = Join-Path $OutDir $f.FullName.Substring($srcRoot.Length + 1)
  New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
  [IO.File]::WriteAllText($dest, $patched, (New-Object Text.UTF8Encoding($bom)))
  $e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($dest, [ref]$null, [ref]$e)
  if ($e.Count) { $parseErrors += $e.Count; "PARSE ERROR in $dest : $($e[0].Message)" }
  $left = [regex]::Matches($patched, $bad).Count
  if ($left) { "STILL BAD: $left in $dest" }
  $files++; $lines += $n
  '{0}: {1} line(s)' -f $f.FullName.Substring($srcRoot.Length + 1), $n
}
"patched copies: $files file(s), $lines Hdg line(s), parse errors $parseErrors, written to $OutDir"
