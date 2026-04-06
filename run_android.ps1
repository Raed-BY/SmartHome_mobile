$ErrorActionPreference = 'SilentlyContinue'

$adb = 'C:\Users\raedb\AppData\Local\Android\sdk\platform-tools\adb.exe'

Write-Host 'Cleaning stale Flutter/Dart processes...'
Get-Process -Name dart,flutter -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host 'Resetting ADB forwards...'
& $adb start-server | Out-Null
& $adb -s emulator-5554 forward --remove-all | Out-Null

Write-Host 'Launching mobile app on emulator-5554 (no DDS, no Impeller)...'
flutter run -d emulator-5554 --no-dds --no-enable-impeller
