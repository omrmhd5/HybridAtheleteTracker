import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  String? _memoryToken; // Fallback if native plugin fails
  String? _memoryRefreshToken;

  Future<void> saveToken(String token) async {
    _memoryToken = token; // Always save to memory first
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      debugPrint('--- STORAGE WARNING --- Failed to save to SharedPreferences, using memory token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) return token;
    } catch (e) {
      debugPrint('--- STORAGE WARNING --- Failed to read SharedPreferences, using memory token: $e');
    }
    return _memoryToken;
  }

  Future<void> deleteToken() async {
    _memoryToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      debugPrint('--- STORAGE WARNING --- Failed to delete from SharedPreferences: $e');
    }
  }

  Future<void> saveRefreshToken(String token) async {
    _memoryRefreshToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, token);
    } catch (e) {
      debugPrint('--- STORAGE WARNING --- Failed to save refresh token, using memory: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_refreshTokenKey);
      if (token != null) return token;
    } catch (e) {
      debugPrint('--- STORAGE WARNING --- Failed to read refresh token, using memory: $e');
    }
    return _memoryRefreshToken;
  }

  Future<void> deleteRefreshToken() async {
    _memoryRefreshToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_refreshTokenKey);
    } catch (e) {
      debugPrint('--- STORAGE WARNING --- Failed to delete refresh token: $e');
    }
  }

  /// Clears both access and refresh tokens (full sign-out).
  Future<void> clearTokens() async {
    await deleteToken();
    await deleteRefreshToken();
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
