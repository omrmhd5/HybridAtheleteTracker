class CardioLogModel {
  final String id;
  final DateTime date;
  final String type;
  final int durationMinutes;
  final double distance;
  final int? avgHeartRate;
  final String? notes;

  CardioLogModel({
    required this.id,
    required this.date,
    required this.type,
    required this.durationMinutes,
    required this.distance,
    this.avgHeartRate,
    this.notes,
  });

  factory CardioLogModel.fromJson(Map<String, dynamic> json) {
    return CardioLogModel(
      id: json['_id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      type: json['type'] ?? 'other',
      durationMinutes: json['durationMinutes'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      avgHeartRate: json['avgHeartRate'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'type': type,
      'durationMinutes': durationMinutes,
      'distance': distance,
      if (avgHeartRate != null) 'avgHeartRate': avgHeartRate,
      if (notes != null) 'notes': notes,
    };
  }
}
