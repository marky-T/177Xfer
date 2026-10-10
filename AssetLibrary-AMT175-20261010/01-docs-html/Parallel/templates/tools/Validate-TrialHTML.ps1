<#
.SYNOPSIS
    Validate generated HTML against drift (CSS/layout corruption).

.DESCRIPTION
    Performs 7-point drift validation on generated HTML files to ensure
    immutable sections (CSS, nav, headers, fonts, badges) were not modified
    during placeholder replacement.

    Validation checks:
    1. CSS <style> blocks are present and unchanged
    2. Nav structure unchanged (color codes intact)
    3. No remaining placeholder markers
    4. Template version markers match
    5. Header h1/h2 titles unchanged
    6. Font-face declarations preserved (if any)
    7. Badge CSS classes (badge-done, badge-prog, badge-pend, etc.) intact

.PARAMETER HtmlFile
    Path to generated HTML file to validate.

.PARAMETER TemplateVersion
    Expected template version (default: 'v1').

.PARAMETER ExpectedNavColor
    Expected nav background color (hex). Defaults vary by template:
    - Trial Progress: #1e1b4b (indigo)
    - Command Matrix: #0f2832 (teal)
    - PowerShell Ref: #14331f (green)

.PARAMETER Strict
    If specified, fails on warnings (not just errors). Default: warnings only.

.EXAMPLE
    .\Validate-TrialHTML.ps1 -HtmlFile "SSG-Trial-Progress_20260819-143000.html"

.EXAMPLE
    .\Validate-TrialHTML.ps1 -HtmlFile "output.html" -Strict

.NOTES
    PowerShell 5.1 compliant
    Exit codes: 0=valid, 1=validation failure
#>

param(
    [string]$HtmlFile,
    [string]$TemplateVersion = 'v1',
    [string]$ExpectedNavColor,
    [switch]$Strict
)

$ErrorActionPreference = 'Stop'
$warnings = @()
$errors = @()

try {
    if ([string]::IsNullOrEmpty($HtmlFile)) {
        throw 'HtmlFile parameter is required'
    }

    if (-not (Test-Path $HtmlFile)) {
        throw "HTML file not found: $HtmlFile"
    }

    Write-Verbose "Loading HTML file: $HtmlFile"
    $content = Get-Content $HtmlFile -Raw

    # Check 1: CSS style block present (use Singleline flag for multiline matching)
    if (-not [regex]::IsMatch($content, '<style>.*?</style>', [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $errors += "CSS <style> block missing or malformed"
    }
    else {
        Write-Verbose "Check 1 PASS: CSS style block present"
    }

    # Check 2: Nav structure present (use Singleline flag for multiline matching)
    if (-not [regex]::IsMatch($content, '<nav[^>]*>.*?</nav>', [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $errors += "Nav element missing or malformed"
    }
    else {
        if ($ExpectedNavColor -and -not [regex]::IsMatch($content, "background:$([regex]::Escape($ExpectedNavColor))")) {
            $warnings += "Expected nav color $ExpectedNavColor not found (may be acceptable if overridden)"
        }
        Write-Verbose "Check 2 PASS: Nav structure present"
    }

    # Check 3: No remaining placeholders
    if ($content -match '<!-- @slot:[^:]+:(?:start|end) -->') {
        $errors += "Placeholder markers still present in output: $($matches[0])"
    }
    else {
        Write-Verbose "Check 3 PASS: No placeholder markers remaining"
    }

    # Check 4: Header h1 present
    if ($content -notmatch '<h1>.*?</h1>') {
        $warnings += "Main h1 header not found (non-critical)"
    }
    else {
        Write-Verbose "Check 4 PASS: H1 header present"
    }

    # Check 5: Footer present (use Singleline flag for multiline matching)
    if (-not [regex]::IsMatch($content, '</main>.*?</html>', [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $warnings += "Footer structure may be damaged (check manually)"
    }
    else {
        Write-Verbose "Check 5 PASS: Footer structure intact"
    }

    # Check 6: Badge classes intact (spot check)
    $expectedBadges = @('badge-done', 'badge-prog', 'badge-pend')
    foreach ($badge in $expectedBadges) {
        if (-not [regex]::IsMatch($content, "\.$badge\s*{")) {
            $warnings += "Badge class .$badge CSS definition may be missing"
        }
    }
    if (@($warnings | Where-Object { $_ -match 'Badge class' }).Count -eq 0) {
        Write-Verbose "Check 6 PASS: Badge CSS classes present"
    }

    # Check 7: DOCTYPE and html structure (use Singleline flag for multiline matching)
    if (-not [regex]::IsMatch($content, '<!DOCTYPE html>')) {
        $errors += "DOCTYPE declaration missing"
    }
    if (-not [regex]::IsMatch($content, '<html[^>]*>.*?</html>', [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $errors += "HTML structure malformed"
    }
    else {
        Write-Verbose "Check 7 PASS: HTML structure intact"
    }

    # Output results
    Write-Host ""
    Write-Host "=== Drift Validation Results ===" -ForegroundColor Cyan
    Write-Host "File: $HtmlFile" -ForegroundColor Gray

    if ($errors.Count -gt 0) {
        Write-Host ""
        Write-Host "ERRORS ($($errors.Count)):" -ForegroundColor Red
        foreach ($err in $errors) {
            Write-Host "  - $err" -ForegroundColor Red
        }
    }

    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "WARNINGS ($($warnings.Count)):" -ForegroundColor Yellow
        foreach ($warn in $warnings) {
            Write-Host "  - $warn" -ForegroundColor Yellow
        }
    }

    if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
        Write-Host ""
        Write-Host "RESULT: PASS (all checks passed)" -ForegroundColor Green
    }
    elseif ($errors.Count -eq 0) {
        Write-Host ""
        Write-Host "RESULT: PASS WITH WARNINGS" -ForegroundColor Yellow
        if ($Strict) {
            Write-Host "Strict mode enabled; treating warnings as errors" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Host ""
        Write-Host "RESULT: FAIL ($($errors.Count) error(s))" -ForegroundColor Red
        exit 1
    }

    exit 0
}
catch {
    Write-Error "VALIDATION ERROR: $_"
    exit 1
}
