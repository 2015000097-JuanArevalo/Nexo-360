# NEXO 360 - Instrucciones para Cambiar Firebase

Este documento explica exactamente qué debes modificar en Firebase tomando como base la versión final anterior.

---

## 1. Cambios principales que debes hacer

Debes ajustar tres cosas:

1. Usuarios.
2. Colecciones.
3. Rules.

El cambio más importante es que la sección de Permisos queda independiente de Eventos.

---

## 2. Usuarios: campos que deben quedar

En cada documento dentro de `users`, usa estos campos:

```text
uid
email
displayName
accountType
eventRole
eventPermissions
status
schoolCode
classId
committeeId
assignedEventIds
createdAt
updatedAt
```

---

## 3. Campos que debes dejar de usar

Si todavía existen, ya no los uses:

```text
role
roles
movementRole
movementPermissions
```

Puedes eliminarlos manualmente o simplemente dejarlos sin usar, pero para que todo quede limpio es mejor eliminarlos.

---

## 4. Cambiar usuarios actuales

## 4.1 Técnico

Debe quedar:

```json
"accountType": "technical",
"eventRole": "none",
"eventPermissions": []
```

---

## 4.2 Docente normal o invitado

Debe quedar:

```json
"accountType": "teacher",
"eventRole": "guest",
"eventPermissions": []
```

Si no quieres que aparezca en Eventos, usa:

```json
"eventRole": "none"
```

---

## 4.3 Docente organizador

Debe quedar:

```json
"accountType": "teacher",
"eventRole": "organizer",
"eventPermissions": [],
"assignedEventIds": ["event-demo-01"]
```

---

## 4.4 Estudiante invitado

Debe quedar:

```json
"accountType": "student",
"eventRole": "guest",
"eventPermissions": [],
"assignedEventIds": ["event-demo-01"]
```

---

## 4.5 Estudiante organizador

Debe quedar:

```json
"accountType": "student",
"eventRole": "organizer",
"eventPermissions": [],
"assignedEventIds": ["event-demo-01"]
```

---

## 4.6 Estudiante comisionado

Debe quedar:

```json
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
"assignedEventIds": ["event-demo-01"]
```

Importante: no uses `validate_qr`.

---

## 5. Qué hacer con los usuarios de comité y organizador antiguos

Sí, se recomienda eliminarlos o convertirlos.

### Opción recomendada

Eliminar las cuentas antiguas de:

```text
organizer@nexo360.test
committee@nexo360.test
```

Y crear nuevos usuarios como:

```text
student.organizer@nexo360.test
student.commissioner@nexo360.test
teacher.organizer@nexo360.test
```

### Opción alternativa

Puedes reutilizar los usuarios actuales, pero debes cambiar su documento `users/{uid}` para que tenga:

```text
accountType: "student" o "teacher"
eventRole: "organizer" o "commissioner"
```

---

## 6. Colecciones que debes crear

Crea estas colecciones si no existen:

```text
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

## 7. Colecciones que debes dejar de usar

Puedes eliminarlas si ya no tienen datos importantes, o dejarlas vacías.

```text
announcements
movement_announcements
qr_permissions
assignments
inventory_items
map_locations
committee_messages
```

---

## 8. Migrar avisos

Si tenías avisos escolares en `announcements`, muévelos a:

```text
school_announcements
```

Si tenías avisos del movimiento, muévelos a:

```text
event_announcements
```

---

## 9. Migrar actividades

Si tenías tareas en:

```text
assignments
```

ahora usa:

```text
school_activities
```

---

## 10. Migrar permisos

Si tenías permisos en:

```text
qr_permissions
```

ahora usa:

```text
permissions
```

Los permisos reales deben estar en `permissions`.

Las solicitudes deben estar en:

```text
permission_requests
```

---

## 11. Crear una solicitud de permiso de prueba

Crea colección:

```text
permission_requests
```

Documento:

```text
request-demo-01
```

Campos:

```json
{
  "requestType": "create",
  "targetPermissionId": null,
  "requestedBy": "UID_DOCENTE_U_ORGANIZADOR",
  "requestDescription": "Solicitud de permiso para demo.",
  "status": "pending",
  "proposedData": {
    "studentId": "UID_ESTUDIANTE",
    "reason": "Salida autorizada para actividad escolar",
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

## 12. Crear un permiso aprobado de prueba

Crea colección:

```text
permissions
```

Documento:

```text
permission-demo-01
```

Campos:

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

---

## 13. Publicar las nuevas rules

1. Ir a Firebase Console.
2. Entrar a Firestore Database.
3. Ir a la pestaña Rules.
4. Borrar las rules anteriores.
5. Pegar el contenido de `firestore.rules`.
6. Presionar Publish.

---

## 14. Pruebas que debes hacer

Después de publicar las rules, prueba esto:

- [ ] Técnico puede crear directamente un permiso en `permissions`.
- [ ] Docente no puede crear directamente en `permissions`.
- [ ] Docente puede crear solicitud en `permission_requests`.
- [ ] Organizador puede crear solicitud en `permission_requests`.
- [ ] Técnico puede aprobar o denegar solicitud.
- [ ] Estudiante puede leer su permiso.
- [ ] Estudiante puede abrir un permiso por QR/document ID para consultar si existe.
- [ ] Docente puede abrir un permiso por QR/document ID para consultar si existe.
- [ ] Comisionado no tiene permiso especial de QR por su rol de Eventos.
- [ ] `validate_qr` ya no aparece en `eventPermissions`.

---

## 15. Resumen final

La versión final debe quedar así:

```text
Portal Escolar = depende de accountType
Permisos = técnicos administran, docentes/organizadores solicitan, estudiantes consultan
Eventos = depende de eventRole y eventPermissions
```
