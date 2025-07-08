import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient _apiClient;

  // Constructor
  AuthApi(this._apiClient);

  // Getter untuk mengakses apiClient dari luar
  ApiClient get apiClient => _apiClient;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_name': 'flutter_app',
        },
      );

      if (response.statusCode == 200 && response.data['success']) {
        // Simpan token
        await _apiClient.saveToken(response.data['token']);
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } finally {
      // Clear token even if request fails
      await _apiClient.clearToken();
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/profile');

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get profile');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    }
  }
}