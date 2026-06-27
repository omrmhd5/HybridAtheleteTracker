import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/weekly_summary_model.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService;

  WeeklySummaryModel? _summary;
  bool _isLoading = false;
  String? _error;

  DashboardProvider(this._apiService);

  WeeklySummaryModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeeklySummary() async {
    try {
      _setLoading(true);
      final response = await _apiService.client.get(ApiConstants.dashboardWeekly);
      _summary = WeeklySummaryModel.fromJson(response.data['data']);
    } catch (e) {
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
