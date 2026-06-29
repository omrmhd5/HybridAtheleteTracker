import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/common/common.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int _week = 26;
  bool _generated = false;

  // (day, name, icon, status) — UI-only; no backend plan endpoint yet.
  static const _plan = [
    ('Mon', 'Push day', Icons.fitness_center, 'done'),
    ('Tue', 'Easy run · 5 km', Icons.directions_run, 'done'),
    ('Wed', 'Pull day', Icons.fitness_center, 'today'),
    ('Thu', 'Rest', Icons.self_improvement, 'planned'),
    ('Fri', 'Leg day', Icons.fitness_center, 'planned'),
    ('Sat', 'Long run · 12 km', Icons.directions_run, 'planned'),
    ('Sun', 'Rest', Icons.self_improvement, 'planned'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My plan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              for (final w in const [26, 27, 28])
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: GestureDetector(
                    onTap: () => setState(() => _week = w),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      decoration: BoxDecoration(
                        color: w == _week
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Week $w',
                        style: AppTextStyles.sans(
                          size: 13,
                          weight: FontWeight.w600,
                          color: w == _week
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          for (final d in _plan) ...[
            _PlanRow(day: d.$1, name: d.$2, icon: d.$3, status: d.$4),
            const SizedBox(height: 9),
          ],
          const SizedBox(height: 5),
          HAButton(
            label: _generated
                ? 'Next week generated ✓'
                : 'Generate next week with AI',
            variant:
                _generated ? HAButtonVariant.secondary : HAButtonVariant.primary,
            fullWidth: true,
            icon: Icons.auto_awesome,
            onPressed:
                _generated ? null : () => setState(() => _generated = true),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final String day;
  final String name;
  final IconData icon;
  final String status;

  const _PlanRow({
    required this.day,
    required this.name,
    required this.icon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = status == 'today';
    final isDone = status == 'done';
    return AppCard(
      accent: isToday ? AppColors.primary : null,
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(day,
                style: AppTextStyles.sans(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.textMuted)),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primaryDim : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon,
                size: 18,
                color:
                    isDone ? AppColors.primary : AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: AppTextStyles.sans(size: 15, weight: FontWeight.w600)),
          ),
          if (isDone)
            const Icon(Icons.check_circle, size: 20, color: AppColors.primary)
          else if (isToday)
            const HABadge('today')
          else
            const HABadge('planned', variant: BadgeVariant.neutral),
        ],
      ),
    );
  }
}
