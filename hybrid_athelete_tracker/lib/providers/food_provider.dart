import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/food_log_model.dart';

class FoodProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<FoodLogModel> _logs = [];
  bool _isLoading = false;
  String? _error;

  FoodProvider(this._apiService);

  List<FoodLogModel> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLogs({DateTime? date}) async {
    try {
      _setLoading(true);
      String url = ApiConstants.food;
      if (date != null) {
        url += '?date=${date.toIso8601String()}';
      }
      final response = await _apiService.client.get(url);
      final List data = response.data['data'];
      _logs = data.map((e) => FoodLogModel.fromJson(e)).toList();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> logMeal(FoodLogModel meal) async {
    try {
      _setLoading(true);
      await _apiService.client.post(
        ApiConstants.food,
        data: meal.toJson(),
      );
      await fetchLogs();
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
