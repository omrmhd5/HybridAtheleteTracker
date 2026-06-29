import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/targets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/tips_provider.dart';
import '../../widgets/common/common.dart';
import '../food/fuel_detail_screen.dart';
import '../plan/plan_screen.dart';
import '../home/app_route.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int> onGoToTab;
  const DashboardScreen({super.key, required this.onGoToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchWeeklySummary();
      context.read<FoodProvider>().fetchLogs(date: DateTime.now());
      context.read<TipsProvider>().fetchWeeklyTip();
    });
  }

  /// Blends weekly activity into a single 0–100 balance score.
  int _balance(DashboardProvider d) {
    final s = d.summary;
    if (s == null) return 82;
    final lift = (s.liftingSessionsCount * 8).clamp(0, 34);
    final cardio = (s.cardioSessionsCount * 8).clamp(0, 33);
    final fuel = (s.daysGoalMet * 5).clamp(0, 33);
    final score = lift + cardio + fuel;
    return score == 0 ? 82 : score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final food = context.watch<FoodProvider>();
    final tips = context.watch<TipsProvider>();
    final user = context.watch<AuthProvider>().user;
    final t = Targets.forUser(user);

    final p = food.logs.fold<int>(0, (s, m) => s + m.protein);
    final c = food.logs.fold<int>(0, (s, m) => s + m.carbs);
    final f = food.logs.fold<int>(0, (s, m) => s + m.fat);
    final balance = _balance(dash);

    final summary = dash.summary;
    final liftSub = summary == null
        ? 'Tap to view sessions'
        : '${summary.liftingSessionsCount} sessions · ${summary.totalVolume.toStringAsFixed(0)} kg volume';
    final cardioSub = summary == null
        ? 'Tap to view sessions'
        : '${summary.cardioSessionsCount} sessions · ${summary.totalCardioMinutes} min · ${summary.totalCardioDistance.toStringAsFixed(1)} km';

    final tipBody = tips.currentTip?['tipText'] as String? ??
        'Protein lagged your lifting on 2 days — worth watching for recovery.';

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final dashProvider = context.read<DashboardProvider>();
        final foodProvider = context.read<FoodProvider>();
        await dashProvider.fetchWeeklySummary();
        await foodProvider.fetchLogs(date: DateTime.now());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // balance hero
          AppCard(
            padding: CardPadding.lg,
            child: Row(
              children: [
                ProgressRing(
                  size: 82,
                  stroke: 9,
                  pct: balance / 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$balance',
                          style: AppTextStyles.sans(
                              size: 24, weight: FontWeight.w700, height: 1)),
                      Text('balance', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lift · Cardio · Fuel',
                          style: AppTextStyles.sans(
                              size: 17, weight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(
                        'One score for how the three line up this week.',
                        style: AppTextStyles.sans(
                            size: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // AI nudge
          TipCard(
            title: 'AI Coach',
            body: tipBody,
            footer: 'Tap Tips for the full picture',
          ),
          const SizedBox(height: 12),

          // categories
          AppCard(
            interactive: true,
            onTap: () => widget.onGoToTab(1),
            child: ListRow(
              icon: Icons.fitness_center,
              title: 'Lifting',
              subtitle: liftSub,
              trailing: const Icon(Icons.trending_up,
                  size: 20, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            interactive: true,
            onTap: () => widget.onGoToTab(3),
            child: ListRow(
              icon: Icons.directions_run,
              title: 'Cardio',
              subtitle: cardioSub,
              trailing: const Icon(Icons.trending_up,
                  size: 20, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),

          // Fuel — multi-macro
          AppCard(
            interactive: true,
            onTap: () => context.pushScreen(const FuelDetailScreen()),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDim,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restaurant,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fuel',
                              style: AppTextStyles.sans(
                                  size: 15, weight: FontWeight.w600)),
                          Text('${p}g P · ${c}g C · ${f}g F',
                              style: AppTextStyles.sans(
                                  size: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 20, color: AppColors.textMuted),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: MacroBar(
                            label: 'Protein', value: p, target: t.protein)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: MacroBar(
                            label: 'Carbs', value: c, target: t.carbs, dim: true)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: MacroBar(
                            label: 'Fat', value: f, target: t.fat, dim: true)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // plan teaser
          AppCard(
            interactive: true,
            onTap: () => context.pushScreen(const PlanScreen()),
            child: ListRow(
              icon: Icons.event,
              iconBg: AppColors.surfaceLight,
              iconColor: AppColors.textSecondary,
              title: 'Today’s plan',
              subtitle: 'Push day · then easy run',
              trailing: const HABadge('View plan'),
            ),
          ),
        ],
      ),
    );
  }
}
