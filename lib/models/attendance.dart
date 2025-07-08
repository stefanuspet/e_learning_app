import 'package:e_learning_app/models/semester.dart';

class Attendance {
  final int id;
  final String status;
  final DateTime submittedAt;
  final Session session;
  final Semester semester;

  Attendance({
    required this.id,
    required this.status,
    required this.submittedAt,
    required this.session,
    required this.semester,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      status: json['status'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : DateTime.now(),
      session: Session.fromJson(json['session']),
      semester: json['semester'] != null
          ? Semester.fromJson(json['semester'])
          : Semester(
        id: 0,
        name: '-',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        isActive: false,
      ),
    );
  }

}

class Session {
  final int id;
  final String title;
  final DateTime date;

  Session({
    required this.id,
    required this.title,
    required this.date,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
    );
  }
}
