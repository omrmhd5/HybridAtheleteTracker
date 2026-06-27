class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String unitPreference;
  final int dailyProteinGoal;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.unitPreference,
    required this.dailyProteinGoal,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      unitPreference: json['unitPreference'] ?? 'kg',
      dailyProteinGoal: json['dailyProteinGoal'] ?? 150,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'unitPreference': unitPreference,
      'dailyProteinGoal': dailyProteinGoal,
    };
  }
}
