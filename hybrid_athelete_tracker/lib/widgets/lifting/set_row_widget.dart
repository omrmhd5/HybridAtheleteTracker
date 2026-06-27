import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SetRowWidget extends StatelessWidget {
  final int setIndex;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final VoidCallback onRemove;

  const SetRowWidget({
    super.key,
    required this.setIndex,
    required this.repsController,
    required this.weightController,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('${setIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: TextFormField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Weight',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('x', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Reps',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
