import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'jwt_token';
  String? _memoryToken; // Fallback if native plugin fails

  Future<void> saveToken(String token) async {
    _memoryToken = token; // Always save to memory first
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('--- STORAGE WARNING --- Failed to save to SharedPreferences, using memory token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) return token;
    } catch (e) {
      print('--- STORAGE WARNING --- Failed to read SharedPreferences, using memory token: $e');
    }
    return _memoryToken;
  }

  Future<void> deleteToken() async {
    _memoryToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('--- STORAGE WARNING --- Failed to delete from SharedPreferences: $e');
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
