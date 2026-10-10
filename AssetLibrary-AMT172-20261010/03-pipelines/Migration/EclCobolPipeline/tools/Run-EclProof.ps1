<#
.SYNOPSIS
  Tier-1 proof harness for the SSG-COBOL -> C# trial (Stream A).

.DESCRIPTION
  Proves the report/output contents of the converted SSG-COBOL utility modules
  WITHOUT the PowerShell/AMT runtime stack. It is deliberately STRUCTURED like
  the AMT PowerShell ECL skeleton (Set-Jobname -> file-assignment map ->
  Xqt-style invoke) so the SAME harness graduates across execution tiers:

    Tier 1 (NOW, this script)  : executor = PS reference oracle (tools\refimpl\<key>.ps1)
    Tier 2 (LATER, P4)         : executor = the converted C# under the AMT runtime
    Tier 3 (OPTIONAL)          : the real Stream-B PowerShell ECL script + BatchController

  Per module: materialise the assigned input file, assign FILEIN-1/FILEOUT-1,
  Xqt the executor, then diff the produced FILEOUT-1 against the hand-derived
  golden (fixtures\<key>\expected.dat). Pure file-in -> file-out, deterministic.

  The program universe is enumerated data-driven from the SSG source directory
  (the 16 ASSURFED_UTILIT_*.TXT modules). A module is "ready" when its manifest
  entry is status=done AND it has a proof block AND its fixtures + refimpl exist;
  everything else is "pending".

.PARAMETER Program
  One or more manifest 'key' values (or source module names) to prove.
  Omit to prove every 'ready' module.

.PARAMETER ListOnly
  Print the ready/pending roster and exit (no execution).

.PARAMETER IncludePlanned
  Also attempt modules whose manifest status is 'planned'.

.PARAMETER ManifestPath
  Override path to programs.manifest.json (default: ..\manifest\programs.manifest.json).

.PARAMETER ConfigPath
  Override path to pipeline.config.json (default: ..\config\pipeline.config.json).

.EXAMPLE
  .\Run-EclProof.ps1 -ListOnly

.EXAMPLE
  .\Run-EclProof.ps1 -Program MONTANT
