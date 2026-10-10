try {
    Get-Content 'manifest\programs.manifest.json' -Raw | ConvertFrom-Json | Out-Null
    Write-Host 'JSON valid'
} catch {
    Write-Host "JSON ERROR: $_"
}
