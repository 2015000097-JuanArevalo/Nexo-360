# NEXO 360 - Prototype Setup and Firebase Configuration

This guide applies to the current repository. The Flutter application is inside `app/` and is already associated with Firebase project `nexo-360-9ed4c`.

## 1. Local requirements

Install Flutter stable, Android Studio or Chrome, Node.js LTS, Firebase CLI, and FlutterFire CLI.

```bash
flutter doctor
node --version
firebase --version
dart pub global list
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

## 2. Run the design shell

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For Android:

```bash
flutter devices
flutter run -d <ANDROID_DEVICE_ID>
```

The Android package name is `com.example.nexo_360`, matching `google-services.json`. Do not change one without registering a replacement Android app in Firebase and downloading a new configuration file.

## 3. Confirm Firebase association

The repository already contains `firebase.json`, `lib/firebase_options.dart`, `android/app/google-services.json`, and Firebase initialization in `lib/main.dart`.

To regenerate configuration after adding or renaming a platform:

```bash
cd app
firebase login
flutterfire configure --project=nexo-360-9ed4c
```

For the deadline, Android and Web are sufficient.

## 4. Enable Authentication

1. Open project `nexo-360-9ed4c` in Firebase Console.
2. Go to **Build -> Authentication -> Get started**.
3. Open **Sign-in method**.
4. Enable **Email/Password**.
5. Do not enable anonymous sign-in for this prototype.

Recommended demo accounts:

| Email | `accountType` | `eventRole` | Purpose |
|---|---|---|---|
| `technical@nexo360.test` | `technical` | `none` | Full technical flow |
| `teacher.guest@nexo360.test` | `teacher` | `guest` | School publishing and permission request |
| `teacher.organizer@nexo360.test` | `teacher` | `organizer` | Registration administration |
| `student.guest@nexo360.test` | `student` | `guest` | Student activity and QR flow |
| `student.commissioner@nexo360.test` | `student` | `commissioner` | Limited event actions |

Use a demo-only password with at least six characters. Never commit passwords.

## 5. Create Firestore user profiles

1. Go to **Build -> Firestore Database** and create it in production mode.
2. For every Authentication user, copy its UID.
3. Create `users/{uid}` using exactly that UID as document ID.

Technical profile example:

```json
{
  "uid": "AUTH_UID_HERE",
  "email": "technical@nexo360.test",
  "displayName": "Técnico Demo",
  "accountType": "technical",
  "eventRole": "none",
  "eventPermissions": [],
  "status": "active",
  "schoolCode": "T-001",
  "classId": null,
  "committeeId": null,
  "assignedEventIds": [],
  "createdAt": "SERVER_TIMESTAMP",
  "updatedAt": "SERVER_TIMESTAMP"
}
```

Student profile example:

```json
{
  "uid": "AUTH_UID_HERE",
  "email": "student.guest@nexo360.test",
  "displayName": "Estudiante Demo",
  "accountType": "student",
  "eventRole": "guest",
  "eventPermissions": [],
  "status": "active",
  "schoolCode": "S-001",
  "classId": "class-10A",
  "committeeId": null,
  "assignedEventIds": ["event-demo-01"],
  "createdAt": "SERVER_TIMESTAMP",
  "updatedAt": "SERVER_TIMESTAMP"
}
```

Use Firestore Timestamp values in Console rather than the literal `SERVER_TIMESTAMP` string.

## 6. Collections for the next milestone

```text
users
school_announcements
school_activities
permissions
permission_requests
events
event_registrations
```

Do not return to obsolete names such as `assignments`, `announcements`, `qr_permissions`, or `movement_announcements`.

## 7. Deploy rules and indexes

The included rules are for a prototype, not a production security audit. They allow public reads of events and public registration creation with initial status `pending`.

```bash
cd app
firebase use nexo-360-9ed4c
firebase deploy --only firestore:rules,firestore:indexes
```

Before production, protect public registration with App Check and stronger validation, return only a minimal QR validation result through a trusted backend or Cloud Function, and consider custom claims for role administration.

## 8. Web configuration

In **Authentication -> Settings -> Authorized domains**, confirm `localhost` is present. Add the final Hosting domain only if you deploy a web build.

```bash
flutter build web
firebase init hosting
firebase deploy --only hosting
```

Choose `build/web` as the public directory, configure it as a single-page app, and do not overwrite Flutter's `index.html`.

## 9. Verification checklist

- Email/password sign-in is enabled.
- Every Auth UID has a matching `users/{uid}` document.
- Every profile has `status: active`.
- Account and event roles use only documented values.
- Android package and `google-services.json` match.
- `flutter analyze` has no errors and `flutter test` passes.
- Technical, teacher, and student accounts reach the expected dashboard.
- Public event registration opens without signing in.

## 10. Milestone boundary

These files freeze layout, access points, responsive navigation, forms, statuses, and feedback. Activity writes, QR generation/scanning, permission validation, file upload, event writes, and registration approval are intentionally left for development milestones. The blue prototype notice inside affected screens makes this boundary visible.

