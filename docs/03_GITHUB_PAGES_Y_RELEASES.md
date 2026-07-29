# GitHub, páginas y archivos descargables

## 1. Sustituir el repositorio

Trabaja en una rama:

```powershell
git clone https://github.com/2015000097-JuanArevalo/Nexo-360.git
cd Nexo-360
git switch -c version-completa
```

Copia el contenido del ZIP en esta carpeta sin borrar `.git`.

```powershell
git status
git add .
git commit -m "Implement complete NEXO 360 application"
git push -u origin version-completa
```

En GitHub crea un Pull Request de `version-completa` hacia `main`, revísalo y fusiónalo.

## 2. Publicar las dos páginas gratis

El workflow `.github/workflows/pages.yml` publica toda la carpeta `web/`.

En GitHub:

```text
Settings → Pages → Build and deployment → Source → GitHub Actions
```

Después abre:

```text
https://2015000097-juanarevalo.github.io/Nexo-360/eventos/
https://2015000097-juanarevalo.github.io/Nexo-360/descargas/
```

Si el nombre de usuario o repositorio cambia, modifica las URLs predeterminadas en:

```text
app/lib/core/config/app_config.dart
```

## 3. Crear APK y Windows automáticamente

El repositorio es público, por lo que el workflow usa runners estándar de GitHub Actions.

Crea la versión:

```powershell
git switch main
git pull
git tag v2.0.0
git push origin v2.0.0
```

El workflow `.github/workflows/build-release.yml` ejecutará:

```text
flutter analyze
flutter test
flutter build apk --release
flutter build windows --release
```

Después crea un GitHub Release con estos nombres exactos:

```text
NEXO-360-Android.apk
NEXO-360-Windows.zip
```

La página de descargas consulta la API pública de GitHub y los muestra automáticamente.

## 4. Ejecutar el build sin etiqueta

```text
GitHub → Actions → Build APK and Windows Release → Run workflow
```

Esto genera artifacts temporales, pero no un Release. Para que aparezcan en la página, crea una etiqueta `v...`.

## 5. Actualizaciones futuras

1. Cambia `version:` en `app/pubspec.yaml`, por ejemplo `2.0.1+21`.
2. Trabaja en una rama nueva.
3. Ejecuta pruebas.
4. Fusiona en `main`.
5. Crea una etiqueta nueva:

```powershell
git tag v2.0.1
git push origin v2.0.1
```

La web siempre mostrará el Release más reciente.
