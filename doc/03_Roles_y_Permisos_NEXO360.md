# 03 - Roles y Permisos NEXO 360

**Proyecto:** NEXO 360  
**Fase:** 1. Estructura de usuarios y control de acceso  
**Hito:** M03 - Matriz de roles y permisos  
**Dependencia:** M02 - Priorización de funciones y plan de lanzamiento  
**Estado del hito:** Finalizado  
**Checkpoint:** Roles validados contra el alcance del MVP  
**Nivel del proyecto:** Proyecto escolar / competencia académica  

---

## 1. Objetivo del hito

El objetivo de este hito es definir de forma clara **quiénes pueden usar NEXO 360** y **qué puede hacer cada tipo de usuario** dentro de la plataforma.

Este documento servirá como base para las siguientes partes del proyecto:

- Configuración de usuarios en Firebase Authentication.
- Creación de perfiles de usuario en Firestore.
- Redirección a pantallas según el rol.
- Control de qué módulos puede ver cada usuario.
- Preparación de cuentas de prueba.
- Validación de la demostración del proyecto.

Como NEXO 360 es un proyecto escolar, el control de acceso se mantiene simple, ordenado y fácil de explicar durante una presentación.

---

## 2. Alcance de este hito

### Incluido en este hito

Este hito incluye:

1. Definición de los roles principales.
2. Explicación de las acciones permitidas y no permitidas por rol.
3. Matriz general de permisos.
4. Reglas simples de acceso por módulo.
5. Modelo recomendado de perfil de usuario.
6. Plan básico de rutas y dashboards.
7. Plan de cuentas de prueba.
8. Checklist de validación.
9. Criterios para marcar el hito como terminado.

### No incluido en este hito

Este hito no incluye:

- Configuración final de Firebase.
- Implementación completa de la base de datos.
- Reglas finales de seguridad.
- Pantalla final de inicio de sesión.
- Desarrollo completo de la aplicación.
- Flujo completo de permisos QR.

Esas partes se trabajarán en los siguientes hitos.

---

## 3. Roles oficiales del sistema

NEXO 360 usará seis roles principales.

Los nombres visibles pueden estar en español, pero los valores técnicos deben mantenerse en inglés para evitar confusión en la aplicación y en la base de datos.

| Rol visible | Clave técnica |
|---|---|
| Usuario técnico | `technical` |
| Docente | `teacher` |
| Estudiante | `student` |
| Organizador | `organizer` |
| Miembro de comité | `committee` |
| Invitado | `guest` |

Estas claves técnicas deben usarse igual en Firestore, en el código de Flutter y en las reglas de acceso.

---

## 4. Definición de cada rol

## 4.1 Usuario técnico

### Propósito

El usuario técnico ayuda a configurar, probar y mantener la plataforma.

Este rol puede ser usado por el equipo del proyecto, el encargado de tecnología o una persona responsable de revisar que todo funcione correctamente.

### Puede hacer

- Entrar al panel técnico.
- Ver usuarios del sistema.
- Crear o desactivar usuarios de prueba.
- Revisar la configuración general.
- Acceder a los módulos para probarlos.
- Corregir problemas de datos durante la demo.

### No debe hacer

- Usar el sistema como si fuera estudiante normal.
- Cambiar notas sin motivo académico.
- Eliminar datos importantes sin autorización del equipo.
- Modificar información real durante la presentación si no es necesario.

### Clave técnica

```text
technical
```

---

## 4.2 Docente

### Propósito

El docente administra información académica para sus estudiantes.

### Puede hacer

- Ver sus clases asignadas.
- Crear tareas.
- Publicar anuncios académicos.
- Compartir archivos o enlaces.
- Registrar asistencia.
- Ingresar o revisar notas.
- Ver información relacionada con sus estudiantes.

### No debe hacer

- Administrar configuración técnica.
- Aprobar registros de eventos externos, excepto si también tiene función de organizador.
- Modificar información general del sistema.
- Acceder a información que no pertenezca a sus clases.

### Clave técnica

```text
teacher
```

---

## 4.3 Estudiante

### Propósito

El estudiante usa NEXO 360 para consultar su información escolar.

