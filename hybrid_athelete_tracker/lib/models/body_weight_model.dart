class BodyWeightModel {
  final String id;
  final DateTime date;
  final double weight;
  final String unit;

  BodyWeightModel({
    required this.id,
    required this.date,
    required this.weight,
    required this.unit,
  });

  factory BodyWeightModel.fromJson(Map<String, dynamic> json) {
    return BodyWeightModel(
      id: json['_id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      weight: (json['weight'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'unit': unit,
    };
  }
}
