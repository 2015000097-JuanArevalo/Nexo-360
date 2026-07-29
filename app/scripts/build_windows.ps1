$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
flutter clean
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build windows --release --dart-define=STORAGE_ENABLED=false
Compress-Archive -Path "build/windows/x64/runner/Release/*" -DestinationPath "../NEXO-360-Windows.zip" -Force
Write-Host "Windows creado en NEXO_360_COMPLETO/NEXO-360-Windows.zip"
