import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/lifting_session_model.dart';

class LiftingProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<LiftingSessionModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  LiftingProvider(this._apiService);

  List<LiftingSessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSessions() async {
    try {
      _setLoading(true);
      final response = await _apiService.client.get(ApiConstants.lifting);
      final List data = response.data['data'];
      _sessions = data.map((e) => LiftingSessionModel.fromJson(e)).toList();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> logSession(LiftingSessionModel session) async {
    try {
      _setLoading(true);
      await _apiService.client.post(
        ApiConstants.lifting,
        data: session.toJson(),
      );
      await fetchSessions();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
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
