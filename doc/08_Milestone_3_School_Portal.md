# NEXO 360 - Milestone 3 School Portal

## Delivered outcome

The School Portal now uses Cloud Firestore in real time. A teacher or technical user can publish an activity, sign out, and a student can sign in and see the same activity without rebuilding the application.

## Collection names

The simplified milestone mentioned `announcements` and `assignments`, but the current repository already migrated those names. This implementation therefore uses:

```text
users/{uid}
school_announcements/{announcementId}
school_activities/{activityId}
```

Do not create new `announcements` or `assignments` collections.

## Implemented files

| File | Responsibility |
|---|---|
| `core/models/school_announcement.dart` | Converts announcement documents into app models |
| `core/models/school_assignment.dart` | Converts activity documents into app models |
| `core/services/school_portal_service.dart` | Firestore listeners, assignment creation, sample announcement seed |
| `core/utils/date_formatters.dart` | Consistent date and time display |
| `features/portal_escolar/assignments_screen.dart` | Announcements and shared activity list |
| `features/portal_escolar/create_assignment_sheet.dart` | Teacher creation form |
| `features/portal_escolar/assignment_detail_screen.dart` | Student activity details and attachment link |
| `features/home/home_screen.dart` | Sample grade and attendance preview |
| `test/school_portal_models_test.dart` | Firestore model and date tests |

## Assignment document

Every `school_activities/{activityId}` document contains:

| Field | Firestore type | Source |
|---|---|---|
| `title` | string | Teacher form |
| `description` | string | Teacher instructions |
| `course` | string | Course selector |
| `dueDate` | timestamp | Date and time picker |
| `teacherId` | string | Current authenticated profile UID |
| `teacherName` | string | Current profile display name |
| `createdAt` | timestamp | `FieldValue.serverTimestamp()` |
| `attachmentUrl` | string or null | Optional link |
| `classId` | string or null | Teacher profile |
| `status` | string | Always `published` in this MVP |

## Functional states

- Loading: `AppLoadingIndicator` while each listener connects.
- Empty: `AppEmptyState` when no announcements or assignments exist.
- Firebase error: `AppErrorMessage` when a listener fails.
- Creation error: form-level error when Firestore rejects the write.
- Successful creation: bottom sheet closes and a success snackbar appears.
- Real-time update: the activity list refreshes through Firestore snapshots.

## Role behavior

### Teacher or technical account

- Sees the **Nueva actividad** button.
- Enters title and instructions.
- Selects a course.
- Chooses due date and time.
- Optionally enters an attachment URL.
- Publishes the activity to `school_activities`.
- Can create three fixed demonstration announcements when the list is empty.

### Student

- Cannot see creation controls.
- Reads the same `school_activities` collection.
- Opens any activity to see its instructions, course, teacher and due date.
- Sees and can copy the attachment link.
- Sees sample average and attendance cards on the dashboard.

## End-to-end checkpoint

1. Log in as `teacher@nexo360.com` or an existing active teacher.
2. Open **Actividades**.
3. If announcements are empty, select **Crear datos de demostración**.
4. Select **Nueva actividad**.
5. Complete and publish the form.
6. Confirm the new document appears under `school_activities` in Firebase Console.
7. Sign out.
8. Log in as `student@nexo360.com` or an existing active student.
9. Open **Actividades**.
10. Open the new activity and confirm its due date and link.

The checkpoint passes only when the student sees the document created by the teacher.

