import 'package:dio/dio.dart';
import 'api_client.dart';

class MaterialApi {
  final ApiClient _apiClient;

  MaterialApi(this._apiClient);

  // GET /materials - daftar materi (raw)
  Future<List<dynamic>> getMaterials() async {
    try {
      final response = await _apiClient.dio.get('/materials');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('materials')) {
          return data['materials'] as List<dynamic>;
        }
        return <dynamic>[];
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get materials');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Failed to get materials');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // GET /materials/{material} - detail materi
  Future<Map<String, dynamic>> getMaterialDetail(int materialId) async {
    try {
      final response =
          await _apiClient.dio.get('/materials/$materialId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(response.data['message'] ??
            'Failed to get material detail');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get material detail');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}

