# NEXO 360 - Milestone 2 Firebase Configuration

## 1. Confirm the project

The repository is configured for Firebase project `nexo-360-9ed4c` and Android package `com.example.nexo_360`.

From `app/`:

```bash
firebase login
firebase use nexo-360-9ed4c
flutterfire configure --project=nexo-360-9ed4c
```

Select Android and Web for the prototype. Re-run `flutterfire configure` only when adding a platform or changing Firebase services or configuration.

## 2. Enable Email/Password

In Firebase Console:

1. Open **Build -> Authentication**.
2. Select **Sign-in method**.
3. Enable **Email/Password**.
4. Keep anonymous authentication disabled.

## 3. Create the four authenticated demo users

Under **Authentication -> Users -> Add user**, create:

```text
teacher@nexo360.com
student@nexo360.com
staff@nexo360.com
organizer@nexo360.com
```

Use a demo-only password of at least six characters. Store it outside the repository.

The guest flow does not require a Firebase Authentication user. It opens at `/events/register`.

## 4. Create matching Firestore profiles

For each Authentication user:

1. Copy the UID displayed in Firebase Authentication.
2. Open **Firestore Database -> Data**.
3. Create or open the `users` collection.
4. Create a document whose ID is exactly the Authentication UID.
5. Copy the corresponding fields from `app/tool/demo_user_profiles.json`.
6. Replace the placeholder in both `documentId` and `data.uid` with the real UID.
7. Add `createdAt` and `updatedAt` as Firestore Timestamp fields.

Required fields:

```text
uid
email
displayName
accountType
eventRole
eventPermissions
status
schoolCode
classId
committeeId
assignedEventIds
createdAt
updatedAt
```

The app rejects the profile when `status` is not `active` or when a matching `users/{uid}` document does not exist.

## 5. Deploy Firestore rules and indexes

The included `app/firestore.rules` and `app/firestore.indexes.json` are already referenced by `firebase.json`.

```bash
cd app
firebase deploy --only firestore:rules,firestore:indexes
```

These are prototype rules. Client-side route guards do not replace Firestore security rules, App Check, server-side QR validation, or a production security review.

## 6. Authorized web domains

Under **Authentication -> Settings -> Authorized domains**:

- keep `localhost` for local development;
- add the final Firebase Hosting domain if you deploy the web version;
- do not add unrelated domains.

## 7. Android verification

The following must represent the same Android app:

```text
android/app/build.gradle.kts -> com.example.nexo_360
android/app/google-services.json -> com.example.nexo_360
Firebase Console Android app -> com.example.nexo_360
```

If you change the package name, register the new package in Firebase and download a replacement `google-services.json`.

## 8. Login test matrix

| Login | Expected access |
|---|---|
| Teacher | `/assignments`, `/permissions/create`, `/permissions/validate`, `/events` |
| Student | `/assignments`, `/permissions/student`, `/permissions/validate`, `/events` |
| Staff/technical | `/permissions/create`, `/permissions/validate`, `/events/admin` |
| Organizer | `/assignments`, `/permissions/create`, `/events/admin` |
| Unauthenticated guest | `/events/register` only |

For every account, paste a forbidden URL directly into the browser and confirm that it returns to `/dashboard`.

