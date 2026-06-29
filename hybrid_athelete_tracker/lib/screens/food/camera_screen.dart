import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/food_log_model.dart';
import '../../providers/food_provider.dart';
import '../../widgets/common/common.dart';
import 'log_food_screen.dart';

enum _Phase { aim, analyzing, result }

/// Camera meal capture. The AI analysis is UI-only (no backend vision
/// endpoint yet); the resulting meal is saved through FoodProvider.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  _Phase _phase = _Phase.aim;
  bool _saving = false;

  // Mock recognition result.
  static const _name = 'Grilled chicken bowl';
  static const _kcal = 520, _carbs = 42, _fat = 14, _protein = 46;

  void _shoot() {
    setState(() => _phase = _Phase.analyzing);
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) setState(() => _phase = _Phase.result);
    });
  }

  Future<void> _add() async {
    setState(() => _saving = true);
    final provider = context.read<FoodProvider>();
    final ok = await provider.logMeal(FoodLogModel(
      id: '',
      date: DateTime.now(),
      mealName: _name,
      calories: _kcal,
      protein: _protein,
      carbs: _carbs,
      fat: _fat,
      proteinGoalMet: false,
    ));
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not save meal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F12),
        foregroundColor: Colors.white,
        title: const Text('Snap a meal',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1D22), Color(0xFF0D0F12)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Viewfinder(analyzing: _phase == _Phase.analyzing),
                  const SizedBox(height: 22),
                  Text(
                    _phase == _Phase.analyzing
                        ? 'Analyzing your plate…'
                        : 'Point at your plate — AI estimates calories & macros',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sans(
                        size: 13, color: Colors.white.withValues(alpha: 0.55)),
                  ),
                ],
              ),
            ),
          ),
          if (_phase == _Phase.result) _resultSheet() else _shutterBar(),
        ],
      ),
    );
  }

  Widget _resultSheet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      size: 22, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name,
                          style: AppTextStyles.sans(
                              size: 16, weight: FontWeight.w700)),
                      Text('$_kcal kcal · ${_carbs}g C · ${_fat}g F',
                          style: AppTextStyles.sans(
                              size: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const HABadge('${_protein}g P'),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: HAButton(
                    label: 'Retake',
                    variant: HAButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => setState(() => _phase = _Phase.aim),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: HAButton(
                    label: 'Add to log',
                    fullWidth: true,
                    loading: _saving,
                    onPressed: _saving ? null : _add,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shutterBar() {
    final analyzing = _phase == _Phase.analyzing;
    return Container(
      color: const Color(0xFF0D0F12),
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 26),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _roundBtn(Icons.photo_library, () {}),
            const SizedBox(width: 34),
            GestureDetector(
              onTap: analyzing ? null : _shoot,
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85), width: 4),
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: analyzing ? AppColors.textMuted : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 34),
            _roundBtn(Icons.keyboard, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LogFoodScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Icon(icon, size: 24, color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  final bool analyzing;
  const _Viewfinder({required this.analyzing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF1C1F24),
            ),
            child: Center(
              child: analyzing
                  ? const SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                          strokeWidth: 4, color: AppColors.primary),
                    )
                  : Icon(Icons.restaurant,
                      size: 48, color: Colors.white.withValues(alpha: 0.18)),
            ),
          ),
          ..._corners(),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    const len = 26.0, thick = 3.0;
    Widget corner(Alignment a) {
      final top = a.y < 0;
      final left = a.x < 0;
      return Align(
        alignment: a,
        child: Container(
          margin: const EdgeInsets.all(14),
          width: len,
          height: len,
          decoration: BoxDecoration(
            border: Border(
              top: top
                  ? const BorderSide(color: AppColors.primary, width: thick)
                  : BorderSide.none,
              bottom: !top
                  ? const BorderSide(color: AppColors.primary, width: thick)
                  : BorderSide.none,
              left: left
                  ? const BorderSide(color: AppColors.primary, width: thick)
                  : BorderSide.none,
              right: !left
                  ? const BorderSide(color: AppColors.primary, width: thick)
                  : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return [
      corner(Alignment.topLeft),
      corner(Alignment.topRight),
      corner(Alignment.bottomLeft),
      corner(Alignment.bottomRight),
    ];
  }
}