#>
[CmdletBinding()]
param(
    [string[]]$Program,
    [switch]$ListOnly,
    [switch]$IncludePlanned,
    [string]$ManifestPath,
    [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not $ManifestPath) { $ManifestPath = Join-Path $RepoRoot 'manifest\programs.manifest.json' }
if (-not $ConfigPath)   { $ConfigPath   = Join-Path $RepoRoot 'config\pipeline.config.json' }
foreach ($f in @($ManifestPath, $ConfigPath)) {
    if (-not (Test-Path $f)) { Write-Error "Required file not found: $f"; exit 1 }
}

$manifest    = Get-Content $ManifestPath -Raw | ConvertFrom-Json
$config      = Get-Content $ConfigPath   -Raw | ConvertFrom-Json
$sourceDir   = $config.rawSourceDir
$fixturesDir = Join-Path $RepoRoot 'fixtures'
$refImplDir  = Join-Path $PSScriptRoot 'refimpl'
$workDir     = Join-Path $RepoRoot 'output\.proof'

if (-not (Test-Path $sourceDir)) { Write-Error "SSG source dir not found: $sourceDir"; exit 1 }

# --- Enumerate the program universe data-driven from the SSG source dir --------
$universe = Get-ChildItem $sourceDir -Filter 'ASSURFED_UTILIT_*.TXT' -File |
    Sort-Object Name | ForEach-Object { $_.Name }

# Index manifest entries by their sourceFile for matching against the universe.
$bySource = @{}
foreach ($p in $manifest.programs) {
    if ($p.PSObject.Properties.Name -contains 'sourceFile' -and $p.sourceFile) {
        $bySource[$p.sourceFile] = $p
    }
}

function Get-ProofState($entry) {
    # Returns: Ready | Planned | Pending(reason) for a matched manifest entry.
    if (-not $entry) { return @{ state = 'pending'; reason = 'not in manifest' } }
    $hasProof = ($entry.PSObject.Properties.Name -contains 'proof') -and $entry.proof
    if ($entry.status -eq 'done' -and $hasProof) {
        $key   = $entry.key
        $fxDir = Join-Path $fixturesDir $key
        $fxIn  = Join-Path $fxDir 'input.dat'
        # Fall back to first existing fileAssignment file when input.dat absent
        if (-not (Test-Path $fxIn) -and
            $entry.proof.PSObject.Properties.Name -contains 'fileAssignments') {
            foreach ($fa in $entry.proof.fileAssignments.PSObject.Properties) {
                $cand = Join-Path $fxDir $fa.Value
                if (Test-Path $cand) { $fxIn = $cand; break }
            }
        }
        $fxExp = Join-Path $fxDir 'expected.dat'
        $ref   = Join-Path $refImplDir ($key.ToLower() + '.ps1')
        if ((Test-Path $fxIn) -and (Test-Path $fxExp) -and (Test-Path $ref)) {
            return @{ state = 'ready'; reason = '' }
        }
        return @{ state = 'pending'; reason = 'proof block but fixtures/refimpl missing' }
    }
    if ($entry.status -eq 'planned') { return @{ state = 'planned'; reason = 'scaffold pending' } }
    if ($entry.status -eq 'done')    { return @{ state = 'pending'; reason = 'no proof block' } }
    return @{ state = 'pending'; reason = "status=$($entry.status)" }
}

# --- Build the roster ----------------------------------------------------------
$roster = foreach ($src in $universe) {
    $entry = if ($bySource.ContainsKey($src)) { $bySource[$src] } else { $null }
    $st    = Get-ProofState $entry
    [pscustomobject]@{
        Source = $src
        Key    = if ($entry) { $entry.key } else { ($src -replace '^ASSURFED_UTILIT_','' -replace '\(P\)\.TXT$','') }
        Status = if ($entry) { $entry.status } else { 'not-started' }
        State  = $st.state
        Reason = $st.reason
        Entry  = $entry
    }
}

$readyCount   = @($roster | Where-Object State -eq 'ready').Count
$pendingCount = @($roster | Where-Object State -ne 'ready').Count

if ($ListOnly) {
    Write-Host ''
    Write-Host "SSG-COBOL -> C# proof roster  (universe = $(@($universe).Count) modules)" -ForegroundColor Cyan
    Write-Host ('-' * 78)
    foreach ($r in $roster) {
        $color = switch ($r.State) { 'ready' { 'Green' } 'planned' { 'Yellow' } default { 'DarkGray' } }
        $tag   = $r.State.PadRight(8)
        $line  = ('  {0}  {1,-14} {2}' -f $tag, $r.Key, $r.Reason)
        Write-Host $line -ForegroundColor $color
    }
    Write-Host ('-' * 78)
    Write-Host ("  READY = $readyCount    PENDING = $pendingCount") -ForegroundColor Cyan
    return
}

# --- Select programs to prove --------------------------------------------------
$selected = if ($Program) {
    @($roster | Where-Object { $Program -contains $_.Key -or $Program -contains $_.Source })
} else {
    @($roster | Where-Object State -eq 'ready')
}
if (-not $selected) { Write-Warning 'No matching programs to prove.'; return }

New-Item -ItemType Directory -Force -Path $workDir | Out-Null

$pass = 0; $fail = 0; $skip = 0
foreach ($r in $selected) {
    Write-Host ''
    Write-Host "=== $($r.Key)  [$($r.Source)]  state=$($r.State) ===" -ForegroundColor Cyan

    if ($r.State -eq 'planned' -and -not $IncludePlanned) {
        Write-Warning "  planned entry skipped (use -IncludePlanned)"; $skip++; continue
    }
    if ($r.State -ne 'ready') {
        Write-Warning "  not provable yet: $($r.Reason)"; $skip++; continue
    }

    $entry   = $r.Entry
    $fxDir   = Join-Path $fixturesDir $r.Key
    $assign  = Get-Content (Join-Path $fxDir 'assign.json') -Raw | ConvertFrom-Json
    $refImpl = Join-Path $refImplDir ($r.Key.ToLower() + '.ps1')

    # ---- AMT PS-ECL-style skeleton: jobname -> file assignments -> Xqt --------
    $jobname = if ($assign.PSObject.Properties.Name -contains 'jobname' -and $assign.jobname) { $assign.jobname } else { $r.Key }
    Write-Host "  Set-Jobname     : $jobname"

    # Resolve the file-assignment map. Input files come from the fixture folder;
    # output files are materialised in the per-job work dir.
    $jobWork = Join-Path $workDir $r.Key
    if (Test-Path $jobWork) { Remove-Item $jobWork -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $jobWork | Out-Null

    $assignedIn  = $null
    $assignedOut = $null
    foreach ($a in $assign.fileAssignments.PSObject.Properties) {
        $logical = $a.Name
        $srcPath = Join-Path $fxDir $a.Value
        if (Test-Path $srcPath) {
            $dst = Join-Path $jobWork $a.Value
            Copy-Item $srcPath $dst -Force
            Write-Host "  Assign (in)     : $logical -> $($a.Value)"
            if (-not $assignedIn) { $assignedIn = $dst }
        } else {
            $assignedOut = Join-Path $jobWork $a.Value
            Write-Host "  Assign (out)    : $logical -> $($a.Value)"
        }
    }
    if (-not $assignedIn)  { Write-Warning "  no input file assigned"; $fail++; continue }
    if (-not $assignedOut) { $assignedOut = Join-Path $jobWork 'output.dat' }

    # ---- Xqt: invoke the Tier-1 executor (PS reference oracle) ----------------
    $executor = if ($entry.proof.PSObject.Properties.Name -contains 'executor') { $entry.proof.executor } else { 'refimpl' }
    Write-Host "  Xqt             : executor=$executor  $($r.Key.ToLower()).ps1"
    switch ($executor) {
        'refimpl' {
            & $refImpl -InFile $assignedIn -OutFile $assignedOut
        }
        default {
            Write-Warning "  executor '$executor' not implemented in Tier 1 (only 'refimpl')"; $skip++; continue
        }
    }

    # ---- Diff produced output vs the hand-derived golden ----------------------
    $expected = Join-Path $fxDir 'expected.dat'
    $expBytes = [IO.File]::ReadAllBytes($expected)
    $actBytes = [IO.File]::ReadAllBytes($assignedOut)
    $same = ($expBytes.Length -eq $actBytes.Length)
    if ($same) {
        for ($i = 0; $i -lt $expBytes.Length; $i++) {
            if ($expBytes[$i] -ne $actBytes[$i]) { $same = $false; break }
        }
    }
    if ($same) {
        Write-Host "  RESULT          : PASS (diff=0, $($expBytes.Length) bytes)" -ForegroundColor Green
        $pass++
    } else {
        Write-Host "  RESULT          : FAIL (output != expected)" -ForegroundColor Red
        Write-Host "    expected: $expected"
        Write-Host "    actual  : $assignedOut"
        $fail++
    }
}

Write-Host ''
Write-Host "Proof complete. PASS=$pass  FAIL=$fail  SKIP=$skip" -ForegroundColor $(if ($fail) { 'Red' } else { 'Green' })
if ($fail) { exit 1 }
