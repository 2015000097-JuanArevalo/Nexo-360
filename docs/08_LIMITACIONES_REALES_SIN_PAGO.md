# Limitaciones reales sin pago

La aplicación funciona con Firebase Authentication y Firestore en Spark mientras permanezca dentro de las cuotas gratuitas. No usa Cloud Functions, Cloud Run ni Cloud Storage.

## Archivos y galería

La carga binaria directa permanece desactivada. Se conserva la interfaz y se muestra el aviso de mantenimiento. Para material público se pueden guardar enlaces externos.

Opciones sin costo que no sustituyen un Storage privado:

- GitHub Releases: útil para APK, ZIP, reglamentos y archivos públicos del proyecto.
- GitHub Pages: útil para imágenes y archivos públicos pequeños incluidos en el repositorio.
- Google Drive/OneDrive: enlaces compartidos manualmente; la seguridad depende de los permisos del enlace.

Ninguna de esas opciones debe usarse para entregas privadas de estudiantes, autorizaciones con datos personales o expedientes. La entrega mantiene esos campos desactivados para evitar exposición.

## Correos

El flujo predeterminado abre el cliente de correo del organizador. Apps Script puede automatizar un volumen pequeño, pero tiene cuotas diarias y no es un backend institucional.

## Notificaciones

Los avisos y recordatorios aparecen dentro de la app en tiempo real. Las notificaciones push en segundo plano requerirían una fuente confiable que envíe mensajes FCM; no se incluye porque Cloud Functions no está disponible en Spark.

## Disponibilidad

Cuando se alcanza una cuota gratuita, Firebase puede bloquear temporalmente ese producto hasta que se reinicie la cuota. Revisa periódicamente el panel de uso de Firebase.
