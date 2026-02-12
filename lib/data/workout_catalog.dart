import '../models/exercise.dart';
import '../models/workout.dart';

class WorkoutCatalog {
  static List<Workout> allWorkouts() {
    return [
      Workout(
        id: 'morning-boost',
        name: 'Утренняя зарядка',
        description: 'Мягкий старт дня на всё тело.',
        difficulty: 1,
        totalDuration: 5,
        category: WorkoutCategory.warmup,
        muscleGroups: const ['Плечи', 'Ноги', 'Кор'],
        exercises: const [
          Exercise(id: 'jumping-jacks', name: 'Джампинг-джек', durationSeconds: 40, restSeconds: 15, difficulty: 1),
          Exercise(id: 'arm-circles', name: 'Круги руками', durationSeconds: 30, restSeconds: 15, difficulty: 1),
          Exercise(id: 'bodyweight-squat', name: 'Приседания', durationSeconds: 40, restSeconds: 20, difficulty: 1),
          Exercise(id: 'plank-knee', name: 'Планка с колен', durationSeconds: 30, restSeconds: 15, difficulty: 1),
        ],
      ),
      Workout(
        id: 'wake-up-warmup',
        name: 'Разминка после сна',
        description: 'Разогреваем мышцы и суставы за 6 минут.',
        difficulty: 1,
        totalDuration: 6,
        category: WorkoutCategory.warmup,
        muscleGroups: const ['Шея', 'Плечи', 'Ноги'],
        exercises: const [
          Exercise(id: 'neck-roll', name: 'Повороты шеи', durationSeconds: 30, restSeconds: 10, difficulty: 1),
          Exercise(id: 'hip-open', name: 'Раскрытие таза', durationSeconds: 40, restSeconds: 15, difficulty: 1),
          Exercise(id: 'wall-pushup', name: 'Отжимания от стены', durationSeconds: 40, restSeconds: 20, difficulty: 1),
          Exercise(id: 'calf-raise', name: 'Подъёмы на носки', durationSeconds: 40, restSeconds: 15, difficulty: 1),
        ],
      ),
      Workout(
        id: 'easy-stretch',
        name: 'Лёгкая растяжка',
        description: 'Снимаем напряжение после рабочего дня.',
        difficulty: 1,
        totalDuration: 7,
        category: WorkoutCategory.mobility,
        muscleGroups: const ['Спина', 'Ноги', 'Грудь'],
        exercises: const [
          Exercise(id: 'cat-cow', name: 'Кошка-корова', durationSeconds: 45, restSeconds: 15, difficulty: 1),
          Exercise(id: 'hamstring', name: 'Растяжка задней поверхности бедра', durationSeconds: 45, restSeconds: 20, difficulty: 1),
          Exercise(id: 'child-pose', name: 'Поза ребёнка', durationSeconds: 40, restSeconds: 15, difficulty: 1),
          Exercise(id: 'chest-open', name: 'Растяжка груди', durationSeconds: 40, restSeconds: 15, difficulty: 1),
        ],
      ),
      Workout(
        id: 'abs-home',
        name: 'Пресс дома',
        description: '10 минут на кор и пресс.',
        difficulty: 2,
        totalDuration: 10,
        category: WorkoutCategory.core,
        muscleGroups: const ['Пресс', 'Кор'],
        exercises: const [
          Exercise(id: 'crunches', name: 'Скручивания', durationSeconds: 45, restSeconds: 20, difficulty: 2),
          Exercise(id: 'mountain-climber', name: 'Альпинист', durationSeconds: 40, restSeconds: 20, difficulty: 2),
          Exercise(id: 'leg-raise', name: 'Подъёмы ног', durationSeconds: 40, restSeconds: 20, difficulty: 2),
          Exercise(id: 'plank', name: 'Планка', durationSeconds: 45, restSeconds: 20, difficulty: 2),
          Exercise(id: 'bicycle', name: 'Велосипед', durationSeconds: 40, restSeconds: 20, difficulty: 2),
        ],
      ),
      Workout(
        id: 'full-body',
        name: 'Всё тело',
        description: 'Сбалансированная тренировка на 12 минут.',
        difficulty: 2,
        totalDuration: 12,
        category: WorkoutCategory.mixed,
        muscleGroups: const ['Ноги', 'Грудь', 'Спина', 'Кор'],
        exercises: const [
          Exercise(id: 'squat', name: 'Приседания', durationSeconds: 45, restSeconds: 15, difficulty: 2),
          Exercise(id: 'pushup-knee', name: 'Отжимания с колен', durationSeconds: 40, restSeconds: 20, difficulty: 2),
          Exercise(id: 'lunges', name: 'Выпады', durationSeconds: 45, restSeconds: 20, difficulty: 2),
          Exercise(id: 'superman', name: 'Супермен', durationSeconds: 40, restSeconds: 20, difficulty: 2),
          Exercise(id: 'plank-shoulder', name: 'Планка с касанием плеч', durationSeconds: 40, restSeconds: 15, difficulty: 2),
        ],
      ),
      Workout(
        id: 'no-jump-cardio',
        name: 'Кардио без прыжков',
        description: 'Поднимаем пульс без ударной нагрузки.',
        difficulty: 2,
        totalDuration: 11,
        category: WorkoutCategory.cardio,
        muscleGroups: const ['Ноги', 'Сердце', 'Кор'],
        exercises: const [
          Exercise(id: 'step-touch', name: 'Шаги в сторону', durationSeconds: 45, restSeconds: 15, difficulty: 2),
          Exercise(id: 'knee-up', name: 'Подъём коленей', durationSeconds: 45, restSeconds: 20, difficulty: 2),
          Exercise(id: 'shadow-box', name: 'Теневой бокс', durationSeconds: 45, restSeconds: 20, difficulty: 2),
          Exercise(id: 'speed-skater', name: 'Скейтер шагом', durationSeconds: 40, restSeconds: 15, difficulty: 2),
          Exercise(id: 'march-plank', name: 'Планка-марш', durationSeconds: 35, restSeconds: 20, difficulty: 2),
        ],
      ),
      Workout(
        id: 'bike-power',
        name: 'Велосипедная мощь',
        description: 'Имитация интервальной велотренировки дома.',
        difficulty: 2,
        totalDuration: 13,
        category: WorkoutCategory.cardio,
        muscleGroups: const ['Ноги', 'Ягодицы', 'Выносливость'],
        exercises: const [
          Exercise(id: 'bike-sprint', name: 'Велосипед: быстрый темп', durationSeconds: 60, restSeconds: 20, difficulty: 2),
          Exercise(id: 'bike-standing', name: 'Велосипед: стоя в горку', durationSeconds: 50, restSeconds: 20, difficulty: 2),
          Exercise(id: 'step-touch', name: 'Активное восстановление', durationSeconds: 45, restSeconds: 20, difficulty: 2),
          Exercise(id: 'bike-sprint', name: 'Велосипед: спринт', durationSeconds: 60, restSeconds: 25, difficulty: 3),
          Exercise(id: 'calf-raise', name: 'Подъёмы на носки', durationSeconds: 45, restSeconds: 20, difficulty: 2),
        ],
      ),
      Workout(
        id: 'run-intervals',
        name: 'Беговые интервалы',
        description: 'Силовой беговой блок для выносливости.',
        difficulty: 3,
        totalDuration: 14,
        category: WorkoutCategory.cardio,
        muscleGroups: const ['Ноги', 'Сердце', 'Выносливость'],
        exercises: const [
          Exercise(id: 'run-high-tempo', name: 'Бег на месте: темп', durationSeconds: 60, restSeconds: 20, difficulty: 3),
          Exercise(id: 'high-knees', name: 'Высокие колени', durationSeconds: 45, restSeconds: 20, difficulty: 3),
          Exercise(id: 'run-cadence', name: 'Бег: частота шага', durationSeconds: 55, restSeconds: 20, difficulty: 3),
          Exercise(id: 'lunges', name: 'Выпады', durationSeconds: 45, restSeconds: 20, difficulty: 2),
          Exercise(id: 'run-sprint', name: 'Финишный спринт', durationSeconds: 50, restSeconds: 20, difficulty: 3),
        ],
      ),
      Workout(
        id: 'hiit15',
        name: 'HIIT 15 минут',
        description: 'Интенсивный блок для жиросжигания.',
        difficulty: 3,
        totalDuration: 15,
        category: WorkoutCategory.cardio,
        muscleGroups: const ['Всё тело', 'Сердце', 'Кор'],
        exercises: const [
          Exercise(id: 'burpees', name: 'Бёрпи', durationSeconds: 35, restSeconds: 20, difficulty: 3),
          Exercise(id: 'jump-squat', name: 'Прыжковые приседания', durationSeconds: 35, restSeconds: 20, difficulty: 3),
          Exercise(id: 'high-knees', name: 'Высокие колени', durationSeconds: 40, restSeconds: 20, difficulty: 3),
          Exercise(id: 'pushup', name: 'Отжимания', durationSeconds: 35, restSeconds: 20, difficulty: 3),
          Exercise(id: 'plank-jack', name: 'Планка-джек', durationSeconds: 35, restSeconds: 20, difficulty: 3),
          Exercise(id: 'sit-through', name: 'Сит-тру', durationSeconds: 35, restSeconds: 20, difficulty: 3),
        ],
      ),
      Workout(
        id: 'strength-home',
        name: 'Силовая тренировка дома',
        description: 'Функциональная силовая с весом тела.',
        difficulty: 3,
        totalDuration: 14,
        category: WorkoutCategory.strength,
        muscleGroups: const ['Ноги', 'Грудь', 'Ягодицы', 'Кор'],
        exercises: const [
          Exercise(id: 'slow-squat', name: 'Медленные приседания', durationSeconds: 50, restSeconds: 20, difficulty: 3),
          Exercise(id: 'diamond-pushup-knee', name: 'Узкие отжимания с колен', durationSeconds: 40, restSeconds: 20, difficulty: 3),
          Exercise(id: 'reverse-lunge', name: 'Обратные выпады', durationSeconds: 45, restSeconds: 20, difficulty: 3),
          Exercise(id: 'side-plank', name: 'Боковая планка', durationSeconds: 40, restSeconds: 20, difficulty: 3),
          Exercise(id: 'glute-bridge', name: 'Ягодичный мост', durationSeconds: 50, restSeconds: 20, difficulty: 3),
          Exercise(id: 'hollow-hold', name: 'Hollow hold', durationSeconds: 35, restSeconds: 20, difficulty: 3),
        ],
      ),
      Workout(
        id: 'dumbbell-blast',
        name: 'Гантельный заряд',
        description: 'Крутая тренировка с гантелями на всё тело.',
        difficulty: 3,
        totalDuration: 16,
        category: WorkoutCategory.strength,
        muscleGroups: const ['Плечи', 'Спина', 'Ноги', 'Ягодицы'],
        exercises: const [
          Exercise(id: 'dumbbell-squat-press', name: 'Присед + жим гантелей', durationSeconds: 50, restSeconds: 20, difficulty: 3),
          Exercise(id: 'dumbbell-row', name: 'Тяга гантелей в наклоне', durationSeconds: 50, restSeconds: 20, difficulty: 3),
          Exercise(id: 'dumbbell-lunge', name: 'Выпады с гантелями', durationSeconds: 45, restSeconds: 20, difficulty: 3),
          Exercise(id: 'dumbbell-shoulder-press', name: 'Жим гантелей над головой', durationSeconds: 45, restSeconds: 20, difficulty: 3),
          Exercise(id: 'dumbbell-deadlift', name: 'Румынская тяга с гантелями', durationSeconds: 50, restSeconds: 20, difficulty: 3),
          Exercise(id: 'plank', name: 'Планка', durationSeconds: 45, restSeconds: 20, difficulty: 2),
        ],
      ),
    ];
  }

