# Reassembles the split payload back into the original 8.0.26230.0 release tree.
# Run on the AMT177 VM from inside AMT177-Runtime-8.0.26230.0\.
# Rejoins *.partNNN files, copies whole files as-is, verifies SHA256 from MANIFEST.json.
# No external tools required (does NOT need 7-Zip).
param(
  [string]$PayloadDir = (Join-Path $PSScriptRoot 'payload'),
  [string]$OutDir     = (Join-Path $PSScriptRoot 'Reassembled')
)
$ErrorActionPreference = 'Stop'
$manifest = Get-Content (Join-Path $PayloadDir 'MANIFEST.json') -Raw | ConvertFrom-Json
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$fail = 0
foreach ($e in $manifest) {
  $src = Join-Path $PayloadDir $e.Path
  $dst = Join-Path $OutDir $e.Path
  New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
  if ($e.Parts -gt 0) {
    $out = [System.IO.File]::Create($dst)
    try {
      for ($i = 0; $i -lt $e.Parts; $i++) {
        $part = ('{0}.part{1:000}' -f $src, $i)
        $bytes = [System.IO.File]::ReadAllBytes($part)
        $out.Write($bytes, 0, $bytes.Length)
      }
    } finally { $out.Close() }
  } else {
    Copy-Item $src $dst -Force
  }
  $sha = (Get-FileHash $dst -Algorithm SHA256).Hash
  if ($sha -ne $e.SHA256) { Write-Warning ("SHA MISMATCH: {0}" -f $e.Path); $fail++ }
  else { Write-Output ("OK  {0}" -f $e.Path) }
}
if ($fail) { Write-Error ("{0} file(s) FAILED verification" -f $fail) }
else { Write-Output ("`nAll {0} files verified. Release tree at: {1}\8.0.26230.0" -f $manifest.Count, $OutDir) }
