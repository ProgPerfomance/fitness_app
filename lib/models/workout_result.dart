class WorkoutResult {
  const WorkoutResult({
    required this.workoutId,
    required this.date,
    required this.totalDuration,
    required this.completed,
    this.workoutName,
  });

  final String workoutId;
  final DateTime date;
  final int totalDuration;
  final bool completed;
  final String? workoutName;

  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'date': date.toIso8601String(),
      'totalDuration': totalDuration,
      'completed': completed,
      'workoutName': workoutName,
    };
  }

  factory WorkoutResult.fromJson(Map<String, dynamic> json) {
    return WorkoutResult(
      workoutId: json['workoutId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalDuration: json['totalDuration'] as int,
      completed: json['completed'] as bool,
      workoutName: json['workoutName'] as String?,
    );
  }
}
