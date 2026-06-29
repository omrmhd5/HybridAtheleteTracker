import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/cardio_provider.dart';
import '../../widgets/common/common.dart';
import '../home/app_route.dart';
import 'log_cardio_screen.dart';

class CardioScreen extends StatefulWidget {
  const CardioScreen({super.key});

  @override
  State<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends State<CardioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardioProvider>().fetchSessions();
    });
  }

  IconData _icon(String type) => switch (type.toLowerCase()) {
        'run' => Icons.directions_run,
        'cycle' => Icons.directions_bike,
        'swim' => Icons.pool,
        _ => Icons.fitness_center,
      };

  Future<void> _sync() async {
    final provider = context.read<CardioProvider>();
    await provider.fetchSessions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Synced from connected app'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        duration: Duration(milliseconds: 1800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<CardioProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.sessions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _sync,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                children: [
                  const SectionLabel('This week'),
                  const SizedBox(height: 10),
                  if (provider.sessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text('No cardio yet — pull down to sync or log one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    for (final s in provider.sessions) ...[
                      AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primaryDim,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(_icon(s.type),
                                  size: 20, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.type.toUpperCase(),
                                      style: AppTextStyles.sans(
                                          size: 13,
                                          weight: FontWeight.w700,
                                          letterSpacing: 0.5)),
                                  Text(
                                      DateFormat('MMM d, yyyy').format(s.date),
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${s.durationMinutes} min',
                                    style: AppTextStyles.sans(
                                        size: 15, weight: FontWeight.w700)),
                                if (s.distance > 0)
                                  Text('${s.distance.toStringAsFixed(1)} km',
                                      style: AppTextStyles.caption),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                    ],
                ],
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: HAFab(
            icon: Icons.add,
            label: 'Log cardio',
            onPressed: () => context.pushScreen(const LogCardioScreen()),
          ),
        ),
      ],
    );
  }
}
