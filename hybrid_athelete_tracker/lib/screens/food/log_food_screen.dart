import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../models/food_log_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

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
    if (_formKey.currentState!.validate()) {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);

      final meal = FoodLogModel(
        id: '',
        date: DateTime.now(),
        mealName: _mealNameController.text.trim(),
        calories: int.tryParse(_caloriesController.text) ?? 0,
        protein: int.tryParse(_proteinController.text) ?? 0,
        carbs: int.tryParse(_carbsController.text) ?? 0,
        fat: int.tryParse(_fatController.text) ?? 0,
        proteinGoalMet: false, // Calculated on backend
      );

      final success = await foodProvider.logMeal(meal);
      if (success && mounted) {
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(foodProvider.error ?? 'Failed to log meal'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FoodProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isLoading ? null : _saveMeal,
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
                Text(
                  'Enter the macros for your meal. Check nutrition labels or search online.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _mealNameController,
                  decoration: const InputDecoration(
                    hintText: 'Meal Name (e.g., Breakfast, Chicken Salad)',
                    prefixIcon: Icon(Icons.restaurant_menu),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a meal name' : null,
                ),
                const SizedBox(height: 16),
                _buildMacroField('Calories (kcal)', _caloriesController),
                const SizedBox(height: 16),
                _buildMacroField('Protein (g)', _proteinController),
                const SizedBox(height: 16),
                _buildMacroField('Carbs (g)', _carbsController),
                const SizedBox(height: 16),
                _buildMacroField('Fat (g)', _fatController),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _saveMeal,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Meal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: label,
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
