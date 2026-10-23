# Review of one promoted cluster: parse every script, then run its offline check and its Prepare scripts from the new
# place and confirm the CC jobs and deployed includes they write are byte-identical to what the _scratch versions wrote.
param([Parameter(Mandatory)][String]$Utility, [String[]]$Prepare = @(), [String[]]$Offline = @(), [String[]]$Jobs = @(), [String[]]$Includes = @(),
  # 'old|new' pairs (files or folders): what the _scratch version wrote vs what the promoted version writes
  [String[]]$Compare = @(), [String]$Environment = 'CC-Trial')
. "$PSScriptRoot\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$g = "$PSScriptRoot\$Utility"
$scripts = $ge.ScriptRoot
$out = [Collections.Generic.List[String]]::new()
$bad = 0
foreach ($f in Get-ChildItem $g -Recurse -Filter *.ps1) {
  $e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$e)
  if ($e.Count) { $bad++; $out.Add("PARSE $($f.Name): $($e.Count) errors") }
  foreach ($m in Select-String -Path $f.FullName -Pattern '_scratch|\$spike\b') { $bad++; $out.Add("OLD REF $($f.Name):$($m.LineNumber): $($m.Line.Trim())") }
}
$out.Add("parse + old-reference scan: $((Get-ChildItem $g -Recurse -Filter *.ps1).Count) scripts")
$before = @{}
foreach ($j in $Jobs) { $p = "$scripts\ASSURFED_F999\RUN\$j.ps1"; $before[$j] = if (Test-Path $p) { (Get-FileHash $p).Hash } }
foreach ($o in $Offline) { $out.Add("--- $o"); pwsh -NoProfile -File "$g\$o" 2>&1 | ForEach-Object { $out.Add("  $_") } }
foreach ($p in $Prepare) { $out.Add("--- $p"); pwsh -NoProfile -File "$g\$p" 2>&1 | Select-Object -Last 3 | ForEach-Object { $out.Add("  $_") } }
foreach ($j in $Jobs) {
  $now = (Get-FileHash "$scripts\ASSURFED_F999\RUN\$j.ps1").Hash
  $same = $now -eq $before[$j]; if (-not $same) { $bad++ }
  $out.Add("job $j.ps1 unchanged: $same")
}
foreach ($i in $Includes) {
  $src = Get-ChildItem $g -Recurse -Filter "$i.ps1" | Select-Object -First 1
  if (-not $src) { $src = Get-ChildItem (Split-Path $g) -Recurse -Filter "$i.ps1" | Select-Object -First 1 }
  $same = (Get-FileHash $src.FullName).Hash -eq (Get-FileHash "$scripts\ASSURFED_UTILIT\$i.inc").Hash; if (-not $same) { $bad++ }
  $out.Add("deployed $i.inc == Generic\$Utility source: $same")
}
foreach ($pair in $Compare) {
  $old, $new = $pair -split '\|'
  $rel = if (Test-Path $old -PathType Container) { Get-ChildItem $old -Recurse -File | ForEach-Object { $_.FullName.Substring($old.Length) } } else { @('') }
  $diff = @($rel | Where-Object { -not (Test-Path "$new$_") -or (Get-FileHash "$old$_").Hash -ne (Get-FileHash "$new$_").Hash })
  if ($diff.Count) { $bad++ }
  $out.Add("compare $(Split-Path $new -Leaf): $($rel.Count - $diff.Count)/$($rel.Count) identical$(if ($diff.Count) { ' DIFF: ' + ($diff | Select-Object -First 5) -join ', ' })")
}
$out.Add("problems: $bad")
$out | Set-Content "$($ge.GenericWork)\$Utility\promote-review.txt"
$out

