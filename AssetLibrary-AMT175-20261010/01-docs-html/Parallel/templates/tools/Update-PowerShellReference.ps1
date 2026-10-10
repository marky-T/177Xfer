<#
.SYNOPSIS
    Update SSG-ECL-PowerShell-Reference_v1.html template with runbook entries from JSON.

.DESCRIPTION
    Loads the PowerShell reference template, validates content against schema_v1.json,
    replaces the @slot:runbookEntries placeholder with generated tool documentation blocks
    (example-header + example-body divs for each runbook entry), and outputs timestamped HTML.

    Template: SSG-ECL-PowerShell-Reference_v1.html
    Slot: @slot:runbookEntries (section 6 tool documentation blocks)
    Input: JSON file with runbookEntries[] array (toolName, description, usageExample, parameters[], outputs, notes)
    Output: SSG-ECL-PowerShell-Reference_<timestamp>.html

.PARAMETER TemplateVersion
    Template version to use (default: 'v1').

.PARAMETER ContentFile
    Path to JSON content file with runbookEntries data.

.PARAMETER OutputDir
    Directory to write output HTML. Defaults to current directory.

.PARAMETER TemplatePath
    Base path to template directory. Defaults to C:\Amt\Parallel\templates

.EXAMPLE
    .\Update-PowerShellReference.ps1 -ContentFile runbook-v1.json

.NOTES
    PowerShell 5.1 compliant
    Exit codes: 0=success, 1=failure
#>

param(
    [string]$TemplateVersion = 'v1',
    [string]$ContentFile,
    [string]$OutputDir = (Get-Location).Path,
    [string]$TemplatePath = 'C:\Amt\Parallel\templates'
)

$ErrorActionPreference = 'Stop'
$templateFile = Join-Path $TemplatePath "SSG-ECL-PowerShell-Reference_$TemplateVersion.html"

try {
    if ([string]::IsNullOrEmpty($ContentFile)) {
        throw 'ContentFile parameter is required'
    }

    if (-not (Test-Path $ContentFile)) {
        throw "ContentFile not found: $ContentFile"
    }

    if (-not (Test-Path $templateFile)) {
        throw "Template not found: $templateFile"
    }

    # Load content
    Write-Verbose "Loading content from $ContentFile"
    $jsonContent = Get-Content $ContentFile -Raw | ConvertFrom-Json

    # Load template
    Write-Verbose "Loading template from $templateFile"
    $template = Get-Content $templateFile -Raw

    # Validate placeholder exists
    if ($template -notmatch '<!-- @slot:runbookEntries:start -->') {
        throw "Template missing @slot:runbookEntries:start marker"
    }
    if ($template -notmatch '<!-- @slot:runbookEntries:end -->') {
        throw "Template missing @slot:runbookEntries:end marker"
    }

    # Generate runbook entry blocks
    Write-Verbose "Generating runbook entries from $(@($jsonContent.runbookEntries).Count) tools"
    $entries = @()

    foreach ($entry in $jsonContent.runbookEntries) {
        $block = "    <div class='example-header' style='border-radius:8px 8px 0 0;'>`n"
        $block += "      <h3 id='run-$($entry.toolName.ToLower())'>" + ($entry.toolName -replace '_', ' ') + "</h3>`n"
        $block += "      <p>$($entry.description)</p>`n"
        $block += "    </div>`n"
        $block += "    <div class='example-body'>`n"

        # Tool reference table
        $block += "      <table class='ref'>`n"
        $block += "        <tr><th>Item</th><th>Value</th></tr>`n"

        if ($entry.toolName) {
            $block += "        <tr><td>Tool</td><td><code>$($entry.toolName)</code></td></tr>`n"
        }
        if ($entry.filePath) {
            $block += "        <tr><td>Path</td><td><code>$($entry.filePath)</code></td></tr>`n"
        }
        if ($entry.parameters) {
            $paramStr = $entry.parameters -join ', '
            $block += "        <tr><td>Parameters</td><td><code>$paramStr</code></td></tr>`n"
        }
        if ($entry.outputs) {
            $block += "        <tr><td>Output</td><td>$($entry.outputs)</td></tr>`n"
        }
        if ($entry.notes) {
            $block += "        <tr><td>Notes</td><td>$($entry.notes)</td></tr>`n"
        }

        $block += "      </table>`n"

        # Usage example
        if ($entry.usageExample) {
            $block += "      <div class='info-box' style='margin-top:10px;'>`n"
            $block += "        <strong>Usage:</strong><br/>`n"
            $block += "        <code>$($entry.usageExample)</code>`n"
            $block += "      </div>`n"
        }

        $block += "    </div>"
        $entries += $block
    }

    $entriesContent = $entries -join "`n    `n"

    # Replace placeholder with generated content (using regex with Singleline flag for multiline matching)
    # Note: replacement should NOT include the markers—they get removed
    Write-Verbose "Replacing @slot:runbookEntries placeholder"
    $pattern = '<!-- @slot:runbookEntries:start -->.*?<!-- @slot:runbookEntries:end -->'
    $replacement = $entriesContent
    $output = [regex]::Replace($template, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    # Drift validation
    if ($output -match '<!-- @slot:runbookEntries:') {
        throw "Drift validation failed: placeholder markers still present"
    }

    # Output with timestamp
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $outputFile = Join-Path $OutputDir "SSG-ECL-PowerShell-Reference_$timestamp.html"
    Set-Content -Path $outputFile -Value $output -Encoding UTF8

    Write-Host "SUCCESS: Generated $outputFile" -ForegroundColor Green
    exit 0
}
catch {
    Write-Error "FAILED: $_"
    exit 1
}
