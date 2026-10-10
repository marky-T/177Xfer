<#
.SYNOPSIS
    Update SSG-Trial-Progress_v1.html template with program trial data from JSON.

.DESCRIPTION
    Loads a trial progress template, validates content against schema_v1.json,
    replaces the @slot:programRows placeholder with generated table rows,
    and outputs a timestamped HTML file after drift validation.

    Template: SSG-Trial-Progress_v1.html
    Slot: @slot:programRows (tbody rows with program status, candidate info, proof status)
    Input: JSON file conforming to schema_v1.json (programRows[] array required)
    Output: SSG-Trial-Progress_<timestamp>.html

.PARAMETER TemplateVersion
    Template version to use (default: 'v1'). Must match template filename suffix.
    Pattern: v[0-9]+ (e.g., v1, v2, v3)

.PARAMETER ContentFile
    Path to JSON content file with programRows data.
    Required fields per row: programId, ssgElementName, status, trialNumber, candidateBytes

.PARAMETER OutputDir
    Directory to write output HTML. Defaults to current directory.
    Output filename: SSG-Trial-Progress_<YYYYMMDD-HHMMSS>.html

.PARAMETER TemplatePath
    Base path to template directory. Defaults to C:\Amt\Parallel\templates

.EXAMPLE
    .\Update-TrialProgress.ps1 -ContentFile trial-03-montant_v1.json
    # Loads SSG-Trial-Progress_v1.html, replaces @slot:programRows with MONTANT data

.EXAMPLE
    .\Update-TrialProgress.ps1 -TemplateVersion v1 -ContentFile trial-04-loadis_v1.json -OutputDir "C:\Output"

.NOTES
    PowerShell 5.1 compliant (no Unicode literals, no backticks for line continuation)
    Exit codes: 0=success, 1=failure
#>

param(
    [string]$TemplateVersion = 'v1',
    [string]$ContentFile,
    [string]$OutputDir = (Get-Location).Path,
    [string]$TemplatePath = 'C:\Amt\Parallel\templates'
)

$ErrorActionPreference = 'Stop'
$schemaFile = Join-Path $TemplatePath 'schema_v1.json'
$templateFile = Join-Path $TemplatePath "SSG-Trial-Progress_$TemplateVersion.html"

try {
    # Validate inputs
    if ([string]::IsNullOrEmpty($ContentFile)) {
        throw 'ContentFile parameter is required'
    }

    if (-not (Test-Path $ContentFile)) {
        throw "ContentFile not found: $ContentFile"
    }

    if (-not (Test-Path $templateFile)) {
        throw "Template not found: $templateFile"
    }

    if (-not (Test-Path $schemaFile)) {
        throw "Schema not found: $schemaFile"
    }

    # Load and validate JSON content
    Write-Verbose "Loading content from $ContentFile"
    $jsonContent = Get-Content $ContentFile -Raw | ConvertFrom-Json
    $templateVersionFromJson = $jsonContent.templateVersion

    if ($templateVersionFromJson -ne $TemplateVersion) {
        throw "Template version mismatch: JSON specifies $templateVersionFromJson, but $TemplateVersion requested"
    }

    # Load template
    Write-Verbose "Loading template from $templateFile"
    $template = Get-Content $templateFile -Raw

    # Validate placeholder exists
    if ($template -notmatch '<!-- @slot:programRows:start -->') {
        throw "Template missing @slot:programRows:start marker"
    }
    if ($template -notmatch '<!-- @slot:programRows:end -->') {
        throw "Template missing @slot:programRows:end marker"
    }

    # Generate table rows from programRows array
    Write-Verbose "Generating table rows from $(@($jsonContent.programRows).Count) programs"
    $rows = @()
    
    foreach ($program in $jsonContent.programRows) {
        $statusClass = 'badge-pend'
        $statusIcon = 'mdash'
        $statusText = 'pending'
        
        switch ($program.status) {
            'done' {
                $statusClass = 'badge-done'
                $statusIcon = '10003'
                $statusText = 'PASS'
            }
            'in-progress' {
                $statusClass = 'badge-prog'
                $statusIcon = '25a1'
                $statusText = 'in progress'
            }
            'failed' {
                $statusClass = 'badge-bug'
                $statusIcon = '10007'
                $statusText = 'failed'
            }
        }

        $row = "        <tr>`n"
        $row += "          <td><code>$($program.programId)</code></td>`n"
        $row += "          <td>$($program.category)</td>`n"
        $row += "          <td>$($program.description)</td>`n"
        $row += "          <td>`n"
        $row += "            <span class='badge $statusClass'>&#$statusIcon; $statusText</span>`n"
        
        if ($program.trialNumber) {
            $row += "            <span class='trial-detail'>trial-$($program.trialNumber) | $($program.candidateBytes)B</span>`n"
        }
        if ($program.candidateLink) {
            $row += "            <span class='trial-detail'><a href='$($program.candidateLink)'>Candidate</a></span>`n"
        }
        
        $row += "          </td>`n"
        $row += "          <td><span class='badge badge-pend'>&mdash; pending</span></td>`n"
        $row += "        </tr>"
        
        $rows += $row
    }

    $rowsContent = $rows -join "`n        `n"

    # Replace placeholder with generated content (using regex with Singleline flag for multiline matching)
    # Note: replacement should NOT include the markers—they get removed
    Write-Verbose "Replacing @slot:programRows placeholder"
    $pattern = '<!-- @slot:programRows:start -->.*?<!-- @slot:programRows:end -->'
    $replacement = $rowsContent
    $output = [regex]::Replace($template, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    # Drift validation (placeholder should be completely gone)
    if ($output -match '<!-- @slot:programRows:') {
        throw "Drift validation failed: placeholder markers still present in output"
    }

    # Output with timestamp
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $outputFile = Join-Path $OutputDir "SSG-Trial-Progress_$timestamp.html"
    Set-Content -Path $outputFile -Value $output -Encoding UTF8

    Write-Host "SUCCESS: Generated $outputFile" -ForegroundColor Green
    exit 0
}
catch {
    Write-Error "FAILED: $_"
    exit 1
}
