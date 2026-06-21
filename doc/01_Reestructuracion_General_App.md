# 01 - Reestructuración General de NEXO 360

**Proyecto:** NEXO 360  
**Objetivo:** Reorganizar la app en tres secciones claras y simplificar los roles.  
**Estado:** Propuesta final para aplicar en Firebase, Firestore y la app.

---

## 1. Nueva estructura principal de la app

Después de iniciar sesión, el usuario verá tres secciones:

```text
NEXO 360
├── Portal Escolar
├── Permisos
└── Eventos
```

La sección antes llamada **Movimiento Juventud** ahora se llamará **Eventos** para que pueda usarse en cualquier actividad del colegio, no solo en el movimiento.

---

## 2. Sección: Portal Escolar

El **Portal Escolar** es exclusivamente para información académica y escolar.

Aquí solamente influyen los tipos de cuenta principales:

| Nivel | Tipo de cuenta | Acceso |
|---|---|---|
| 1 | `technical` | Acceso completo |
| 2 | `teacher` | Administra información escolar |
| 3 | `student` | Consulta información escolar |

Los roles de eventos como `organizer`, `commissioner` o `guest` **no dan permisos extra** en esta sección.

### Módulos del Portal Escolar

```text
Portal Escolar
├── Actividades
├── Horarios
├── Avisos escolares
├── Archivos escolares
├── Asistencia
└── Notas
```

### Reglas generales

- Los técnicos pueden crear, editar y eliminar todo.
- Los docentes pueden crear, editar y eliminar información escolar.
- Los estudiantes solo pueden consultar información asignada a ellos o a su clase.
- Ser organizador o comisionado no cambia nada dentro del Portal Escolar.

---

## 3. Sección: Permisos

La sección **Permisos** sirve para manejar permisos y QR.

### Reglas generales

| Usuario | Qué puede hacer |
|---|---|
| Técnico | Crear, editar, eliminar, aprobar y denegar permisos directamente |
| Docente | Solicitar creación, edición o eliminación de permisos |
| Organizador | Solicitar creación, edición o eliminación de permisos |
| Estudiante | Ver sus propios permisos |
| Comisionado | Validar QR solo si tiene esa opción asignada |
| Invitado | No administra permisos |

---

## 4. Permisos reales vs solicitudes

Para que esto quede ordenado, se usan dos colecciones:

```text
permissions
permission_requests
```

### `permissions`

Guarda permisos reales ya aprobados.

Solo los técnicos pueden escribir directamente en esta colección.

### `permission_requests`

Guarda solicitudes creadas por docentes u organizadores.

Estas solicitudes pueden ser de tres tipos:

```text
create
update
delete
```

Siempre nacen con estado:

```text
pending
```

Luego un técnico las aprueba o deniega.

---

## 5. Flujo de permisos

### Técnico crea un permiso

```text
Técnico crea permiso → queda en permissions directamente
```

### Docente solicita crear permiso

```text
Docente crea solicitud → queda pending → técnico aprueba o deniega
```

### Organizador solicita crear permiso

```text
Organizador crea solicitud → queda pending → técnico aprueba o deniega
```

### Docente u organizador solicita editar permiso

```text
Crea solicitud de edición + descripción → pending → técnico aprueba o deniega
```

### Docente u organizador solicita eliminar permiso

```text
Crea solicitud de eliminación + descripción → pending → técnico aprueba o deniega
```

---

## 6. Sección: Eventos

La sección **Eventos** reemplaza a Movimiento Juventud.

Aquí sí influyen los roles de evento:

```text
organizer
commissioner
guest
```

Estos roles no reemplazan el tipo de cuenta principal. Solo sirven dentro de Eventos.

---

## 7. Jerarquía de Eventos

| Nivel | Rol de evento | Descripción |
|---|---|---|
| 1 | `organizer` | Tiene todas las opciones de Eventos |
| 2 | `commissioner` | Tiene opciones limitadas |
| 3 | `guest` | Puede ver información y enviar formulario |

---

## 8. Tipos de cuenta principales

Desde esta reestructuración solo existen tres tipos de cuenta:

```text
technical
teacher
student
```

Ya no se recomienda usar como tipos de cuenta principales:

```text
organizer
committee
guest
```

Ahora esos son roles internos de la sección Eventos.

---

## 9. Roles de evento

| Rol visible | Clave técnica |
|---|---|
| Ninguno | `none` |
| Invitado | `guest` |
| Comisionado / Comité | `commissioner` |
| Organizador | `organizer` |

---

## 10. Combinaciones permitidas

### Técnico

```json
{
  "accountType": "technical",
  "eventRole": "none"
}
```

El técnico tiene acceso total en las tres secciones.

### Docentes

| Caso | Configuración |
|---|---|
| Docente invitado | `accountType: "teacher"`, `eventRole: "guest"` |
| Docente organizador | `accountType: "teacher"`, `eventRole: "organizer"` |

### Estudiantes

| Caso | Configuración |
|---|---|
| Estudiante invitado | `accountType: "student"`, `eventRole: "guest"` |
| Estudiante organizador | `accountType: "student"`, `eventRole: "organizer"` |
| Estudiante comisionado | `accountType: "student"`, `eventRole: "commissioner"` |

---

## 11. Comisionado como organizador limitado

El comisionado funciona como un organizador con opciones reducidas.

Sus opciones se guardan en:

```text
eventPermissions
```

Ejemplo:

```json
{
  "eventRole": "commissioner",
  "eventPermissions": [
    "view_event_announcements",
    "view_assigned_event",
    "check_in",
    "validate_qr",
    "request_inventory",
    "view_map"
  ]
}
```

Los permisos de un comisionado pueden ser asignados por:

- Técnicos.
- Organizadores.

Un comisionado no puede asignarse permisos a sí mismo.

---

## 12. Avisos separados

Ahora hay dos tipos de avisos completamente separados:

| Sección | Colección | Administradores |
|---|---|---|
| Portal Escolar | `school_announcements` | Técnicos y docentes |
| Eventos | `event_announcements` | Técnicos y organizadores |

Esto evita mezclar avisos académicos con avisos de eventos.
