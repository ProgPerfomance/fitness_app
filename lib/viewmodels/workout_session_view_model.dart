import 'dart:async';

import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout.dart';

class WorkoutSessionViewModel extends ChangeNotifier {
  WorkoutSessionViewModel(this.workout)
      : assert(workout.exercises.isNotEmpty, 'Workout must include at least one exercise.'),
        _secondsLeft = workout.exercises.first.durationSeconds;

  final Workout workout;
  Timer? _timer;

  int _exerciseIndex = 0;
  bool _isRestPhase = false;
  bool _isPaused = false;
  int _secondsLeft;
  bool _isCompleted = false;
  bool _isFinishedEarly = false;
  int _elapsedWorkoutSeconds = 0;

  int get exerciseIndex => _exerciseIndex;
  bool get isRestPhase => _isRestPhase;
  bool get isPaused => _isPaused;
  int get secondsLeft => _secondsLeft;
  bool get isCompleted => _isCompleted;
  bool get isFinishedEarly => _isFinishedEarly;
  bool get isEnded => _isCompleted || _isFinishedEarly;
  bool get isFullyCompleted => _isCompleted;
  int get elapsedWorkoutSeconds => _elapsedWorkoutSeconds;
  int get plannedWorkoutSeconds => _plannedWorkoutSeconds(workout);
  double get completionRatio => plannedWorkoutSeconds == 0 ? 0 : (_elapsedWorkoutSeconds / plannedWorkoutSeconds).clamp(0, 1);

  int get totalSteps => workout.exercises.length;
  double get progress {
    if (isEnded) return completionRatio;
    return (_exerciseIndex + (_isRestPhase ? 0.5 : 0)) / totalSteps;
  }

  String get phaseTitle {
    if (_isCompleted) return 'Готово!';
    if (_isFinishedEarly) return 'Тренировка остановлена';
    if (_isRestPhase) return 'Отдых';
    return workout.exercises[_exerciseIndex].name;
  }

  Exercise? get activeExercise {
    if (workout.exercises.isEmpty) return null;
    if (_isRestPhase && _exerciseIndex < workout.exercises.length - 1) {
      return workout.exercises[_exerciseIndex + 1];
    }
    if (_exerciseIndex >= workout.exercises.length) {
      return workout.exercises.last;
    }
    return workout.exercises[_exerciseIndex];
  }

  List<Exercise> get upcomingExercises {
    final start = _isRestPhase ? _exerciseIndex + 1 : _exerciseIndex;
    if (start >= workout.exercises.length) return const [];
    return workout.exercises.sublist(start);
  }

  int get remainingWorkoutSeconds {
    var sum = _secondsLeft;
    for (var i = _exerciseIndex; i < workout.exercises.length; i++) {
      if (i == _exerciseIndex) continue;
      sum += workout.exercises[i].durationSeconds;
      if (i < workout.exercises.length - 1) {
        sum += workout.exercises[i].restSeconds;
      }
    }
    if (!_isRestPhase && _exerciseIndex < workout.exercises.length - 1) {
      sum += workout.exercises[_exerciseIndex].restSeconds;
    }
    return sum;
  }

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pauseOrResume() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void finishEarly() {
    _timer?.cancel();
    if (isEnded) return;
    _isFinishedEarly = true;
    notifyListeners();
  }

  void _tick() {
    if (_isPaused || isEnded) return;

    if (_secondsLeft > 0) {
      _secondsLeft--;
      _elapsedWorkoutSeconds++;
      notifyListeners();
      return;
    }

    if (_isRestPhase) {
      _isRestPhase = false;
      _exerciseIndex++;
      if (_exerciseIndex >= workout.exercises.length) {
        _completeSession();
        return;
      }
      _secondsLeft = workout.exercises[_exerciseIndex].durationSeconds;
      notifyListeners();
      return;
    }

    final currentExercise = workout.exercises[_exerciseIndex];
    if (_exerciseIndex < workout.exercises.length - 1) {
      _isRestPhase = true;
      _secondsLeft = currentExercise.restSeconds;
      notifyListeners();
    } else {
      _completeSession();
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _isCompleted = true;
    notifyListeners();
  }

  int _plannedWorkoutSeconds(Workout workout) {
    return workout.exercises.asMap().entries.fold<int>(
      0,
      (sum, entry) {
        final index = entry.key;
        final exercise = entry.value;
        final hasRestAfter = index < workout.exercises.length - 1;
        return sum + exercise.durationSeconds + (hasRestAfter ? exercise.restSeconds : 0);
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
