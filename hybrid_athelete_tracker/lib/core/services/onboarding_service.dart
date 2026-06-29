import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has seen the onboarding flow.
/// The cached value is loaded once at startup so the router can read it
/// synchronously inside its redirect.
class OnboardingService {
  static const _key = 'onboarding_complete';
  static bool _complete = false;

  static bool get isComplete => _complete;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _complete = prefs.getBool(_key) ?? false;
  }

  static Future<void> markComplete() async {
    _complete = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Test/dev helper to replay onboarding.
  static Future<void> reset() async {
    _complete = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
