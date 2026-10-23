<#
  Manage-FederaleServices.ps1  —  Area D operational helper

  Start/Stop/Restart the "Federale*" Windows services (BatchController, FileController,
  PrintController, TransactionServer, ControlCenter + BusinessLogic, BlazorApi/Client) in a
  dependency-aware order: core controllers first on start / last on stop, web/UI layer the
  opposite way round. Discovers services dynamically (Get-Service -Name 'Federale*') rather than
  hardcoding exact service names, so it still works if a name differs slightly on this VM.

  Requires an ELEVATED (Administrator) PowerShell session - Start-Service/Stop-Service fail with
  "Access is denied" otherwise (same issue hit earlier with LionDevNet_Generator).

  Usage:
    .\Manage-FederaleServices.ps1 -Action Stop
    .\Manage-FederaleServices.ps1 -Action Start
    .\Manage-FederaleServices.ps1 -Action Restart
    .\Manage-FederaleServices.ps1 -Action Restart -WhatIf   # just show the order, don't act
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory)][ValidateSet('Start','Stop','Restart')][string]$Action,
  [string]$NamePattern = 'Federale*',
  [int]$TimeoutSeconds = 60
)
$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  Write-Warning "Not running elevated - Start-Service/Stop-Service will fail with 'Access is denied'. Re-run from an Administrator PowerShell."
}

# Core controllers/servers load first (start) / stop last; web/UI layer is the other way round.
# Matched by regex against the service Name; anything unmatched sorts to the end (start) /
# start (stop) - i.e. treated as "web/UI layer" by default, the safer assumption.
$startOrderPatterns = @(
  'FileController',
  'PrintController',
  'TransactionServer',
  'BatchController',
  'ControlCenterBusinessLogic',
  'BusinessLogic',
  'ControlCenter(?!.*BusinessLogic)',
  'BlazorApi',
  'BlazorClient'
)

function Get-ServiceRank {
  param([string]$Name)
  for ($i = 0; $i -lt $startOrderPatterns.Count; $i++) {
    if ($Name -match $startOrderPatterns[$i]) { return $i }
  }
  return $startOrderPatterns.Count
}

$services = Get-Service -Name $NamePattern -ErrorAction SilentlyContinue
if (-not $services) { throw "No services matched '$NamePattern'." }

$ranked = $services | ForEach-Object {
  [PSCustomObject]@{ Service = $_; Name = $_.Name; Rank = (Get-ServiceRank $_.Name) }
}

$startOrder = $ranked | Sort-Object Rank, Name
$stopOrder  = $ranked | Sort-Object @{Expression='Rank';Descending=$true}, Name

function Invoke-StopAll {
  Write-Host "`n=== STOP order ==="
  foreach ($r in $stopOrder) {
    $svc = $r.Service
    if ($svc.Status -eq 'Stopped') { Write-Host "SKIP (already stopped): $($svc.Name)"; continue }
    if (-not $PSCmdlet.ShouldProcess($svc.Name, 'Stop-Service')) { continue }
    Write-Host "Stopping $($svc.Name) ..."
    Stop-Service -Name $svc.Name -Force -ErrorAction Stop
    $null = $svc.WaitForStatus('Stopped', (New-TimeSpan -Seconds $TimeoutSeconds))
  }
}

function Invoke-StartAll {
  Write-Host "`n=== START order ==="
  foreach ($r in $startOrder) {
    $svc = $r.Service
    $svc.Refresh()
    if ($svc.Status -eq 'Running') { Write-Host "SKIP (already running): $($svc.Name)"; continue }
    if (-not $PSCmdlet.ShouldProcess($svc.Name, 'Start-Service')) { continue }
    Write-Host "Starting $($svc.Name) ..."
    Start-Service -Name $svc.Name -ErrorAction Stop
    $null = $svc.WaitForStatus('Running', (New-TimeSpan -Seconds $TimeoutSeconds))
  }
}

switch ($Action) {
  'Stop'    { Invoke-StopAll }
  'Start'   { Invoke-StartAll }
  'Restart' { Invoke-StopAll; Invoke-StartAll }
}

Write-Host "`n=== Final status ==="
Get-Service -Name $NamePattern | Sort-Object Name | Select-Object Name, Status, StartType | Format-Table -AutoSize
