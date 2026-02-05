import 'package:dio/dio.dart';
import '../models/class_info.dart';
import 'api_client.dart';

class ClassroomApi {
  final ApiClient _apiClient;

  ClassroomApi(this._apiClient);

  // GET /classes/current - kelas aktif siswa saat ini
  Future<ClassInfo?> getCurrentClass() async {
    try {
      final response = await _apiClient.dio.get('/classes/current');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return ClassInfo.fromJson(data);
        } else if (data is Map &&
            data.containsKey('class')) {
          return ClassInfo.fromJson(
              data['class'] as Map<String, dynamic>);
        }
        return null;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get current class');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get current class');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // GET /classes/{id} - detail kelas
  Future<ClassInfo?> getClassDetail(int classId) async {
    try {
      final response = await _apiClient.dio.get('/classes/$classId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return ClassInfo.fromJson(data);
        } else if (data is Map &&
            data.containsKey('class')) {
          return ClassInfo.fromJson(
              data['class'] as Map<String, dynamic>);
        }
        return null;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get class detail');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get class detail');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}

