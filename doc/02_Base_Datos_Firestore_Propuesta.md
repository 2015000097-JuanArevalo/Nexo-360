# 02 - Base de Datos Firestore Propuesta

**Proyecto:** NEXO 360  
**Objetivo:** Definir la estructura completa recomendada de Firestore después de la reestructuración.

---

## 1. Colecciones principales

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

Para una primera versión funcional, estas colecciones son suficientes:

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

Cada usuario de Firebase Authentication debe tener un documento en `users`.

### Modelo base

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

### Campos

| Campo | Descripción |
|---|---|
| `uid` | UID del usuario en Firebase Authentication |
| `email` | Correo del usuario |
| `displayName` | Nombre visible |
| `accountType` | Tipo de cuenta: `technical`, `teacher`, `student` |
| `eventRole` | Rol en Eventos: `none`, `guest`, `commissioner`, `organizer` |
| `eventPermissions` | Opciones disponibles si es comisionado |
| `status` | `active` o `inactive` |
| `schoolCode` | Código interno |
| `classId` | Clase asignada |
| `committeeId` | Comisión asignada |
| `assignedEventIds` | Eventos asignados |
| `createdAt` | Fecha de creación |
| `updatedAt` | Fecha de actualización |

---

## 4. Usuarios de prueba recomendados

Sí se recomienda eliminar o dejar de usar las cuentas principales de `organizer` y `committee`.

Ahora solo deben existir cuentas principales de tipo:

```text
technical
teacher
student
```

### Cuentas recomendadas para demo

| Cuenta | `accountType` | `eventRole` | Uso |
|---|---|---|---|
| Técnico Demo | `technical` | `none` | Administra todo |
| Docente Invitado Demo | `teacher` | `guest` | Docente que participa en eventos |
| Docente Organizador Demo | `teacher` | `organizer` | Docente que organiza eventos |
| Estudiante Invitado Demo | `student` | `guest` | Estudiante normal que participa |
| Estudiante Organizador Demo | `student` | `organizer` | Estudiante que organiza |
| Estudiante Comisionado Demo | `student` | `commissioner` | Estudiante con opciones limitadas |

---

## 5. Ejemplos de usuarios

### Técnico Demo

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

### Docente Invitado Demo

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

### Docente Organizador Demo

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

### Estudiante Invitado Demo

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

### Estudiante Organizador Demo

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

### Estudiante Comisionado Demo

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
    "validate_qr",
    "request_inventory",
    "view_map"
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

## 6. `school_activities`

Ruta:

```text
school_activities/{activityId}
```

```json
{
  "title": "Actividad de matemática",
  "description": "Resolver ejercicios de práctica.",
  "classId": "class-10A",
  "createdBy": "UID_DOCENTE",
  "status": "published",
  "dueDate": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 7. `school_schedules`

Ruta:

```text
school_schedules/{scheduleId}
```

```json
{
  "classId": "class-10A",
  "day": "lunes",
  "startTime": "07:00",
  "endTime": "07:45",
  "subject": "Matemática",
  "teacherId": "UID_DOCENTE",
  "createdAt": "timestamp"
}
```

---

## 8. `school_announcements`

Ruta:

```text
school_announcements/{announcementId}
```

```json
{
  "title": "Aviso escolar de prueba",
  "message": "Mañana traer cuaderno.",
  "classId": "class-10A",
  "audience": "students",
  "createdBy": "UID_DOCENTE",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

Administran técnicos y docentes.  
Leen técnicos, docentes y estudiantes.

---

## 9. `permissions`

Ruta:

```text
permissions/{permissionId}
```

Guarda permisos reales ya aprobados.

```json
{
  "permissionId": "permission-demo-01",
  "studentId": "UID_ESTUDIANTE",
  "reason": "Salida para actividad autorizada",
  "status": "active",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "createdBy": "UID_TECNICO",
  "approvedBy": "UID_TECNICO",
  "validatedBy": null,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

Estados recomendados:

```text
active
expired
used
cancelled
```

---

## 10. `permission_requests`

Ruta:

```text
permission_requests/{requestId}
```

Guarda solicitudes de creación, edición o eliminación hechas por docentes u organizadores.

### Solicitud de creación

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

### Solicitud de edición

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

### Solicitud de eliminación

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

Estados recomendados:

```text
pending
approved
denied
cancelled
```

---

## 11. `events`

Ruta:

```text
events/{eventId}
```

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

Administran técnicos y organizadores.

---

## 12. `event_announcements`

Ruta:

```text
event_announcements/{announcementId}
```

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

Administran técnicos y organizadores.

---

## 13. `event_registrations`

Ruta:

```text
event_registrations/{registrationId}
```

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

Estados:

```text
pending
approved
denied
checked_in
```

---

## 14. Colecciones antiguas que ya no se recomiendan

| Antes | Ahora |
|---|---|
| `announcements` | `school_announcements` o `event_announcements` |
| `movement_announcements` | `event_announcements` |
| `qr_permissions` | `permissions` |
| `assignments` | `school_activities` |
| `inventory_items` | `event_inventory` |
| `map_locations` | `event_locations` |
| `committee_messages` | `event_messages` |
