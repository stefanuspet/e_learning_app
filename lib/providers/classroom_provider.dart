import 'package:flutter/foundation.dart';
import '../api/classroom_api.dart';
import '../models/class_info.dart';

class ClassroomProvider with ChangeNotifier {
  final ClassroomApi _classroomApi;

  bool _isLoading = false;
  String? _error;
  ClassInfo? _currentClass;
  ClassInfo? _classDetail;

  ClassroomProvider(this._classroomApi);

  bool get isLoading => _isLoading;
  String? get error => _error;
  ClassInfo? get currentClass => _currentClass;
  ClassInfo? get classDetail => _classDetail;

  Future<void> fetchCurrentClass() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentClass = await _classroomApi.getCurrentClass();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchClassDetail(int classId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _classDetail = await _classroomApi.getClassDetail(classId);

      _isLoading = false;
      notifyListeners();
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