  static List<Exercise> exerciseLibrary() {
    final byId = <String, Exercise>{};
    for (final workout in allWorkouts()) {
      for (final exercise in workout.exercises) {
        byId.putIfAbsent(exercise.id, () => exercise);
      }
    }
    return byId.values.toList();
  }

  static Workout buildCustomWorkout({
    required String name,
    required List<Exercise> exercises,
  }) {
    if (exercises.isEmpty) {
      throw ArgumentError('Custom workout must include at least one exercise.');
    }

    final totalSeconds = exercises.asMap().entries.fold<int>(
      0,
      (sum, entry) {
        final index = entry.key;
        final exercise = entry.value;
        final hasRestAfter = index < exercises.length - 1;
        return sum + exercise.durationSeconds + (hasRestAfter ? exercise.restSeconds : 0);
      },
    );
    final averageDifficulty =
        ((exercises.fold<int>(0, (sum, item) => sum + item.difficulty) / exercises.length).round().clamp(1, 3))
            as int;

    return Workout(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Своя тренировка' : name.trim(),
      description: 'Собрана из выбранных упражнений.',
      difficulty: averageDifficulty,
      totalDuration: (totalSeconds / 60).ceil(),
      category: WorkoutCategory.custom,
      muscleGroups: _resolveMuscleGroups(exercises),
      exercises: exercises,
    );
  }

  static List<String> _resolveMuscleGroups(List<Exercise> exercises) {
    final joined = exercises.map((item) => item.id).join(' ');
    final groups = <String>{};
    if (joined.contains('squat') || joined.contains('lunge') || joined.contains('calf')) {
      groups.add('Ноги');
    }
    if (joined.contains('pushup') || joined.contains('press')) {
      groups.add('Грудь');
      groups.add('Плечи');
    }
    if (joined.contains('row') || joined.contains('deadlift') || joined.contains('superman')) {
      groups.add('Спина');
    }
    if (joined.contains('plank') || joined.contains('crunch') || joined.contains('bicycle') || joined.contains('hollow')) {
      groups.add('Кор');
      groups.add('Пресс');
    }
    if (groups.isEmpty) groups.add('Всё тело');
    return groups.toList();
  }
}
