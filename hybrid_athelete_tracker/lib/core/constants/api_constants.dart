import 'dart:io';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/me';
  
  static const String lifting = '/lifting';
  static const String food = '/food';
  static const String cardio = '/cardio';
  static const String bodyweight = '/bodyweight';
  
  static const String dashboardWeekly = '/dashboard/weekly';
  
  static const String tipsWeekly = '/tips/weekly';
  static const String tipsHistory = '/tips/history';
  static const String tipsChat = '/tips/chat';
}
