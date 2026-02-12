import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/workout.dart';
import '../viewmodels/home_view_model.dart';
import 'custom_workout_builder_screen.dart';
import 'global_progress_screen.dart';
import 'onboarding_screen.dart';
import 'training_screen.dart';
import 'widgets/aurora_background.dart';
import 'widgets/difficulty_badge.dart';
import 'widgets/exercise_visual_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WorkoutCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final visibleWorkouts = _selectedCategory == null
            ? vm.workouts
            : vm.workouts.where((workout) => workout.category == _selectedCategory).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('HomeFit')),
          body: AuroraBackground(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _WelcomeCard(
                  level: vm.stats.level,
                  currentStreak: vm.stats.currentStreak,
                  experience: vm.stats.experience,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GlobalProgressScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (!vm.hasCompletedOnboarding) _OnboardingPromoCard(),
                if (!vm.hasCompletedOnboarding) const SizedBox(height: 16),
                if (vm.hasCompletedOnboarding && vm.personalizedWorkout != null)
                  _PersonalWorkoutCard(
                    workout: vm.personalizedWorkout!,
                    onEditTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    },
                  ),
                if (vm.hasCompletedOnboarding && vm.personalizedWorkout != null) const SizedBox(height: 16),
                _DailyCard(),
                const SizedBox(height: 18),
                _CategoryFilterBar(
                  selectedCategory: _selectedCategory,
                  onChanged: (category) => setState(() => _selectedCategory = category),
                ),
                const SizedBox(height: 14),
                Text(
                  'Выбор тренировки',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedCategory == null
                      ? 'Выберите цель: разминка, кардио или акцент на мышечную группу.'
                      : 'Категория: ${_selectedCategory!.title}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (visibleWorkouts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Для выбранной категории пока нет тренировок.'),
                    ),
                  ),
                if (visibleWorkouts.isNotEmpty) ..._buildSections(visibleWorkouts),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CustomWorkoutBuilderScreen()),
                    );
                  },
                  icon: const Icon(Icons.construction_rounded),
                  label: const Text('Собрать тренировку из упражнений'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSections(List<Workout> workouts) {
    final categories = <WorkoutCategory>[
      WorkoutCategory.warmup,
      WorkoutCategory.cardio,
      WorkoutCategory.strength,
      WorkoutCategory.core,
      WorkoutCategory.mobility,
      WorkoutCategory.mixed,
      WorkoutCategory.custom,
    ];

    if (_selectedCategory != null) {
      return workouts
          .map((workout) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WorkoutCard(workout: workout),
              ))
          .toList();
    }

    final widgets = <Widget>[];
    for (final category in categories) {
      final items = workouts.where((workout) => workout.category == category).toList();
      if (items.isEmpty) continue;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(category.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
      );
      widgets.addAll(
        items.map(
          (workout) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _WorkoutCard(workout: workout),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.selectedCategory,
    required this.onChanged,
  });

  final WorkoutCategory? selectedCategory;
  final ValueChanged<WorkoutCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    const categories = [
      WorkoutCategory.warmup,
      WorkoutCategory.cardio,
      WorkoutCategory.strength,
      WorkoutCategory.core,
      WorkoutCategory.mobility,
      WorkoutCategory.mixed,
      WorkoutCategory.custom,
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Все'),
              selected: selectedCategory == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.title),
                selected: selectedCategory == category,
                onSelected: (_) => onChanged(category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.level,
    required this.currentStreak,
    required this.experience,
    required this.onTap,
  });

  final int level;
  final int currentStreak;
  final int experience;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = (experience % 100) / 100;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
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
                    const SizedBox(height: 6),
                    Text(
                      'Нажми, чтобы увидеть глобальный прогресс тела',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
                if (vm.isDailyChallengeDone) const Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Text(workout.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              '${workout.totalDuration} мин • ~${workout.estimatedCalories} ккал • +20 XP',
              style: TextStyle(color: Colors.white.withOpacity(0.95)),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => _openWorkout(context, workout, true, false),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showWorkoutPreview(context, workout),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                DifficultyBadge(level: workout.difficulty),
              ],
            ),
            const SizedBox(height: 8),
            Text(workout.description),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.category_outlined, size: 16),
                  label: Text(workout.category.title),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.local_fire_department_outlined, size: 16),
                  label: Text('~${workout.estimatedCalories} ккал'),
                ),
                ...workout.muscleGroups.take(3).map(
                      (group) => Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(group, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 410;
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text('${workout.totalDuration} минут'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.list_alt_rounded, size: 18),
                              const SizedBox(width: 6),
                              Text('${workout.exercises.length} упражн.'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _showWorkoutPreview(context, workout),
                            icon: const Icon(Icons.visibility_outlined),
                            tooltip: 'Что внутри',
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () => _openWorkout(context, workout, false, false),
                            child: const Text('Начать'),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('${workout.totalDuration} минут'),
                    const SizedBox(width: 12),
                    const Icon(Icons.list_alt_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text('${workout.exercises.length} упражн.'),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showWorkoutPreview(context, workout),
                      icon: const Icon(Icons.visibility_outlined),
                      tooltip: 'Что внутри',
                    ),
                    FilledButton(
                      onPressed: () => _openWorkout(context, workout, false, false),
                      child: const Text('Начать'),
                    ),
                  ],
                );
              },
            ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showWorkoutPreview(BuildContext context, Workout workout) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                workout.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${workout.category.title} • ~${workout.estimatedCalories} ккал • Тренирует: ${workout.muscleGroups.join(', ')}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: workout.exercises.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final exercise = workout.exercises[index];
                  return ExerciseVisualCard(
                    exercise: exercise,
                    trailing: Text(
                      '#${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

class _OnboardingPromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF264653),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Пройти тест и получить персональную тренировку бесплатно',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Соберем нагрузку под твой уровень, оборудование и прогресс.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF264653),
              ),
              child: const Text('Пройти онбординг'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalWorkoutCard extends StatelessWidget {
  const _PersonalWorkoutCard({
    required this.workout,
    required this.onEditTap,
  });

  final Workout workout;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A9D8F),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Персональная тренировка',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Нагрузка адаптирована под тебя и текущий прогресс.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.95)),
            ),
            const SizedBox(height: 10),
            Text(
              '${workout.exercises.length} упражнений • ${workout.totalDuration} минут • ~${workout.estimatedCalories} ккал',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => _openWorkout(context, workout, false, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2A9D8F),
              ),
              child: const Text('Начать персональную'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onEditTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
              ),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Изменить параметры'),
            ),
          ],
        ),
      ),
    );
  }
}

void _openWorkout(
  BuildContext context,
  Workout workout,
  bool isDailyChallenge,
  bool isPersonalized,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TrainingScreen(
        workout: workout,
        isDailyChallenge: isDailyChallenge,
        isPersonalized: isPersonalized,
      ),
    ),
  );
}
