class Subject {
  final int id;
  final String name;
  final String? description;
  final Teacher? teacher;

  Subject({
    required this.id,
    required this.name,
    this.description,
    this.teacher,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    // Handle 'id' or 'subject_id' field
    int subjectId = 0;
    if (json.containsKey('id') && json['id'] != null) {
      subjectId = json['id'];
    } else if (json.containsKey('subject_id') && json['subject_id'] != null) {
      subjectId = json['subject_id'];
    }

    // Handle 'name' or 'subject_name' field
    String subjectName = 'Unknown Subject';
    if (json.containsKey('name') && json['name'] != null) {
      subjectName = json['name'];
    } else if (json.containsKey('subject_name') && json['subject_name'] != null) {
      subjectName = json['subject_name'];
    }

    return Subject(
      id: subjectId,
      name: subjectName,
      description: json['description'],
      teacher: json['teacher'] != null
          ? Teacher.fromJson(json['teacher'])
          : null,
    );
  }
}

class Teacher {
  final int id;
  final String name;
  final String? nip;
  final String? phone;
  final String? address;

  Teacher({
    required this.id,
    required this.name,
    this.nip,
    this.phone,
    this.address,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Teacher',
      nip: json['nip'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}