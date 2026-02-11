import 'dart:async';

import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutSessionViewModel extends ChangeNotifier {
  WorkoutSessionViewModel(this.workout)
      : _secondsLeft = workout.exercises.first.durationSeconds;

  final Workout workout;
  Timer? _timer;

  int _exerciseIndex = 0;
  bool _isRestPhase = false;
  bool _isPaused = false;
  int _secondsLeft;
  bool _isCompleted = false;

  int get exerciseIndex => _exerciseIndex;
  bool get isRestPhase => _isRestPhase;
  bool get isPaused => _isPaused;
  int get secondsLeft => _secondsLeft;
  bool get isCompleted => _isCompleted;

  int get totalSteps => workout.exercises.length;
  double get progress => (_exerciseIndex + (_isRestPhase ? 0.5 : 0)) / totalSteps;

  String get phaseTitle {
    if (_isCompleted) return 'Готово!';
    if (_isRestPhase) return 'Отдых';
    return workout.exercises[_exerciseIndex].name;
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
    _isCompleted = true;
    notifyListeners();
  }

  void _tick() {
    if (_isPaused || _isCompleted) return;

    if (_secondsLeft > 0) {
      _secondsLeft--;
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
