# Creación de eventos y acceso por roles

## Funcionalidad

La ruta protegida `/events/create` permite crear eventos con:

- Nombre.
- Fecha y hora.
- Ubicación.
- Descripción.
- Capacidad disponible.
- Visibilidad pública o privada.
- Inscripciones abiertas o cerradas.

El evento se guarda en `events/{eventId}` con estado inicial `active`, UID del creador y timestamps del servidor. Si el evento es privado, el formulario desactiva automáticamente las inscripciones públicas.

## Dos ejes independientes

`accountType` define el tipo escolar. `eventRole` define las responsabilidades de Movimiento Juventud. No deben combinarse en un único campo.

| accountType | eventRole | Crear eventos | Administrar inscripciones |
| --- | --- | --- | --- |
| `technical` | Cualquiera | Sí | Sí |
| `teacher` | `organizer` | Sí | Sí |
| `student` | `organizer` | Sí | Sí |
| `teacher` | `guest` o `none` | No | No |
| `student` | `guest` o `none` | No | No |
| `teacher` o `student` | `commissioner` | No | No, salvo capacidades futuras específicas |

Todos los perfiles deben usar `status: active`. Una cuenta inactiva no puede abrir la ruta aunque tenga `eventRole: organizer`.

## Archivos modificados

| Archivo | Cambio |
| --- | --- |
| `app/lib/core/models/app_user.dart` | Agrega `canCreateEvents` |
| `app/lib/core/services/event_service.dart` | Agrega `createEvent` y lista de eventos autenticada |
| `app/lib/features/eventos/create_event_screen.dart` | Formulario funcional |
| `app/lib/features/eventos/eventos_screen.dart` | Tarjeta Crear evento y eventos privados |
| `app/lib/features/home/home_screen.dart` | Acceso directo en dashboard autorizado |
| `app/lib/core/routing/app_router.dart` | Protección de `/events/create` |
| `app/firestore.rules` | `canManageEvents()` para técnicos y organizadores |
| `app/test/route_access_test.dart` | Casos teacher/student organizer y guest |

## Configuración de perfiles

Ejemplo de estudiante organizador:

```text
users/{AUTH_UID}
  uid: AUTH_UID
  accountType: student
  eventRole: organizer
  status: active
```

Ejemplo de docente organizador:

```text
users/{AUTH_UID}
  uid: AUTH_UID
  accountType: teacher
  eventRole: organizer
  status: active
```

El archivo `app/tool/demo_user_profiles.json` contiene ambos tipos, además de estudiante invitado, comisionado y cuenta técnica.

## Verificación

1. Publique las reglas de Firestore.
2. Inicie sesión como `teacher + organizer`: debe aparecer **Crear evento**.
3. Inicie sesión como `student + organizer`: debe aparecer la misma opción.
4. Cree un evento público y confirme que aparece en la lista y en el formulario público.
5. Inicie sesión como `teacher + guest`: no debe aparecer la opción y la ruta directa debe regresar al dashboard.
6. Repita con `student + guest`.
