# NEXO 360 - Reestructuración Final de la Aplicación

**Proyecto:** NEXO 360  
**Versión:** Reestructuración final de secciones, roles y permisos  
**Nivel:** Proyecto escolar  

---

## 1. Estructura final de la app

Después de iniciar sesión, la aplicación tendrá tres secciones principales:

```text
NEXO 360
├── Portal Escolar
├── Permisos
└── Eventos
```

La sección que antes se llamaba **Movimiento Juventud** ahora se llamará **Eventos**.

Este nombre es mejor porque permite usar la sección para cualquier actividad del colegio, no solo para el Movimiento Juventud.

---

## 2. Tipos de cuenta principales

En NEXO 360 solo existirán tres tipos de cuenta principales:

```text
technical
teacher
student
```

| Tipo de cuenta | Significado | Dónde influye |
|---|---|---|
| `technical` | Técnico / administrador del sistema | Todas las secciones |
| `teacher` | Docente | Portal Escolar y solicitudes de permisos |
| `student` | Estudiante | Portal Escolar, consulta de permisos y Eventos |

Ya no se recomienda usar `organizer`, `committee` o `guest` como tipos de cuenta principales.

---

## 3. Roles dentro de Eventos

La sección **Eventos** tendrá roles propios, separados del tipo de cuenta principal.

```text
eventRole
```

Valores posibles:

```text
none
guest
organizer
commissioner
```

| eventRole | Significado |
|---|---|
| `none` | No tiene rol en Eventos |
| `guest` | Invitado; puede ver información pública y enviar formulario |
| `organizer` | Organizador; tiene todas las opciones de Eventos |
| `commissioner` | Comisionado; tiene opciones limitadas asignadas |

---

## 4. Relación entre tipo de cuenta y rol de Eventos

## 4.1 Técnicos

Los técnicos tienen acceso total en todas las secciones.

No necesitan ser organizadores, invitados ni comisionados.

Ejemplo:

```json
{
  "accountType": "technical",
  "eventRole": "none"
}
```

---

## 4.2 Docentes

Los docentes pueden ser:

| Caso | accountType | eventRole |
|---|---|---|
| Docente invitado | `teacher` | `guest` |
| Docente organizador | `teacher` | `organizer` |

Un docente no recibe permisos QR como estudiante.

---

## 4.3 Estudiantes

Los estudiantes pueden ser:

| Caso | accountType | eventRole |
|---|---|---|
| Estudiante invitado | `student` | `guest` |
| Estudiante organizador | `student` | `organizer` |
| Estudiante comisionado | `student` | `commissioner` |

Los estudiantes son los únicos usuarios a quienes se les pueden asignar permisos QR.

---

## 5. Sección Portal Escolar

El **Portal Escolar** es solo para información académica o escolar.

El rol de Eventos no influye aquí.

Por ejemplo:

- Un estudiante organizador sigue siendo estudiante dentro del Portal Escolar.
- Un estudiante comisionado sigue siendo estudiante dentro del Portal Escolar.
- Un docente organizador sigue siendo docente dentro del Portal Escolar.

### Jerarquía del Portal Escolar

| Nivel | Usuario | Permisos |
|---|---|---|
| 1 | Técnico | Administra todo |
| 2 | Docente | Administra información escolar asignada |
| 3 | Estudiante | Consulta información escolar |

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

- Los técnicos pueden crear, editar y eliminar todo en el Portal Escolar.
- Los docentes pueden crear, editar y eliminar información escolar relacionada con sus clases.
- Los estudiantes solo consultan información.
- Los roles de Eventos no dan permisos extra en esta sección.

---

## 6. Sección Permisos

La sección **Permisos** es independiente de Eventos.

Aquí se manejan:

- Permisos reales asignados a estudiantes.
- QR de permisos.
- Solicitudes de creación, edición o eliminación de permisos.
- Consulta de permisos mediante QR.

---

