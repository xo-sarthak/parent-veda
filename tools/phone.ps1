# =============================================================================
#  phone.ps1 — quick wireless ADB connect for the dev phone
# -----------------------------------------------------------------------------
#  Usage:
#    .\tools\phone.ps1 -Arm          # run ONCE with the phone on USB: enables
#                                     # wireless mode (tcpip 5555) + saves phone IP
#    .\tools\phone.ps1               # later, wireless: reconnects using saved IP
#    .\tools\phone.ps1 -Ip 192.168.x.y   # connect to an explicit IP
#    .\tools\phone.ps1 -Run          # connect, then `flutter run` on the phone
#
#  The saved IP lives in tools\.phone-ip (gitignored). If the phone reboots,
#  re-run with -Arm over USB once.
# =============================================================================
param(
  [switch]$Arm,
  [switch]$Run,
  [string]$Ip
)

$ipFile = Join-Path $PSScriptRoot ".phone-ip"

if ($Arm) {
  Write-Host "Arming wireless debugging (phone must be on USB)..." -ForegroundColor Cyan
  adb devices
  # grab the phone's wlan IP from the device itself
  $line = adb shell ip -f inet addr show wlan0 2>$null | Select-String "inet "
  if ($line) {
    $Ip = ($line -split "\s+")[2].Split("/")[0]
    Set-Content -Path $ipFile -Value $Ip -Encoding ascii
    Write-Host "Phone IP detected and saved: $Ip" -ForegroundColor Green
  } else {
    Write-Host "Could not auto-detect IP. Find it in Settings > Wi-Fi > (your network) > IP address, then run: .\tools\phone.ps1 -Ip <ip>" -ForegroundColor Yellow
  }
  adb tcpip 5555
  Start-Sleep -Seconds 1
}

if (-not $Ip) {
  if (Test-Path $ipFile) { $Ip = (Get-Content $ipFile -Raw).Trim() }
}
if (-not $Ip) {
  Write-Host "No IP known. Run once over USB:  .\tools\phone.ps1 -Arm" -ForegroundColor Red
  exit 1
}

Write-Host "Connecting to $Ip`:5555 ..." -ForegroundColor Cyan
adb connect "$($Ip):5555"
adb devices -l

if ($Run) {
  Write-Host "Launching flutter run on the phone..." -ForegroundColor Cyan
  flutter run -d "$($Ip):5555"
}
