class UserStats {
  const UserStats({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.currentStreak,
    required this.bestStreak,
    required this.level,
    required this.experience,
    this.lastWorkoutDate,
    this.lastDailyChallengeDate,
    required this.onboardingCompleted,
    this.heightCm,
    this.weightKg,
    this.equipment = const [],
    this.maxPushUps,
    this.maxSquats,
    this.plankSeconds,
    this.age,
    this.trainingDaysPerWeek,
    this.goal,
    this.hasInjuries = false,
    this.personalizationOffset = 0,
  });

  final int totalWorkouts;
  final int totalMinutes;
  final int currentStreak;
  final int bestStreak;
  final int level;
  final int experience;
  final DateTime? lastWorkoutDate;
  final DateTime? lastDailyChallengeDate;
  final bool onboardingCompleted;
  final int? heightCm;
  final double? weightKg;
  final List<String> equipment;
  final int? maxPushUps;
  final int? maxSquats;
  final int? plankSeconds;
  final int? age;
  final int? trainingDaysPerWeek;
  final String? goal;
  final bool hasInjuries;
  final int personalizationOffset;

  int get xpToNextLevel => 100 - (experience % 100);

  UserStats copyWith({
    int? totalWorkouts,
    int? totalMinutes,
    int? currentStreak,
    int? bestStreak,
    int? level,
    int? experience,
    DateTime? lastWorkoutDate,
    DateTime? lastDailyChallengeDate,
    bool? onboardingCompleted,
    int? heightCm,
    double? weightKg,
    List<String>? equipment,
    int? maxPushUps,
    int? maxSquats,
    int? plankSeconds,
    int? age,
    int? trainingDaysPerWeek,
    String? goal,
    bool? hasInjuries,
    int? personalizationOffset,
    bool clearLastWorkoutDate = false,
    bool clearLastDailyChallengeDate = false,
  }) {
    return UserStats(
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      lastWorkoutDate: clearLastWorkoutDate
          ? null
          : (lastWorkoutDate ?? this.lastWorkoutDate),
      lastDailyChallengeDate: clearLastDailyChallengeDate
          ? null
          : (lastDailyChallengeDate ?? this.lastDailyChallengeDate),
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      equipment: equipment ?? this.equipment,
      maxPushUps: maxPushUps ?? this.maxPushUps,
      maxSquats: maxSquats ?? this.maxSquats,
      plankSeconds: plankSeconds ?? this.plankSeconds,
      age: age ?? this.age,
      trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
      goal: goal ?? this.goal,
      hasInjuries: hasInjuries ?? this.hasInjuries,
      personalizationOffset: personalizationOffset ?? this.personalizationOffset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWorkouts': totalWorkouts,
      'totalMinutes': totalMinutes,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'level': level,
      'experience': experience,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
      'lastDailyChallengeDate': lastDailyChallengeDate?.toIso8601String(),
      'onboardingCompleted': onboardingCompleted,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'equipment': equipment,
      'maxPushUps': maxPushUps,
      'maxSquats': maxSquats,
      'plankSeconds': plankSeconds,
      'age': age,
      'trainingDaysPerWeek': trainingDaysPerWeek,
      'goal': goal,
      'hasInjuries': hasInjuries,
      'personalizationOffset': personalizationOffset,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWorkouts: json['totalWorkouts'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.parse(json['lastWorkoutDate'] as String)
          : null,
      lastDailyChallengeDate: json['lastDailyChallengeDate'] != null
          ? DateTime.parse(json['lastDailyChallengeDate'] as String)
          : null,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      heightCm: json['heightCm'] as int?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      equipment: ((json['equipment'] as List<dynamic>?) ?? const [])
          .map((item) => item as String)
          .toList(),
      maxPushUps: json['maxPushUps'] as int?,
      maxSquats: json['maxSquats'] as int?,
      plankSeconds: json['plankSeconds'] as int?,
      age: json['age'] as int?,
      trainingDaysPerWeek: json['trainingDaysPerWeek'] as int?,
      goal: json['goal'] as String?,
      hasInjuries: json['hasInjuries'] as bool? ?? false,
      personalizationOffset: json['personalizationOffset'] as int? ?? 0,
    );
  }

  factory UserStats.initial() {
    return const UserStats(
      totalWorkouts: 0,
      totalMinutes: 0,
      currentStreak: 0,
      bestStreak: 0,
      level: 1,
      experience: 0,
      onboardingCompleted: false,
    );
  }
}
