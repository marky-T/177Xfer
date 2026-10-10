<#
.SYNOPSIS
  Opens an elevated PowerShell session running as a chosen admin account.

.DESCRIPTION
  1. Discovers members of the local Administrators group.
  2. Presents them in a selection grid (Out-GridView).
  3. Prompts for the password of the chosen account.
  4. Launches a new PowerShell window running as that user.
     (Because the target account is a local/domain admin the resulting
      process has a full admin token — no secondary UAC prompt needed.)
#>

# ── 1. Discover local Administrators group members ─────────────────────────────
$admins = try {
    Get-LocalGroupMember -Group 'Administrators' -ErrorAction Stop |
        Where-Object { $_.ObjectClass -eq 'User' } |
        Select-Object @{N='Account'; E={ $_.Name }},
                      @{N='Source';  E={ $_.PrincipalSource }}
} catch {
    # Fallback if Get-LocalGroupMember unavailable
    @([PSCustomObject]@{ Account = "$env:USERDOMAIN\$env:USERNAME"; Source = 'Local' })
}

if (-not $admins) {
    [System.Windows.Forms.MessageBox]::Show(
        'No local administrator accounts found.',
        'AMT Launcher – PowerShell Admin',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
    exit
}

# ── 2. Select account ──────────────────────────────────────────────────────────
$selected = $admins |
    Out-GridView -Title 'AMT Launcher — Select admin account' -OutputMode Single

if (-not $selected) { exit }   # user cancelled

# ── 3. Prompt for credentials ──────────────────────────────────────────────────
$cred = Get-Credential -UserName $selected.Account `
                       -Message  "Password for $($selected.Account)"

if (-not $cred) { exit }       # user cancelled

# ── 4. Launch PowerShell as that user via runas.exe ───────────────────────────
#    runas.exe always prompts for the password in its own secure dialog and
#    reliably opens a proper interactive console — no split-token issues.
#    The /noprofile flag keeps startup fast; remove it if you need the profile.
$account = $cred.UserName
$pass    = $cred.GetNetworkCredential().Password

# Split domain\user or user@domain for runas /user: syntax
$runasUser = if ($account -match '\\') { $account } `
             elseif ($account -match '@') { $account } `
             else { "$env:COMPUTERNAME\$account" }

try {
    # Use cmd /c start to get a new interactive window with proper stdin/stdout
    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $ps1exe = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
    $psi.FileName               = 'runas.exe'
    $psi.Arguments              = "/user:`"$runasUser`" /noprofile `"$ps1exe -NoExit -NoProfile -ExecutionPolicy RemoteSigned`""
    $psi.UseShellExecute        = $false
    $psi.RedirectStandardInput  = $true
    $psi.CreateNoWindow         = $false

    $proc = [System.Diagnostics.Process]::Start($psi)
    # runas reads the password from stdin when RedirectStandardInput is true
    $proc.StandardInput.WriteLine($pass)
    $proc.StandardInput.Flush()
} catch {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Could not start PowerShell as $($account):`n$($_.Exception.Message)",
        'AMT Launcher – PowerShell Admin',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}
