import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/targets.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          if (user == null) {
            return const Center(child: Text('Loading profile…'));
          }
          final t = Targets.forUser(user);
          final goals = [
            ('Protein', '${t.protein}g'),
            ('Daily calories', t.calories.toString()),
            ('Cardio / week', '3×'),
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  InitialsAvatar(text: initialsOf(user.name), size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: AppTextStyles.sans(
                                size: 18, weight: FontWeight.w700)),
                        Text('@${user.username}',
                            style: AppTextStyles.sans(
                                size: 13, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Goals'),
                    const SizedBox(height: 10),
                    for (var i = 0; i < goals.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: i < goals.length - 1
                                  ? AppColors.surfaceBorder
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(goals[i].$1,
                                style: AppTextStyles.sans(
                                    size: 15, color: AppColors.textSecondary)),
                            HABadge(goals[i].$2),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _settingRow(Icons.monitor_weight, 'Body stats'),
              _settingRow(Icons.straighten, 'Units & display',
                  trailingText: user.unitPreference.toUpperCase()),
              _settingRow(Icons.link, 'Connected apps'),
              _settingRow(Icons.notifications, 'Reminders'),
              _settingRow(
                Icons.logout,
                'Sign out',
                onTap: () async {
                  await auth.logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _settingRow(IconData icon, String label,
      {String? trailingText, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: AppCard(
        interactive: true,
        onTap: onTap ?? () {},
        child: ListRow(
          icon: icon,
          iconBg: AppColors.surfaceLight,
          iconColor: AppColors.textSecondary,
          title: label,
          trailing: trailingText != null
              ? Text(trailingText,
                  style: AppTextStyles.sans(
                      size: 13, color: AppColors.textMuted))
              : const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
