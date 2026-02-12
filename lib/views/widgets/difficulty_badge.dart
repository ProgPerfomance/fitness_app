import 'package:flutter/material.dart';

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final labels = {1: 'Лёгкая', 2: 'Средняя', 3: 'Сложная'};
    final colors = {
      1: const Color(0xFF64B5F6),
      2: const Color(0xFFFFB74D),
      3: const Color(0xFFE57373),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors[level]!.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        labels[level] ?? 'Средняя',
        style: TextStyle(color: colors[level], fontWeight: FontWeight.w600),
      ),
    );
  }
}
