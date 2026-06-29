import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/targets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/common/common.dart';

class FuelDetailScreen extends StatelessWidget {
  const FuelDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final food = context.watch<FoodProvider>();
    final user = context.watch<AuthProvider>().user;
    final t = Targets.forUser(user);

    final p = food.logs.fold<int>(0, (s, m) => s + m.protein);
    final c = food.logs.fold<int>(0, (s, m) => s + m.carbs);
    final f = food.logs.fold<int>(0, (s, m) => s + m.fat);
    final cal = food.logs.fold<int>(0, (s, m) => s + m.calories);

    final rows = [
      ('Protein', p, t.protein, false),
      ('Carbs', c, t.carbs, true),
      ('Fat', f, t.fat, true),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Fuel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionLabel('Today’s macros'),
          const SizedBox(height: 12),
          AppCard(
            padding: CardPadding.lg,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 18),
                    child: _MacroRow(
                      label: rows[i].$1,
                      value: rows[i].$2,
                      target: rows[i].$3,
                      dim: rows[i].$4,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calories',
                    style: AppTextStyles.sans(
                        size: 15, color: AppColors.textSecondary)),
                Text.rich(TextSpan(
                  text: cal.toString(),
                  style: AppTextStyles.sans(size: 17, weight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: ' / ${t.calories}',
                      style: AppTextStyles.sans(
                          size: 13,
                          weight: FontWeight.w500,
                          color: AppColors.textMuted),
                    ),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Tap any macro to see the meals that hit it.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final bool dim;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.target,
    required this.dim,
  });

  @override
  Widget build(BuildContext context) {
    final pct = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.sans(size: 15, weight: FontWeight.w600)),
            Text('$value / ${target}g',
                style: AppTextStyles.sans(
                    size: 13, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 7),
        LayoutBuilder(
          builder: (context, box) => Container(
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: box.maxWidth * pct,
                decoration: BoxDecoration(
                  color: dim ? const Color(0xFFC4C8CF) : AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
