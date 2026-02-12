import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout.dart';
import '../viewmodels/home_view_model.dart';
import 'app_shell_screen.dart';
import 'training_screen.dart';
import 'widgets/aurora_background.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.workout,
    required this.gainedXp,
    required this.completed,
    required this.completionPercent,
    required this.actualDurationMinutes,
    required this.isPersonalized,
  });

  final Workout workout;
  final int gainedXp;
  final bool completed;
  final int completionPercent;
  final int actualDurationMinutes;
  final bool isPersonalized;

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<HomeViewModel>().stats;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(automaticallyImplyLeading: false),
      body: AuroraBackground(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Icon(
                completed ? Icons.emoji_events_rounded : Icons.flag_rounded,
                size: 72,
                color: completed ? Colors.orange : Colors.blueGrey,
              ),
              const SizedBox(height: 14),
              Text(
                completed ? 'Тренировка завершена' : 'Тренировка завершена досрочно',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 26),
              _ResultTile(label: 'Длительность', value: '$actualDurationMinutes минут'),
              _ResultTile(label: 'Выполнено', value: '$completionPercent%'),
              _ResultTile(label: 'Получено XP', value: '+$gainedXp XP'),
              _ResultTile(label: 'Уровень', value: '${stats.level}'),
              _ResultTile(label: 'Серия дней', value: '${stats.currentStreak}'),
              if (isPersonalized) ...[
                const SizedBox(height: 10),
                const Text(
                  'Сложность следующей персональной тренировки',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.read<HomeViewModel>().adjustPersonalizationDifficulty(-1),
                        child: const Text('Понизить'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.read<HomeViewModel>().adjustPersonalizationDifficulty(1),
                        child: const Text('Повысить'),
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => TrainingScreen(
                        workout: workout,
                        isDailyChallenge: false,
                        isPersonalized: isPersonalized,
                      ),
                    ),
                  );
                },
                child: const Text('Повторить тренировку'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AppShellScreen()),
                    (_) => false,
                  );
                },
                child: const Text('На главный экран'),
              ),
            ],
          ),
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
