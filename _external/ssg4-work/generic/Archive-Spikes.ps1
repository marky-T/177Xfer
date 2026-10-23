# Archive the promoted SSG-4 spike folders (_scratch\spike-*): one zip with a SHA256 manifest, verified by extracting and
# comparing every file, and only then the originals are removed.
$ErrorActionPreference = 'Stop'
$scratch = 'E:\Repos\SsgTrial\_scratch'
$arch = 'E:\Repos\ssg4-work\archive'
$zip = "$arch\spikes-20261021.zip"
if (Test-Path $zip) { throw "$zip exists" }
New-Item -ItemType Directory -Force $arch | Out-Null
$dirs = @(Get-ChildItem $scratch -Directory -Filter 'spike-*')
$manifest = foreach ($d in $dirs) { foreach ($f in Get-ChildItem $d.FullName -Recurse -File) { [pscustomobject]@{ Path = $f.FullName.Substring($scratch.Length + 1); Bytes = $f.Length; Sha256 = (Get-FileHash $f.FullName).Hash } } }
$manifestFile = Join-Path $env:TEMP 'MANIFEST.csv'
$manifest | Export-Csv $manifestFile -NoTypeInformation
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z = [IO.Compression.ZipFile]::Open($zip, 'Create')
try {
  foreach ($m in $manifest) { [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, "$scratch\$($m.Path)", $m.Path.Replace('\', '/'), 'Optimal') }
  [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, $manifestFile, 'MANIFEST.csv', 'Optimal')
} finally { $z.Dispose() }
# verify: read every entry back and compare its hash with the manifest
$bad = 0
$z = [IO.Compression.ZipFile]::OpenRead($zip)
try {
  $byName = @{}; foreach ($e in $z.Entries) { $byName[$e.FullName] = $e }
  foreach ($m in $manifest) {
    $e = $byName[$m.Path.Replace('\', '/')]
    if (-not $e) { $bad++; continue }
    $s = $e.Open(); $h = [Security.Cryptography.SHA256]::Create().ComputeHash($s); $s.Dispose()
    if (([BitConverter]::ToString($h) -replace '-', '') -ne $m.Sha256) { $bad++ }
  }
} finally { $z.Dispose() }
'{0} files, {1} spike folders, zip {2:N1} MB, verification failures: {3}' -f $manifest.Count, $dirs.Count, ((Get-Item $zip).Length / 1MB), $bad
if ($bad) { throw 'Verification failed; originals kept.' }
foreach ($d in $dirs) { Remove-Item $d.FullName -Recurse -Force }
'removed: ' + (($dirs | ForEach-Object Name) -join ', ')
Copy-Item $manifestFile "$arch\spikes-20261021.MANIFEST.csv" -Force
