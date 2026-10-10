<#
.SYNOPSIS
  Tiny HTTP launcher server for the AMT172-Setup-Guide floating toolbar.

.DESCRIPTION
  Listens on http://localhost:9797/ and responds to GET requests:
    /ping              — health check, returns {"status":"ok"}
    /launch?app=<key>  — starts the named application, returns {"status":"launched"}
    /list              — returns all registered apps + whether exe exists

  Start once before using the toolbar:
    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Amt\Migration\tools\Start-AmtLauncher.ps1"

  Leave the window open. Ctrl+C to stop.

.NOTES
  Registered apps and their exe paths are in the $apps hashtable below.
  Add/remove entries as needed — key is the ?app= value used by the toolbar.
#>

$port = 9797

$apps = [ordered]@{
    'liondev'        = 'C:\Amt\Working\Lion\LionDev.exe'
    'cobolconverter' = 'C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\CobolConverterGui\bin\Debug\net8.0-windows\CobolConverterGui.exe'
    'linctolion'     = 'C:\Dev\amt-go-net-net8\AmtLion\Lion\LincToLionGui\bin\Release\net8.0-windows\LincToLionGui.exe'
    'reorg'          = 'C:\Amt\Working\AMTTools\Reorganize\AmtReorganize.exe'
}

# Windows services managed by the toolbar (Start-Service / Stop-Service)
$services = [ordered]@{
    'liondevgennet' = 'LionDevNet_Generator'
}

Add-Type -AssemblyName System.Web

# Win32 helpers — keybd_event trick bypasses Windows focus-stealing prevention
# (SetForegroundWindow alone is blocked unless calling process owns the foreground;
#  simulating Alt-down/up makes Windows treat this process as interactive and allows it)
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinFocus {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte sc, uint flags, int ei);
    public static void ForceToFront(IntPtr hWnd) {
        if (IsIconic(hWnd)) ShowWindow(hWnd, 9);   // SW_RESTORE
        else                ShowWindow(hWnd, 5);    // SW_SHOW
        keybd_event(0x12, 0, 0, 0);                 // Alt key down
        SetForegroundWindow(hWnd);
        keybd_event(0x12, 0, 2, 0);                 // Alt key up (KEYEVENTF_KEYUP)
    }
}
"@

# Runspace pool — runs in the SAME process as the server so Win32 calls are permitted
$rsPool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, 4)
$rsPool.Open()

function Invoke-BringToFrontAsync([int]$procId) {
    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.RunspacePool = $rsPool
    [void]$ps.AddScript({
        param([int]$pid)
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinFocusRS {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte sc, uint flags, int ei);
    public static void ForceToFront(IntPtr hWnd) {
        if (IsIconic(hWnd)) ShowWindow(hWnd, 9);
        else                ShowWindow(hWnd, 5);
        keybd_event(0x12, 0, 0, 0);
        SetForegroundWindow(hWnd);
        keybd_event(0x12, 0, 2, 0);
    }
}
"@ -ErrorAction SilentlyContinue
        $p = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if (-not $p) { return }
        try { $p.WaitForInputIdle(5000) | Out-Null } catch {}
        for ($i = 0; $i -lt 30; $i++) {
            $p.Refresh()
            if ($p.MainWindowHandle -ne [IntPtr]::Zero) { break }
            Start-Sleep -Milliseconds 200
        }
        $h = $p.MainWindowHandle
        if ($h -ne [IntPtr]::Zero) {
            [WinFocusRS]::ForceToFront($h)
        }
    })
    [void]$ps.AddArgument($procId)
    [void]$ps.BeginInvoke()
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")

