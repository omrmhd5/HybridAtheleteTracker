import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/food_log_model.dart';
import '../../providers/food_provider.dart';
import '../../widgets/common/common.dart';

class LogFoodScreen extends StatefulWidget {
  const LogFoodScreen({super.key});

  @override
  State<LogFoodScreen> createState() => _LogFoodScreenState();
}

class _LogFoodScreenState extends State<LogFoodScreen> {
  final _mealNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;
    final foodProvider = context.read<FoodProvider>();
    final meal = FoodLogModel(
      id: '',
      date: DateTime.now(),
      mealName: _mealNameController.text.trim(),
      calories: int.tryParse(_caloriesController.text) ?? 0,
      protein: int.tryParse(_proteinController.text) ?? 0,
      carbs: int.tryParse(_carbsController.text) ?? 0,
      fat: int.tryParse(_fatController.text) ?? 0,
      proteinGoalMet: false,
    );
    final success = await foodProvider.logMeal(meal);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(foodProvider.error ?? 'Failed to log meal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FoodProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Log meal'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter the macros for your meal — check nutrition labels or search online.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                _field(_mealNameController, 'Meal name',
                    icon: Icons.restaurant_menu,
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter a meal name' : null),
                const SizedBox(height: 12),
                _field(_caloriesController, 'Calories (kcal)', number: true),
                const SizedBox(height: 12),
                _field(_proteinController, 'Protein (g)', number: true),
                const SizedBox(height: 12),
                _field(_carbsController, 'Carbs (g)', number: true),
                const SizedBox(height: 12),
                _field(_fatController, 'Fat (g)', number: true),
                const SizedBox(height: 24),
                HAButton(
                  label: 'Save meal',
                  fullWidth: true,
                  loading: isLoading,
                  onPressed: isLoading ? null : _saveMeal,
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      validator: validator ??
          (v) {
            if (number && v != null && v.isNotEmpty && int.tryParse(v) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
    );
  }
}
