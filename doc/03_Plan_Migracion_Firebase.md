# 03 - Plan de Migración en Firebase

Este documento indica cómo pasar de la estructura anterior a la nueva.

---

## 1. Respuesta sobre usuarios de comité y organizador

Sí, se recomienda eliminar o dejar de usar usuarios cuyo tipo de cuenta principal sea:

```text
organizer
committee
```

Ahora el tipo de cuenta principal debe ser solo:

```text
technical
teacher
student
```

El rol de organizador, comisionado o invitado se define con:

```text
eventRole
```

---

## 2. Cuentas recomendadas para la demo

Crear estas cuentas:

| Cuenta | `accountType` | `eventRole` |
|---|---|---|
| Técnico Demo | `technical` | `none` |
| Docente Invitado Demo | `teacher` | `guest` |
| Docente Organizador Demo | `teacher` | `organizer` |
| Estudiante Invitado Demo | `student` | `guest` |
| Estudiante Organizador Demo | `student` | `organizer` |
| Estudiante Comisionado Demo | `student` | `commissioner` |

Esto muestra todos los casos necesarios sin confundir tipos de cuenta con roles de eventos.

---

## 3. Opción recomendada: eliminar y recrear

Esta es la opción más limpia para una demo escolar:

1. Entrar a Firebase Authentication.
2. Eliminar usuarios antiguos de prueba `organizer` y `committee`.
3. Entrar a Firestore.
4. Eliminar sus documentos antiguos en `users`.
5. Crear las nuevas cuentas de prueba.
6. Copiar el UID de cada cuenta.
7. Crear un documento `users/{uid}` para cada cuenta.
8. Usar el modelo nuevo con `accountType`, `eventRole` y `eventPermissions`.

---

## 4. Opción alternativa: reutilizar usuarios actuales

Si no quieres borrar usuarios, puedes cambiar sus documentos.

Ejemplo antiguo:

```json
{
  "role": "organizer"
}
```

Ejemplo nuevo como estudiante organizador:

```json
{
  "accountType": "student",
  "eventRole": "organizer"
}
```

Ejemplo nuevo como docente organizador:

```json
{
  "accountType": "teacher",
  "eventRole": "organizer"
}
```

---

## 5. Campos que ya no se recomiendan

Dejar de usar:

```text
role
roles
movementRole
movementPermissions
```

Usar:

```text
accountType
eventRole
eventPermissions
```

---

## 6. Nuevas colecciones

Crear:

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

Opcionales para después:

```text
school_files
attendance_records
grades
event_inventory
event_locations
event_messages
audit_logs
```

---

## 7. Migración de avisos

Avisos escolares:

```text
school_announcements
```

Avisos de eventos:

```text
event_announcements
```

No mezclar ambos.

---

## 8. Migración de permisos

Permisos aprobados:

```text
permissions
```

Solicitudes pendientes:

```text
permission_requests
```

---

## 9. Checklist de migración

- [ ] Crear capturas de la estructura actual.
- [ ] Crear nuevas colecciones.
- [ ] Crear nuevas cuentas de prueba.
- [ ] Crear documentos `users/{uid}` con el modelo nuevo.
- [ ] Usar `accountType`.
- [ ] Usar `eventRole`.
- [ ] Usar `eventPermissions`.
- [ ] Separar `school_announcements` y `event_announcements`.
- [ ] Crear `permissions`.
- [ ] Crear `permission_requests`.
- [ ] Publicar nuevas Firestore Rules.
- [ ] Probar técnico.
- [ ] Probar docente invitado.
- [ ] Probar docente organizador.
- [ ] Probar estudiante invitado.
- [ ] Probar estudiante organizador.
- [ ] Probar estudiante comisionado.