### Puede hacer

- Ver tareas.
- Ver anuncios.
- Ver archivos compartidos.
- Ver su asistencia.
- Ver sus notas.
- Ver sus permisos QR.
- Consultar información pública de eventos.

### No debe hacer

- Crear tareas.
- Editar notas.
- Aprobar permisos.
- Ver información privada de otros estudiantes.
- Administrar eventos o inventario.

### Clave técnica

```text
student
```

---

## 4.4 Organizador

### Propósito

El organizador administra eventos, actividades juveniles y procesos logísticos.

### Puede hacer

- Crear o editar información de eventos.
- Revisar registros de participantes.
- Aprobar o rechazar participantes.
- Ver asistencia o check-in de eventos.
- Gestionar inventario básico.
- Publicar anuncios de eventos.
- Ver o editar ubicaciones del evento.
- Validar permisos QR cuando le corresponda.

### No debe hacer

- Cambiar notas académicas.
- Modificar tareas de docentes.
- Acceder a información privada de estudiantes que no esté relacionada con un evento.
- Cambiar configuraciones técnicas del sistema.

### Clave técnica

```text
organizer
```

---

## 4.5 Miembro de comité

### Propósito

El miembro de comité apoya en tareas específicas de un evento, pero tiene menos permisos que un organizador.

### Puede hacer

- Ver información del evento asignado.
- Ver tareas de su comité.
- Leer o enviar mensajes internos del comité.
- Solicitar artículos del inventario.
- Ver el mapa o croquis del evento.
- Marcar avances de tareas simples.
- Validar QR solo si fue asignado a entrada o check-in.

### No debe hacer

- Aprobar registros finales de participantes.
- Crear eventos oficiales.
- Modificar información académica.
- Administrar usuarios.
- Cambiar configuraciones generales.

### Clave técnica

```text
committee
```

---

## 4.6 Invitado

### Propósito

El invitado es una persona externa que usa únicamente el sitio web público.

### Puede hacer

- Ver información pública de eventos.
- Llenar formularios de registro.
- Subir documentos requeridos si el formulario lo solicita.
- Recibir confirmación de registro.

### No debe hacer

- Iniciar sesión en el portal privado.
- Ver datos de estudiantes.
- Acceder a dashboards internos.
- Editar información del sistema.
- Validar códigos QR.

### Clave técnica

```text
guest
```

### Nota importante

Para el MVP, el invitado **no necesita cuenta ni inicio de sesión**. Su interacción se realiza desde el sitio web público.

---

## 5. Matriz general de permisos

Leyenda:

| Término | Significado |
|---|---|
| Ver | Puede consultar información |
| Crear | Puede agregar información nueva |
| Editar | Puede modificar información existente |
| Aprobar | Puede aceptar o rechazar solicitudes |
| Validar | Puede revisar QR o check-in |
| Solo propio | Solo puede ver su propia información |
| No | No tiene acceso |

| Módulo / Función | Técnico | Docente | Estudiante | Organizador | Comité | Invitado |
|---|---|---|---|---|---|---|
| Inicio de sesión | Sí | Sí | Sí | Sí | Sí | No |
| Dashboard privado | Sí | Sí | Sí | Sí | Sí | No |
| Gestión de usuarios | Ver / Editar | No | No | No | No | No |
| Tareas | Ver / Editar | Crear / Editar | Ver | No | No | No |
| Anuncios | Crear / Editar | Crear / Editar | Ver | Crear / Editar eventos | Ver / Crear notas internas | Ver públicos |
| Archivos | Ver / Editar | Crear / Editar | Ver | Ver / Editar archivos de evento | Ver asignados | Ver públicos |
| Asistencia | Ver / Editar | Crear / Editar clase | Solo propio | Asistencia de evento | Check-in asignado | No |
| Notas | Ver / Editar | Crear / Editar clase | Solo propio | No | No | No |
| Permisos QR | Ver / Editar | Solicitar o ver relacionados | Solo propio | Validar | Validar si está asignado | No |
| Información de eventos | Ver / Editar | Ver | Ver | Crear / Editar | Ver asignado | Ver público |
| Registro a eventos | Ver / Editar | No | No | Aprobar / Ver | Ver lista asignada | Crear registro |
| Lista de participantes | Ver / Editar | No | No | Ver / Editar | Ver asignada | No |
| Inventario | Ver / Editar | No | No | Crear / Editar | Solicitar / Ver asignado | No |
| Mapa o croquis | Ver / Editar | Ver | Ver | Crear / Editar | Ver | Ver público |
| Comunicación de comité | Ver / Editar | No | No | Crear / Editar | Crear / Ver | No |
| Configuración del sistema | Ver / Editar | No | No | No | No | No |

