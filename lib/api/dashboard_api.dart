import 'package:dio/dio.dart';
import 'api_client.dart';

class DashboardApi {
  final ApiClient _apiClient;

  DashboardApi(this._apiClient);

  // Get dashboard data - this will get all data in one call
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/dashboard');

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get dashboard data');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get dashboard data');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get subjects list - as a fallback if the dashboard API doesn't include subjects
  Future<List<dynamic>> getSubjects() async {
    try {
      final response = await _apiClient.dio.get('/subjects');

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get subjects');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get subjects');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get upcoming assignments - with optional limit parameter
  Future<List<dynamic>> getUpcomingAssignments([int limit = 5]) async {
    try {
      final response = await _apiClient.dio.get('/assignments/upcoming',
          queryParameters: {'limit': limit});

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get upcoming assignments');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get upcoming assignments');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get recent materials - with optional limit parameter
  Future<List<dynamic>> getRecentMaterials([int limit = 5]) async {
    try {
      final response = await _apiClient.dio.get('/materials/recent',
          queryParameters: {'limit': limit});

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get recent materials');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get recent materials');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}