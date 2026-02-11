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
        exercises: const [
          Exercise(id: 'step-touch', name: 'Шаги в сторону', durationSeconds: 45, restSeconds: 15, difficulty: 2),
          Exercise(id: 'knee-up', name: 'Подъём коленей', durationSeconds: 45, restSeconds: 20, difficulty: 2),
          Exercise(id: 'shadow-box', name: 'Теневой бокс', durationSeconds: 45, restSeconds: 20, difficulty: 2),
          Exercise(id: 'speed-skater', name: 'Скейтер шагом', durationSeconds: 40, restSeconds: 15, difficulty: 2),
          Exercise(id: 'march-plank', name: 'Планка-марш', durationSeconds: 35, restSeconds: 20, difficulty: 2),
        ],
      ),
      Workout(
        id: 'hiit15',
        name: 'HIIT 15 минут',
        description: 'Интенсивный блок для жиросжигания.',
        difficulty: 3,
        totalDuration: 15,
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
        exercises: const [
          Exercise(id: 'slow-squat', name: 'Медленные приседания', durationSeconds: 50, restSeconds: 20, difficulty: 3),
          Exercise(id: 'diamond-pushup-knee', name: 'Узкие отжимания с колен', durationSeconds: 40, restSeconds: 20, difficulty: 3),
          Exercise(id: 'reverse-lunge', name: 'Обратные выпады', durationSeconds: 45, restSeconds: 20, difficulty: 3),
          Exercise(id: 'side-plank', name: 'Боковая планка', durationSeconds: 40, restSeconds: 20, difficulty: 3),
          Exercise(id: 'glute-bridge', name: 'Ягодичный мост', durationSeconds: 50, restSeconds: 20, difficulty: 3),
          Exercise(id: 'hollow-hold', name: 'Hollow hold', durationSeconds: 35, restSeconds: 20, difficulty: 3),
        ],
      ),
    ];
  }
}
