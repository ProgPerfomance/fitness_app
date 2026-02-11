import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/workout_session_view_model.dart';
import 'result_screen.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({
    super.key,
    required this.workout,
    required this.isDailyChallenge,
  });

  final Workout workout;
  final bool isDailyChallenge;

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
    if (!session.isCompleted || _navigated) return;
    _navigated = true;
    final homeVm = context.read<HomeViewModel>();
    final gainedXp = homeVm.projectedXpGain(
      widget.workout,
      asDailyChallenge: widget.isDailyChallenge,
    );
    await homeVm.completeWorkout(widget.workout, fromDailyChallenge: widget.isDailyChallenge);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          workout: widget.workout,
          gainedXp: gainedXp,
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
            appBar: AppBar(title: Text(widget.workout.name)),
            body: Padding(
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
          );
        },
      ),
    );
  }
}
