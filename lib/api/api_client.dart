import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Callback global yang dipanggil ketika server merespon 401 (unauthorized)
  final void Function()? _onUnauthorized;

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  ApiClient({void Function()? onUnauthorized})
      : _onUnauthorized = onUnauthorized {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Jika status 401 (session habis / unauthorized) dan bukan request login,
          // hapus token dan panggil callback global untuk mengarahkan ke halaman login.
          if (error.response?.statusCode == 401 &&
              error.requestOptions.path != '/auth/login') {
            await clearToken();
            _onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> init() async {
    final token = await _storage.read(key: 'auth_token');
    print("ApiClient.init() token = $token");
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }


  Dio get dio => _dio;

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print("Token saved: $token");
  }

  Future<void> clearToken() async {
    final rememberMe = await isRememberMeActive();
    if (!rememberMe) {
      await _storage.delete(key: 'auth_token');
    }
    _dio.options.headers.remove('Authorization');
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<void> saveRememberMe(bool remember) async {
    await _storage.write(key: 'remember_me', value: remember.toString());
  }

  Future<bool> isRememberMeActive() async {
    final remember = await _storage.read(key: 'remember_me');
    return remember == 'true';
  }
}
