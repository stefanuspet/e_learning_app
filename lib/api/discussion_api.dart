import 'package:dio/dio.dart';
import 'api_client.dart';

class DiscussionApi {
  final ApiClient _apiClient;

  DiscussionApi(this._apiClient);

  // GET /subjects/{subject}/detail
  Future<Map<String, dynamic>> getSubjectDetail(int subjectId) async {
    try {
      final response =
          await _apiClient.dio.get('/subjects/$subjectId/detail');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(response.data['message'] ??
            'Failed to get subject detail');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get subject detail');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // GET /subjects/{subject}/discussions
  Future<List<dynamic>> getDiscussions(int subjectId) async {
    try {
      final response =
          await _apiClient.dio.get('/subjects/$subjectId/discussions');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map && data.containsKey('threads')) {
          return data['threads'] as List<dynamic>;
        } else if (data is List) {
          return data;
        }
        return <dynamic>[];
      } else {
        throw Exception(response.data['message'] ??
            'Failed to get discussions');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get discussions');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // POST /subjects/{subject}/discussions
  Future<Map<String, dynamic>> createDiscussion(
      int subjectId, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(
        '/subjects/$subjectId/discussions',
        data: payload,
      );

      if (response.statusCode == 201 ||
          (response.statusCode == 200 &&
              response.data['success'] == true)) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(response.data['message'] ??
            'Failed to create discussion');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to create discussion');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // GET /subjects/{subject}/discussions/{thread}
  Future<Map<String, dynamic>> getDiscussionThread(
      int subjectId, int threadId) async {
    try {
      final response = await _apiClient.dio
          .get('/subjects/$subjectId/discussions/$threadId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(response.data['message'] ??
            'Failed to get discussion thread');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get discussion thread');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // POST /subjects/{subject}/discussions/{thread}/reply
  Future<Map<String, dynamic>> replyDiscussion(
      int subjectId, int threadId, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(
        '/subjects/$subjectId/discussions/$threadId/reply',
        data: payload,
      );

      if (response.statusCode == 201 ||
          (response.statusCode == 200 &&
              response.data['success'] == true)) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(response.data['message'] ??
            'Failed to reply discussion');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to reply discussion');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}
