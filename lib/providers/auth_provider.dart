import 'package:flutter/foundation.dart';
import '../api/auth_api.dart';
import '../models/user.dart';
import '../models/student.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthApi _authApi;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  Student? _student;
  String? _error;
  bool _rememberMe = false;

  AuthProvider(this._authApi);

  AuthStatus get status => _status;
  User? get user => _user;
  Student? get student => _student;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get rememberMe => _rememberMe;

  Future<void> checkAuth() async {
    _rememberMe = await _authApi.apiClient.isRememberMeActive();
    print("Remember Me active: $_rememberMe");

    final hasToken = await _authApi.apiClient.hasToken();
    print("Has token? $hasToken");

    if (hasToken) {
      await getProfile();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }


  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      _error = null;
      final data = await _authApi.login(email, password);

      // Simpan informasi user dari response login jika tersedia
      if (data is Map<String, dynamic> && data['user'] != null) {
        _user = User.fromJson(data['user'] as Map<String, dynamic>);
      }

      _rememberMe = rememberMe;
      await _authApi.apiClient.saveRememberMe(rememberMe);

      await getProfile();

      _status = AuthStatus.authenticated;
      notifyListeners();
      print("Login successful - Status: $_status, User: ${_user?.email}");
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      print("Login failed - Error: $_error");
      return false;
    }
  }

  Future<void> logout() async {
    await _authApi.apiClient.clearToken();
    _user = null;
    _student = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }


  Future<void> getProfile() async {
    try {
      final data = await _authApi.getProfile();

      _student = Student.fromJson(data);

      // Perbarui data user jika tersedia di response profile
      if (data is Map<String, dynamic> && data['user'] != null) {
        _user = User.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        // Fallback: gunakan field langsung jika ada, atau pertahankan data user sebelumnya
        final updatedId = data['id'] ?? _user?.id;
        final updatedEmail = data['email'] ?? _user?.email;

        if (updatedId != null && updatedEmail != null) {
          _user = User(
            id: updatedId,
            email: updatedEmail,
            role: data['role'] ?? _user?.role ?? 'siswa',
            studentId: data['student_id'] ?? _user?.studentId,
            name: data['name'] ?? _user?.name,
            nisn: data['nisn'] ?? _user?.nisn,
            emailVerifiedAt:
                data['email_verified_at'] ?? _user?.emailVerifiedAt,
          );
        }
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();

      // jika gagal ambil profile, hapus token
      await _authApi.apiClient.clearToken();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      _error = null;
      await _authApi.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return true;
    } catch (e) {
      var message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring('Exception: '.length);
      }
      _error = message;
      return false;
    }
  }
}
