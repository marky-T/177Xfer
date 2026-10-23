<#
.SYNOPSIS
  Serves Conversion\Pipeline\ControlCenter\*.js on http://localhost:<Port>/ so the CC page can load cc-actions.js:
    await page.addScriptTag({ url: 'http://localhost:8765/cc-actions.js' })
  Read-only, localhost only, .js files of this folder only. Runs until the terminal is closed.
#>
param([Int32]$Port = 8765)
$root = $PSScriptRoot
$l = [System.Net.HttpListener]::new()
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
"serving $root\*.js on http://localhost:$Port/"
while ($l.IsListening) {
  $ctx = $l.GetContext()
  $name = [IO.Path]::GetFileName($ctx.Request.Url.AbsolutePath)
  $file = Join-Path $root $name
  if ($name -like '*.js' -and (Test-Path $file -PathType Leaf)) {
    $b = [IO.File]::ReadAllBytes($file)
    $ctx.Response.ContentType = 'application/javascript'
    $ctx.Response.Headers.Add('Cache-Control', 'no-store')
    $ctx.Response.OutputStream.Write($b, 0, $b.Length)
  } else { $ctx.Response.StatusCode = 404 }
  $ctx.Response.Close()
}
