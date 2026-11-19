New-Item -ItemType Directory -Force C:\turbo | Out-Null
@'
$d = Join-Path $env:APPDATA 'MetaQuotes\Terminal\Common\Files'
New-Item -ItemType Directory -Force $d | Out-Null
$t = Join-Path $d 'turbo_bias.csv.tmp'
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -UseBasicParsing -Headers @{Accept='application/vnd.github.raw'; 'User-Agent'='turbo'} -Uri 'https://api.github.com/repos/bbymaikol/turbo-bias/contents/turbo_bias.csv' -OutFile $t
  if ((Get-Item $t).Length -gt 20) { Move-Item -Force $t (Join-Path $d 'turbo_bias.csv') }
  Add-Content C:\turbo\bias.log ((Get-Date -Format s) + ' ok')
} catch { Add-Content C:\turbo\bias.log ((Get-Date -Format s) + ' ERROR ' + $_) }
'@ | Set-Content C:\turbo\bias.ps1
$a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\turbo\bias.ps1'
$g = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10)
$g2 = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName 'TurboBias' -Action $a -Trigger @($g,$g2) -Force | Out-Null
Start-ScheduledTask -TaskName 'TurboBias'; Start-Sleep 8
Get-Content C:\turbo\bias.log -Tail 2
Get-Content (Join-Path $env:APPDATA 'MetaQuotes\Terminal\Common\Files\turbo_bias.csv') -Tail 3
