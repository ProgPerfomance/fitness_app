class WorkoutResult {
  const WorkoutResult({
    required this.workoutId,
    required this.date,
    required this.totalDuration,
    required this.completed,
  });

  final String workoutId;
  final DateTime date;
  final int totalDuration;
  final bool completed;

  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'date': date.toIso8601String(),
      'totalDuration': totalDuration,
      'completed': completed,
    };
  }

  factory WorkoutResult.fromJson(Map<String, dynamic> json) {
    return WorkoutResult(
      workoutId: json['workoutId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalDuration: json['totalDuration'] as int,
      completed: json['completed'] as bool,
    );
  }
}
