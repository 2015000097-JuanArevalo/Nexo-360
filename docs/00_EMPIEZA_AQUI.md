# Empieza aquí

## Resultado de la entrega

El ZIP ya contiene el código para la versión completa solicitada, con estas decisiones:

- Plataformas de la aplicación: Android y Windows.
- Páginas: eventos/Movimiento Juventud y presentación/descargas.
- Base de datos: el proyecto Firebase existente `nexo-360-9ed4c`.
- Plan Firebase: Spark, sin tarjeta ni Cloud Storage.
- Archivos: botones visibles con aviso de mantenimiento; enlaces permitidos.
- Correos: cliente de correo prellenado de forma predeterminada; Apps Script gratuito opcional para automatizarlos.
- Publicación gratuita: GitHub Pages y GitHub Releases.

## Orden exacto

1. Haz una copia de seguridad local del repositorio actual:

```powershell
git clone https://github.com/2015000097-JuanArevalo/Nexo-360.git
cd Nexo-360
git switch -c version-completa
```

2. Copia el contenido de este ZIP dentro del repositorio. Conserva `.git/`.

3. Configura Firebase siguiendo `02_FIREBASE_PASO_A_PASO.md`.

4. Instala Flutter, Android Studio y Visual Studio según `04_COMPILAR_APK_Y_WINDOWS.md`.

5. Desde PowerShell:

```powershell
cd app
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\bootstrap_windows.ps1
flutter run -d windows --dart-define=STORAGE_ENABLED=false
```

6. Inicia sesión con la cuenta técnica existente. Abre:

```text
Administración → Migrar datos del prototipo
Administración → Crear datos iniciales
Administración → Diagnóstico Firebase
```

7. Prueba todo con `06_PLAN_DE_PRUEBAS.md`.

8. Sube la rama y crea el Pull Request siguiendo `03_GITHUB_PAGES_Y_RELEASES.md`.

9. Al fusionar en `main`, GitHub Pages publicará las dos páginas. Al crear `v2.0.0`, Actions generará:

```text
NEXO-360-Android.apk
NEXO-360-Windows.zip
```

La segunda página los detectará automáticamente desde GitHub Releases.
