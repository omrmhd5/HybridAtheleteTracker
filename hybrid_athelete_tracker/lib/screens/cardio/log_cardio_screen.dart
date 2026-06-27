import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cardio_provider.dart';
import '../../models/cardio_log_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

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

  String _selectedType = 'run';
  final List<String> _types = ['run', 'cycle', 'swim', 'other'];

  Future<void> _saveSession() async {
    if (_formKey.currentState!.validate()) {
      final cardioProvider = Provider.of<CardioProvider>(context, listen: false);

      final session = CardioLogModel(
        id: '',
        date: DateTime.now(),
        type: _selectedType,
        durationMinutes: int.tryParse(_durationController.text) ?? 0,
        distance: double.tryParse(_distanceController.text) ?? 0.0,
        avgHeartRate: int.tryParse(_heartRateController.text),
        notes: _notesController.text.trim(),
      );

      final success = await cardioProvider.logSession(session);
      if (success && mounted) {
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cardioProvider.error ?? 'Failed to log cardio'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CardioProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Cardio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isLoading ? null : _saveSession,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Activity Type', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  children: _types.map((type) {
                    return ChoiceChip(
                      label: Text(type.toUpperCase()),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = type);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedType == type ? Colors.white : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Duration (minutes)',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter duration' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _distanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Distance (e.g., km or miles)',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _heartRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Average Heart Rate (bpm)',
                    prefixIcon: Icon(Icons.favorite_border),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _saveSession,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Cardio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
