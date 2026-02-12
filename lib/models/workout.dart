import 'exercise.dart';

enum WorkoutCategory {
  warmup,
  cardio,
  strength,
  mobility,
  core,
  mixed,
  custom,
}

extension WorkoutCategoryX on WorkoutCategory {
  String get title {
    switch (this) {
      case WorkoutCategory.warmup:
        return 'Разминка';
      case WorkoutCategory.cardio:
        return 'Кардио';
      case WorkoutCategory.strength:
        return 'Силовые';
      case WorkoutCategory.mobility:
        return 'Мобильность';
      case WorkoutCategory.core:
        return 'Пресс и кор';
      case WorkoutCategory.mixed:
        return 'Смешанные';
      case WorkoutCategory.custom:
        return 'Персональные';
    }
  }
}

class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.totalDuration,
    required this.exercises,
    required this.category,
    required this.muscleGroups,
  });

  final String id;
  final String name;
  final String description;
  final int difficulty;
  final int totalDuration;
  final List<Exercise> exercises;
  final WorkoutCategory category;
  final List<String> muscleGroups;

  int get estimatedCalories {
    final caloriesPerMinute = switch (difficulty) {
      1 => 5.0,
      2 => 7.0,
      _ => 9.0,
    };
    return (totalDuration * caloriesPerMinute).round();
  }
}
