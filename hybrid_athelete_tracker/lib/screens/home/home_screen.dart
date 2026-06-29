import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/tips_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../lifting/lifting_screen.dart';
import '../food/food_screen.dart';
import '../cardio/cardio_screen.dart';
import '../tips/tips_screen.dart';
import '../plan/plan_screen.dart';
import '../profile/profile_screen.dart';
import 'app_route.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = [
    'This week',
    'Lifting',
    'Today’s food',
    'Cardio',
    'AI coach',
  ];

  static const _tabs = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Week'),
    (Icons.fitness_center_outlined, Icons.fitness_center, 'Lift'),
    (Icons.restaurant_outlined, Icons.restaurant, 'Food'),
    (Icons.directions_run_outlined, Icons.directions_run, 'Cardio'),
    (Icons.lightbulb_outline, Icons.lightbulb, 'Tips'),
  ];

  void _goTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(onGoToTab: _goTab),
          const LiftingScreen(),
          const FoodScreen(),
          const CardioScreen(),
          const TipsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_titles[_index]),
      leading: _index == 0
          ? IconButton(
              icon: const Icon(Icons.event),
              color: AppColors.textPrimary,
              onPressed: () => context.pushScreen(const PlanScreen()),
            )
          : null,
      actions: [
        if (_index == 4)
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: () => context.read<TipsProvider>().fetchWeeklyTip(),
          )
        else
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textMuted),
            onPressed: () => context.pushScreen(const ProfileScreen()),
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final t = _tabs[i];
              final active = i == _index;
              return Expanded(
                child: InkWell(
                  onTap: () => _goTab(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? t.$2 : t.$1,
                        size: 24,
                        color:
                            active ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.$3,
                        style: AppTextStyles.sans(
                          size: 11,
                          weight: active ? FontWeight.w600 : FontWeight.w500,
                          color:
                              active ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