---

## 6. Reglas de acceso por módulo

## 6.1 Autenticación

Los usuarios privados deben iniciar sesión con Firebase Authentication.

Usuarios privados:

- Usuario técnico.
- Docente.
- Estudiante.
- Organizador.
- Miembro de comité.

Usuario público:

- Invitado.

El invitado no inicia sesión para el MVP.

---

## 6.2 Dashboards

Después de iniciar sesión, la aplicación debe leer el perfil del usuario y enviarlo al dashboard correcto.

| Rol | Dashboard |
|---|---|
| Técnico | `/technical/dashboard` |
| Docente | `/teacher/dashboard` |
| Estudiante | `/student/dashboard` |
| Organizador | `/organizer/dashboard` |
| Comité | `/committee/dashboard` |
| Invitado | Sitio web público |

Si un usuario no tiene rol asignado, debe mostrarse este mensaje:

```text
Cuenta no configurada. Por favor contacta al equipo del proyecto.
```

---

## 6.3 Tareas

- Los docentes pueden crear y editar tareas de sus clases.
- Los estudiantes solo pueden ver tareas asignadas a su clase.
- El usuario técnico puede ver y editar tareas para pruebas o soporte.
- Organizadores, comités e invitados no acceden a tareas académicas.

---

## 6.4 Anuncios

Se manejarán dos tipos de anuncios:

1. Anuncios escolares.
2. Anuncios de eventos.

Reglas:

- Docentes y técnicos pueden publicar anuncios escolares.
- Organizadores pueden publicar anuncios de eventos.
- Miembros de comité pueden publicar notas internas si están asignados.
- Estudiantes solo pueden ver anuncios.
- Invitados solo pueden ver anuncios públicos del sitio web.

---

## 6.5 Archivos

- Docentes pueden compartir archivos académicos.
- Organizadores pueden compartir archivos de eventos.
- Estudiantes pueden ver archivos asignados.
- Miembros de comité pueden ver archivos de su evento o comité.
- Invitados solo pueden ver archivos marcados como públicos.

Para el MVP, los archivos pueden ser enlaces, imágenes o documentos PDF simples.

---

## 6.6 Asistencia

- Docentes pueden registrar asistencia de sus clases.
- Estudiantes solo pueden ver su propia asistencia.
- Organizadores pueden ver asistencia de eventos.
- Miembros de comité pueden hacer check-in si fueron asignados.
- Invitados no tienen acceso a asistencia.

---

## 6.7 Notas

- Docentes pueden ingresar o modificar notas de sus clases.
- Estudiantes solo pueden ver sus propias notas.
- Técnicos pueden ver o editar notas solo para pruebas.
- Organizadores, comités e invitados no tienen acceso a notas académicas.

---

## 6.8 Permisos QR

Los permisos QR sirven para validar autorizaciones de estudiantes o participantes.

Reglas:

- Técnicos pueden administrar registros de permisos QR.
- Docentes pueden solicitar o ver permisos relacionados con sus estudiantes.
- Estudiantes pueden ver solo sus propios permisos.
- Organizadores pueden validar permisos QR.
- Miembros de comité pueden validar QR solo si están asignados a entrada o check-in.
- Invitados no tienen acceso a permisos QR.

Datos mínimos de un permiso QR:

| Campo | Descripción |
|---|---|
| `permissionId` | Identificador del permiso |
| `studentId` o `participantId` | Persona relacionada con el permiso |
| `reason` | Motivo del permiso |
| `status` | Estado del permiso |
| `startTime` | Inicio de validez |
| `endTime` | Fin de validez |
| `generatedBy` | Usuario que generó el permiso |
| `validatedBy` | Usuario que lo validó |
| `createdAt` | Fecha de creación |

