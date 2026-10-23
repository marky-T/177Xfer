# Shared helpers for the New/Test/Land-ConverterFix.ps1 routine (replaces the one-off
# _scratch\Build-FixN / Test-FixN / Land-FixN scripts). An edit script (one small .ps1 per fix,
# written fresh each time - only the patch content is one-off, not the plumbing) imports this
# module and calls Edit-SourceFile for each change it makes to a scratch copy of the source.

function ReplaceOnce {
  param([Parameter(Mandatory)][String]$Text, [Parameter(Mandatory)][String]$Old, [Parameter(Mandatory)][String]$New)
  function Crlf([String]$s) { $s -replace "`r?`n", "`r`n" }
  $oldC = Crlf $Old; $newC = Crlf $New
  $first = $Text.IndexOf($oldC)
  if ($first -lt 0) { throw "Not found: $($oldC.Substring(0, [Math]::Min(70, $oldC.Length)))" }
  if ($Text.IndexOf($oldC, $first + 1) -ge 0) { throw "More than once: $($oldC.Substring(0, [Math]::Min(70, $oldC.Length)))" }
  return $Text.Substring(0, $first) + $newC + $Text.Substring($first + $oldC.Length)
}

function Edit-SourceFile {
  # Applies one ReplaceOnce edit to a file in place, preserving its BOM state.
  param([Parameter(Mandatory)][String]$Path, [Parameter(Mandatory)][String]$Old, [Parameter(Mandatory)][String]$New)
  if (-not (Test-Path -LiteralPath $Path)) { throw "Not found: $Path" }
  $bytes = [IO.File]::ReadAllBytes($Path)
  $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
  $t = [IO.File]::ReadAllText($Path)
  $t = ReplaceOnce -Text $t -Old $Old -New $New
  [IO.File]::WriteAllText($Path, $t, (New-Object Text.UTF8Encoding($bom)))
  "patched $Path ($((Get-Item $Path).Length) bytes)"
}

Export-ModuleMember -Function ReplaceOnce, Edit-SourceFile
