$r = 'E:\Repos\Federale_InternalRelease'
$old = 'd4da9d0d80'; $new = 'origin/main'
function Show($p) { git -C $r --no-optional-locks show "${new}:$p" 2>$null }
'== new main'
git -C $r --no-optional-locks log -1 --format='%h %ci %s' $new
'== T3-028: AddTo-SgsList in the new main'
$lib = Show 'Scripts/Libraries/AmtPsEclLib.psm1'
$i = ($lib | Select-String '^function AddTo-SgsList\b').LineNumber
if ($i) { $lib[($i - 1)..($i + 40)] | Select-String 'Split|quote|''' | Select-Object -First 8 | ForEach-Object { "  L$($i + $_.LineNumber - 1): $($_.Line.Trim())" } } else { '  AddTo-SgsList not found' }
"AmtPsEclLib changed since d4da9d0d80: $([bool](git -C $r --no-optional-locks diff --name-only $old $new -- Scripts/Libraries/AmtPsEclLib.psm1))"
'== T3-046: Hdg lines with options+text in one string, in the new main converted scripts'
$hdg = git -C $r --no-optional-locks grep -c -E '^\s*Hdg "P\s+\S' $new -- Scripts 2>$null
"files: $(@($hdg).Count); lines: $((@($hdg) | ForEach-Object { [int]($_ -split ':')[-1] } | Measure-Object -Sum).Sum)"
@($hdg) | Select-Object -First 3
git -C $r --no-optional-locks grep -n -E '^\s*Hdg "P\s+\S' $new -- Scripts 2>$null | Select-Object -First 2
'== Hdg function in the new library (accepted forms)'
$j = ($lib | Select-String '^function Hdg\b').LineNumber
if ($j) { $lib[($j - 1)..($j + 25)] | Select-String 'param|Option|Abort|Invalid' | Select-Object -First 6 | ForEach-Object { "  $($_.Line.Trim())" } }
'== T3-059: reader source changed since d4da9d0d80?'
git -C $r --no-optional-locks diff --stat $old $new -- 'AmtFramework/Amt.Net/Libraries/Libs/Files/AmtReadFile.cs' 2>$null | Select-Object -Last 1
git -C $r --no-optional-locks ls-tree -r --name-only $new -- AmtFramework 2>$null | Select-String 'AmtReadFile\.cs$' | Select-Object -First 2
