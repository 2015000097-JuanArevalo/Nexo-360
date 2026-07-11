# Milestone 5 — Inscripción, aprobación y check-in de eventos

## Resultado implementado

El flujo M15–M16 ya es funcional:

1. Un organizador o técnico crea el evento de demostración desde la app.
2. Una persona abre el formulario público sin iniciar sesión.
3. La inscripción se guarda con estado `pending`.
4. La app entrega un código de seguimiento único.
5. La inscripción aparece en tiempo real para el organizador.
6. El organizador cambia el estado a aprobada, en reserva o rechazada.
7. Una inscripción aprobada puede registrar su ingreso con **Check in**.
8. El participante consulta el estado final con su código y ve los cambios en tiempo real.

## Decisión de colección

El milestone propuesto usa `registrations/{id}`, pero el repositorio ya había establecido `event_registrations/{id}` en sus reglas, índices y documentación. Esta implementación conserva `event_registrations` para evitar dos colecciones con el mismo propósito.

## Archivos principales

| Archivo | Responsabilidad |
| --- | --- |
| `app/lib/core/models/event_record.dart` | Modelo de evento |
| `app/lib/core/models/event_registration.dart` | Modelo de inscripción y check-in |
| `app/lib/core/services/event_service.dart` | Lecturas y escrituras de Firestore |
| `app/lib/features/eventos/eventos_screen.dart` | Eventos públicos, creación demo y contador real |
| `app/lib/features/eventos/event_registration_screen.dart` | Formulario público funcional |
| `app/lib/features/eventos/registration_status_screen.dart` | Consulta pública por código |
| `app/lib/features/eventos/registration_admin_screen.dart` | Estados y check-in del organizador |
| `app/firestore.rules` | Validación y acceso por rol |
| `app/test/event_models_test.dart` | Pruebas de los modelos principales |

## Esquema del evento

```text
events/{eventId}
  name: string
  date: timestamp
  location: string
  description: string
  capacity: int
  isPublic: bool
  registrationOpen: bool
  status: active | cancelled | completed
  createdBy: uid
  createdAt: timestamp
  updatedAt: timestamp
```

## Esquema de inscripción

```text
event_registrations/{registrationId}
  eventId: string
  fullName: string
  email: string
  phone: string
  organization: string
  status: pending | approved | reserved | rejected
  documentUrl: string | null
  createdAt: timestamp
  updatedAt: timestamp
  checkedIn: bool
  checkedInAt: timestamp | null
  checkedInBy: uid | null
```

## Acceso

| Acción | Público | Organizador | Técnico |
| --- | --- | --- | --- |
| Ver eventos públicos | Sí | Sí | Sí |
| Crear inscripción pendiente | Sí | Sí | Sí |
| Consultar por código aleatorio | Sí | Sí | Sí |
| Listar todas las inscripciones | No | Sí | Sí |
| Aprobar/reservar/rechazar | No | Sí | Sí |
| Check-in aprobado | No | Sí | Sí |
| Crear evento demo | No | Sí | Sí |

## Estados visibles

- `pending`: pendiente, amarillo.
- `approved`: aprobada, verde.
- `reserved`: en reserva, amarillo.
- `rejected`: rechazada, rojo.
- `checkedIn: true`: ingreso registrado, verde.

## Documento adjunto

Firebase Storage no estaba configurado en el repositorio, por lo que se implementó `documentUrl` opcional. El formulario valida URLs `http` o `https`. Cuando Storage esté listo, este campo puede recibir la URL de descarga sin cambiar el modelo de Firestore.

## Límites conscientes del prototipo

- `capacity` se muestra, pero no se descuenta ni bloquea automáticamente. Un control de cupo resistente a concurrencia debería ejecutarse en Cloud Functions o una transacción protegida.
- El ID aleatorio de Firestore funciona como código de seguimiento y permite leer un documento específico. No se permite listar públicamente. Para producción, devuelva un estado mínimo mediante una Cloud Function, use un token adicional y active App Check.
