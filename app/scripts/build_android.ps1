$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
flutter clean
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --release --dart-define=STORAGE_ENABLED=false
Copy-Item "build/app/outputs/flutter-apk/app-release.apk" "../NEXO-360-Android.apk" -Force
Write-Host "APK creado en NEXO_360_COMPLETO/NEXO-360-Android.apk"
