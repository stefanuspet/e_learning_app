class Assignment {
  final int id;
  final String title;
  final String description;
  final DateTime deadline;
  final String? filePath;
  final DateTime? submittedAt;
  final int? grade;
  final String? messageEval;
  final bool isLate;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.filePath,
    this.submittedAt,
    this.grade,
    this.messageEval,
    this.isLate = false,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    // Handle 'assignment_id' or 'id' field
    int assignmentId = 0;
    if (json.containsKey('assignment_id') && json['assignment_id'] != null) {
      assignmentId = json['assignment_id'];
    } else if (json.containsKey('id') && json['id'] != null) {
      assignmentId = json['id'];
    }

    // Handle 'description' field which might be missing
    String description = '';
    if (json.containsKey('description') && json['description'] != null) {
      description = json['description'];
    }

    // Handle 'deadline' field which might be missing or in different format
    DateTime deadline = DateTime.now().add(const Duration(days: 7)); // Default value
    if (json.containsKey('deadline') && json['deadline'] != null) {
      try {
        deadline = DateTime.parse(json['deadline']);
      } catch (e) {
        print('Error parsing deadline: $e');
      }
    }

    // Handle 'submitted_at' field
    DateTime? submittedAt;
    if (json.containsKey('submitted_at') && json['submitted_at'] != null) {
      try {
        submittedAt = DateTime.parse(json['submitted_at']);
      } catch (e) {
        print('Error parsing submitted_at: $e');
      }
    }

    // Handle 'is_late' field with default value
    bool isLate = false;
    if (json.containsKey('is_late') && json['is_late'] != null) {
      isLate = json['is_late'];
    }

    return Assignment(
      id: assignmentId,
      title: json['title'] ?? 'Unnamed Assignment',
      description: description,
      deadline: deadline,
      filePath: json['file_path'],
      submittedAt: submittedAt,
      grade: json['grade'],
      messageEval: json['message_eval'],
      isLate: isLate,
    );
  }
}

class AssignmentSubmission {
  final int id;
  final int assignmentId;
  final int studentId;
  final String? submissionText;
  final String? filePath;
  final int? grade;
  final String? messageEval;
  final DateTime? submittedAt;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.submissionText,
    this.filePath,
    this.grade,
    this.messageEval,
    this.submittedAt,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    DateTime? submittedAt;
    if (json.containsKey('submitted_at') && json['submitted_at'] != null) {
      try {
        submittedAt = DateTime.parse(json['submitted_at']);
      } catch (e) {
        print('Error parsing submitted_at in AssignmentSubmission: $e');
      }
    }

    return AssignmentSubmission(
      id: json['id'] ?? 0,
      assignmentId: json['assignment_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      submissionText: json['submission_text'],
      filePath: json['file_path'],
      grade: json['grade'],
      messageEval: json['message_eval'],
      submittedAt: submittedAt,
    );
  }
}