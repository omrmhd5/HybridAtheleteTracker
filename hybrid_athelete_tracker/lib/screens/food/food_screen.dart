import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/auth_provider.dart';
import 'log_food_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().fetchLogs(date: DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s Food')),
      body: Consumer2<FoodProvider, AuthProvider>(
        builder: (context, foodProvider, authProvider, child) {
          if (foodProvider.isLoading && foodProvider.logs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final dailyGoal = authProvider.user?.dailyProteinGoal ?? 150;
          final totalProtein = foodProvider.logs.fold<int>(
            0,
            (sum, log) => sum + log.protein,
          );
          final double progress = (totalProtein / dailyGoal).clamp(0.0, 1.0);

          return Column(
            children: [
              // Macro Progress Bar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Protein Goal', style: AppTextStyles.heading3),
                        Text(
                          '$totalProtein / ${dailyGoal}g',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceLight,
                      color: progress >= 1.0
                          ? AppColors.success
                          : AppColors.primary,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    if (progress >= 1.0)
                      Text(
                        'Goal met! Great job.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                        ),
                      )
                    else
                      Text(
                        'You need ${dailyGoal - totalProtein}g more protein today.',
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ),

              // Meals List
              Expanded(
                child: foodProvider.logs.isEmpty
                    ? const Center(child: Text('No meals logged today.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: foodProvider.logs.length,
                        itemBuilder: (context, index) {
                          final log = foodProvider.logs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                log.mealName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${log.calories} kcal • ${log.carbs}g C • ${log.fat}g F',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${log.protein}g P',
                                  style: const TextStyle(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LogFoodScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
