import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  Future<String> _getToken() async {
    final auth = Supabase.instance.client.auth;
    var session = auth.currentSession;
    if (session != null && session.isExpired) {
      try {
        final res = await auth.refreshSession();
        session = res.session;
      } catch (e) {
        debugPrint('Token refresh failed: $e');
      }
    }
    return session?.accessToken ?? '';
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final token = await _getToken();

    debugPrint('🔗 API → $baseUrl$path (token: ${token.isNotEmpty ? "${token.substring(0, 20)}..." : "EMPTY"})');

    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('📡 API ← ${response.statusCode} for $path');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('API ${response.statusCode}: $path — ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
  }

  Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body) async {
    final token = await _getToken();

    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('API ${response.statusCode}: $path');
  }

  // ─── GitHub ───

  @override
  Future<UserData> getUserData() async {
    final data = await _getJson('/github/stats');
    return UserData.fromJson(data['user'] ?? {});
  }

  @override
  Future<GitHubStats> getGitHubStats() async {
    final data = await _getJson('/github/stats');
    return GitHubStats.fromJson(data['stats'] ?? {});
  }

  // ─── LeetCode ───

  @override
  Future<LeetCodeStats> getLeetCodeStats() async {
    final data = await _getJson('/leetcode/stats');
    return LeetCodeStats.fromJson(data);
  }

  // ─── WakaTime ───

  @override
  Future<WakaTimeStats> getWakaTimeStats() async {
    final data = await _getJson('/wakatime/stats');
    return WakaTimeStats.fromJson(data);
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

  // ─── News ───

  @override
  Future<List<NewsItem>> getNewsFeed({String source = 'all'}) async {
    final data = await _getJson('/news/feed?source=$source');
    return (data['items'] as List? ?? [])
        .map((e) => NewsItem.fromJson(e))
        .toList();
  }

  @override
  Future<List<AiNewsItem>> getAiNewsFeed() async {
    final data = await _getJson('/news/ai-feed');
    return (data['items'] as List? ?? [])
        .map((e) => AiNewsItem.fromJson(e))
        .toList();
  }

  @override
  Future<List<TrendingRepo>> getTrendingRepos() async {
    final data = await _getJson('/news/trending');
    return (data['repos'] as List? ?? [])
        .map((e) => TrendingRepo.fromJson(e))
        .toList();
  }

  // ─── AI ───

  @override
  Future<List<AiInsight>> getAiInsights(String context, Map<String, dynamic> stats) async {
    final data = await _postJson('/ai/insights', {
      'context': context,
      'stats': stats,
    });
    return (data['insights'] as List? ?? [])
        .map((e) => AiInsight.fromJson(e))
        .toList();
  }

  @override
  Future<String> getAiSummary(String context, Map<String, dynamic> stats) async {
    final data = await _postJson('/ai/summary', {
      'context': context,
      'stats': stats,
    });
    return data['summary'] ?? '';
  }

  @override
  Future<String> sendChatMessage(
    String message,
    List<ChatMessage> history,
    Map<String, dynamic> context,
  ) async {
    final data = await _postJson('/ai/chat', {
      'message': message,
      'history': history.map((h) => {'role': h.role, 'content': h.content}).toList(),
      'context': context,
    });
    return data['reply'] ?? '';
  }

  // ─── Connection Test ───

  /// Tests connectivity to a backend URL by hitting the unauthenticated /health endpoint.
  Future<({bool ok, int latencyMs, String? error})> testConnection(String url) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _client.get(
        Uri.parse('$url/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      stopwatch.stop();

      if (response.statusCode == 200) {
        return (ok: true, latencyMs: stopwatch.elapsedMilliseconds, error: null);
      }
      return (
        ok: false,
        latencyMs: stopwatch.elapsedMilliseconds,
        error: 'HTTP ${response.statusCode}',
      );
    } on TimeoutException {
      stopwatch.stop();
      return (ok: false, latencyMs: stopwatch.elapsedMilliseconds, error: 'Connection timed out (5s)');
    } catch (e) {
      stopwatch.stop();
      return (ok: false, latencyMs: stopwatch.elapsedMilliseconds, error: e.toString());
    }
  }
}

