# NEXO 360 - Milestone 2 Application Foundation

## Delivered outcome

Milestone 2 turns the Milestone 1 mockup into an application foundation with a centralized Firebase session, declarative routes, role guards, responsive authenticated shell, role-specific dashboards, reusable UI states, and a brand system based on the supplied NEXO 360 logo.

## Repository-aware organization

The project already used a feature-based layout. It was preserved because it separates the requested responsibilities without moving stable files only for naming purposes.

```text
lib/
├── core/
│   ├── auth/                 # Authentication, profile loading, app session
│   ├── models/               # AppUser and access helpers
│   ├── routing/              # Route constants, GoRouter, route guards
│   ├── theme/                # NEXO/Don Bosco visual theme
│   └── widgets/              # Shared shell and reusable UI components
├── features/
│   ├── login/                # Authentication screen
│   ├── home/                 # Role-dependent dashboard
│   ├── portal_escolar/       # Assignments and announcements
│   ├── permisos/             # Permission and QR screens
│   ├── eventos/              # Public registration and administration
│   └── profile/              # Settings and sign-out
├── app.dart                  # Session and router composition
├── firebase_options.dart
└── main.dart                 # Firebase initialization
```

This maps to the requested models, services, screens, widgets, and routes layers while keeping related feature files together.

## Session flow

1. `main.dart` initializes Firebase.
2. `Nexo360App` creates one `AppSession` and one `GoRouter`.
3. `AppSession` listens to `FirebaseAuth.authStateChanges()`.
4. When a Firebase user exists, it loads `users/{uid}` from Firestore.
5. Missing or inactive profiles are signed out.
6. GoRouter refreshes when session state changes.
7. Authenticated users are routed to `/dashboard`.
8. Unauthorized routes redirect to `/dashboard`.

Client-side guards improve UX but are not production security. Firestore rules remain the authoritative data-access layer.

## Route catalog

| Route | Authentication | Access rule |
|---|---:|---|
| `/login` | No | Unauthenticated users |
| `/dashboard` | Yes | Every active profile |
| `/assignments` | Yes | Every active profile; write actions only for teacher/technical |
| `/permissions` | Yes | Every active profile; cards filtered by role |
| `/permissions/create` | Yes | Technical, teacher, or event organizer |
| `/permissions/student` | Yes | Student only |
| `/permissions/validate` | Yes | Every active profile under current repository rules |
| `/events` | Yes | Every active profile |
| `/events/register` | No | Public registration |
| `/events/admin` | Yes | Technical or event organizer |
| `/profile` | Yes | Every active profile |

## Requested accounts mapped to the repository model

| Account | Firestore model | Dashboard access |
|---|---|---|
| `teacher@nexo360.com` | `accountType: teacher`, `eventRole: guest` | Activities, permission requests, QR consultation, events |
| `student@nexo360.com` | `accountType: student`, `eventRole: guest` | Activities, personal QR, QR consultation, events |
| `staff@nexo360.com` | `accountType: technical`, `eventRole: none` | Permission creation, QR consultation, event administration |
| `organizer@nexo360.com` | `accountType: teacher`, `eventRole: organizer` | Activities, permission requests, registration administration |
| Guest | No Firebase account | Public `/events/register` flow |

No staff, organizer, or guest account types were added. Doing so would conflict with the role model already documented in the repository.

## Reusable components

All shared components are in `lib/core/widgets/nexo_ui.dart`.

| Requirement | Component |
|---|---|
| Dashboard card | `NexoModuleCard` |
| Loading indicator | `AppLoadingIndicator` |
| Error message | `AppErrorMessage` |
| Status chip | `StatusBadge` |
| Standard form field | `NexoTextFormField` |
| Confirmation dialog | `showNexoConfirmationDialog` |
| Empty-state message | `AppEmptyState` |
| Branded logo | `NexoLogo`, `NexoBrandPanel` |
| Responsive navigation | `NexoAppShell` |

## Brand system

The supplied logo is stored at `app/assets/images/nexo_360_logo.png` and declared in `pubspec.yaml`.

| Color | Hex | Use |
|---|---|---|
| Logo navy | `#020619` | App bars, login background, wide navigation |
| Don Bosco blue | `#0E6EC7` | School Portal and academic actions |
| Cyan | `#00A4D6` | QR, connectivity, active accents |
| Violet | `#5E109E` | Permissions and organizer actions |
| Youth coral | `#D4526B` | Movimiento Juventud and event highlights |

## Verification commands

Run from `app/`:

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

Route tests verify that students cannot access event administration, technical staff cannot access a student's personal QR, and organizers can access registration administration.

## Milestone checkpoint

- Each Firebase account reaches `/dashboard` after its Firestore profile loads.
- Dashboard cards are generated from `AppUser` access helpers.
- Direct unauthorized URLs redirect to `/dashboard`.
- Public registration remains available without authentication.
- Navigation changes from bottom navigation to side rail at 900 logical pixels.
- Firebase rules enforce server-side access independently from UI visibility.

