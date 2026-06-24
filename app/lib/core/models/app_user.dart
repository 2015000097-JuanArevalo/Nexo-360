class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String accountType;
  final String eventRole;
  final List<String> eventPermissions;
  final String status;
  final String? schoolCode;
  final String? classId;
  final String? committeeId;
  final List<String> assignedEventIds;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.accountType,
    required this.eventRole,
    required this.eventPermissions,
    required this.status,
    required this.schoolCode,
    required this.classId,
    required this.committeeId,
    required this.assignedEventIds,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Usuario',
      accountType: data['accountType'] ?? 'student',
      eventRole: data['eventRole'] ?? 'guest',
      eventPermissions: List<String>.from(data['eventPermissions'] ?? []),
      status: data['status'] ?? 'inactive',
      schoolCode: data['schoolCode'],
      classId: data['classId'],
      committeeId: data['committeeId'],
      assignedEventIds: List<String>.from(data['assignedEventIds'] ?? []),
    );
  }

  bool get isActive => status == 'active';

  bool get isTechnical => accountType == 'technical';
  bool get isTeacher => accountType == 'teacher';
  bool get isStudent => accountType == 'student';

  bool get isEventOrganizer => eventRole == 'organizer';
  bool get isEventCommissioner => eventRole == 'commissioner';
  bool get isEventGuest => eventRole == 'guest';

  bool hasEventPermission(String permission) {
    return eventPermissions.contains(permission);
  }
}
