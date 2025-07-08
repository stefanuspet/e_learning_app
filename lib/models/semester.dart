class Semester {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final ClassInfo? classInfo;

  Semester({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.classInfo,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? false,
      classInfo: json['class'] != null
          ? ClassInfo.fromJson(json['class'])
          : null,
    );
  }
}

class ClassInfo {
  final int id;
  final String name;
  final String description;

  ClassInfo({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
