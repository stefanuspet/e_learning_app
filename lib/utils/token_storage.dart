import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';

  // Simpan token ke shared preferences
  Future<void> saveToken(String token) async {
    debugPrint('Saving token to storage: ${_maskToken(token)}');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      debugPrint('Token saved successfully');
    } catch (e) {
      debugPrint('Error saving token: $e');
      throw Exception('Failed to save authentication token');
    }
  }

  // Ambil token dari shared preferences
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      debugPrint('Retrieved token from storage: ${token != null ? _maskToken(token) : 'null'}');
      return token;
    } catch (e) {
      debugPrint('Error retrieving token: $e');
      return null;
    }
  }

  // Hapus token dari shared preferences
  Future<void> deleteToken() async {
    debugPrint('Deleting token from storage');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      debugPrint('Token deleted successfully');
    } catch (e) {
      debugPrint('Error deleting token: $e');
      // Tidak throw exception karena ini biasanya dipanggil saat logout
      // dan kita ingin memastikan proses logout tetap berjalan
    }
  }

  // Cek apakah token ada di storage
  Future<bool> hasToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasKey = prefs.containsKey(_tokenKey);
      debugPrint('Token exists in storage: $hasKey');
      return hasKey;
    } catch (e) {
      debugPrint('Error checking token existence: $e');
      return false;
    }
  }

  // Helper untuk masking token di log untuk keamanan
  String _maskToken(String token) {
    if (token.length > 10) {
      return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
    } else if (token.isNotEmpty) {
      return '${token.substring(0, 2)}...';
    }
    return '';
  }
}