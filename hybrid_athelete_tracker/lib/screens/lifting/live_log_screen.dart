import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/lifting_session_model.dart';
import '../../providers/lifting_provider.dart';
import '../../widgets/common/common.dart';

class _PlannedExercise {
  final String name;
  final double kg;
  final int reps;
  final int total;
  const _PlannedExercise(this.name, this.kg, this.reps, this.total);
}

class LiveLogScreen extends StatefulWidget {
  const LiveLogScreen({super.key});

  @override
  State<LiveLogScreen> createState() => _LiveLogScreenState();
}

class _LiveLogScreenState extends State<LiveLogScreen> {
  static const _workoutName = 'Push day';
  static const _plan = [
    _PlannedExercise('Bench press', 60, 8, 4),
    _PlannedExercise('Incline DB press', 24, 10, 3),
    _PlannedExercise('Cable fly', 15, 12, 3),
  ];

  int _exIdx = 0;
  List<SetModel> _sets = [
    SetModel(weight: 60, reps: 8),
    SetModel(weight: 60, reps: 8),
  ];
  final List<ExerciseModel> _completed = [];
  int _rest = 0;
  Timer? _restTimer;
  bool _listening = false;
  bool _saving = false;
  late final stt.SpeechToText _speech;

  _PlannedExercise get _ex => _plan[_exIdx];
  bool get _complete => _sets.length >= _ex.total;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  void _logSet(double kg, int reps) {
    setState(() {
      _sets = [..._sets, SetModel(weight: kg, reps: reps)];
      _rest = 90;
    });
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _rest = (_rest - 1).clamp(0, 9999));
      if (_rest <= 0) t.cancel();
    });
  }

  Future<void> _mic() async {
    if (_listening) return;
    final available = await _speech.initialize();
    if (!available) {
      // No mic permission/engine — fall back to the planned set.
      _logSet(_ex.kg, _ex.reps);
      return;
    }
    setState(() => _listening = true);
    _speech.listen(
      listenOptions: stt.SpeechListenOptions(listenFor: const Duration(seconds: 4)),
      onResult: (r) {
        if (!r.finalResult) return;
        final parsed = _parse(r.recognizedWords);
        _stopMic();
        _logSet(parsed.$1, parsed.$2);
      },
    );
    // Safety stop if nothing recognized.
    Future.delayed(const Duration(seconds: 5), () {
      if (_listening) {
        _stopMic();
        _logSet(_ex.kg, _ex.reps);
      }
    });
  }

  void _stopMic() {
    _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  /// Pulls `kg` and `reps` numbers out of a spoken phrase; falls back to target.
  (double, int) _parse(String text) {
    final t = text.toLowerCase();
    final kg = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kg|kilo)').firstMatch(t);
    final reps = RegExp(r'(\d+)\s*(?:rep|reps|times|x)').firstMatch(t);
    return (
      kg != null ? double.tryParse(kg.group(1)!) ?? _ex.kg : _ex.kg,
      reps != null ? int.tryParse(reps.group(1)!) ?? _ex.reps : _ex.reps,
    );
  }

  Future<void> _next() async {
    _completed.add(ExerciseModel(name: _ex.name, sets: _sets));
    if (_exIdx < _plan.length - 1) {
      setState(() {
        _exIdx++;
        _sets = [];
        _rest = 0;
      });
      _restTimer?.cancel();
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final provider = context.read<LiftingProvider>();
    final session = LiftingSessionModel(
      id: '',
      date: DateTime.now(),
      sessionName: _workoutName,
      exercises: _completed,
    );
    await provider.logSession(session);
    if (mounted) Navigator.pop(context);
  }

  String _fmt(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final last = _exIdx == _plan.length - 1;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
        title: const Text(_workoutName),
        actions: [
          IconButton(
              icon: const Icon(Icons.check, color: AppColors.primary),
              onPressed: _saving ? null : _finish),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_ex.name,
                        style:
                            AppTextStyles.sans(size: 20, weight: FontWeight.w700)),
                    Text(
                      'target ${_ex.total} × ${_ex.reps} · ${_ex.kg.toStringAsFixed(0)} kg',
                      style: AppTextStyles.sans(
                          size: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              HABadge(
                _complete ? 'done' : 'set ${_sets.length + 1}',
                variant: _complete ? BadgeVariant.success : BadgeVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: CardPadding.sm,
            child: Column(
              children: [
                for (var i = 0; i < _sets.length; i++)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: AppColors.surfaceBorder)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text('${i + 1}',
                              style: AppTextStyles.sans(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.textMuted)),
                        ),
                        Expanded(
                          child: Text(
                            '${_sets[i].weight.toStringAsFixed(0)} kg × ${_sets[i].reps}',
                            style: AppTextStyles.sans(
                                size: 15, weight: FontWeight.w600),
                          ),
                        ),
                        const Icon(Icons.check_circle,
                            size: 20, color: AppColors.primary),
                      ],
                    ),
                  ),
                if (!_complete)
                  Container(
                    margin: const EdgeInsets.fromLTRB(2, 8, 2, 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.surfaceBorder,
                          width: 1.5,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text('${_sets.length + 1}',
                              style: AppTextStyles.sans(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.textMuted)),
                        ),
                        Expanded(
                          child: Text('__ kg × __ reps',
                              style: AppTextStyles.sans(
                                  size: 13, color: AppColors.textMuted)),
                        ),
                        const Icon(Icons.keyboard,
                            size: 18, color: AppColors.textMuted),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_rest > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rest',
                      style: AppTextStyles.sans(
                          size: 15,
                          weight: FontWeight.w500,
                          color: AppColors.textSecondary)),
                  Text(_fmt(_rest),
                      style: AppTextStyles.sans(
                          size: 22,
                          weight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: SafeArea(
          top: false,
          child: _complete
              ? HAButton(
                  label: last ? 'Finish workout' : 'Next exercise',
                  icon: last ? Icons.check : Icons.arrow_forward,
                  iconRight: true,
                  fullWidth: true,
                  loading: _saving,
                  onPressed: _saving ? null : _next,
                )
              : Row(
                  children: [
                    GestureDetector(
                      onTap: _mic,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _listening
                              ? AppColors.errorDim
                              : AppColors.primaryDim,
                          border: Border.all(
                            color: _listening
                                ? AppColors.error
                                : AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _listening ? Icons.mic : Icons.mic_none,
                          size: 24,
                          color:
                              _listening ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HAButton(
                        label: _listening ? 'Listening…' : 'Add set',
                        variant: HAButtonVariant.secondary,
                        icon: Icons.add,
                        fullWidth: true,
                        onPressed: () => _logSet(_ex.kg, _ex.reps),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
