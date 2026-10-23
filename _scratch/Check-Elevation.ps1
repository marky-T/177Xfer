Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class Elev {
  [DllImport("kernel32.dll", SetLastError = true)] static extern IntPtr OpenProcess(uint a, bool i, int pid);
  [DllImport("advapi32.dll", SetLastError = true)] static extern bool OpenProcessToken(IntPtr p, uint a, out IntPtr t);
  [DllImport("advapi32.dll", SetLastError = true)] static extern bool GetTokenInformation(IntPtr t, int c, out int v, int l, out int r);
  [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
  public static string Check(int pid) {
    IntPtr p = OpenProcess(0x1000, false, pid);
    if (p == IntPtr.Zero) return "cannot open process (error " + Marshal.GetLastWin32Error() + ")";
    IntPtr t;
    if (!OpenProcessToken(p, 0x0008, out t)) { int e = Marshal.GetLastWin32Error(); CloseHandle(p); return "cannot read token (error " + e + "): it runs at a higher level than this shell, i.e. ELEVATED"; }
    int v, r; bool ok = GetTokenInformation(t, 20, out v, 4, out r);
    CloseHandle(t); CloseHandle(p);
    return ok ? (v != 0 ? "ELEVATED" : "NOT elevated") : "unknown";
  }
}
'@
Get-Process -Name LionDevGenNet, LionDev -ErrorAction SilentlyContinue | ForEach-Object { '{0,-14} pid={1,-6} {2}' -f $_.ProcessName, $_.Id, [Elev]::Check($_.Id) }
