import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/targets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/common/common.dart';
import '../home/app_route.dart';
import 'camera_screen.dart';
import 'log_food_screen.dart';

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

  void _snap() => context.pushScreen(const CameraScreen());
  void _manual() => context.pushScreen(const LogFoodScreen());

  @override
  Widget build(BuildContext context) {
    return Consumer2<FoodProvider, AuthProvider>(
      builder: (context, food, auth, _) {
        if (food.isLoading && food.logs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final t = Targets.forUser(auth.user);
        final cal = food.logs.fold<int>(0, (s, m) => s + m.calories);
        final p = food.logs.fold<int>(0, (s, m) => s + m.protein);
        final c = food.logs.fold<int>(0, (s, m) => s + m.carbs);
        final f = food.logs.fold<int>(0, (s, m) => s + m.fat);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // calorie-led header
            AppCard(
              padding: CardPadding.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('Calories',
                          style: AppTextStyles.sans(
                              size: 17, weight: FontWeight.w700)),
                      Text.rich(TextSpan(
                        style: AppTextStyles.sans(
                            size: 15, color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: cal.toString(),
                            style: AppTextStyles.sans(
                                size: 15, weight: FontWeight.w700),
                          ),
                          TextSpan(text: ' / ${t.calories}'),
                        ],
                      )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  HAProgressBar.lg(value: cal.toDouble(), max: t.calories.toDouble()),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: MacroBar(
                              label: 'Protein', value: p, target: t.protein)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: MacroBar(
                              label: 'Carbs',
                              value: c,
                              target: t.carbs,
                              dim: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: MacroBar(
                              label: 'Fat', value: f, target: t.fat, dim: true)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // capture actions
            Row(
              children: [
                Expanded(
                  child: HAButton(
                    label: 'Snap a meal',
                    icon: Icons.photo_camera,
                    fullWidth: true,
                    onPressed: _snap,
                  ),
                ),
                const SizedBox(width: 10),
                HAButton(
                  variant: HAButtonVariant.ghost,
                  icon: Icons.add,
                  onPressed: _manual,
                ),
              ],
            ),
            const SizedBox(height: 14),

            SectionLabel('Meals · ${food.logs.length} logged'),
            const SizedBox(height: 10),
            if (food.logs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text('No meals logged today.',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              for (final m in food.logs) ...[
                AppCard(
                  interactive: true,
                  onTap: () {},
                  child: ListRow(
                    icon: Icons.restaurant,
                    iconBg: AppColors.surfaceLight,
                    iconColor: AppColors.textSecondary,
                    title: m.mealName,
                    subtitle: '${m.calories} kcal · ${m.carbs}g C · ${m.fat}g F',
                    trailing: HABadge('${m.protein}g P'),
                  ),
                ),
                const SizedBox(height: 9),
              ],
          ],
        );
      },
    );
  }
}
