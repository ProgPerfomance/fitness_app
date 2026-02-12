import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/workout_session_view_model.dart';
import 'result_screen.dart';
import 'widgets/aurora_background.dart';
import 'widgets/exercise_visual_card.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({
    super.key,
    required this.workout,
    required this.isDailyChallenge,
    required this.isPersonalized,
  });

  final Workout workout;
  final bool isDailyChallenge;
  final bool isPersonalized;

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late final WorkoutSessionViewModel session;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    session = WorkoutSessionViewModel(widget.workout)..start();
    session.addListener(_listenCompletion);
  }

  @override
  void dispose() {
    session.removeListener(_listenCompletion);
    session.dispose();
    super.dispose();
  }

  Future<void> _listenCompletion() async {
    if (!session.isEnded || _navigated) return;
    _navigated = true;
    final homeVm = context.read<HomeViewModel>();
    final gainedXp = homeVm.projectedXpGain(
      widget.workout,
      asDailyChallenge: widget.isDailyChallenge,
      completed: session.isFullyCompleted,
      completionRatio: session.completionRatio,
    );
    await homeVm.completeWorkout(
      widget.workout,
      fromDailyChallenge: widget.isDailyChallenge,
      completed: session.isFullyCompleted,
      completionRatio: session.completionRatio,
      actualDurationMinutes: (session.elapsedWorkoutSeconds / 60).ceil(),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          workout: widget.workout,
          gainedXp: gainedXp,
          completed: session.isFullyCompleted,
          completionPercent: (session.completionRatio * 100).round(),
          actualDurationMinutes: (session.elapsedWorkoutSeconds / 60).ceil(),
          isPersonalized: widget.isPersonalized,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: session,
      child: Consumer<WorkoutSessionViewModel>(
        builder: (context, vm, child) {
          final timerColor = vm.isRestPhase ? Colors.blueGrey : Theme.of(context).colorScheme.primary;
          final left = vm.remainingWorkoutSeconds;
          final minutes = (left ~/ 60).toString().padLeft(2, '0');
          final seconds = (left % 60).toString().padLeft(2, '0');

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: Text(widget.workout.name)),
            body: AuroraBackground(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      vm.phaseTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    if (vm.activeExercise != null) ...[
                      ExerciseVisualCard(exercise: vm.activeExercise!),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      vm.secondsLeft.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 92, fontWeight: FontWeight.w700, color: timerColor),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: vm.progress.clamp(0, 1),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Осталось: $minutes:$seconds',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 14),
                    if (vm.upcomingExercises.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Дальше по плану',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    if (vm.upcomingExercises.isNotEmpty) const SizedBox(height: 8),
                    if (vm.upcomingExercises.isNotEmpty)
                      ...vm.upcomingExercises
                          .take(3)
                          .map((exercise) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ExerciseVisualCard(
                                  exercise: exercise,
                                  compact: true,
                                ),
                              )),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: vm.pauseOrResume,
                            icon: Icon(vm.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                            label: Text(vm.isPaused ? 'Продолжить' : 'Пауза'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: vm.finishEarly,
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('Завершить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
