import 'package:flutter/foundation.dart';
import '../api/assignment_api.dart';
import '../models/assignment_model.dart';

class AssignmentProvider with ChangeNotifier {
  final AssignmentApi _assignmentApi;

  bool _isLoading = false;
  String? _error;
  List<Assignment> _assignments = [];
  Map<String, dynamic>? _assignmentDetail;

  AssignmentProvider(this._assignmentApi);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Assignment> get assignments => _assignments;
  Map<String, dynamic>? get assignmentDetail => _assignmentDetail;

  Future<void> fetchAssignments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _assignmentApi.getAssignments();
      _assignments = result;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchAssignmentDetail(int assignmentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result =
          await _assignmentApi.getAssignmentDetailRaw(assignmentId);

      _assignmentDetail = result;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Submit / resubmit assignment dengan teks dan/atau file
  Future<Map<String, dynamic>> submitAssignment(
    int assignmentId, {
    String? submissionText,
    String? filePath,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _assignmentApi.submitAssignment(
        assignmentId,
        submissionText: submissionText,
        filePath: filePath,
      );

      // Refresh detail setelah submit berhasil
      await fetchAssignmentDetail(assignmentId);

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
