class FoodLogModel {
  final String id;
  final DateTime date;
  final String mealName;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final bool proteinGoalMet;

  FoodLogModel({
    required this.id,
    required this.date,
    required this.mealName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinGoalMet,
  });

  factory FoodLogModel.fromJson(Map<String, dynamic> json) {
    return FoodLogModel(
      id: json['_id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      mealName: json['mealName'] ?? 'Meal',
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
      proteinGoalMet: json['proteinGoalMet'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mealName': mealName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
