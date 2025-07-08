import 'assignment_model.dart';
import 'subject_model.dart';

class GradeStats {
  final int totalAssignments;
  final int graded;
  final int submittedNotGraded;
  final int notSubmitted;
  final double averageGrade;
  final int highestGrade;
  final int lowestGrade;

  GradeStats({
    required this.totalAssignments,
    required this.graded,
    required this.submittedNotGraded,
    required this.notSubmitted,
    required this.averageGrade,
    required this.highestGrade,
    required this.lowestGrade,
  });

  factory GradeStats.fromJson(Map<String, dynamic> json) {
    // Parse average_grade which could be double or int
    double avgGrade = 0.0;
    if (json['average_grade'] != null) {
      avgGrade = double.parse(json['average_grade'].toString());
    }

    return GradeStats(
      totalAssignments: json['total_assignments'] ?? 0,
      graded: json['graded'] ?? 0,
      submittedNotGraded: json['submitted_not_graded'] ?? 0,
      notSubmitted: json['not_submitted'] ?? 0,
      averageGrade: avgGrade,
      highestGrade: json['highest_grade'] ?? 0,
      lowestGrade: json['lowest_grade'] ?? 0,
    );
  }
}

class SubjectGrade {
  final int subjectId;
  final String subjectName;
  final double averageGrade;
  final int totalGraded;
  final List<Assignment> assignments;

  SubjectGrade({
    required this.subjectId,
    required this.subjectName,
    required this.averageGrade,
    required this.totalGraded,
    required this.assignments,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    // Handle 'subject_id' field
    int subjectId = 0;
    if (json.containsKey('subject_id') && json['subject_id'] != null) {
      subjectId = json['subject_id'];
    }

    // Handle 'subject_name' field
    String subjectName = 'Unknown Subject';
    if (json.containsKey('subject_name') && json['subject_name'] != null) {
      subjectName = json['subject_name'];
    }

    // Handle 'average_grade' field which could be double or int
    double avgGrade = 0.0;
    if (json.containsKey('average_grade') && json['average_grade'] != null) {
      avgGrade = double.parse(json['average_grade'].toString());
    }

    // Handle 'total_graded' field
    int totalGraded = 0;
    if (json.containsKey('total_graded') && json['total_graded'] != null) {
      totalGraded = json['total_graded'];
    }

    // Handle 'assignments' field
    var assignmentsList = <Assignment>[];
    if (json.containsKey('assignments') && json['assignments'] != null) {
      try {
        assignmentsList = List<Assignment>.from(
          (json['assignments'] as List).map((item) => Assignment.fromJson(item)),
        );
      } catch (e) {
        print('Error parsing assignments in SubjectGrade: $e');
      }
    }

    return SubjectGrade(
      subjectId: subjectId,
      subjectName: subjectName,
      averageGrade: avgGrade,
      totalGraded: totalGraded,
      assignments: assignmentsList,
    );
  }
}

class SubjectGradeDetail {
  final Subject subject;
  final GradeStats stats;
  final List<Assignment> gradedAssignments;
  final List<Assignment> submittedAssignments;
  final List<Assignment> pendingAssignments;

  SubjectGradeDetail({
    required this.subject,
    required this.stats,
    required this.gradedAssignments,
    required this.submittedAssignments,
    required this.pendingAssignments,
  });

  factory SubjectGradeDetail.fromJson(Map<String, dynamic> json) {
    // Validate the existence of required fields
    if (!json.containsKey('subject') || !json.containsKey('stats') || !json.containsKey('assignments')) {
      print('Missing required fields in SubjectGradeDetail.fromJson');
      // Return a default instance with empty data
      return SubjectGradeDetail(
        subject: Subject(id: 0, name: 'Unknown Subject'),
        stats: GradeStats(
          totalAssignments: 0,
          graded: 0,
          submittedNotGraded: 0,
          notSubmitted: 0,
          averageGrade: 0.0,
          highestGrade: 0,
          lowestGrade: 0,
        ),
        gradedAssignments: [],
        submittedAssignments: [],
        pendingAssignments: [],
      );
    }

    // Parse subject
    Subject subject;
    try {
      subject = Subject.fromJson(json['subject']);
    } catch (e) {
      print('Error parsing subject in SubjectGradeDetail: $e');
      subject = Subject(id: 0, name: 'Unknown Subject');
    }

    // Parse stats
    GradeStats stats;
    try {
      stats = GradeStats.fromJson(json['stats']);
    } catch (e) {
      print('Error parsing stats in SubjectGradeDetail: $e');
      stats = GradeStats(
        totalAssignments: 0,
        graded: 0,
        submittedNotGraded: 0,
        notSubmitted: 0,
        averageGrade: 0.0,
        highestGrade: 0,
        lowestGrade: 0,
      );
    }

    // Parse assignments
    List<Assignment> gradedAssignments = [];
    List<Assignment> submittedAssignments = [];
    List<Assignment> pendingAssignments = [];

    if (json['assignments'].containsKey('graded') && json['assignments']['graded'] != null) {
      try {
        gradedAssignments = (json['assignments']['graded'] as List)
            .map((item) => Assignment.fromJson(item))
            .toList();
      } catch (e) {
        print('Error parsing graded assignments in SubjectGradeDetail: $e');
      }
    }

    if (json['assignments'].containsKey('submitted_not_graded') && json['assignments']['submitted_not_graded'] != null) {
      try {
        submittedAssignments = (json['assignments']['submitted_not_graded'] as List)
            .map((item) => Assignment.fromJson(item))
            .toList();
      } catch (e) {
        print('Error parsing submitted assignments in SubjectGradeDetail: $e');
      }
    }

    if (json['assignments'].containsKey('not_submitted') && json['assignments']['not_submitted'] != null) {
      try {
        pendingAssignments = (json['assignments']['not_submitted'] as List)
            .map((item) => Assignment.fromJson(item))
            .toList();
      } catch (e) {
        print('Error parsing pending assignments in SubjectGradeDetail: $e');
      }
    }

    return SubjectGradeDetail(
      subject: subject,
      stats: stats,
      gradedAssignments: gradedAssignments,
      submittedAssignments: submittedAssignments,
      pendingAssignments: pendingAssignments,
    );
  }
}