import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_view_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<HomeViewModel>().stats;

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Item(title: 'Всего тренировок', value: '${stats.totalWorkouts}'),
          _Item(title: 'Всего минут', value: '${stats.totalMinutes}'),
          _Item(title: 'Текущая серия', value: '${stats.currentStreak}'),
          _Item(title: 'Лучший результат', value: '${stats.bestStreak}'),
          _Item(title: 'Уровень пользователя', value: '${stats.level}'),
          _Item(title: 'Опыт', value: '${stats.experience} XP'),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
