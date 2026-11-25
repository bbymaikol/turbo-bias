# Instala la subida de trades del MT5 al Worker (cada 10 min). Uso en PowerShell del VPS:
#   $k='CLAVE'; irm https://raw.githubusercontent.com/bbymaikol/turbo-bias/main/t.ps1 | iex
New-Item -ItemType Directory -Force C:\turbo | Out-Null
if ($k) { Set-Content -NoNewline C:\turbo\mt5key.txt $k }
@'
$d = Join-Path $env:APPDATA 'MetaQuotes\Terminal\Common\Files'
$k = (Get-Content C:\turbo\mt5key.txt -Raw).Trim()
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
foreach ($f in Get-ChildItem $d -Filter 'turbo_trades*.csv') {
  $n = $f.BaseName -replace '[^A-Za-z0-9_-]', '_'
  try {
    $b = [IO.File]::ReadAllBytes($f.FullName)
    $r = Invoke-WebRequest -UseBasicParsing -Method Post -Uri "https://turbo-alertas.tws565hjf5.workers.dev/mt5/$k/$n" -Body $b -ContentType 'text/csv'
    Add-Content C:\turbo\trades.log ((Get-Date -Format s) + " $n " + $r.Content)
  } catch { Add-Content C:\turbo\trades.log ((Get-Date -Format s) + " $n ERROR " + $_) }
}
'@ | Set-Content C:\turbo\trades.ps1
$a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\turbo\trades.ps1'
$g = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10)
$g2 = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName 'TurboTrades' -Action $a -Trigger @($g,$g2) -Force | Out-Null
Start-ScheduledTask -TaskName 'TurboTrades'; Start-Sleep 10
Get-Content C:\turbo\trades.log -Tail 4
