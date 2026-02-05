import 'package:flutter/foundation.dart';
import '../api/extracurricular_api.dart';

class ExtracurricularProvider with ChangeNotifier {
  final ExtracurricularApi _extracurricularApi;

  bool _isLoading = false;
  String? _error;
  List<dynamic> _extracurriculars = [];
  Map<String, dynamic>? _detail;

  ExtracurricularProvider(this._extracurricularApi);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get extracurriculars => _extracurriculars;
  Map<String, dynamic>? get detail => _detail;

  Future<void> fetchExtracurriculars() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _extracurriculars =
          await _extracurricularApi.getExtracurriculars();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchDetail(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _detail =
          await _extracurricularApi.getExtracurricularDetail(id);

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

