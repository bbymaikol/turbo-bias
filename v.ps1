# Actualiza TurboB.ex5/.mq5 en todos los MT5 del VPS desde el Worker (usa la clave de C:\turbo\mt5key.txt).
$k = (Get-Content C:\turbo\mt5key.txt -Raw).Trim()
$u = "https://turbo-alertas.tws565hjf5.workers.dev/mt5/$k"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ex = [Convert]::FromBase64String((Invoke-WebRequest -UseBasicParsing "$u/ea_ex5").Content)
$mq = [Convert]::FromBase64String((Invoke-WebRequest -UseBasicParsing "$u/ea_mq5").Content)
$log = @()
foreach ($f in Get-ChildItem (Join-Path $env:APPDATA 'MetaQuotes\Terminal') -Recurse -Filter 'TurboB.ex5' -ErrorAction SilentlyContinue) {
  if ($f.FullName -notmatch '\\MQL5\\Experts\\') { continue }
  [IO.File]::WriteAllBytes($f.FullName, $ex)
  [IO.File]::WriteAllBytes(($f.FullName -replace '\.ex5$', '.mq5'), $mq)
  $log += "$(Get-Date -Format s) actualizado $($f.FullName) ($($ex.Length) bytes)"
}
if (-not $log) { $log = "$(Get-Date -Format s) NO se encontró TurboB.ex5" }
$log | Add-Content C:\turbo\ea.log; $log
