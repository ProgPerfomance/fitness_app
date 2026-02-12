import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_view_model.dart';
import 'widgets/aurora_background.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final monthLabel = '${_monthName(_month.month)} ${_month.year}';
        final dates = _buildMonthGrid(_month);
        final monthCompleted = _countCompletedInMonth(vm, _month);
        final monthMinutes = _sumMinutesInMonth(vm, _month);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Статистика: календарь')),
          body: AuroraBackground(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Text(
                            _capitalize(monthLabel),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _LegendRow(),
                const SizedBox(height: 10),
                GridView.builder(
                  itemCount: dates.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    if (date == null) {
                      return const DecoratedBox(decoration: BoxDecoration());
                    }
                    final completed = vm.completedWorkoutsOnDate(date);
                    final minutes = vm.totalWorkoutMinutesOnDate(date);
                    return _DayCell(
                      date: date,
                      completedCount: completed,
                      minutes: minutes,
                      isToday: _isSameDay(date, DateTime.now()),
                      onTap: () => _showDayWorkouts(context, vm, date),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _Item(title: 'Выполнено за месяц', value: '$monthCompleted'),
                _Item(title: 'Минут за месяц', value: '$monthMinutes'),
                _Item(title: 'Всего тренировок', value: '${vm.stats.totalWorkouts}'),
                _Item(title: 'Общий прогресс', value: '${vm.stats.experience} XP'),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DateTime?> _buildMonthGrid(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final leading = (first.weekday + 6) % 7;
    final result = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      result.add(null);
    }
    for (var day = 1; day <= days; day++) {
      result.add(DateTime(month.year, month.month, day));
    }
    return result;
  }

  int _countCompletedInMonth(HomeViewModel vm, DateTime month) {
    return vm.results
        .where((r) => r.completed && r.date.year == month.year && r.date.month == month.month)
        .length;
  }

  int _sumMinutesInMonth(HomeViewModel vm, DateTime month) {
    return vm.results
        .where((r) => r.date.year == month.year && r.date.month == month.month)
        .fold<int>(0, (sum, r) => sum + r.totalDuration);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _monthName(int month) {
    const names = [
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    final safeIndex = (month - 1).clamp(0, 11) as int;
    return names[safeIndex];
  }

  void _showDayWorkouts(BuildContext context, HomeViewModel vm, DateTime date) {
    final workouts = vm.workoutResultsOnDate(date);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final title = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Тренировки за $title',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (workouts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('В этот день тренировок не было.'),
                ),
              if (workouts.isNotEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: workouts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return ListTile(
                        tileColor: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(vm.displayNameForWorkoutResult(workout)),
                        subtitle: Text('${workout.totalDuration} минут'),
                        trailing: Icon(
                          workout.completed ? Icons.check_circle_rounded : Icons.flag_rounded,
                          color: workout.completed ? const Color(0xFF2A9D8F) : const Color(0xFFE9C46A),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
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

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendDot(color: Color(0xFF2A9D8F), label: 'Выполнено'),
        SizedBox(width: 12),
        _LegendDot(color: Color(0xFFE9C46A), label: 'Частично'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.completedCount,
    required this.minutes,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final int completedCount;
  final int minutes;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasTraining = minutes > 0;
    final color = completedCount > 0 ? const Color(0xFF2A9D8F) : const Color(0xFFE9C46A);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isToday ? Theme.of(context).colorScheme.primary : Colors.black12,
              width: isToday ? 1.5 : 1,
            ),
            color: hasTraining ? color.withValues(alpha: 0.14) : Colors.transparent,
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.day}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (hasTraining)
                Text(
                  '${minutes}м',
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
