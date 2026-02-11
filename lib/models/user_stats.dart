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
  });

  final int totalWorkouts;
  final int totalMinutes;
  final int currentStreak;
  final int bestStreak;
  final int level;
  final int experience;
  final DateTime? lastWorkoutDate;
  final DateTime? lastDailyChallengeDate;

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
    );
  }
}
