import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/onboarding_service.dart';
import '../../widgets/common/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  // form state
  int _weight = 78;
  int _height = 180;
  int _age = 27;
  String _sex = 'male';
  String _units = 'metric';
  String _mix = 'hybrid';
  int _days = 5;
  String _exp = 'some';
  String _goal = 'muscle';
  int _cardio = 3;
  bool _reminders = true;

  int get _protein => (_weight * 1.9).round();
  int get _calories =>
      (_weight * 31 + (_goal == 'muscle' ? 250 : _goal == 'lean' ? -250 : 0))
          .round();
  bool get _metric => _units == 'metric';

  void _next() => setState(() => _step++);
  void _back() => setState(() => _step = (_step - 1).clamp(0, 4));

  Future<void> _toRegister() async {
    await OnboardingService.markComplete();
    if (!mounted) return;
    context.go('/register', extra: {
      'dailyProteinGoal': _protein,
      'unitPreference': _metric ? 'kg' : 'lb',
    });
  }

  Future<void> _toLogin() async {
    await OnboardingService.markComplete();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: switch (_step) {
          0 => _welcome(),
          1 => _aboutYou(),
          2 => _howYouTrain(),
          3 => _goals(),
          _ => _finish(),
        },
      ),
    );
  }

  // ── Welcome ──
  Widget _welcome() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 40, 26, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.shadowPrimary,
            ),
            child: const Icon(Icons.fitness_center, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 34),
          Text('One app for lifting,\ncardio & fuel.',
              style: AppTextStyles.sans(
                  size: 30, weight: FontWeight.w700, letterSpacing: -0.6)),
          const SizedBox(height: 10),
          Text(
            'AI that connects the dots between how you train and how you eat. Let’s set up your targets.',
            style: AppTextStyles.sans(
                size: 15, color: AppColors.textSecondary, height: 1.5),
          ),
          const Spacer(),
          HAButton(
            label: 'Create account',
            fullWidth: true,
            onPressed: _next,
          ),
          const SizedBox(height: 11),
          HAButton(
            label: 'I already have an account',
            variant: HAButtonVariant.ghost,
            fullWidth: true,
            onPressed: _toLogin,
          ),
        ],
      ),
    );
  }

  // ── Step scaffold ──
  Widget _stepShell({
    required int idx,
    required String title,
    required String sub,
    required List<Widget> children,
    required String cta,
    required VoidCallback onCta,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Row(
            children: [
              IconButton(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back,
                    size: 22, color: AppColors.textPrimary),
              ),
              Expanded(child: _Dots(active: idx, total: 4)),
              const SizedBox(width: 38),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.sans(size: 26, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(sub,
                    style: AppTextStyles.sans(
                        size: 13, color: AppColors.textMuted, height: 1.5)),
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 14, 26, 26),
          child: HAButton(label: cta, fullWidth: true, onPressed: onCta),
        ),
      ],
    );
  }

  Widget _fieldLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SectionLabel(t),
      );

  // ── Step 1 ──
  Widget _aboutYou() {
    return _stepShell(
      idx: 0,
      title: 'About you',
      sub: 'Sets your calorie & protein targets.',
      cta: 'Continue',
      onCta: _next,
      children: [
        StatField(
          label: 'Weight',
          value: _weight,
          unit: _metric ? 'kg' : 'lb',
          onChanged: (v) => setState(() => _weight = v.clamp(35, 400)),
        ),
        const SizedBox(height: 18),
        StatField(
          label: 'Height',
          value: _height,
          unit: _metric ? 'cm' : 'in',
          onChanged: (v) => setState(() => _height = v.clamp(120, 250)),
        ),
        const SizedBox(height: 18),
        StatField(
          label: 'Age',
          value: _age,
          unit: 'yr',
          onChanged: (v) => setState(() => _age = v.clamp(13, 100)),
        ),
        const SizedBox(height: 18),
        _fieldLabel('Sex'),
        SegmentedControl<String>(
          value: _sex,
          onChanged: (v) => setState(() => _sex = v),
          options: const [
            SegmentOption(value: 'male', label: 'Male'),
            SegmentOption(value: 'female', label: 'Female'),
          ],
        ),
        const SizedBox(height: 18),
        _fieldLabel('Units'),
        SegmentedControl<String>(
          value: _units,
          onChanged: (v) => setState(() => _units = v),
          options: const [
            SegmentOption(value: 'metric', label: 'kg / cm'),
            SegmentOption(value: 'imperial', label: 'lb / ft'),
          ],
        ),
      ],
    );
  }

  // ── Step 2 ──
  Widget _howYouTrain() {
    return _stepShell(
      idx: 1,
      title: 'How you train',
      sub: 'So we balance lifting and cardio for you.',
      cta: 'Continue',
      onCta: _next,
      children: [
        _fieldLabel('Your mix'),
        SegmentedControl<String>(
          value: _mix,
          onChanged: (v) => setState(() => _mix = v),
          options: const [
            SegmentOption(value: 'lift', label: 'Lift', icon: Icons.fitness_center),
            SegmentOption(
                value: 'cardio', label: 'Cardio', icon: Icons.directions_run),
            SegmentOption(value: 'hybrid', label: 'Hybrid', icon: Icons.sync),
          ],
        ),
        const SizedBox(height: 18),
        _fieldLabel('Days per week'),
        StepperField(
          value: _days,
          onChanged: (v) => setState(() => _days = v),
          min: 1,
          max: 7,
          suffix: ' days',
        ),
        const SizedBox(height: 18),
        _fieldLabel('Experience'),
        SegmentedControl<String>(
          value: _exp,
          onChanged: (v) => setState(() => _exp = v),
          options: const [
            SegmentOption(value: 'new', label: 'New'),
            SegmentOption(value: 'some', label: 'Some'),
            SegmentOption(value: 'adv', label: 'Advanced'),
          ],
        ),
      ],
    );
  }

  // ── Step 3 ──
  Widget _goals() {
    const goals = [
      ('muscle', 'Build muscle', Icons.fitness_center),
      ('endurance', 'Endurance', Icons.directions_run),
      ('lean', 'Stay lean', Icons.monitor_weight),
      ('general', 'General health', Icons.favorite),
    ];
    return _stepShell(
      idx: 2,
      title: 'Your goals',
      sub: 'We’ll suggest targets — adjust anytime.',
      cta: 'Continue',
      onCta: _next,
      children: [
        _fieldLabel('Primary goal'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 9,
          crossAxisSpacing: 9,
          childAspectRatio: 2.6,
          children: goals.map((g) {
            final on = _goal == g.$1;
            return GestureDetector(
              onTap: () => setState(() => _goal = g.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                decoration: BoxDecoration(
                  color: on ? AppColors.primaryDim : AppColors.surface,
                  border: Border.all(
                    color: on ? AppColors.primary : AppColors.surfaceBorder,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(g.$3,
                        size: 19,
                        color: on ? AppColors.primary : AppColors.textMuted),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        g.$2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sans(
                          size: 13,
                          weight: FontWeight.w600,
                          color:
                              on ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Protein / day',
                      style: AppTextStyles.sans(
                          size: 15,
                          weight: FontWeight.w500,
                          color: AppColors.textSecondary)),
                  Text.rich(TextSpan(
                    text: '$_protein',
                    style: AppTextStyles.sans(size: 19, weight: FontWeight.w700),
                    children: [
                      TextSpan(
                        text: 'g',
                        style: AppTextStyles.sans(
                            size: 13, color: AppColors.textMuted),
                      ),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 4),
              Text('Suggested from your weight — 1.9 g/kg',
                  style: AppTextStyles.caption),
            ],
          ),
        ),
        const SizedBox(height: 18),
        StatField(
          label: 'Cardio / week',
          value: _cardio,
          unit: '×',
          onChanged: (v) => setState(() => _cardio = v.clamp(0, 14)),
        ),
      ],
    );
  }

  // ── Step 4 ──
  Widget _finish() {
    final rows = [
      ('Protein target', '${_protein}g'),
      ('Daily calories', _calories.toString()),
      (
        'Training',
        '${_mix == 'hybrid' ? 'Hybrid' : _mix == 'lift' ? 'Lifting' : 'Cardio'} · $_days×'
      ),
      ('Cardio / week', '$_cardio×'),
    ];
    return _stepShell(
      idx: 3,
      title: 'You’re set',
      sub: 'Here’s where you’ll start — change it anytime in your profile.',
      cta: 'Start tracking',
      onCta: _toRegister,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i < rows.length - 1
                            ? AppColors.surfaceBorder
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rows[i].$1,
                          style: AppTextStyles.sans(
                              size: 15, color: AppColors.textSecondary)),
                      HABadge(rows[i].$2),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _connectRow(
          icon: Icons.link,
          title: 'Connect an app',
          sub: 'Sync cardio from Strava, Health…',
          trailing: const Icon(Icons.chevron_right,
              size: 20, color: AppColors.textMuted),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _connectRow(
          title: 'Daily reminders',
          trailing: HAToggle(
            value: _reminders,
            onChanged: (v) => setState(() => _reminders = v),
          ),
        ),
      ],
    );
  }

  Widget _connectRow({
    IconData? icon,
    required String title,
    String? sub,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          AppTextStyles.sans(size: 15, weight: FontWeight.w600)),
                  if (sub != null)
                    Text(sub, style: AppTextStyles.caption),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int active;
  final int total;
  const _Dots({required this.active, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final on = i <= active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: on ? AppColors.primary : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
