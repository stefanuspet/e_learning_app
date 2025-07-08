class Statistics {
  final int totalSubjects;
  final int pendingAssignments;
  final int completedAssignments;
  final String attendanceRate;

  final int present;
  final int sick;
  final int excused;
  final int absent;

  Statistics({
    required this.totalSubjects,
    required this.pendingAssignments,
    required this.completedAssignments,
    required this.attendanceRate,
    required this.present,
    required this.sick,
    required this.excused,
    required this.absent,
  });

  /// fromJson() - NEW
  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalSubjects: json['total_subjects'] ?? 0,
      pendingAssignments: json['pending_assignments'] ?? 0,
      completedAssignments: json['completed_assignments'] ?? 0,
      attendanceRate: json['attendance_rate']?.toString() ?? '0%',
      present: json['present'] ?? 0,
      sick: json['sick'] ?? 0,
      excused: json['excused'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'total_subjects': totalSubjects,
      'pending_assignments': pendingAssignments,
      'completed_assignments': completedAssignments,
      'attendance_rate': attendanceRate,
      'present': present,
      'sick': sick,
      'excused': excused,
      'absent': absent,
    };
  }
}
