import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchWeeklySummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Overview')),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final summary = provider.summary;
          if (summary == null) {
            return const Center(child: Text('No data available.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchWeeklySummary(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(
                  title: 'Lifting',
                  icon: Icons.fitness_center,
                  iconColor: AppColors.primaryLight,
                  stats: [
                    '${summary.liftingSessionsCount} sessions',
                    '${summary.totalVolume} total volume',
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  title: 'Cardio',
                  icon: Icons.directions_run,
                  iconColor: AppColors.secondary,
                  stats: [
                    '${summary.cardioSessionsCount} sessions',
                    '${summary.totalCardioMinutes} min total',
                    '${summary.totalCardioDistance} dist total',
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  title: 'Food & Macros',
                  icon: Icons.restaurant,
                  iconColor: AppColors.success,
                  stats: [
                    '${summary.foodLogsCount} meals logged',
                    '${summary.daysGoalMet} days goal met',
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required IconData icon, required Color iconColor, required List<String> stats}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Text(title, style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            ...stats.map((stat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(stat, style: AppTextStyles.bodyLarge),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
