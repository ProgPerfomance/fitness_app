import 'dart:math';

import 'package:flutter/material.dart';

import '../data/local_storage_service.dart';
import '../data/workout_catalog.dart';
import '../models/user_stats.dart';
import '../models/workout.dart';
import '../models/workout_result.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._storageService);

  final LocalStorageService _storageService;

  final List<Workout> workouts = WorkoutCatalog.allWorkouts();
  List<WorkoutResult> _results = [];

  UserStats _stats = UserStats.initial();
  UserStats get stats => _stats;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Workout? _dailyWorkout;
  Workout? get dailyWorkout => _dailyWorkout;

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

  Future<void> completeWorkout(Workout workout, {required bool fromDailyChallenge}) async {
    final now = DateTime.now();
    final alreadyTrainedToday = _stats.lastWorkoutDate != null && _isSameDay(_stats.lastWorkoutDate!, now);

    var currentStreak = _stats.currentStreak;
    if (!alreadyTrainedToday) {
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

    var gainedXp = xpForWorkout(workout);
    DateTime? dailyChallengeDate = _stats.lastDailyChallengeDate;
    if (fromDailyChallenge && !isDailyChallengeDone) {
      gainedXp += 20;
      dailyChallengeDate = now;
    }

    final nextExperience = _stats.experience + gainedXp;
    final nextLevel = (nextExperience ~/ 100) + 1;

    _stats = _stats.copyWith(
      totalWorkouts: _stats.totalWorkouts + 1,
      totalMinutes: _stats.totalMinutes + workout.totalDuration,
      currentStreak: currentStreak,
      bestStreak: max(_stats.bestStreak, currentStreak),
      experience: nextExperience,
      level: nextLevel,
      lastWorkoutDate: now,
      lastDailyChallengeDate: dailyChallengeDate,
    );

    _results = [
      ..._results,
      WorkoutResult(
        workoutId: workout.id,
        date: now,
        totalDuration: workout.totalDuration,
        completed: true,
      ),
    ];

    await _storageService.saveStats(_stats);
    await _storageService.saveResults(_results);
    notifyListeners();
  }

  int projectedXpGain(Workout workout, {required bool asDailyChallenge}) {
    final xp = xpForWorkout(workout);
    if (asDailyChallenge && !isDailyChallengeDone) return xp + 20;
    return xp;
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
}