Estados recomendados:

```text
pending
approved
active
expired
rejected
used
```

---

## 6.9 Eventos y registros

- Invitados pueden registrarse desde el sitio web público.
- Organizadores pueden revisar, aprobar o rechazar registros.
- Miembros de comité pueden ver únicamente listas asignadas.
- Técnicos pueden ver o editar datos para pruebas.
- Docentes y estudiantes pueden ver información del evento, pero no aprueban registros.

---

## 6.10 Inventario

El inventario se usa para apoyar la organización de eventos.

Reglas:

- Organizadores pueden crear y actualizar artículos.
- Miembros de comité pueden solicitar o ver artículos asignados.
- Técnicos pueden revisar o editar el inventario para soporte.
- Estudiantes, docentes e invitados no administran inventario.

Datos mínimos de inventario:

| Campo | Descripción |
|---|---|
| `itemId` | Identificador del artículo |
| `name` | Nombre del artículo |
| `category` | Categoría |
| `quantity` | Cantidad |
| `status` | Estado |
| `assignedCommitteeId` | Comité asignado |
| `notes` | Observaciones |

---

## 6.11 Mapa o croquis

Para el MVP, el mapa puede ser simple.

Puede mostrarse como:

- Croquis del evento.
- Lista de ubicaciones.
- Imagen con puntos importantes.
- Mapa básico con lugares principales.

Reglas:

- Organizadores pueden crear o editar ubicaciones.
- Técnicos pueden administrar ubicaciones para soporte.
- Estudiantes, docentes y comités pueden ver ubicaciones.
- Invitados solo pueden ver ubicaciones públicas.

---

## 6.12 Comunicación de comité

- Organizadores pueden crear y editar mensajes de coordinación.
- Miembros de comité pueden crear y ver mensajes internos.
- Técnicos pueden revisar mensajes para soporte.
- Estudiantes, docentes e invitados no acceden a comunicación interna de comités.

---

## 7. Modelo recomendado de perfil de usuario

Cada usuario privado tendrá un documento en Firestore.

Ruta recomendada:

```text
users/{uid}
```

Ejemplo de documento:

```json
{
  "uid": "firebase-auth-user-id",
  "email": "student@nexo360.test",
  "displayName": "Estudiante Demo",
  "role": "student",
  "status": "active",
  "schoolCode": "S-001",
  "classId": "class-10A",
  "committeeId": null,
  "assignedEventIds": [],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

Explicación de campos:

| Campo | Propósito |
|---|---|
| `uid` | Conecta Firebase Auth con el perfil en Firestore |
| `email` | Correo de inicio de sesión |
| `displayName` | Nombre visible del usuario |
| `role` | Rol del usuario |
| `status` | Indica si el usuario está activo o inactivo |
| `schoolCode` | Código escolar o identificador interno |
| `classId` | Clase o sección asignada |
| `committeeId` | Comité asignado, si aplica |
| `assignedEventIds` | Eventos a los que el usuario tiene acceso |
| `createdAt` | Fecha de creación |
| `updatedAt` | Fecha de última actualización |

---

## 8. Valores técnicos fijos para roles

Para evitar errores, se deben usar siempre los mismos valores.

```text
technical
teacher
student
organizer
committee
guest
```

En Flutter, se puede representar así:

```dart
enum UserRole {
  technical,
  teacher,
  student,
  organizer,
  committee,
  guest,
}
```

No se recomienda mezclar nombres como:

```text
admin
administrator
staff
technical_user
```

El proyecto debe escoger una sola convención y mantenerla igual en todo el sistema.

---

## 9. Estructura simple recomendada para Flutter

La aplicación puede organizarse de esta forma:

```text
lib/
  main.dart
  core/
    auth/
      auth_service.dart
      access_service.dart
      user_role.dart
    routes/
      app_router.dart
  models/
    app_user.dart
  features/
    login/
    dashboards/
      technical_dashboard.dart
      teacher_dashboard.dart
      student_dashboard.dart
      organizer_dashboard.dart
      committee_dashboard.dart
    school_portal/
    qr_permissions/
    events/
    inventory/
    maps/
