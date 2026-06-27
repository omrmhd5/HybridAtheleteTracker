import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';

class TipsProvider extends ChangeNotifier {
  final ApiService _apiService;

  Map<String, dynamic>? _currentTip;
  List<dynamic> _history = [];
  bool _isLoading = false;
  String? _error;

  TipsProvider(this._apiService);

  Map<String, dynamic>? get currentTip => _currentTip;
  List<dynamic> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeeklyTip() async {
    try {
      print('--- FRONTEND: Fetching AI Weekly Tip ---');
      _setLoading(true);
      final response = await _apiService.client.get(ApiConstants.tipsWeekly);
      _currentTip = response.data['data'];
      print('--- FRONTEND: AI Weekly Tip loaded successfully ---');
    } catch (e) {
      print('--- FRONTEND: AI Weekly Tip Error --- $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchHistory() async {
    try {
      print('--- FRONTEND: Fetching AI Tip History ---');
      _setLoading(true);
      final response = await _apiService.client.get(ApiConstants.tipsHistory);
      _history = response.data['data'];
      print('--- FRONTEND: AI Tip History loaded successfully ---');
    } catch (e) {
      print('--- FRONTEND: AI Tip History Error --- $e');
      _setError(e.toString());
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
