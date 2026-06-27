class SetModel {
  final int reps;
  final double weight;

  SetModel({required this.reps, required this.weight});

  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      reps: json['reps'] ?? 0,
      weight: (json['weight'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }
}

class ExerciseModel {
  final String name;
  final List<SetModel> sets;

  ExerciseModel({required this.name, required this.sets});

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    var setsList = json['sets'] as List? ?? [];
    List<SetModel> sets = setsList.map((i) => SetModel.fromJson(i)).toList();
    
    return ExerciseModel(
      name: json['name'] ?? '',
      sets: sets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }
}

class LiftingSessionModel {
  final String id;
  final DateTime date;
  final String sessionName;
  final List<ExerciseModel> exercises;
  final String? voiceTranscript;
  final String? notes;

  LiftingSessionModel({
    required this.id,
    required this.date,
    required this.sessionName,
    required this.exercises,
    this.voiceTranscript,
    this.notes,
  });

  factory LiftingSessionModel.fromJson(Map<String, dynamic> json) {
    var exercisesList = json['exercises'] as List? ?? [];
    List<ExerciseModel> exercises = exercisesList.map((i) => ExerciseModel.fromJson(i)).toList();

    return LiftingSessionModel(
      id: json['_id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      sessionName: json['sessionName'] ?? 'Workout',
      exercises: exercises,
      voiceTranscript: json['voiceTranscript'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sessionName': sessionName,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      if (voiceTranscript != null) 'voiceTranscript': voiceTranscript,
      if (notes != null) 'notes': notes,
    };
  }
}
