class WeeklySummaryModel {
  final int liftingSessionsCount;
  final double totalVolume;
  final int cardioSessionsCount;
  final int totalCardioMinutes;
  final double totalCardioDistance;
  final int foodLogsCount;
  final int daysGoalMet;
  final List<dynamic> weightTrend;

  WeeklySummaryModel({
    required this.liftingSessionsCount,
    required this.totalVolume,
    required this.cardioSessionsCount,
    required this.totalCardioMinutes,
    required this.totalCardioDistance,
    required this.foodLogsCount,
    required this.daysGoalMet,
    required this.weightTrend,
  });

  factory WeeklySummaryModel.fromJson(Map<String, dynamic> json) {
    return WeeklySummaryModel(
      liftingSessionsCount: json['lifting']['sessionsCount'] ?? 0,
      totalVolume: (json['lifting']['totalVolume'] ?? 0).toDouble(),
      cardioSessionsCount: json['cardio']['sessionsCount'] ?? 0,
      totalCardioMinutes: json['cardio']['totalMinutes'] ?? 0,
      totalCardioDistance: (json['cardio']['totalDistance'] ?? 0).toDouble(),
      foodLogsCount: json['food']['logsCount'] ?? 0,
      daysGoalMet: json['food']['daysGoalMet'] ?? 0,
      weightTrend: json['weight']['trend'] ?? [],
    );
  }
}
