class Student {
  final int id;
  final String name;
  final String nisn;
  final String? email;
  final String? gender;
  final String? birthDate;
  final String? birthPlace;
  final String? religion;
  final String? className;
  final Map<String, dynamic>? currentSemester;
  final Map<String, dynamic>? currentClass;
  final int? userId;

  Student({
    required this.id,
    required this.name,
    required this.nisn,
    this.email,
    this.gender,
    this.birthDate,
    this.birthPlace,
    this.religion,
    this.className,
    this.currentSemester,
    this.userId,
    this.currentClass,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    // Handle jika response langsung berupa data student atau nested di bawah data
    final studentData = json.containsKey('data') ? json['data'] : json;

    String? extractedClassName;
    if (studentData['current_class'] != null && studentData['current_class'] is Map) {
      extractedClassName = studentData['current_class']['name'];
    } else if (studentData.containsKey('class_name')) {
      extractedClassName = studentData['class_name'];
    }

    return Student(
      id: studentData['id'],
      name: studentData['name'],
      nisn: studentData['nisn'],
      userId: json['user_id'],
      email: studentData['email'],
      gender: studentData['gender'],
      birthDate: studentData['birth_date'],
      birthPlace: studentData['birth_place'],
      religion: studentData['religion'],
      className: extractedClassName,
      currentSemester: studentData['current_semester'],
      currentClass: studentData['current_class'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nisn': nisn,
      'email': email,
      'gender': gender,
      'birth_date': birthDate,
      'birth_place': birthPlace,
      'religion': religion,
      'class_name': className,
      'current_semester': currentSemester,
      'current_class': currentClass,
    };
  }
}