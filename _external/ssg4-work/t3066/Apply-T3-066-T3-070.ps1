<#
.SYNOPSIS
  T3-066 + T3-070 landing (owner, ELEVATED window; close VS Code first if the build reports a locked file).
  Applies the tested SsgConverter changes to SsgTrial:
    T3-066  SymstreamProcessor.cs        literal @ ECL images (option A)
    T3-070  SymstreamExpressionParser.cs  the label position of [label,...] is never a variable
  rebuilds the SsgConverter library, refreshes Build\Console + Build\Gui SsgConverter.dll, regenerates Examples\Output
  (Reconvert-And-Verify backs them up first), then checks the goldens equal the pre-tested output in
  E:\Repos\ssg4-work\t3066\combined (ARCHIFORMAT, ARCHISEPARE, EXTEUR, RECAP, TABAN_ASCII change; 15 unchanged).
  Idempotent: re-running after success only re-verifies.
#>
$ErrorActionPreference = 'Stop'
$repoSsg  = 'E:\Repos\SsgTrial\SsgConverter'
$scratch  = 'E:\Repos\ssg4-work\t3066'
$expected = "$scratch\combined"
$files = @(
  @{ Target = "$repoSsg\Source\SsgConverter\SymstreamProcessor.cs";        New = "$scratch\SymstreamProcessor.T3-066.cs";        Old = '9FB1853B61AF'; NewHash = '2350528DA43D'; Id = 'T3-066' },
  @{ Target = "$repoSsg\Source\SsgConverter\SymstreamExpressionParser.cs"; New = "$scratch\SymstreamExpressionParser.T3-070.cs"; Old = 'C0E600BEC3BE'; NewHash = 'D60EF1D21F8A'; Id = 'T3-070' }
)
$changed = $false
foreach ($f in $files) {
  $h = (Get-FileHash $f.Target).Hash.Substring(0, 12)
  if ($h -eq $f.NewHash) { "$($f.Id): already patched" }
  elseif ($h -eq $f.Old) { Copy-Item $f.New $f.Target -Force; $changed = $true; "$($f.Id): patched $(Split-Path $f.Target -Leaf)" }
  else { throw "$($f.Id): $(Split-Path $f.Target -Leaf) has unexpected hash $h (expected $($f.Old) or $($f.NewHash)): stop, do not overwrite." }
  if ((Get-FileHash $f.Target).Hash.Substring(0, 12) -ne $f.NewHash) { throw "$($f.Id): patch did not reach disk." }
}

$dllBefore = (Get-FileHash "$repoSsg\Build\Console\SsgConverter.dll").Hash.Substring(0, 12)
& "$repoSsg\Trials\Reconvert-And-Verify.ps1" -Rebuild -RefreshDll -UpdateGoldens
$dllAfter = (Get-FileHash "$repoSsg\Build\Console\SsgConverter.dll").Hash.Substring(0, 12)
"Build\Console SsgConverter.dll: $dllBefore -> $dllAfter"
if ($changed -and $dllBefore -eq $dllAfter) { throw 'DLL unchanged: the change did not compile in (see ssg-converter-dev rule 3a).' }

$bad = Get-ChildItem $expected -Filter *.ps1 | Where-Object {
  (Get-FileHash $_.FullName).Hash -ne (Get-FileHash (Join-Path "$repoSsg\Examples\Output" $_.Name)).Hash }
if ($bad) { throw "Goldens differ from the pre-tested output: $($bad.Name -join ', ')" }
'All 20 goldens equal the pre-tested output. T3-066 and T3-070 landed in SsgTrial.'
