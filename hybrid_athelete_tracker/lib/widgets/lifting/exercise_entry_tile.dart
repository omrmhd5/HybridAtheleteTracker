import 'package:flutter/material.dart';
import 'set_row_widget.dart';
import '../../core/constants/app_colors.dart';

class ExerciseEntryData {
  String name = '';
  List<SetEntryData> sets = [SetEntryData()];
}

class SetEntryData {
  TextEditingController repsController = TextEditingController();
  TextEditingController weightController = TextEditingController();
}

class ExerciseEntryTile extends StatefulWidget {
  final ExerciseEntryData exerciseData;
  final VoidCallback onRemoveExercise;

  const ExerciseEntryTile({
    super.key,
    required this.exerciseData,
    required this.onRemoveExercise,
  });

  @override
  State<ExerciseEntryTile> createState() => _ExerciseEntryTileState();
}

class _ExerciseEntryTileState extends State<ExerciseEntryTile> {
  void _addSet() {
    setState(() {
      widget.exerciseData.sets.add(SetEntryData());
    });
  }

  void _removeSet(int index) {
    setState(() {
      if (widget.exerciseData.sets.length > 1) {
        widget.exerciseData.sets.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.exerciseData.name,
                    onChanged: (value) => widget.exerciseData.name = value,
                    decoration: const InputDecoration(
                      hintText: 'Exercise Name (e.g., Bench Press)',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: widget.onRemoveExercise,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.exerciseData.sets.asMap().entries.map((entry) {
              return SetRowWidget(
                setIndex: entry.key,
                repsController: entry.value.repsController,
                weightController: entry.value.weightController,
                onRemove: () => _removeSet(entry.key),
              );
            }),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add, color: AppColors.primaryLight),
              label: Text(
                'Add Set',
                style: TextStyle(color: AppColors.primaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
