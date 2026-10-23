#-------------------------------------------------------------------------------
# AMT PowerShell Customer Library (empty base)
#
# This module is imported by AmtPsEclLib.psm1 and serves as the extension point
# for customer-specific functions. Add customer-specific overrides or additional
# functions here as needed.
#-------------------------------------------------------------------------------

# Minimal stub: several T3 SsgConverter-generated programs (e.g. CONDIS2_ASCII,
# TABAN_ASCII) call Log-Message for diagnostic output; it has no real implementation
# in this bundle. AMT172's original fix (T3-011, marky-T/177Xfer branch
# T3-LiveRun-Results-20261001) logged to host only; extended here to write into the
# real per-job AmtPsEclLib joblog (Write-JobLog) instead, so the message actually
# persists in the AMT joblog rather than only a transient console stream.
# $Level arrives as the literal string "([LogMessageType]::Information)" (an
# SsgConverter quoting quirk - LogMessageType isn't evaluated, just text) - parse the
# severity word out of it and map to the real runtime's [LoggingSeverity] enum.
function Log-Message {
  param(
    [string]$Message,
    [string]$Level = ''
  )
  $severity = [LoggingSeverity]::Info
  if ($Level -match '::\s*(\w+)') {
    switch ($Matches[1]) {
      'Error'   { $severity = [LoggingSeverity]::Error }
      'Warning' { $severity = [LoggingSeverity]::Warning }
      'Debug'   { $severity = [LoggingSeverity]::Debug }
      default   { $severity = [LoggingSeverity]::Info }
    }
  }
  Write-JobLog $Message $severity
}

