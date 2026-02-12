import 'dart:math';

import 'package:flutter/material.dart';

import '../data/local_storage_service.dart';
import '../models/exercise.dart';
import '../data/workout_catalog.dart';
import '../models/user_stats.dart';
import '../models/workout.dart';
import '../models/workout_result.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._storageService);

  final LocalStorageService _storageService;

  final List<Workout> workouts = WorkoutCatalog.allWorkouts();
  List<WorkoutResult> _results = [];
  List<WorkoutResult> get results => List.unmodifiable(_results);

  UserStats _stats = UserStats.initial();
  UserStats get stats => _stats;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Workout? _dailyWorkout;
  Workout? get dailyWorkout => _dailyWorkout;
  bool get hasCompletedOnboarding => _stats.onboardingCompleted;
  Workout? get personalizedWorkout => hasCompletedOnboarding ? _buildPersonalizedWorkout() : null;

  double _bodyWeightKg = 70;
  int _waterIntakeMlToday = 0;
  DateTime _waterLogDate = DateTime.now();

  double get bodyWeightKg => _bodyWeightKg;
  int get waterIntakeMlToday => _waterIntakeMlToday;
  int get hydrationGoalMl => (_bodyWeightKg * 35).round();
  double get hydrationProgress => hydrationGoalMl == 0 ? 0 : (_waterIntakeMlToday / hydrationGoalMl).clamp(0, 1);

  bool get isDailyChallengeDone {
    final last = _stats.lastDailyChallengeDate;
    if (last == null) return false;
    return _isSameDay(last, DateTime.now());
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _stats = await _storageService.loadStats();
    _results = await _storageService.loadResults();
    final hydration = await _storageService.loadHydrationData();
    if (hydration != null) {
      _bodyWeightKg = (hydration['bodyWeightKg'] as num?)?.toDouble() ?? 70;
      _waterIntakeMlToday = hydration['waterIntakeMlToday'] as int? ?? 0;
      final rawDate = hydration['waterLogDate'] as String?;
      _waterLogDate = rawDate != null ? DateTime.tryParse(rawDate) ?? DateTime.now() : DateTime.now();
    }
    _refreshHydrationDay();
    if (_stats.weightKg != null) {
      _bodyWeightKg = _stats.weightKg!;
    }
    _dailyWorkout = _pickWorkoutForToday();
    _isLoading = false;
    notifyListeners();
  }

  int xpForWorkout(Workout workout) {
    switch (workout.difficulty) {
      case 1:
        return 10;
      case 2:
        return 20;
      default:
        return 30;
    }
  }

  Future<void> completeWorkout(
    Workout workout, {
    required bool fromDailyChallenge,
    required bool completed,
    required double completionRatio,
    required int actualDurationMinutes,
  }) async {
    final now = DateTime.now();
    final alreadyTrainedToday = _stats.lastWorkoutDate != null && _isSameDay(_stats.lastWorkoutDate!, now);
    final effectiveRatio = completionRatio.clamp(0.0, 1.0);

    var currentStreak = _stats.currentStreak;
    if (completed && !alreadyTrainedToday) {
      if (_stats.lastWorkoutDate == null) {
        currentStreak = 1;
      } else {
        final diff = _differenceInDays(_stats.lastWorkoutDate!, now);
        if (diff == 1) {
          currentStreak = _stats.currentStreak + 1;
        } else if (diff > 1) {
          currentStreak = 1;
        }
      }
    }

    var gainedXp = (xpForWorkout(workout) * effectiveRatio).round();
    DateTime? dailyChallengeDate = _stats.lastDailyChallengeDate;
    if (completed && fromDailyChallenge && !isDailyChallengeDone) {
      gainedXp += 20;
      dailyChallengeDate = now;
    }

    final nextExperience = _stats.experience + gainedXp;
    final nextLevel = (nextExperience ~/ 100) + 1;

    _stats = _stats.copyWith(
      totalWorkouts: _stats.totalWorkouts + (completed ? 1 : 0),
      totalMinutes: _stats.totalMinutes + actualDurationMinutes,
      currentStreak: completed ? currentStreak : _stats.currentStreak,
      bestStreak: max(_stats.bestStreak, currentStreak),
      experience: nextExperience,
      level: nextLevel,
      lastWorkoutDate: completed ? now : _stats.lastWorkoutDate,
      lastDailyChallengeDate: dailyChallengeDate,
    );

    _results = [
      ..._results,
      WorkoutResult(
        workoutId: workout.id,
        date: now,
        totalDuration: actualDurationMinutes,
        completed: completed,
        workoutName: workout.name,
      ),
    ];

    await _storageService.saveStats(_stats);
    await _storageService.saveResults(_results);
    notifyListeners();
  }

  void updateBodyWeight(double valueKg) {
    if (valueKg <= 0) return;
    _bodyWeightKg = valueKg;
    _stats = _stats.copyWith(weightKg: valueKg);
    _storageService.saveStats(_stats);
    _persistHydration();
    notifyListeners();
  }

  void addWater(int amountMl) {
    _refreshHydrationDay();
    _waterIntakeMlToday = (_waterIntakeMlToday + amountMl).clamp(0, 10000) as int;
    _persistHydration();
    notifyListeners();
  }

  void resetWaterForToday() {
    _refreshHydrationDay(force: true);
    _persistHydration();
    notifyListeners();
  }

  int completedWorkoutsOnDate(DateTime date) {
    return _results.where((result) => result.completed && _isSameDay(result.date, date)).length;
  }

  int totalWorkoutMinutesOnDate(DateTime date) {
    return _results.where((result) => _isSameDay(result.date, date)).fold<int>(0, (sum, result) => sum + result.totalDuration);
  }

  List<WorkoutResult> workoutResultsOnDate(DateTime date) {
    final dailyResults = _results.where((result) => _isSameDay(result.date, date)).toList();
    dailyResults.sort((a, b) => b.date.compareTo(a.date));
    return dailyResults;
  }

  String displayNameForWorkoutResult(WorkoutResult result) {
    if (result.workoutName != null && result.workoutName!.trim().isNotEmpty) {
      return result.workoutName!;
    }
    final catalogMatch = workouts.where((workout) => workout.id == result.workoutId);
    if (catalogMatch.isNotEmpty) return catalogMatch.first.name;
    if (result.workoutId.startsWith('custom-')) return 'Персональная/своя тренировка';
    return 'Тренировка';
  }

  int projectedXpGain(
    Workout workout, {
    required bool asDailyChallenge,
    required bool completed,
    required double completionRatio,
  }) {
    final xp = (xpForWorkout(workout) * completionRatio.clamp(0.0, 1.0)).round();
    if (completed && asDailyChallenge && !isDailyChallengeDone) return xp + 20;
    return xp;
  }

  Future<void> completeOnboarding({
    required int heightCm,
    required double weightKg,
    required List<String> equipment,
    required int maxPushUps,
    required int maxSquats,
    required int plankSeconds,
    required int age,
    required int trainingDaysPerWeek,
    required String goal,
    required bool hasInjuries,
  }) async {
    _stats = _stats.copyWith(
      onboardingCompleted: true,
      heightCm: heightCm,
      weightKg: weightKg,
      equipment: equipment,
      maxPushUps: maxPushUps,
      maxSquats: maxSquats,
      plankSeconds: plankSeconds,
      age: age,
      trainingDaysPerWeek: trainingDaysPerWeek,
      goal: goal,
      hasInjuries: hasInjuries,
    );
    _bodyWeightKg = weightKg;

    await _storageService.saveStats(_stats);
    await _persistHydration();
    notifyListeners();
  }

  Future<void> adjustPersonalizationDifficulty(int delta) async {
    final next = (_stats.personalizationOffset + delta).clamp(-2, 2) as int;
    _stats = _stats.copyWith(personalizationOffset: next);
    await _storageService.saveStats(_stats);
    notifyListeners();
  }

  Workout _pickWorkoutForToday() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    return workouts[random.nextInt(workouts.length)];
  }

  int _differenceInDays(DateTime first, DateTime second) {
    final a = DateTime(first.year, first.month, first.day);
    final b = DateTime(second.year, second.month, second.day);
    return b.difference(a).inDays;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Workout _buildPersonalizedWorkout() {
    final difficulty = _targetPersonalDifficulty();
    final all = WorkoutCatalog.exerciseLibrary();
    final filtered = all.where((exercise) => _exerciseMatchesProfile(exercise)).toList();
    final candidates = filtered.isEmpty ? all : filtered;
    final exactDifficulty = candidates.where((exercise) => exercise.difficulty == difficulty).toList();
    final pool = exactDifficulty.isNotEmpty ? exactDifficulty : candidates;
    final sortedPool = [...pool]..sort((a, b) => a.id.compareTo(b.id));

    final count = difficulty == 1 ? 4 : (difficulty == 2 ? 5 : 6);
    final selected = <Exercise>[];
    final seed = DateTime.now().year * 10000 + DateTime.now().month * 100 + DateTime.now().day + _stats.totalWorkouts;
    final random = Random(seed);

    while (selected.length < count && sortedPool.isNotEmpty) {
      final exercise = sortedPool[random.nextInt(sortedPool.length)];
      if (selected.any((item) => item.id == exercise.id)) {
        continue;
      }
      selected.add(exercise);
    }

    final safeSelected = selected.isNotEmpty ? selected : candidates.take(count).toList();
    return WorkoutCatalog.buildCustomWorkout(
      name: 'Персональная тренировка',
      exercises: safeSelected,
    );
  }

  int _targetPersonalDifficulty() {
    final pushUps = _stats.maxPushUps ?? 0;
    final squats = _stats.maxSquats ?? 0;
    final plank = _stats.plankSeconds ?? 0;
    final baseScore = pushUps + (squats ~/ 2) + (plank ~/ 15);

    var difficulty = 1;
    if (baseScore >= 60) {
      difficulty = 3;
    } else if (baseScore >= 30) {
      difficulty = 2;
    }

    final autoProgress = (_stats.totalWorkouts ~/ 6).clamp(0, 2) as int;
    final goalBoost = _stats.goal == 'strength' ? 1 : 0;
    final frequencyBoost = ((_stats.trainingDaysPerWeek ?? 2) >= 4) ? 1 : 0;
    final injuryPenalty = _stats.hasInjuries ? -1 : 0;
    return (difficulty + autoProgress + goalBoost + frequencyBoost + injuryPenalty + _stats.personalizationOffset)
        .clamp(1, 3) as int;
  }

  bool _exerciseMatchesProfile(Exercise exercise) {
    final equipment = _stats.equipment;
    final isDumbbell = exercise.id.contains('dumbbell');
    final isBike = exercise.id.contains('bike');
    if (isDumbbell && !equipment.contains('dumbbells')) return false;
    if (isBike && !equipment.contains('bike')) return false;
    return true;
  }

  void _refreshHydrationDay({bool force = false}) {
    final now = DateTime.now();
    if (force || !_isSameDay(_waterLogDate, now)) {
      _waterIntakeMlToday = 0;
      _waterLogDate = now;
    }
  }

  Future<void> _persistHydration() async {
    await _storageService.saveHydrationData({
      'bodyWeightKg': _bodyWeightKg,
      'waterIntakeMlToday': _waterIntakeMlToday,
      'waterLogDate': _waterLogDate.toIso8601String(),
    });
  }
}
