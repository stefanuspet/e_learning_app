class User {
  final int id;
  final String email;
  final String role;
  final int? studentId; // Ubah menjadi nullable
  final String? name; // Tambahkan properti dari response
  final String? nisn; // Tambahkan properti dari response
  final String? emailVerifiedAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.studentId,
    this.name,
    this.nisn,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      studentId: json['student_id'], // Ini bisa null
      name: json['name'],
      nisn: json['nisn'],
      emailVerifiedAt: json['email_verified_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'student_id': studentId,
      'name': name,
      'nisn': nisn,
      'email_verified_at': emailVerifiedAt,
    };
  }
}