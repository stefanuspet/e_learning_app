import 'package:flutter/foundation.dart';
import '../api/quiz_api.dart';

class QuizProvider with ChangeNotifier {
  final QuizApi _quizApi;

  bool _isLoading = false;
  String? _error;
  List<dynamic> _quizzes = [];
  Map<String, dynamic>? _quizDetail;

  QuizProvider(this._quizApi);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get quizzes => _quizzes;
  Map<String, dynamic>? get quizDetail => _quizDetail;

  Future<void> fetchQuizzes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _quizzes = await _quizApi.getQuizzes();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchQuizDetail(int quizId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _quizDetail = await _quizApi.getQuizDetail(quizId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitQuiz(
      int quizId, Map<String, dynamic> payload) async {
    try {
      final result = await _quizApi.submitQuiz(quizId, payload);
      return result;
    } catch (e) {
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

