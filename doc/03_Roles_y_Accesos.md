# 03 - Roles y Accesos

## Objetivo

Definir de forma sencilla qué puede hacer cada usuario dentro de NEXO 360.

Esto ayuda a que la plataforma esté ordenada y que cada persona vea solamente las opciones que necesita.

---

## Roles principales

## 1. Estudiante

El estudiante usa la plataforma para consultar información.

Puede:

- Ver tareas.
- Ver anuncios.
- Ver archivos.
- Ver asistencia.
- Ver notas.
- Ver sus permisos.
- Consultar información de eventos escolares.

No debería poder:

- Crear tareas.
- Cambiar notas.
- Aprobar permisos.
- Administrar eventos.

---

## 2. Docente

El docente usa la plataforma para compartir información académica.

Puede:

- Crear tareas.
- Publicar anuncios.
- Subir o compartir archivos.
- Revisar asistencia.
- Ingresar o consultar notas.
- Ver información de estudiantes.

No debería poder:

- Administrar todo el sistema.
- Aprobar registros de eventos si no es organizador.
- Cambiar permisos administrativos sin autorización.

---

## 3. Personal administrativo

El personal administrativo tiene más control sobre la información escolar.

Puede:

- Revisar estudiantes.
- Revisar docentes.
- Gestionar permisos.
- Generar o validar códigos QR.
- Consultar asistencia y notas.
- Supervisar información general.
- Apoyar la administración de eventos.

No debería usar funciones innecesarias de estudiante, como entregar tareas.

---

## 4. Organizador

El organizador se enfoca en actividades, eventos y logística.

Puede:

- Ver registros de eventos.
- Aprobar o revisar participantes.
- Validar permisos QR.
- Consultar inventario.
- Ver mapa o croquis.
- Publicar mensajes para comités.
- Revisar información del evento.

No debería poder:

- Cambiar notas escolares.
- Modificar tareas académicas.
- Acceder a información privada que no necesita.

---

## 5. Visitante externo

El visitante externo no necesita cuenta en la aplicación.

Puede:

- Ver información pública del evento.
- Llenar un formulario de registro.
- Recibir una confirmación de registro.

No debería poder:

- Entrar al portal escolar.
- Ver datos de estudiantes.
- Acceder a paneles internos.
- Validar permisos o modificar información.

---

## Tabla simple de accesos

| Función | Estudiante | Docente | Administrativo | Organizador | Visitante externo |
|---|---|---|---|---|---|
| Iniciar sesión | Sí | Sí | Sí | Sí | No |
| Ver tareas | Sí | Sí | Sí | No | No |
| Crear tareas | No | Sí | Sí | No | No |
| Ver anuncios | Sí | Sí | Sí | Sí | Algunos |
| Publicar anuncios | No | Sí | Sí | Sí | No |
| Ver archivos | Sí | Sí | Sí | Sí | Algunos |
| Gestionar asistencia | No | Sí | Sí | No | No |
| Ver notas | Sí | Sí | Sí | No | No |
| Modificar notas | No | Sí | Sí | No | No |
| Generar permisos QR | No | No | Sí | No | No |
| Validar permisos QR | No | No | Sí | Sí | No |
| Ver eventos | Sí | Sí | Sí | Sí | Sí |
| Registrarse a eventos | No | No | No | No | Sí |
| Revisar participantes | No | No | Sí | Sí | No |
| Ver inventario | No | No | Sí | Sí | No |
| Ver mapa/croquis | Sí | Sí | Sí | Sí | Sí |

---

## Recomendación para la demostración

Para la presentación, se recomienda usar cuentas de prueba:

| Cuenta de prueba | Uso en la demo |
|---|---|
| Estudiante | Mostrar cómo consulta tareas, notas y permisos |
| Docente | Mostrar cómo publica una tarea o anuncio |
| Administrativo | Mostrar cómo genera o valida un permiso QR |
| Organizador | Mostrar cómo revisa participantes y evento |
| Visitante externo | Mostrar cómo se registra desde la página web |

---

## Resultado esperado

Al finalizar esta parte, el equipo debe saber:

- Cuáles son los tipos de usuarios.
- Qué puede hacer cada uno.
- Qué pantallas debe ver cada rol.
- Qué funciones son privadas y cuáles son públicas.
