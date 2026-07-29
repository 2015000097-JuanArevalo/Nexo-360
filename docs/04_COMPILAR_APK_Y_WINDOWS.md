# Compilar APK y aplicación Windows

## Requisitos en Windows

- Git.
- Flutter estable.
- Android Studio con Android SDK y un dispositivo/emulador.
- Visual Studio 2022 Community con **Desktop development with C++**.
- PowerShell.

Comprueba:

```powershell
flutter doctor -v
```

No continúes hasta que Android toolchain y Visual Studio aparezcan correctos.

## Primera preparación

Desde la raíz del ZIP:

```powershell
cd app
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\bootstrap_windows.ps1
```

Este comando genera las carpetas de plataforma, agrega Internet/Cámara en Android, obtiene paquetes y genera los iconos con el logo proporcionado.

## Probar en Windows

```powershell
.\scripts\run_debug.ps1
```

O:

```powershell
flutter run -d windows --dart-define=STORAGE_ENABLED=false
```

## Crear APK

```powershell
.\scripts\build_android.ps1
```

Resultado:

```text
NEXO_360_COMPLETO/NEXO-360-Android.apk
```

Comando manual equivalente:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=STORAGE_ENABLED=false
```

El APK se encuentra inicialmente en:

```text
app/build/app/outputs/flutter-apk/app-release.apk
```

Para instalar mediante USB:

```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

## Crear Windows

```powershell
.\scripts\build_windows.ps1
```

Resultado:

```text
NEXO_360_COMPLETO/NEXO-360-Windows.zip
```

No distribuyas solo `nexo_360.exe`. Debe permanecer junto con sus DLL y la carpeta `data`.

## Correos automáticos opcionales

Añade los defines al comando de build:

```powershell
flutter build windows --release `
  --dart-define=STORAGE_ENABLED=false `
  --dart-define=EMAIL_WEBHOOK_URL="URL_DE_APPS_SCRIPT" `
  --dart-define=EMAIL_WEBHOOK_SECRET="SECRETO"
```

Haz lo mismo para `flutter build apk`.

## Fallos comunes

- `Unable to find Visual Studio toolchain`: instala Desktop development with C++.
- `cmdline-tools component is missing`: Android Studio → SDK Manager → SDK Tools → Android SDK Command-line Tools.
- Cámara no disponible en Windows: utiliza validación manual o prueba el escáner en Android.
- `PERMISSION_DENIED`: despliega las reglas y verifica el documento `users/{uid}`.
- Página sin datos: crea eventos públicos y marca `isPublic=true`.

## Lectura de QR por plataforma

Android usa la cámara para los QR de estudiante, permisos y pantalla interactiva. En Windows se utiliza la entrada manual del código o enlace porque el paquete de cámara utilizado no ofrece implementación para Windows.
