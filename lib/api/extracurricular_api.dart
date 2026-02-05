import 'package:dio/dio.dart';
import 'api_client.dart';

class ExtracurricularApi {
  final ApiClient _apiClient;

  ExtracurricularApi(this._apiClient);

  // GET /extracurriculars - daftar ekstrakurikuler
  Future<List<dynamic>> getExtracurriculars() async {
    try {
      final response = await _apiClient.dio.get('/extracurriculars');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        } else if (data is Map &&
            data.containsKey('extracurriculars')) {
          return data['extracurriculars'] as List<dynamic>;
        }
        return <dynamic>[];
      } else {
        throw Exception(response.data['message'] ??
            'Failed to get extracurriculars');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get extracurriculars');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // GET /extracurriculars/{extracurricular} - detail ekstrakurikuler
  Future<Map<String, dynamic>> getExtracurricularDetail(
      int extracurricularId) async {
    try {
      final response = await _apiClient.dio
          .get('/extracurriculars/$extracurricularId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(response.data['message'] ??
            'Failed to get extracurricular detail');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get extracurricular detail');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}

