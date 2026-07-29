$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host "Creando plataformas Android y Windows..."
flutter create --platforms=android,windows,web --org com.example --project-name nexo_360 .

$manifest = "android/app/src/main/AndroidManifest.xml"
$content = Get-Content $manifest -Raw
if ($content -notmatch "android.permission.CAMERA") {
  $content = $content.Replace(
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android">',
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android">' + "`r`n    <uses-permission android:name=`"android.permission.INTERNET`"/>`r`n    <uses-permission android:name=`"android.permission.CAMERA`"/>"
  )
  Set-Content $manifest $content -Encoding UTF8
}

$gradle = "android/app/build.gradle.kts"
$gradleContent = Get-Content $gradle -Raw
$gradleContent = $gradleContent.Replace("minSdk = flutter.minSdkVersion", "minSdk = 23")
Set-Content $gradle $gradleContent -Encoding UTF8

flutter pub get
dart run flutter_launcher_icons -f flutter_launcher_icons_android.yaml
dart run flutter_launcher_icons -f flutter_launcher_icons_windows.yaml
Write-Host "Plataformas creadas. Ejecuta build_android.ps1 o build_windows.ps1."
