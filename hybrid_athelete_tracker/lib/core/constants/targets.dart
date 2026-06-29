import '../../models/user_model.dart';

/// Daily nutrition targets. Protein comes from the user's goal; the rest use
/// sensible defaults matching the prototype until the backend provides them.
class Targets {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const Targets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  static const Targets defaults =
      Targets(calories: 2200, protein: 150, carbs: 220, fat: 60);

  factory Targets.forUser(UserModel? user) => Targets(
        calories: defaults.calories,
        protein: user?.dailyProteinGoal ?? defaults.protein,
        carbs: defaults.carbs,
        fat: defaults.fat,
      );
}
