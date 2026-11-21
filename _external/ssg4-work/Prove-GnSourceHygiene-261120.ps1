# Proof: Test-GnSourceHygiene catches the errors of 261120 (and the other rules) on a scratch copy; the repo is not touched.
$ErrorActionPreference = 'Stop'
$gen = 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic'
$scratch = 'E:\Repos\ssg4-work\hygiene-proof'
Remove-Item $scratch -Recurse -Force -ErrorAction SilentlyContinue
robocopy $gen $scratch utilities.json GnHandoff.ps1 /NJH /NJS /NFL /NDL | Out-Null
foreach ($d in (Get-ChildItem $gen -Directory)) { robocopy $d.FullName (Join-Path $scratch $d.Name) *.cob *.ps1 /S /NJH /NJS /NFL /NDL | Out-Null }
$test = "$gen\Test-GnSourceHygiene.ps1"

"--- clean copy"
& pwsh -NoProfile -File $test -Root $scratch | Select-Object -Last 1

$latin1 = [Text.Encoding]::GetEncoding('iso-8859-1')
$af = "$scratch\ARCHIFORMAT\gen\ARCHIFORMAT-GN.cob"
$t = $latin1.GetString([IO.File]::ReadAllBytes($af))
# damage 1: the U+FFFD of today (é rewritten as UTF-8 after a wrong decode); damage 2: the backspace of today
$bytes = [Collections.Generic.List[Byte]]::new($latin1.GetBytes($t.Replace('* bytes, as AMT', "* $([char]8)ytes, as AMT")))
$i = $bytes.IndexOf([Byte]0xE9); $bytes.RemoveAt($i); $bytes.InsertRange($i, [Byte[]](0xEF, 0xBF, 0xBD))
[IO.File]::WriteAllBytes($af, $bytes.ToArray())
# damage 3: an internal id in a hand-off; damage 4: a COBOL comment past column 72
$bp = "$scratch\BABA\gen\BabaParm.ps1"; [IO.File]::WriteAllText($bp, [IO.File]::ReadAllText($bp).Replace('# SSG-4: parameter file', '# SSG-4 (MT-043): parameter file'), (New-Object System.Text.UTF8Encoding($false)))
$bc = "$scratch\BABA\gen\BABA-GN.cob"; $bt = $latin1.GetString([IO.File]::ReadAllBytes($bc)); [IO.File]::WriteAllBytes($bc, $latin1.GetBytes($bt.Replace('      * User story: 119872', '      * User story: 119872 ' + ('x' * 60))))

"--- damaged copy (expect: control char, replacement char, non-ASCII changed, id, line > 72)"
& pwsh -NoProfile -File $test -Root $scratch
"exit $LASTEXITCODE"
"--- same, with -AllowTextChange ARCHIFORMAT (the non-ASCII guard is skipped; the byte checks still fail)"
& pwsh -NoProfile -File $test -Root $scratch -AllowTextChange ARCHIFORMAT | Select-Object -Last 1
Remove-Item $scratch -Recurse -Force
