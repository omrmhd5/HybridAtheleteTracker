import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/lifting_provider.dart';
import 'providers/food_provider.dart';
import 'providers/cardio_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/tips_provider.dart';
import 'providers/chat_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final apiService = ApiService(storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService, storageService)),
        ChangeNotifierProvider(create: (_) => LiftingProvider(apiService)),
        ChangeNotifierProvider(create: (_) => FoodProvider(apiService)),
        ChangeNotifierProvider(create: (_) => CardioProvider(apiService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(apiService)),
        ChangeNotifierProvider(create: (_) => TipsProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ChatProvider(apiService)),
      ],
      child: const HybridAthleteTrackerApp(),
    ),
  );
}
