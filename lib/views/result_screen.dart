import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout.dart';
import '../viewmodels/home_view_model.dart';
import 'dashboard_screen.dart';
import 'training_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.workout,
    required this.gainedXp,
  });

  final Workout workout;
  final int gainedXp;

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<HomeViewModel>().stats;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.emoji_events_rounded, size: 72, color: Colors.orange),
            const SizedBox(height: 14),
            const Text(
              'Тренировка завершена',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 26),
            _ResultTile(label: 'Длительность', value: '${workout.totalDuration} минут'),
            _ResultTile(label: 'Получено XP', value: '+$gainedXp XP'),
            _ResultTile(label: 'Уровень', value: '${stats.level}'),
            _ResultTile(label: 'Серия дней', value: '${stats.currentStreak}'),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => TrainingScreen(workout: workout, isDailyChallenge: false),
                  ),
                );
              },
              child: const Text('Повторить тренировку'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (_) => false,
                );
              },
              child: const Text('На главный экран'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
