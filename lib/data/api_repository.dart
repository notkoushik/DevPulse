import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';
import 'repository.dart';
import 'mock_data.dart' as mock;

/// Repository that fetches real data from DevPulse backend API.
/// Falls back to mock data for endpoints that aren't backed by the server
/// (goals, weekly reports, badges, etc.)
class ApiDataRepository implements DataRepository {
  String baseUrl;
  final http.Client _client;

  ApiDataRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _getJson(String path) async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('API call failed: ${response.statusCode} — $path');
  }

  // ─── GitHub ───

  @override
  Future<UserData> getUserData() async {
    try {
      final data = await _getJson('/github/stats');
      return UserData.fromJson(data['user'] ?? {});
    } catch (_) {
      return mock.userData;
    }
  }

  @override
  Future<GitHubStats> getGitHubStats() async {
    try {
      final data = await _getJson('/github/stats');
      return GitHubStats.fromJson(data['stats'] ?? {});
    } catch (_) {
      return mock.githubStats;
    }
  }

  // ─── LeetCode ───

  @override
  Future<LeetCodeStats> getLeetCodeStats() async {
    try {
      final data = await _getJson('/leetcode/stats');
      return LeetCodeStats.fromJson(data);
    } catch (_) {
      return mock.leetcodeStats;
    }
  }

  // ─── WakaTime ───

  @override
  Future<WakaTimeStats> getWakaTimeStats() async {
    try {
      final data = await _getJson('/wakatime/stats');
      return WakaTimeStats.fromJson(data);
    } catch (_) {
      return const WakaTimeStats(
        todayText: '0 hrs 0 mins',
        todaySeconds: 0,
        weekText: '0 hrs',
        weekSeconds: 0,
        dailyAverage: '0 hrs',
        languages: [],
        editors: [],
        projects: [],
        dailyCoding: [],
      );
    }
  }

  // ─── Local-only data (Goals, Reports, Badges) ───
  // These remain mock for now; they'll be persisted locally or
  // via a separate backend in the future.

  @override
  Future<List<Goal>> getGoals() async => List<Goal>.from(mock.goals);

  @override
  Future<WeeklyReport> getWeeklyReport() async => mock.weeklyReport;

  @override
  Future<List<WeeklyGoalStat>> getWeeklyGoalStats() async => mock.weeklyGoalStats;

  @override
  Future<List<GoalTemplate>> getGoalTemplates() async => mock.goalTemplates;

  @override
  Future<Map<String, CategoryStreak>> getCategoryStreaks() async => mock.categoryStreaks;

  @override
  Future<List<AppBadge>> getBadges() async => mock.badges;

  @override
  Future<List<ActivityItem>> getActivityFeed() async => mock.activityFeed;
}
