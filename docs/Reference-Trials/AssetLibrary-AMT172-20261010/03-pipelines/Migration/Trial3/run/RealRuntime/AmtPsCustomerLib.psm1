#-------------------------------------------------------------------------------
# AMT PowerShell Customer Library (empty base)
#
# This module is imported by AmtPsEclLib.psm1 and serves as the extension point
# for customer-specific functions. Add customer-specific overrides or additional
# functions here as needed.
#-------------------------------------------------------------------------------

# Minimal stub: several T3 SsgConverter-generated programs (e.g. CONDIS2_ASCII,
# TABAN_ASCII) call Log-Message for diagnostic output; it has no real implementation
# in this bundle. Log to host only - not business logic, safe no-op equivalent.
function Log-Message {
  param(
    [string]$Message,
    [string]$Level = ''
  )
  Write-Host "[Log-Message] $Message $Level"
}
