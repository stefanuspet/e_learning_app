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

      _user = User(
        id: data['id'], // <- GANTI disini
        email: data['email'],
        role: 'siswa',
      );

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
}