try { $listener.Start() }
catch {
    Write-Host "ERROR: Could not start listener on port $port." -ForegroundColor Red
    Write-Host "Is another instance already running?" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "  AMT Launcher ready on http://localhost:$port/" -ForegroundColor Green
Write-Host "  Registered apps:" -ForegroundColor Cyan
$apps.GetEnumerator() | ForEach-Object {
    $exists = if (Test-Path $_.Value) { "[OK]" } else { "[MISSING]" }
    Write-Host "    $($_.Key.PadRight(16)) $exists  $($_.Value)" -ForegroundColor $(if ($exists -eq '[OK]') { 'White' } else { 'Red' })
}
Write-Host ""
Write-Host "  Press Ctrl+C to stop." -ForegroundColor DarkGray
Write-Host ""

function Write-Response($ctx, [int]$code, [string]$body) {
    $resp = $ctx.Response
    $resp.Headers.Add("Access-Control-Allow-Origin", "*")
    $resp.Headers.Add("Access-Control-Allow-Methods", "GET, OPTIONS")
    $resp.Headers.Add("Cache-Control", "no-cache")
    $resp.StatusCode  = $code
    $resp.ContentType = "application/json; charset=utf-8"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
    $resp.ContentLength64 = $bytes.Length
    $resp.OutputStream.Write($bytes, 0, $bytes.Length)
    $resp.OutputStream.Close()
}

try {
    while ($listener.IsListening) {
        $ctx  = $listener.GetContext()
        $req  = $ctx.Request
        $path = $req.Url.AbsolutePath

        if ($req.HttpMethod -eq 'OPTIONS') {
            Write-Response $ctx 200 '{}'
            continue
        }

        switch ($path) {
            '/ping' {
                Write-Response $ctx 200 '{"status":"ok"}'
                break
            }
            '/list' {
                $items = $apps.GetEnumerator() | ForEach-Object {
                    $ex = $_.Value -replace '\\','\\\\'
                    $ok = (Test-Path $_.Value).ToString().ToLower()
                "{`"key`":`"$($_.Key)`",`"path`":`"$ex`",`"exists`":$ok}"
                }
                Write-Response $ctx 200 "[$(($items -join ','))]"
                break
            }
            '/svc' {
                $qs     = [System.Web.HttpUtility]::ParseQueryString($req.Url.Query)
                $svcKey = $qs['name']
                $action = $qs['action']   # 'status' | 'start' | 'stop'
                if (-not $svcKey) {
                    Write-Response $ctx 400 '{"status":"error","message":"Missing ?name= parameter"}'
                    break
                }
                if (-not $services.Contains($svcKey)) {
                    Write-Response $ctx 400 "{`"status`":`"error`",`"message`":`"Unknown service: $svcKey`"}"
                    break
                }
                $svcName = $services[$svcKey]
                try {
                    $svc = Get-Service -Name $svcName -ErrorAction Stop
                    if ($action -eq 'start' -and $svc.Status -ne 'Running') {
                        Start-Service -Name $svcName
                        $svc = Get-Service -Name $svcName
                        Write-Host "  Started service: $svcName" -ForegroundColor Green
                    } elseif ($action -eq 'stop' -and $svc.Status -eq 'Running') {
                        Stop-Service -Name $svcName -Force
                        $svc = Get-Service -Name $svcName
                        Write-Host "  Stopped service: $svcName" -ForegroundColor Yellow
                    }
                    $st = $svc.Status.ToString().ToLower()
                    Write-Response $ctx 200 "{`"status`":`"ok`",`"service`":`"$svcName`",`"state`":`"$st`"}"
                } catch {
                    $msg = $_.Exception.Message -replace '"',"'"
                    Write-Response $ctx 500 "{`"status`":`"error`",`"message`":`"$msg`"}"
                }
                break
            }
            '/launch' {
                $qs  = [System.Web.HttpUtility]::ParseQueryString($req.Url.Query)
                $app = $qs['app']
                if (-not $app) {
                    Write-Response $ctx 400 '{"status":"error","message":"Missing ?app= parameter"}'
                    break
                }
                if (-not $apps.Contains($app)) {
                    Write-Response $ctx 400 "{`"status`":`"error`",`"message`":`"Unknown app: $app`"}"
                    break
                }
                $exe = $apps[$app]
                if (-not (Test-Path $exe)) {
                    Write-Response $ctx 404 "{`"status`":`"error`",`"message`":`"Exe not found: $exe`"}"
                    break
                }
                try {
                    $proc = Start-Process -FilePath $exe -PassThru
                    Invoke-BringToFrontAsync -procId $proc.Id
                    Write-Host "  Launched: $app (PID $($proc.Id))" -ForegroundColor Green
                    Write-Response $ctx 200 "{`"status`":`"launched`",`"app`":`"$app`"}"
                } catch {
                    $msg = $_.Exception.Message -replace '"',"'"
                    Write-Response $ctx 500 "{`"status`":`"error`",`"message`":`"
                break
            }
            '/restartgen' {
                try {
                    $svcName = $services['liondevgennet']
                    $svc = Get-Service -Name $svcName -ErrorAction Stop
                    if ($svc.Status -eq 'Running') {
                        Stop-Service -Name $svcName -Force
                        $deadline = (Get-Date).AddSeconds(10)
                        do { Start-Sleep -Milliseconds 300; $svc.Refresh() } while ($svc.Status -ne 'Stopped' -and (Get-Date) -lt $deadline)
                    }
                    Start-Service -Name $svcName
                    $svc.Refresh()
                    $st = $svc.Status.ToString().ToLower()
                    Write-Host "  Restarted: $svcName -> $st" -ForegroundColor Green
                    Write-Response $ctx 200 "{`"status`":`"ok`",`"state`":`"$st`"}"
                } catch {
                    $msg = $_.Exception.Message -replace '"',"'"
                    Write-Response $ctx 500 "{`"status`":`"error`",`"message`":`"$msg`"}"
                }
                break
            }
            '/psadmin' {
                try {
                    Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe' `
                                  -Verb RunAs
                    Write-Host '  Launched: PowerShell ISE (Admin)' -ForegroundColor Green
                    Write-Response $ctx 200 '{"status":"launched","app":"psadmin"}'
                } catch {
                    $msg = $_.Exception.Message -replace '"',"'"
                    Write-Response $ctx 500 "{`"status`":`"error`",`"message`":`"$msg`"}"
                }
                break
            }
            default {
                Write-Response $ctx 404 '{"status":"not found"}'
            }
        }
    }
} finally {
    $listener.Stop()
    $rsPool.Close()
    Write-Host "Launcher stopped." -ForegroundColor Yellow
}
