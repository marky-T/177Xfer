<#
.SYNOPSIS
    List available template versions and select the version to use.

.DESCRIPTION
    Discovers available HTML template versions (_v1, _v2, etc.) in the template
    directory and returns the version path. Useful for scripts that need to
    dynamically select the latest version or a specific version.

.PARAMETER TemplateName
    Base name of the template (without version suffix):
    - SSG-Trial-Progress
    - SSG-ECL-Command-Matrix
    - SSG-ECL-PowerShell-Reference

.PARAMETER Version
    Specific version to select (e.g., v1, v2). If omitted, returns latest.

.PARAMETER TemplatePath
    Base path to template directory. Defaults to C:\Amt\Parallel\templates

.PARAMETER ListOnly
    If specified, lists all available versions and exits without selecting one.

.EXAMPLE
    .\Select-TemplateVersion.ps1 -TemplateName SSG-Trial-Progress
    # Returns: C:\Amt\Parallel\templates\SSG-Trial-Progress_v1.html (latest)

.EXAMPLE
    .\Select-TemplateVersion.ps1 -TemplateName SSG-Trial-Progress -Version v2
    # Returns: C:\Amt\Parallel\templates\SSG-Trial-Progress_v2.html

.EXAMPLE
    .\Select-TemplateVersion.ps1 -TemplateName SSG-Trial-Progress -ListOnly
    # Lists all available versions: v1, v2, etc.

.NOTES
    PowerShell 5.1 compliant
    Exit codes: 0=success, 1=failure/not found
#>

param(
    [string]$TemplateName,
    [string]$Version,
    [string]$TemplatePath = 'C:\Amt\Parallel\templates',
    [switch]$ListOnly
)

$ErrorActionPreference = 'Stop'

try {
    if ([string]::IsNullOrEmpty($TemplateName)) {
        throw 'TemplateName parameter is required'
    }

    if (-not (Test-Path $TemplatePath)) {
        throw "Template path not found: $TemplatePath"
    }

    # Find all versions matching pattern
    Write-Verbose "Searching for templates matching: $TemplateName`_v*.html"
    $templates = @(Get-ChildItem -Path $TemplatePath -Filter "$($TemplateName)_v*.html" -ErrorAction SilentlyContinue)

    if ($templates.Count -eq 0) {
        throw "No templates found matching $TemplateName in $TemplatePath"
    }

    # Sort by version number (extract v# from filename)
    $sorted = $templates | Sort-Object { 
        $versionMatch = [regex]::Match($_.Name, '_v(\d+)')
        if ($versionMatch.Success) {
            [int]$versionMatch.Groups[1].Value
        }
        else {
            0
        }
    }

    if ($ListOnly) {
        Write-Host "Available versions for $TemplateName`:"
        foreach ($template in $sorted) {
            $vMatch = [regex]::Match($template.Name, '_v(\d+)')
            $v = if ($vMatch.Success) { "v" + $vMatch.Groups[1].Value } else { "unknown" }
            Write-Host "  - $v ($($template.Name))"
        }
        exit 0
    }

    # Select version
    if ([string]::IsNullOrEmpty($Version)) {
        # Return latest version
        $selected = $sorted[-1]
        $vMatch = [regex]::Match($selected.Name, '_v(\d+)')
        $selectedVersion = if ($vMatch.Success) { "v" + $vMatch.Groups[1].Value } else { "unknown" }
        Write-Verbose "Selecting latest version: $selectedVersion"
    }
    else {
        # Find specific version
        $selected = $sorted | Where-Object { $_.Name -match "_$Version\.html" } | Select-Object -First 1
        if (-not $selected) {
            throw "Template version $Version not found for $TemplateName"
        }
        Write-Verbose "Selecting specified version: $Version"
    }

    Write-Host $selected.FullName
    exit 0
}
catch {
    Write-Error "FAILED: $_"
    exit 1
}
