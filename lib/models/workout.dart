import 'exercise.dart';

class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.totalDuration,
    required this.exercises,
  });

  final String id;
  final String name;
  final String description;
  final int difficulty;
  final int totalDuration;
  final List<Exercise> exercises;
}
