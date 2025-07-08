import 'package:flutter/foundation.dart';
import '../api/grade_api.dart';

class GradeProvider with ChangeNotifier {
  final GradeApi _gradeApi;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _grades = {
    'stats': {
      'total_assignments': 0,
      'graded': 0,
      'submitted_not_graded': 0,
      'not_submitted': 0,
      'average_grade': 0.0,
      'highest_grade': 0,
      'lowest_grade': 0
    },
    'subjects': []
  };

  Map<String, dynamic>? _subjectGrades;
  Map<String, dynamic>? _assignmentDetail;
  Map<String, dynamic>? _classPerformance;
  List<Map<String, dynamic>>? _subjects;

  GradeProvider(this._gradeApi);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get grades => _grades;
  Map<String, dynamic>? get subjectGrades => _subjectGrades;
  Map<String, dynamic>? get assignmentDetail => _assignmentDetail;
  Map<String, dynamic>? get classPerformance => _classPerformance;
  List<Map<String, dynamic>>? get subjects => _subjects;

  // Get all grades
  Future<void> getGrades() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _gradeApi.getGrades();

      // Validate result structure
      if (result != null &&
          result.containsKey('stats') &&
          result.containsKey('subjects')) {
        _grades = result;
      } else {
        throw Exception('Invalid data format received from API');
      }

      _subjectGrades = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw to allow handling in UI
    }
  }

  // Get grades by subject
  Future<void> getGradesBySubject(int subjectId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _gradeApi.getGradesBySubject(subjectId);

      // Validate result structure
      if (result != null &&
          result.containsKey('subject') &&
          result.containsKey('stats') &&
          result.containsKey('assignments')) {
        _subjectGrades = result;
      } else {
        throw Exception('Invalid data format received from API');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw to allow handling in UI
    }
  }

  // Get assignment detail
  Future<void> getAssignmentDetail(int assignmentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _gradeApi.getAssignmentDetail(assignmentId);

      // Validate result
      if (result != null) {
        _assignmentDetail = result;
      } else {
        throw Exception('Invalid assignment data received from API');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw to allow handling in UI
    }
  }

  // Get class performance for an assignment
  Future<void> getClassPerformance(int assignmentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _gradeApi.getClassPerformance(assignmentId);

      // Validate result
      if (result != null) {
        _classPerformance = result;
      } else {
        throw Exception('Invalid performance data received from API');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw to allow handling in UI
    }
  }

  // Get subjects for dropdown
  Future<void> getSubjects() async {
    try {
      if (_subjects != null && _subjects!.isNotEmpty) return;

      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _gradeApi.getSubjects();

      if (result != null && result is List) {
        _subjects = [
          {'id': null, 'name': 'All Subjects'},
          ...result,
        ];
      } else {
        throw Exception('Invalid subjects data received from API');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }



  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}