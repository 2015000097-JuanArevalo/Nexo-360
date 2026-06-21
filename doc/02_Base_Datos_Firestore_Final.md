# NEXO 360 - Base de Datos Firestore Final

**Objetivo:** Definir cómo debe quedar Firestore después de la reestructuración final.  
**Importante:** Esta versión corrige la lógica de permisos y elimina `validate_qr` de Eventos.

---

## 1. Colecciones finales recomendadas

```text
users
school_activities
school_schedules
school_announcements
school_files
attendance_records
grades
permissions
permission_requests
events
event_announcements
event_registrations
event_inventory
event_locations
event_messages
audit_logs
```

---

## 2. Colecciones mínimas para el MVP

Para una primera versión escolar, basta con estas:

```text
users
school_activities
school_schedules
school_announcements
permissions
permission_requests
events
event_announcements
event_registrations
```

---

## 3. Colección `users`

Ruta:

```text
users/{uid}
```

Cada usuario de Firebase Authentication debe tener un documento en `users` con el mismo UID.

---

## 4. Modelo final de usuario

```json
{
  "uid": "UID_DEL_USUARIO",
  "email": "correo@ejemplo.com",
  "displayName": "Nombre Demo",
  "accountType": "student",
  "eventRole": "guest",
  "eventPermissions": [],
  "status": "active",
  "schoolCode": "S-001",
  "classId": "class-10A",
  "committeeId": null,
  "assignedEventIds": [],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 5. Campos principales

| Campo | Descripción |
|---|---|
| `uid` | UID de Firebase Authentication |
| `email` | Correo del usuario |
| `displayName` | Nombre visible |
| `accountType` | Tipo de cuenta principal: `technical`, `teacher`, `student` |
| `eventRole` | Rol en Eventos: `none`, `guest`, `organizer`, `commissioner` |
| `eventPermissions` | Opciones limitadas si es comisionado |
| `status` | `active` o `inactive` |
| `schoolCode` | Código interno |
| `classId` | Clase asignada, si aplica |
| `committeeId` | Comité asignado, si aplica |
| `assignedEventIds` | Eventos asignados |
| `createdAt` | Fecha de creación |
| `updatedAt` | Fecha de actualización |

---

## 6. Cuentas recomendadas para demo

Sí se recomienda dejar de usar cuentas principales separadas de `organizer` y `committee`.

Las cuentas recomendadas son:

| Cuenta | accountType | eventRole |
|---|---|---|
| Técnico Demo | `technical` | `none` |
| Docente Invitado Demo | `teacher` | `guest` |
| Docente Organizador Demo | `teacher` | `organizer` |
| Estudiante Invitado Demo | `student` | `guest` |
| Estudiante Organizador Demo | `student` | `organizer` |
| Estudiante Comisionado Demo | `student` | `commissioner` |

---

## 7. Ejemplo: Técnico Demo

```json
{
  "uid": "UID_TECNICO",
  "email": "technical@nexo360.test",
  "displayName": "Técnico Demo",
  "accountType": "technical",
  "eventRole": "none",
  "eventPermissions": [],
  "status": "active",
  "schoolCode": "T-001",
  "classId": null,
  "committeeId": null,
  "assignedEventIds": [],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 8. Ejemplo: Docente Invitado Demo

```json
{
  "uid": "UID_DOCENTE_INVITADO",
  "email": "teacher.guest@nexo360.test",
  "displayName": "Docente Invitado Demo",
  "accountType": "teacher",
  "eventRole": "guest",
  "eventPermissions": [],
  "status": "active",
  "schoolCode": "D-001",
  "classId": "class-10A",
  "committeeId": null,
  "assignedEventIds": ["event-demo-01"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 9. Ejemplo: Docente Organizador Demo

```json
{
  "uid": "UID_DOCENTE_ORGANIZADOR",
  "email": "teacher.organizer@nexo360.test",
  "displayName": "Docente Organizador Demo",
  "accountType": "teacher",
  "eventRole": "organizer",
  "eventPermissions": [],
  "status": "active",
  "schoolCode": "D-002",
  "classId": "class-10A",
  "committeeId": null,
  "assignedEventIds": ["event-demo-01"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 10. Ejemplo: Estudiante Invitado Demo

```json
{
  "uid": "UID_ESTUDIANTE_INVITADO",
  "email": "student.guest@nexo360.test",
  "displayName": "Estudiante Invitado Demo",
  "accountType": "student",
  "eventRole": "guest",
  "eventPermissions": [],
  "status": "active",
  "schoolCode": "S-001",
  "classId": "class-10A",
  "committeeId": null,
  "assignedEventIds": ["event-demo-01"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 11. Ejemplo: Estudiante Organizador Demo

```json
{
  "uid": "UID_ESTUDIANTE_ORGANIZADOR",
  "email": "student.organizer@nexo360.test",
  "displayName": "Estudiante Organizador Demo",
  "accountType": "student",
  "eventRole": "organizer",
  "eventPermissions": [],
  "status": "active",
  "schoolCode": "S-002",
  "classId": "class-10A",
  "committeeId": null,
  "assignedEventIds": ["event-demo-01"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 12. Ejemplo: Estudiante Comisionado Demo

```json
{
  "uid": "UID_ESTUDIANTE_COMISIONADO",
  "email": "student.commissioner@nexo360.test",
  "displayName": "Estudiante Comisionado Demo",
  "accountType": "student",
  "eventRole": "commissioner",
  "eventPermissions": [
    "view_event_announcements",
    "view_assigned_event",
    "check_in",
    "request_inventory",
    "view_inventory",
    "view_map",
    "create_event_message"
  ],
  "status": "active",
  "schoolCode": "S-003",
  "classId": "class-10A",
  "committeeId": "committee-logistica",
  "assignedEventIds": ["event-demo-01"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 13. Colección `permissions`

Ruta:

```text
permissions/{permissionId}
```

Aquí se guardan permisos reales asignados a estudiantes.

Solo los técnicos pueden crear, editar o eliminar directamente en esta colección.

### Ejemplo

```json
{
  "permissionId": "permission-demo-01",
  "studentId": "UID_ESTUDIANTE",
  "studentName": "Estudiante Demo",
  "classId": "class-10A",
  "reason": "Salida autorizada para actividad escolar",
  "status": "active",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "createdBy": "UID_TECNICO",
  "approvedBy": "UID_TECNICO",
  "createdFromRequestId": null,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Estados recomendados

```text
active
expired
used
cancelled
```

---

## 14. Colección `permission_requests`

Ruta:

```text
permission_requests/{requestId}
```

Aquí se guardan solicitudes hechas por docentes u organizadores.

### Tipos de solicitud

```text
create
update
delete
```

### Estados de solicitud

```text
pending
approved
denied
cancelled
```

---

## 15. Solicitud para crear permiso

```json
{
  "requestType": "create",
  "targetPermissionId": null,
  "requestedBy": "UID_DOCENTE_U_ORGANIZADOR",
  "requestDescription": "Solicito crear permiso para actividad escolar.",
  "status": "pending",
  "proposedData": {
    "studentId": "UID_ESTUDIANTE",
    "reason": "Salida para actividad",
    "startTime": "timestamp",
    "endTime": "timestamp"
  },
  "reviewedBy": null,
  "reviewComment": null,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 16. Solicitud para editar permiso

```json
{
  "requestType": "update",
  "targetPermissionId": "permission-demo-01",
  "requestedBy": "UID_DOCENTE_U_ORGANIZADOR",
  "requestDescription": "Solicito cambiar la hora de salida.",
  "status": "pending",
  "proposedData": {
    "endTime": "timestamp"
  },
  "reviewedBy": null,
  "reviewComment": null,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 17. Solicitud para eliminar permiso

```json
{
  "requestType": "delete",
  "targetPermissionId": "permission-demo-01",
  "requestedBy": "UID_DOCENTE_U_ORGANIZADOR",
  "requestDescription": "Solicito eliminar el permiso porque ya no se usará.",
  "status": "pending",
  "proposedData": {},
  "reviewedBy": null,
  "reviewComment": null,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 18. Nota importante sobre aprobación

Las reglas de Firestore permiten que el técnico apruebe o deniegue una solicitud.

Pero Firestore por sí solo no copia automáticamente la solicitud aprobada a la colección `permissions`.

Para el MVP escolar hay dos opciones simples:

1. El técnico aprueba la solicitud y luego crea/edita/elimina manualmente el permiso en `permissions`.
2. Más adelante se puede automatizar con Cloud Functions, pero no es necesario para esta fase.

---

## 19. Colecciones de Eventos

### `events/{eventId}`

```json
{
  "title": "Evento Demo",
  "description": "Evento de prueba del colegio.",
  "location": "Salón principal",
  "status": "active",
  "isPublic": true,
  "createdBy": "UID_ORGANIZADOR",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### `event_announcements/{announcementId}`

```json
{
  "eventId": "event-demo-01",
  "title": "Aviso del evento",
  "message": "Presentarse a las 8:00.",
  "isPublic": true,
  "createdBy": "UID_ORGANIZADOR",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### `event_registrations/{registrationId}`

```json
{
  "eventId": "event-demo-01",
  "fullName": "Invitado Demo",
  "email": "invitado@example.com",
  "status": "pending",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 20. Colecciones antiguas que ya no se deben usar

```text
announcements
movement_announcements
qr_permissions
assignments
inventory_items
map_locations
committee_messages
```

Nuevos nombres:

| Antes | Ahora |
|---|---|
| `announcements` | `school_announcements` o `event_announcements` |
| `movement_announcements` | `event_announcements` |
| `qr_permissions` | `permissions` |
| `assignments` | `school_activities` |
| `inventory_items` | `event_inventory` |
| `map_locations` | `event_locations` |
| `committee_messages` | `event_messages` |
