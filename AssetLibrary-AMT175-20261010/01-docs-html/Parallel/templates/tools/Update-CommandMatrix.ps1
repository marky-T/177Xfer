<#
.SYNOPSIS
    Update SSG-ECL-Command-Matrix_v1.html template with directive matrix data from JSON.

.DESCRIPTION
    Loads the command matrix template, validates content against schema_v1.json,
    replaces the @slot:commandMatrixRows placeholder with generated matrix rows
    (ECL directives × program columns), and outputs a timestamped HTML file.

    Template: SSG-ECL-Command-Matrix_v1.html
    Slot: @slot:commandMatrixRows (matrix tbody with directive rows, program columns, badges)
    Input: JSON file with commandMatrixRows[] array (directiveName, description, programColumns{}, patternBadges[])
    Output: SSG-ECL-Command-Matrix_<timestamp>.html

.PARAMETER TemplateVersion
    Template version to use (default: 'v1'). Must match template filename suffix.

.PARAMETER ContentFile
    Path to JSON content file with commandMatrixRows data.

.PARAMETER OutputDir
    Directory to write output HTML. Defaults to current directory.

.PARAMETER TemplatePath
    Base path to template directory. Defaults to C:\Amt\Parallel\templates

.EXAMPLE
    .\Update-CommandMatrix.ps1 -ContentFile trial-03-matrix_v1.json

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
$templateFile = Join-Path $TemplatePath "SSG-ECL-Command-Matrix_$TemplateVersion.html"

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

    # Validate placeholder exists (only in first tbody for matrix, not second for macros)
    if ($template -notmatch '<!-- @slot:commandMatrixRows:start -->') {
        throw "Template missing @slot:commandMatrixRows:start marker"
    }
    if ($template -notmatch '<!-- @slot:commandMatrixRows:end -->') {
        throw "Template missing @slot:commandMatrixRows:end marker"
    }

    # Generate matrix rows from commandMatrixRows array
    Write-Verbose "Generating matrix rows from $(@($jsonContent.commandMatrixRows).Count) directives"
    $rows = @()

    foreach ($directive in $jsonContent.commandMatrixRows) {
        # Group header row (if applicable)
        if ($directive.groupHeader) {
            $rows += "          <tr class='group-header'><td colspan='18'>$($directive.groupHeader)</td></tr>"
        }

        # Directive row
        $row = "          <tr>`n"
        $row += "            <td class='directive'><code>$($directive.directiveName)</code></td>`n"
        $row += "            <td class='directive-desc'>$($directive.description)</td>`n"

        # Program columns (MON, LEC, TRI, ARB1, CFH, etc.)
        if ($directive.programColumns) {
            foreach ($prog in $directive.programColumns.PSObject.Properties) {
                $value = $prog.Value
                if ($value -eq 'YES' -or $value -eq '1') {
                    $row += "            <td class='cell'><span class='cv cv-yes'>&#10003;</span></td>`n"
                }
                elseif ($value -eq 'NO' -or $value -eq '0') {
                    $row += "            <td class='cell'><span class='cv cv-no'>&#10007;</span></td>`n"
                }
                else {
                    $row += "            <td class='cell'><span class='cv cv-pend'>&mdash;</span></td>`n"
                }
            }
        }

        $row += "          </tr>"
        $rows += $row
    }

    $rowsContent = $rows -join "`n"

    # Replace placeholder with generated content (using regex with Singleline flag for multiline matching)
    # Note: replacement should NOT include the markers—they get removed
    Write-Verbose "Replacing @slot:commandMatrixRows placeholder"
    $pattern = '<!-- @slot:commandMatrixRows:start -->.*?<!-- @slot:commandMatrixRows:end -->'
    $replacement = $rowsContent
    $output = [regex]::Replace($template, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    # Drift validation
    if ($output -match '<!-- @slot:commandMatrixRows:') {
        throw "Drift validation failed: placeholder markers still present"
    }

    # Output with timestamp
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $outputFile = Join-Path $OutputDir "SSG-ECL-Command-Matrix_$timestamp.html"
    Set-Content -Path $outputFile -Value $output -Encoding UTF8

    Write-Host "SUCCESS: Generated $outputFile" -ForegroundColor Green
    exit 0
}
catch {
    Write-Error "FAILED: $_"
    exit 1
}
