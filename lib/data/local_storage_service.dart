import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_stats.dart';
import '../models/workout_result.dart';

class LocalStorageService {
  static const _statsKey = 'user_stats_v1';
  static const _resultsKey = 'workout_results_v1';

  Future<UserStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsKey);
    if (raw == null) return UserStats.initial();
    return UserStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  Future<List<WorkoutResult>> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_resultsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => WorkoutResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveResults(List<WorkoutResult> results) async {
    final prefs = await SharedPreferences.getInstance();
    final list = results.map((e) => e.toJson()).toList();
    await prefs.setString(_resultsKey, jsonEncode(list));
  }
}
