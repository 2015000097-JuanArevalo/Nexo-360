# NEXO 360 - Milestone 1: Design Freeze

**Status:** approved for prototype implementation  
**Scope:** M07-M09 compressed into a functional Flutter design shell  
**Source of truth:** current repository role model and Firestore documentation

## 1. Decisions preserved from the repository

- Main account types remain `technical`, `teacher`, and `student`.
- Event roles remain independent: `none`, `guest`, `organizer`, and `commissioner`.
- Organizers and commissioners are not new account types.
- Only students receive QR permissions.
- Teachers and event organizers request permissions; technical users create and approve them.
- QR consultation belongs to Permisos, not Eventos.
- The application retains three product sections: Portal Escolar, Permisos, and Eventos.

## 2. Final screen inventory

| Screen | Route contract | Demonstration purpose |
|---|---|---|
| Login | `/login` | Firebase email/password access and public event entry point |
| Role dashboard | `/dashboard` | Shows actions according to `accountType` and `eventRole` |
| Portal Escolar | `/portal-escolar` | Entry point for academic modules |
| Avisos y actividades | `/portal-escolar/actividades` | Teacher creates content; student sees it |
| Permisos | `/permisos` | Role-specific permission options |
| Crear/solicitar permiso | `/permisos/crear` | Direct creation for technical; request for teacher/organizer |
| Mi permiso y QR | `/permisos/mi-qr` | Student sees status, dates, and QR |
| Consultar QR | `/permisos/consultar-qr` | Camera placeholder, manual fallback, and result state |
| Eventos | `/eventos` | Active event and event-role actions |
| Inscripción pública | `/eventos/inscripcion` | Registration without requiring an account |
| Administrar inscripciones | `/eventos/inscripciones` | Approve, reserve, or reject registrations |
| Perfil y ajustes | `/perfil` | Account data, preferences, and logout |

Route strings are recorded in `lib/core/routing/app_router.dart`. Milestone 1 uses Flutter `Navigator` to keep the existing app simple. A future migration to `go_router` can reuse these contracts without changing the design.

## 3. Navigation model

### Mobile

The authenticated shell uses a five-item bottom navigation bar: Inicio, Portal, Permisos, Eventos, and Perfil.

### Windows, tablet, and web

At 900 logical pixels or wider, the same destinations become a left `NavigationRail`. The top bar always displays the NEXO 360 identity, current user name, and profile shortcut.

### Public flow

`Login -> Inscripción pública -> Confirmation`

No event account is required for the initial registration form.

## 4. Access matrix frozen for the prototype

| Action | Technical | Teacher | Student | Event organizer | Commissioner/guest |
|---|---:|---:|---:|---:|---:|
| View school content | Yes | Yes | Yes | Based on account type | Based on account type |
| Publish school activity | Yes | Yes | No | Based on account type | Based on account type |
| Create real permission | Yes | No | No | No | No |
| Request permission | Not needed | Yes | No | Yes | No |
| Display personal permission QR | No | No | Yes | Only if account is student | Only if account is student |
| Consult student QR | Yes | Yes | Yes | Yes | No extra access from event role |
| Submit event registration | Yes | Yes | Yes | Yes | Yes/public |
| Administer registrations | Yes | Only if organizer | Only if organizer | Yes | No |

## 5. Visual guide

| Token | Value | Use |
|---|---|---|
| Primary | `#123B6D` | Top bar, primary actions, selected navigation |
| Primary dark | `#09284C` | QR camera placeholder and high-contrast areas |
| Accent | `#20B8CD` | Logo mark and profile avatar |
| Background | `#F5F7FA` | Application canvas |
| Surface | `#FFFFFF` | Cards, forms, navigation surfaces |
| Text | `#17202A` | Primary text |
| Muted | `#667085` | Secondary information |
| Border | `#DDE3EA` | Cards and input borders |
| Valid/approved | `#1F8A4C` | Active and approved states |
| Pending | `#B77900` | Pending, review, and warning states |
| Rejected/expired | `#C53A3A` | Error, rejected, expired, or cancelled states |

Typography uses the platform Roboto font with only weights 400 and 700. Components use 12-16 pixel corner radii, 48-pixel minimum action height, and Material 3.

## 6. Components frozen for reuse

- `NexoLogo`: temporary code-native brand mark; replace with an approved asset without changing layout.
- `PageHeading`: title and short purpose statement.
- `NexoModuleCard`: icon, action title, description, optional status, and navigation affordance.
- `StatusBadge`: success, pending, and danger variants.
- `PrototypeNotice`: identifies UI that is not connected to Firestore yet.
- `PrototypeScreen`: consistent top bar, responsive width, padding, and scrolling.

## 7. States required in the next milestone

Every functional screen must support loading, empty data, successful data, recoverable Firebase error, unauthorized action, and success confirmation after a write. QR consultation additionally needs valid, expired, cancelled, not found, and token mismatch states.

## 8. Milestone 1 checkpoint

The checkpoint passes when all listed screens open from the defined navigation, role-dependent cards match the matrix, public registration opens from login, colors come from the shared theme, unfinished flows are identified, and no screen introduces old `role`, `movementRole`, or `validate_qr` fields.