```

Esta estructura es suficiente para un proyecto escolar porque mantiene el orden sin hacerlo demasiado complejo.

---

## 10. Flujo de control de acceso

El flujo recomendado es:

1. El usuario abre la aplicación.
2. La aplicación revisa si el usuario inició sesión.
3. Si no inició sesión, se muestra la pantalla de login.
4. Si inició sesión, se lee el documento `users/{uid}`.
5. Se revisa que el usuario tenga `status = active`.
6. Se obtiene el campo `role`.
7. Se redirige al dashboard correspondiente.
8. Se ocultan las pantallas que el rol no debe ver.
9. Firestore también debe bloquear accesos no permitidos.

Nota importante:

Ocultar botones en la aplicación no es suficiente. La base de datos también debe proteger la información.

---

## 11. Plan simple de rutas

| Ruta | Roles permitidos |
|---|---|
| `/login` | Usuarios privados antes de iniciar sesión |
| `/technical/dashboard` | Técnico |
| `/teacher/dashboard` | Docente, Técnico |
| `/student/dashboard` | Estudiante, Técnico |
| `/organizer/dashboard` | Organizador, Técnico |
| `/committee/dashboard` | Comité, Organizador, Técnico |
| `/school/assignments` | Estudiante, Docente, Técnico |
| `/school/attendance` | Estudiante, Docente, Técnico |
| `/school/grades` | Estudiante, Docente, Técnico |
| `/qr/permissions` | Estudiante, Docente, Organizador, Comité, Técnico |
| `/events` | Estudiante, Docente, Organizador, Comité, Técnico |
| `/inventory` | Organizador, Comité, Técnico |
| `/maps` | Estudiante, Docente, Organizador, Comité, Técnico |
| `/settings` | Técnico |

---

## 12. Colecciones recomendadas en Firestore

Este hito no implementa las colecciones, pero deja definido qué estructura se usará más adelante.

Colecciones generales recomendadas:

```text
users
classes
assignments
announcements
files
attendance_records
grades
qr_permissions
events
event_registrations
inventory_items
map_locations
committee_messages
audit_logs
```

Colecciones mínimas para el MVP:

```text
users
assignments
announcements
qr_permissions
events
event_registrations
```

---

## 13. Lógica base para reglas de seguridad

Estas no son las reglas finales, pero dejan clara la lógica que se usará después.

Reglas generales:

1. Un usuario privado debe estar autenticado.
2. Un usuario autenticado debe tener perfil en `users/{uid}`.
3. El perfil debe tener `status = active`.
4. El estudiante solo puede ver su propia información privada.
5. El docente solo puede gestionar información de sus clases.
6. El organizador solo gestiona información de eventos.
7. El comité solo accede a información asignada.
8. El invitado solo usa formularios públicos.
9. El técnico puede acceder a todo para pruebas y soporte.

Ejemplo base:

```js
function isSignedIn() {
  return request.auth != null;
}

function userDoc() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid));
}

function role() {
  return userDoc().data.role;
}

function isTechnical() {
  return isSignedIn() && role() == "technical";
}

function isTeacher() {
  return isSignedIn() && role() == "teacher";
}

function isStudent() {
  return isSignedIn() && role() == "student";
}

function isOrganizer() {
  return isSignedIn() && role() == "organizer";
}

