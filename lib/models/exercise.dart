class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.restSeconds,
    required this.difficulty,
  });

  final String id;
  final String name;
  final int durationSeconds;
  final int restSeconds;
  final int difficulty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationSeconds': durationSeconds,
      'restSeconds': restSeconds,
      'difficulty': difficulty,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      durationSeconds: json['durationSeconds'] as int,
      restSeconds: json['restSeconds'] as int,
      difficulty: json['difficulty'] as int,
    );
  }
}
