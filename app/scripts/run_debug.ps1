$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
flutter pub get
flutter run -d windows --dart-define=STORAGE_ENABLED=false
