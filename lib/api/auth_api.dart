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

  // Update profil user
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.dio.put(
        '/auth/profile',
        data: profileData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] ?? <String, dynamic>{};
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Failed to update profile');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Ganti password user
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          // Backend expects `new_password` + `new_password_confirmation`
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      if (!(response.statusCode == 200 &&
          response.data['success'] == true)) {
        String message =
            response.data['message']?.toString() ?? 'Failed to change password';

        // Jika ada detail error validasi, ambil pesan pertama
        final errors = response.data['errors'];
        if (errors is Map) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              final first = value.first;
              if (first is String && first.isNotEmpty) {
                message = first;
                break;
              }
            }
          }
        }

        throw Exception(message);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        String message =
            (data is Map && data['message'] != null)
                ? data['message'].toString()
                : 'Failed to change password';

        // Coba ambil pesan validasi yang lebih spesifik
        if (data is Map && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              final first = value.first;
              if (first is String && first.isNotEmpty) {
                message = first;
                break;
              }
            }
          }
        }

        throw Exception(message);
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
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
