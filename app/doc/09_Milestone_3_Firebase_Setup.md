# NEXO 360 - Milestone 3 Firebase Setup

## 1. Required profiles

The teacher and student must both exist in:

```text
Firebase Authentication
Firestore users/{same Authentication UID}
```

Teacher profile requirements:

```json
{
  "accountType": "teacher",
  "status": "active"
}
```

Student profile requirements:

```json
{
  "accountType": "student",
  "status": "active"
}
```

Keep all other fields defined in `app/tool/demo_user_profiles.json`.

## 2. Deploy or merge the Firestore rules

The repository rules now validate the exact fields written by the School Portal. From `app/`:

```bash
firebase login
firebase use nexo-360-9ed4c
firebase deploy --only firestore:rules
```

Important: Firebase CLI deployment replaces the rules currently published in Firebase Console. If your Console contains the longer, more advanced ruleset that is not yet committed to GitHub, do not blindly deploy this file. Instead, copy these parts from the delivered `firestore.rules` into your advanced ruleset:

```text
validAnnouncement(data)
validActivity(data)
match /school_announcements/{documentId}
match /school_activities/{documentId}
```

Then publish the merged rules and commit that final ruleset to GitHub.

## 3. No composite index is required

Milestone 3 uses:

```text
school_announcements ordered by createdAt
school_activities ordered by dueDate
```

These are single-field queries and normally use Firestore's automatic single-field indexes. If either field was manually exempted from indexing, remove that exemption.

## 4. Create sample announcements

Recommended method:

1. Log in with a teacher or technical profile.
2. Open **Actividades**.
3. When the announcement list is empty, press **Crear datos de demostración**.
4. Confirm the operation.

The app creates:

```text
announcement-demo-01
announcement-demo-02
announcement-demo-03
```

The reference content is also recorded in `app/tool/school_portal_sample_data.json`.

## 5. Verify Firestore types

In Firebase Console, confirm:

- `dueDate` is a timestamp, not a quoted string;
- `createdAt` is a timestamp;
- `teacherId` exactly matches the Authentication UID;
- `attachmentUrl` is a string or null;
- `status` is `published`;
- `title`, `description`, `course`, and `teacherName` are strings.

## 6. Run locally

```bash
cd app
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

If a write produces `permission-denied`, check these items in order:

1. The logged-in UID has a matching `users/{uid}` document.
2. `status` is `active`.
3. `accountType` is `teacher` or `technical`.
4. The latest rules were published.
5. `teacherId` is being filled from the authenticated profile.

