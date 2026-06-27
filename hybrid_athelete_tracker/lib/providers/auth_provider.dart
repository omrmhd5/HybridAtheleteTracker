import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService, this._storageService) {
    checkAuthStatus();
  }

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkAuthStatus() async {
    if (await _storageService.hasToken()) {
      await fetchProfile();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      final response = await _apiService.client.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      
      final token = response.data['data']['token'];
      await _storageService.saveToken(token);
      
      await fetchProfile();
      if (_user == null) {
        return false;
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      final response = await _apiService.client.post(
        ApiConstants.register,
        data: data,
      );
      
      final token = response.data['data']['token'];
      await _storageService.saveToken(token);
      
      await fetchProfile();
      if (_user == null) {
        return false;
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _apiService.client.get(ApiConstants.profile);
      _user = UserModel.fromJson(response.data['data']);
      notifyListeners();
    } catch (e) {
      _user = null;
      await _storageService.deleteToken();
      notifyListeners();
      _setError('Failed to fetch profile. Please log in again.');
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
}
