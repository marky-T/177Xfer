$ErrorActionPreference = 'Stop'
$repo = 'E:\Repos\SsgTrial'
$work = "$repo\_scratch\ssgfix4"
$ex = "$repo\SsgConverter\Examples"
$con = "$work\console"; $out = "$work\out"
Remove-Item $con, $out -Recurse -Force -ErrorAction SilentlyContinue
robocopy "$repo\SsgConverter\Build\Console" $con /E /NFL /NDL /NJH /NJS | Out-Null
Copy-Item "$work\src\SsgConverter\bin\Debug\net10.0\SsgConverter.dll" "$con\SsgConverter.dll" -Force
New-Item -ItemType Directory -Force -Path $out | Out-Null
dotnet "$con\SsgConverterConsole.dll" /INPUT:"$ex\Input" /OUTPUT:"$out" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"$out" 2>&1 |
  Select-String -Pattern 'Conversion complete|Error converting' | ForEach-Object { $_.Line }

"`n== parse, diff against goldens, Tier-1"
$harness = "$repo\SsgConverter\Trials\Tier1Mock\Run-SsgPsTrial.ps1"
foreach ($f in Get-ChildItem $out -Filter *.ps1 | Sort-Object Name) {
  $errs = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$errs)
  $d = @(Compare-Object @(Get-Content "$ex\Output\$($f.Name)") @(Get-Content $f.FullName) -SyncWindow 0).Count
  $r = & $harness -Program $f.BaseName -ScriptPath $f.FullName -OutDir "$work\tier1\$($f.BaseName)" 6>$null
  '{0,-18} parse={1} differing={2,-4} tier1={3} lines={4}' -f $f.BaseName, $errs.Count, $d, $(if ($r.Failed) { 'THREW' } else { 'OK' }), $r.LineCount
}

"`n== changed lines"
foreach ($f in Get-ChildItem $out -Filter *.ps1 | Sort-Object Name) {
  $diff = git diff --no-index --unified=0 "$ex\Output\$($f.Name)" $f.FullName | Select-Object -Skip 4 | Where-Object { $_ -match '^[-+]' }
  if ($diff) { "---- $($f.BaseName)"; $diff | Select-Object -First 12 }
}

"`n== expansion with the real cards"
$cards = 'E:\Repos\ssg4-work\sgs-cards'
$calls = Import-Csv "$cards\sgs-calls.csv" | Where-Object { $_.Converted -eq 'True' }
foreach ($key in 'BABA_ASCII', 'FUSBA_ASCII', 'CHABAN_ASCII') {
  $call = @($calls | Where-Object ProgramKey -eq $key)[0]
  $res = pwsh -NoProfile -File "$repo\Conversion\Pipeline\Invoke-SsgExpansion.ps1" -Program $key -CardFile (Join-Path $cards $call.CardFile) -OutFile "$work\exp-$key.cob" -RunInfo "$($call.RunId),$($call.RunAccount),$($call.RunProject)" -ScriptPath "$out\$key.ps1" 2>&1
  '{0,-14} exit {1}  {2}' -f $key, $LASTEXITCODE, (($res | Out-String) -split "`n" | Where-Object { $_ -match 'Failed|Error' } | ForEach-Object Trim) -join ' | '
}

