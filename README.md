# NEXO 360 — versión completa para Android, Windows y Web

Esta entrega sustituye el enfoque MVP. Incluye el código fuente Flutter, reglas de Firebase, migración desde las colecciones del prototipo, dos páginas web, compilación automática de APK/Windows mediante GitHub Actions y documentación paso a paso.

## Qué contiene

- `app/`: aplicación Flutter completa para Android y Windows.
- `firebase/`: reglas de Firestore, reglas de Storage en modo mantenimiento, índices y emuladores.
- `web/eventos/`: página pública de eventos, inscripciones, estado y croquis.
- `web/descargas/`: página de presentación y descarga automática desde GitHub Releases.
- `.github/workflows/`: publicación de las páginas y generación del APK/ZIP de Windows.
- `google_apps_script/`: correo automático opcional sin Cloud Functions.
- `docs/`: configuración, pruebas, Firebase, GitHub, trazabilidad y responsabilidades del usuario.
- `referencias/`: Word, timeline e imágenes originales usados como base.

## Inicio rápido

1. Lee `docs/00_EMPIEZA_AQUI.md`.
2. Copia esta carpeta al repositorio Nexo-360 o reemplaza su contenido en una rama nueva.
3. Despliega `firebase/firestore.rules`.
4. Genera las carpetas Android/Windows ejecutando `app/scripts/bootstrap_windows.ps1`.
5. Ejecuta la app, entra como técnico y usa **Administración técnica → Migrar datos del prototipo**.
6. Sube los cambios a GitHub.
7. Activa GitHub Pages y crea la etiqueta `v2.0.0` para producir los archivos descargables.

## Estado de Storage

`STORAGE_ENABLED=false` es el valor predeterminado. La interfaz conserva todas las opciones de archivos y galería, pero muestra el aviso **“Storage/nube en mantenimiento”**. Los enlaces externos sí funcionan.

## Comprobación realizada en esta entrega

Se verificaron rutas de importación, estructura de carpetas, balance de delimitadores Dart, JSON, JavaScript y archivos requeridos. El entorno que generó este ZIP no incluye Flutter ni Visual Studio, por lo que la validación final `flutter analyze`, `flutter test` y la compilación se ejecutan en tu equipo o en GitHub Actions.
