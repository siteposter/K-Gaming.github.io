$port = $null
foreach ($candidate in 4173..4176) {
  $listener = [System.Net.HttpListener]::new()
  try {
    $listener.Prefixes.Add("http://localhost:$candidate/")
    $listener.Start()
    $port = $candidate
    break
  } catch {
    $listener.Close()
  }
}
if (-not $port) { throw "No available port" }
Write-Output "Static game catalog available at http://localhost:$port/"
while ($listener.IsListening) {
  $context = $listener.GetContext()
  $path = $context.Request.Url.AbsolutePath
  if ($path -eq '/' -or $path -eq '/index.html') {
    $filePath = Join-Path $PSScriptRoot 'index.html'
    $context.Response.ContentType = 'text/html; charset=utf-8'
    $context.Response.StatusCode = 200
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $context.Response.StatusCode = 404
  }
  $context.Response.Close()
}
