import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/cardio_log_model.dart';
import '../../providers/cardio_provider.dart';
import '../../widgets/common/common.dart';

class LogCardioScreen extends StatefulWidget {
  const LogCardioScreen({super.key});

  @override
  State<LogCardioScreen> createState() => _LogCardioScreenState();
}

class _LogCardioScreenState extends State<LogCardioScreen> {
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _type = 'run';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cardioProvider = context.read<CardioProvider>();
    final session = CardioLogModel(
      id: '',
      date: DateTime.now(),
      type: _type,
      durationMinutes: int.tryParse(_durationController.text) ?? 0,
      distance: double.tryParse(_distanceController.text) ?? 0.0,
      avgHeartRate: int.tryParse(_heartRateController.text),
      notes: _notesController.text.trim(),
    );
    final success = await cardioProvider.logSession(session);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cardioProvider.error ?? 'Failed to log cardio'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CardioProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Log cardio'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: SectionLabel('Activity type'),
                ),
                SegmentedControl<String>(
                  value: _type,
                  onChanged: (v) => setState(() => _type = v),
                  options: const [
                    SegmentOption(
                        value: 'run', label: 'Run', icon: Icons.directions_run),
                    SegmentOption(
                        value: 'cycle',
                        label: 'Cycle',
                        icon: Icons.directions_bike),
                    SegmentOption(value: 'swim', label: 'Swim', icon: Icons.pool),
                  ],
                ),
                const SizedBox(height: 20),
                _field(_durationController, 'Duration (minutes)',
                    icon: Icons.timer_outlined,
                    number: true,
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter duration' : null),
                const SizedBox(height: 12),
                _field(_distanceController, 'Distance (km)',
                    icon: Icons.map_outlined, decimal: true),
                const SizedBox(height: 12),
                _field(_heartRateController, 'Avg heart rate (bpm)',
                    icon: Icons.favorite_border, number: true),
                const SizedBox(height: 12),
                _field(_notesController, 'Notes (optional)',
                    icon: Icons.notes, maxLines: 3),
                const SizedBox(height: 24),
                HAButton(
                  label: 'Save cardio',
                  fullWidth: true,
                  loading: isLoading,
                  onPressed: isLoading ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    IconData? icon,
    bool number = false,
    bool decimal = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : number
              ? TextInputType.number
              : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      validator: validator,
    );
  }
}