## 7. Reglas finales de Permisos

## 7.1 Técnicos

Los técnicos administran permisos directamente.

Pueden:

- Crear permisos reales.
- Editar permisos reales.
- Eliminar permisos reales.
- Aprobar solicitudes.
- Denegar solicitudes.

No necesitan autorización de otro usuario.

---

## 7.2 Docentes

Los docentes no crean permisos reales directamente.

Pueden:

- Enviar solicitud para crear un permiso.
- Enviar solicitud para editar un permiso.
- Enviar solicitud para eliminar un permiso.
- Leer un QR para consultar si un estudiante tiene permiso.

La solicitud queda con estado:

```text
pending
```

Un técnico debe aprobarla o denegarla.

---

## 7.3 Organizadores

Los organizadores tampoco crean permisos reales directamente.

Pueden:

- Enviar solicitud para crear un permiso.
- Enviar solicitud para editar un permiso.
- Enviar solicitud para eliminar un permiso.
- Leer un QR para consultar si un estudiante tiene permiso.

La solicitud queda con estado:

```text
pending
```

Un técnico debe aprobarla o denegarla.

---

## 7.4 Estudiantes

Los estudiantes pueden:

- Ver sus propios permisos.
- Ver su QR.
- Leer un QR para consultar si otro estudiante tiene permiso.

Los estudiantes no pueden:

- Crear permisos reales.
- Editar permisos reales.
- Eliminar permisos reales.
- Aprobar solicitudes.
- Denegar solicitudes.

---

## 7.5 Docentes y QR

Los docentes no tienen QR de permiso porque a los docentes no se les asignan permisos estudiantiles.

Los QR son para permisos de estudiantes.

---

## 7.6 Comisionados e invitados

Los roles de Eventos:

```text
commissioner
guest
```

no influyen directamente en la sección Permisos.

Esto significa que un comisionado o invitado no recibe permisos especiales en Permisos solo por tener ese rol de Eventos.

---

## 8. Por qué se elimina `validate_qr`

En la versión anterior se había propuesto una opción llamada:

```text
validate_qr
```

Esta opción ya no se usará dentro de Eventos.

Motivo:

- Leer un QR pertenece a la sección **Permisos**.
- No es una función propia de Eventos.
- Estudiantes y docentes pueden leer un QR para consultar si un estudiante tiene permiso.
- Técnicos pueden administrar permisos.

Por lo tanto, `validate_qr` debe eliminarse de `eventPermissions`.

---

## 9. Sección Eventos

La sección **Eventos** reemplaza a Movimiento Juventud.

Aquí sí influyen los roles:

```text
organizer
commissioner
guest
```

### Jerarquía de Eventos

| Nivel | Rol | Permisos |
|---|---|---|
| 1 | Organizador | Todas las opciones de Eventos |
| 2 | Comisionado | Opciones limitadas asignadas |
| 3 | Invitado | Ver información y enviar formulario |

### Módulos de Eventos

```text
Eventos
├── Información de eventos
├── Avisos de eventos
├── Formularios de inscripción
├── Lista de participantes
├── Inventario
├── Mapa o ubicaciones
└── Mensajes de organización
```

---

## 10. Comisionados

Un comisionado es como un organizador con opciones limitadas.

Los permisos disponibles se guardan en:

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
    "request_inventory",
    "view_inventory",
    "view_map",
    "create_event_message"
  ]
}
```

Importante:

- Los organizadores pueden asignar opciones a los comisionados.
- Los técnicos también pueden hacerlo.
- Un comisionado no puede asignarse permisos a sí mismo.
- La opción `validate_qr` ya no debe usarse.

---

## 11. Invitados

El invitado es el rol más limitado dentro de Eventos.

Puede:

- Ver información pública del evento.
- Enviar formulario de inscripción.

No puede:

- Administrar eventos.
- Ver datos internos.
- Administrar inventario.
- Crear avisos internos.
- Administrar permisos.
