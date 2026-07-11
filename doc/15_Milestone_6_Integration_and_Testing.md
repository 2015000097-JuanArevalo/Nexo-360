# Milestone 6 — Integración y pruebas manuales

## Integración completada

- Todas las tarjetas principales abren módulos funcionales.
- El dashboard muestra tareas pendientes, permisos activos, inscripciones pendientes y el aviso más reciente.
- Las pantallas protegidas que usan `PrototypeScreen` incluyen un botón para regresar al dashboard.
- Los formularios públicos mantienen navegación propia y no muestran un dashboard que requiere autenticación.
- Se eliminó la interacción vacía de Seguridad de la cuenta.
- Inventario, mapa en vivo, comunicación de comités, calificaciones y asistencia están identificados como prototipos sin enlaces rotos.
- El técnico dispone de `/presentation/setup` para crear o refrescar datos con prefijo `presentation-`.

## Preparación previa

```powershell
cd app
firebase use nexo-360-9ed4c
firebase deploy --only firestore:rules,firestore:indexes
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Después, inicie sesión como técnico y ejecute **Preparar presentación**. Debe existir al menos un perfil `student` activo.

## Matriz manual obligatoria

Registre `Pass`, `Fail` o `Blocked`, hora, dispositivo y evidencia.

| ID | Prueba | Resultado esperado | Estado | Evidencia |
| --- | --- | --- | --- | --- |
| AUTH-01 | Login técnico correcto | Dashboard técnico y preparación demo disponibles | Pendiente | |
| AUTH-02 | Login teacher organizer | Actividades, solicitudes, eventos e inscripciones | Pendiente | |
| AUTH-03 | Login teacher guest | Sin creación/administración de eventos | Pendiente | |
| AUTH-04 | Login student organizer | QR personal y creación/administración de eventos | Pendiente | |
| AUTH-05 | Login student commissioner | Sin creación de eventos; comisión marcada prototipo | Pendiente | |
| AUTH-06 | Login student guest | Actividades, QR y eventos públicos | Pendiente | |
| AUTH-07 | Contraseña incorrecta | Mensaje claro; no inicia sesión | Pendiente | |
| SCHOOL-01 | Docente crea actividad | Confirmación y documento Firestore | Pendiente | |
| SCHOOL-02 | Estudiante abre actividad | Mismo título, descripción, curso y fecha | Pendiente | |
| PERM-01 | Docente solicita permiso | Solicitud pendiente visible al técnico | Pendiente | |
| PERM-02 | Técnico aprueba solicitud | Se crea permiso real para el estudiante | Pendiente | |
| PERM-03 | Estudiante abre QR | Muestra el permiso aprobado y código real | Pendiente | |
| PERM-04 | Técnico valida código válido | Resultado VÁLIDO verde | Pendiente | |
| PERM-05 | Técnico valida código expirado | Resultado EXPIRADO rojo | Pendiente | |
| PERM-06 | Técnico cambia un carácter del token | Resultado NO AUTORIZADO | Pendiente | |
| EVENT-01 | Invitado envía inscripción pública | Código y estado PENDIENTE | Pendiente | |
| EVENT-02 | Organizador aprueba | Estado público APROBADA | Pendiente | |
| EVENT-03 | Organizador hace check-in | Estado público Ingreso registrado | Pendiente | |
| ACCESS-01 | Guest abre `/events/create` directamente | Redirección al dashboard | Pendiente | |
| ACCESS-02 | Estudiante guest abre `/events/admin` | Redirección al dashboard | Pendiente | |
| ACCESS-03 | No autenticado abre ruta protegida | Redirección a Login | Pendiente | |
| SESSION-01 | Cerrar y volver a abrir app | Firebase restaura la sesión y perfil | Pendiente | |

## Aclaración del flujo de permisos

Con las reglas actuales, un docente no escribe directamente en `permissions`: crea una solicitud, el técnico la aprueba y entonces aparece el QR del estudiante. Esta secuencia reemplaza “teacher creates a permission” en la prueba original y mantiene la seguridad definida en los milestones anteriores.

## Datos producidos por Preparar presentación

| Documento | Propósito |
| --- | --- |
| `school_announcements/presentation-announcement` | Aviso reciente |
| `school_activities/presentation-assignment` | Tarea pendiente |
| `permissions/presentation-permission-valid` | Caso válido actualizado por 8 horas |
| `permissions/presentation-permission-expired` | Caso expirado |
| `events/presentation-event` | Evento público abierto |
| `event_registrations/presentation-registration-pending` | Aprobación y check-in |

La pantalla muestra códigos manuales válidos y expirados para la prueba del escáner.
