# Qué ya está hecho y qué debes hacer tú

## Ya está incluido en el ZIP

- Código fuente Flutter de todos los módulos.
- Branding e imágenes suministradas.
- Modo claro/oscuro y paletas.
- FirebaseOptions del proyecto existente.
- Reglas completas de Firestore.
- Storage completamente bloqueado y avisos de mantenimiento.
- Migración de datos del prototipo.
- Página pública de eventos.
- Página de presentación y descargas.
- GitHub Actions para Pages, APK, Windows y Releases.
- Scripts locales de compilación.
- Google Apps Script opcional para correos.
- Pruebas unitarias de QR y cálculo de ponderaciones.
- Plan manual de pruebas.

## Debes hacerlo tú porque requiere tus cuentas/equipo

1. Copiar el ZIP dentro del repositorio local y subirlo a GitHub.
2. Aprobar/fusionar el Pull Request.
3. Activar Email/Password en Firebase Authentication.
4. Asegurar que tu usuario técnico tenga el perfil correcto en Firestore.
5. Desplegar las reglas de Firestore.
6. Ejecutar la migración desde la cuenta técnica.
7. Asignar usuarios reales, cursos, docentes, secciones, horarios y comisiones.
8. Revisar/editar correos y teléfonos institucionales de ejemplo.
9. Instalar Flutter/Android Studio/Visual Studio o usar GitHub Actions.
10. Ejecutar las pruebas con cuentas reales de prueba.
11. Activar GitHub Pages.
12. Crear la etiqueta `v2.0.0`.
13. Descargar/probar el APK y ZIP generados.
14. Configurar Apps Script solo si deseas correos automáticos.

## Lo que no debes hacer

- No habilites Storage si no deseas vincular facturación.
- No publiques tareas privadas en enlaces abiertos.
- No borres `event_registrations` antes de ejecutar y verificar la migración.
- No expongas el secreto de Apps Script en el repositorio.
- No distribuyas únicamente el `.exe` de Windows.
- No uses datos reales de estudiantes durante las primeras pruebas.
