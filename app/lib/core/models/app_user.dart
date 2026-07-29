class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String accountType;
  final String eventRole;
  final String status;
  final String schoolCode;
  final String classId;
  final List<String> courseIds;
  final String committeeId;
  final List<String> eventPermissions;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.accountType,
    required this.eventRole,
    required this.status,
    required this.schoolCode,
    required this.classId,
    required this.courseIds,
    required this.committeeId,
    required this.eventPermissions,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) => AppUser(
        uid: uid,
        email: data['email'] as String? ?? '',
        displayName: data['displayName'] as String? ?? 'Usuario',
        accountType: data['accountType'] as String? ?? 'student',
        eventRole: data['eventRole'] as String? ?? 'guest',
        status: data['status'] as String? ?? 'inactive',
        schoolCode: data['schoolCode'] as String? ?? '',
        classId: data['classId'] as String? ?? '',
        courseIds: List<String>.from(data['courseIds'] as List? ?? const []),
        committeeId: data['committeeId'] as String? ?? '',
        eventPermissions:
            List<String>.from(data['eventPermissions'] as List? ?? const []),
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'accountType': accountType,
        'eventRole': eventRole,
        'status': status,
        'schoolCode': schoolCode,
        'classId': classId,
        'courseIds': courseIds,
        'committeeId': committeeId,
        'eventPermissions': eventPermissions,
      };

  bool get isActive => status == 'active';
  bool get isTechnical => accountType == 'technical';
  bool get isTeacher => accountType == 'teacher';
  bool get isStudent => accountType == 'student';
  bool get isOrganizer => eventRole == 'organizer';
  bool get isCommissioner => eventRole == 'commissioner';
  bool get canPublishSchool => isTechnical || isTeacher;
  bool get canManageEvents => isTechnical || isOrganizer;
  bool get canManageSchedules => isTechnical;
  bool get canValidateQr => isTechnical || isTeacher;

  String get accountLabel => switch (accountType) {
        'technical' => 'Personal técnico',
        'teacher' => 'Docente',
        _ => 'Estudiante',
      };

  String get eventRoleLabel => switch (eventRole) {
        'organizer' => 'Organizador',
        'commissioner' => 'Comisionado',
        _ => 'Invitado',
      };
}
