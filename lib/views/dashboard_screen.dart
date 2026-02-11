import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/workout.dart';
import '../viewmodels/home_view_model.dart';
import 'stats_screen.dart';
import 'training_screen.dart';
import 'widgets/difficulty_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('HomeFit'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StatsScreen()),
                  );
                },
                icon: const Icon(Icons.bar_chart_rounded),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WelcomeCard(
                level: vm.stats.level,
                currentStreak: vm.stats.currentStreak,
                experience: vm.stats.experience,
              ),
              const SizedBox(height: 16),
              _DailyCard(),
              const SizedBox(height: 20),
              Text('Тренировки', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...vm.workouts.map((workout) => _WorkoutCard(workout: workout)),
            ],
          ),
        );
      },
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.level,
    required this.currentStreak,
    required this.experience,
  });

  final int level;
  final int currentStreak;
  final int experience;

  @override
  Widget build(BuildContext context) {
    final progress = (experience % 100) / 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ваш прогресс', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Уровень $level', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Серия: $currentStreak дн.', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    color: AppTheme.accent,
                    backgroundColor: AppTheme.accent.withOpacity(0.2),
                  ),
                ),
                Text('${(progress * 100).toInt()}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final workout = vm.dailyWorkout;
    if (workout == null) return const SizedBox.shrink();

    return Card(
      color: AppTheme.accent,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Тренировка дня', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (vm.isDailyChallengeDone)
                  const Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Text(workout.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('+20 XP за выполнение', style: TextStyle(color: Colors.white.withOpacity(0.95))),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => _openWorkout(context, workout, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.accent,
              ),
              child: const Text('Начать челлендж'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(workout.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                DifficultyBadge(level: workout.difficulty),
              ],
            ),
            const SizedBox(height: 8),
            Text(workout.description),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18),
                const SizedBox(width: 6),
                Text('${workout.totalDuration} минут'),
                const Spacer(),
                FilledButton(
                  onPressed: () => _openWorkout(context, workout, false),
                  child: const Text('Начать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _openWorkout(BuildContext context, Workout workout, bool isDailyChallenge) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TrainingScreen(
        workout: workout,
        isDailyChallenge: isDailyChallenge,
      ),
    ),
  );
}
