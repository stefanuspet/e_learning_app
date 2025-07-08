class DashboardStats {
  final int totalSubjects;
  final int pendingAssignments;
  final int completedAssignments;
  final String attendanceRate;

  DashboardStats({
    required this.totalSubjects,
    required this.pendingAssignments,
    required this.completedAssignments,
    required this.attendanceRate,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalSubjects: json['total_subjects'] ?? 0,
      pendingAssignments: json['pending_assignments'] ?? 0,
      completedAssignments: json['completed_assignments'] ?? 0,
      attendanceRate: json['attendance_rate'] ?? '0%',
    );
  }
}

class Subject {
  final int id;
  final String name;
  final String teacherName;
  final int materialsCount;
  final int assignmentsCount;
  final int completedAssignments;

  Subject({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.materialsCount,
    required this.assignmentsCount,
    required this.completedAssignments,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      materialsCount: json['materials_count'] ?? 0,
      assignmentsCount: json['assignments_count'] ?? 0,
      completedAssignments: json['completed_assignments'] ?? 0,
    );
  }
}

class UpcomingAssignment {
  final int id;
  final String title;
  final String subjectName;
  final DateTime deadline;

  UpcomingAssignment({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.deadline,
  });

  factory UpcomingAssignment.fromJson(Map<String, dynamic> json) {
    return UpcomingAssignment(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subjectName: json['subject_name'] ?? '',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : DateTime.now().add(const Duration(days: 7)),
    );
  }
}

class RecentMaterial {
  final int id;
  final String title;
  final String subjectName;
  final DateTime uploadedAt;

  RecentMaterial({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.uploadedAt,
  });

  factory RecentMaterial.fromJson(Map<String, dynamic> json) {
    return RecentMaterial(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subjectName: json['subject_name'] ?? '',
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : DateTime.now().subtract(const Duration(days: 1)),
    );
  }
}