function isCommittee() {
  return isSignedIn() && role() == "committee";
}
```

Estas reglas se completarán en el hito de configuración de Firebase.

---

## 14. Plan de cuentas de prueba

Se debe preparar una cuenta de prueba por cada rol privado.

| Rol | Correo sugerido | Uso en la demo |
|---|---|---|
| Técnico | `technical@nexo360.test` | Revisar configuración y módulos |
| Docente | `teacher@nexo360.test` | Mostrar creación de tareas y anuncios |
| Estudiante | `student@nexo360.test` | Mostrar consulta de información escolar |
| Organizador | `organizer@nexo360.test` | Mostrar gestión de eventos |
| Comité | `committee@nexo360.test` | Mostrar tareas o check-in de comité |
| Invitado | No requiere login | Registrarse desde el sitio web público |

Importante:

Las contraseñas no deben escribirse en este documento. Deben compartirse de forma privada entre el equipo.

---

## 15. Pasos para dar por implementado este hito

## Paso 1: Aprobar los nombres de roles

Roles aprobados:

```text
technical
teacher
student
organizer
committee
guest
```

## Paso 2: Aprobar la matriz de permisos

La matriz queda aprobada si cumple con lo siguiente:

- Cada módulo del MVP tiene roles definidos.
- Ningún usuario tiene permisos innecesarios.
- Los estudiantes solo ven su propia información privada.
- Los invitados solo usan el sitio web público.
- Los organizadores y miembros de comité están separados correctamente.

## Paso 3: Aprobar el modelo de usuario

El modelo `users/{uid}` queda definido como base para los siguientes hitos.

## Paso 4: Aprobar las rutas por rol

Cada usuario tendrá un dashboard según su rol.

## Paso 5: Preparar cuentas de prueba

El equipo debe crear o planificar una cuenta para cada rol privado.

## Paso 6: Validar contra el MVP

La matriz fue revisada contra el alcance del MVP para evitar funciones demasiado complejas.

---

## 16. Integración con hitos anteriores y siguientes

## Relación con M01 - Alcance del proyecto

M01 definió que NEXO 360 debe enfocarse en una primera versión funcional y demostrable.

Este documento respeta ese alcance porque define permisos simples, suficientes para la demostración.

## Relación con M02 - Funciones MVP

M02 separó las funciones necesarias de las funciones futuras.

Este documento toma esas funciones principales y les asigna permisos por rol.

## Relación con M04 - Firebase y entorno de datos

M04 usará esta matriz para configurar:

- Firebase Authentication.
- Perfiles de usuario.
- Colecciones iniciales.
- Reglas básicas de seguridad.
- Datos de prueba.

## Relación con M05 - Login y perfiles

M05 usará este documento para implementar:

- Inicio de sesión.
- Lectura del rol.
- Redirección al dashboard correcto.
- Control de pantallas disponibles por usuario.

---

## 17. Checklist de validación del hito

Para marcar M03 como finalizado, se valida lo siguiente:

- [x] Los seis roles están definidos.
- [x] Cada rol tiene un propósito claro.
- [x] Cada rol tiene acciones permitidas y no permitidas.
- [x] La matriz de permisos cubre los módulos del MVP.
- [x] Los invitados están limitados al sitio web público.
- [x] Los estudiantes solo acceden a su propia información privada.
- [x] Los docentes están enfocados en módulos académicos.
- [x] Los organizadores están enfocados en eventos y logística.
- [x] Los miembros de comité tienen menos permisos que los organizadores.
- [x] Los usuarios técnicos se usan para soporte y configuración.
- [x] Los dashboards por rol están definidos.
- [x] Los campos del perfil de usuario están definidos.
- [x] Las cuentas de prueba están planificadas.
- [x] La matriz fue revisada contra el alcance del MVP.

---

## 18. Criterios de aceptación

El hito M03 se considera terminado porque:

1. Los roles oficiales fueron definidos.
2. Las claves técnicas de roles quedaron establecidas.
3. La matriz de permisos está completa.
4. Cada módulo del MVP tiene reglas de acceso.
5. El modelo de perfil de usuario está definido.
6. Las rutas principales están definidas.
7. Las cuentas de prueba están planificadas.
8. La propuesta es simple y adecuada para un proyecto escolar.
9. El checkpoint “Roles validados contra el alcance del MVP” queda cumplido.

---

## 19. Resultado final del hito

**Archivo final del hito:** `03_Roles_y_Permisos_NEXO360.md`  
**Estado:** Finalizado  
**Checkpoint:** Roles validados contra el alcance del MVP  
**Siguiente hito:** M04 - Proyecto Firebase y entorno de datos  

Con este documento, el equipo puede avanzar al siguiente hito con una base clara para configurar usuarios, permisos y accesos dentro de NEXO 360.
