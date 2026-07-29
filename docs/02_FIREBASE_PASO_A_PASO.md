# Firebase: cambios exactos

Proyecto detectado en la versión anterior:

```text
nexo-360-9ed4c
```

No crees otro proyecto salvo que quieras abandonar los datos actuales.

## 1. Authentication

En Firebase Console:

```text
Build → Authentication → Sign-in method → Email/Password → Enable
```

No habilites el inicio de sesión anónimo.

Verifica que exista al menos una cuenta técnica. Copia su UID y crea/actualiza este documento:

```text
users/{UID_TECNICO}
```

Campos mínimos:

```json
{
  "email": "tu-correo",
  "displayName": "Administrador técnico",
  "accountType": "technical",
  "eventRole": "organizer",
  "status": "active",
  "schoolCode": "TEC-001",
  "classId": "",
  "courseIds": [],
  "committeeId": "",
  "eventPermissions": []
}
```

## 2. Firestore

No borres las colecciones antiguas. La app incluye una migración conservadora.

Instala Firebase CLI:

```powershell
npm install -g firebase-tools
firebase login
```

Desde la carpeta `firebase`:

```powershell
Copy-Item .firebaserc.example .firebaserc
firebase use nexo-360-9ed4c
firebase deploy --only firestore:rules,firestore:indexes
```

También puedes copiar manualmente `firestore.rules` en:

```text
Firestore Database → Rules
```

Las reglas nuevas corrigen el seguimiento público: los datos personales quedan en `event_registration_requests`; la web solo puede leer `public_registration_status/{código}`.

## 3. Storage

No lo actives. La entrega usa:

```text
STORAGE_ENABLED=false
```

`firebase/storage.rules` niega todas las operaciones. Esto evita que una configuración incompleta exponga archivos.

Todos los módulos mantienen el botón de adjuntar, pero muestran:

```text
Storage/nube en mantenimiento
```

Usa enlaces de YouTube, Google Drive con permisos adecuados, OneDrive u otra página pública para materiales no confidenciales. No uses enlaces públicos para tareas privadas o documentos con datos personales.

## 4. Ejecutar la migración

Después de desplegar las reglas y abrir la nueva app:

```text
Administración técnica → Migrar datos del prototipo
```

La migración:

- Lee `event_registrations` y copia a `event_registration_requests`.
- Crea estados seguros en `public_registration_status`.
- Conserva la colección original.
- Añade campos nuevos a `school_activities`.
- Clasifica eventos antiguos como escolares.
- Completa listas y campos faltantes en usuarios.
- Registra un resumen en `audit_logs`.

Luego ejecuta:

```text
Administración técnica → Crear datos iniciales
```

Esto crea cursos de ejemplo, períodos, el evento Juventud 2026, FAQ y los doce puntos del croquis.

## 5. Colecciones finales

```text
users
directory_profiles
courses
course_materials
school_activities
activity_submissions
school_announcements
announcement_reads
timetable_periods
pedagogical_diary
attendance_records
conduct_events
grade_items
grade_scores
school_messages
permissions
permission_requests
events
event_registration_requests
public_registration_status
event_live_locations
event_announcements
event_gallery_items
event_faqs
committees
committee_messages
direct_messages
committee_requests
inventory_items
budget_items
app_settings
audit_logs
```

## 6. Correos sin Cloud Functions

La app funciona sin correo automático: abre `mailto:` con el mensaje listo.

Para correo automático gratuito de bajo volumen:

1. Abre Google Apps Script.
2. Crea un proyecto y pega `google_apps_script/Code.gs`.
3. Cambia `SECRET` por una cadena larga.
4. Implementa como Aplicación web, ejecutando como tu cuenta y con acceso para cualquiera.
5. Copia la URL terminada en `/exec`.
6. Compila así:

```powershell
flutter build apk --release `
  --dart-define=STORAGE_ENABLED=false `
  --dart-define=EMAIL_WEBHOOK_URL="URL_DE_APPS_SCRIPT" `
  --dart-define=EMAIL_WEBHOOK_SECRET="TU_SECRETO"
```

El secreto dentro de una aplicación cliente no equivale a un backend de alta seguridad. Esta opción es adecuada para un proyecto escolar de bajo volumen; mantén el webhook únicamente para correos de estado y cambia el secreto si se filtra.

## 7. Probar reglas localmente

```powershell
cd firebase
firebase emulators:start
```

La app no cambia automáticamente a emuladores. Esta opción sirve principalmente para inspeccionar reglas desde la Emulator UI. La validación práctica final debe hacerse contra el proyecto real con cuentas de prueba.
