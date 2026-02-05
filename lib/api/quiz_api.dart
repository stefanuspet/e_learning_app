import 'package:dio/dio.dart';
import 'api_client.dart';

class QuizApi {
  final ApiClient _apiClient;

  QuizApi(this._apiClient);

  // GET /quizzes - daftar kuis
  Future<List<dynamic>> getQuizzes() async {
    try {
      final response = await _apiClient.dio.get('/quizzes');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('quizzes')) {
          return data['quizzes'] as List<dynamic>;
        }
        return <dynamic>[];
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get quizzes');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Failed to get quizzes');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // GET /quizzes/{quiz} - detail kuis
  Future<Map<String, dynamic>> getQuizDetail(int quizId) async {
    try {
      final response = await _apiClient.dio.get('/quizzes/$quizId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get quiz detail');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get quiz detail');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // POST /quizzes/{quiz}/submit - submit jawaban kuis
  Future<Map<String, dynamic>> submitQuiz(
      int quizId, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(
        '/quizzes/$quizId/submit',
        data: payload,
      );

      // Backend mengembalikan 201 pada sukses submit
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to submit quiz');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Failed to submit quiz');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
