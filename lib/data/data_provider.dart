import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'repository.dart';
import 'api_repository.dart';
import 'mock_data.dart' as mock;

class DataProvider extends ChangeNotifier {
  final DataRepository repository;

  DataProvider({required this.repository});

  bool isLoading = true;
  String? errorMessage;

  UserData? userData;
  GitHubStats? githubStats;
  LeetCodeStats? leetcodeStats;
  WakaTimeStats? wakaTimeStats;
  List<Goal> goals = [];
  WeeklyReport? weeklyReport;
  List<WeeklyGoalStat> weeklyGoalStats = [];
  List<GoalTemplate> goalTemplates = [];
  Map<String, CategoryStreak> categoryStreaks = {};
  List<AppBadge> badges = [];
  List<ActivityItem> activityFeed = [];

  // News & AI state
  List<NewsItem> newsFeed = [];
  List<TrendingRepo> trendingRepos = [];
  Map<String, List<AiInsight>> aiInsights = {};
  Map<String, String> aiSummaries = {};
  bool isLoadingNews = false;
  bool isLoadingAi = false;

  Future<void> loadAllData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final errors = <String>[];

    // ── GitHub (user + stats) ──
    try {
      final results = await Future.wait([
        repository.getUserData(),
        repository.getGitHubStats(),
      ]);
      userData = results[0] as UserData;
      githubStats = results[1] as GitHubStats;
    } catch (e) {
      debugPrint('❌ GitHub failed: $e');
      errors.add('GitHub: $e');
      userData = mock.userData;
      githubStats = mock.githubStats;
    }

    // ── LeetCode ──
    try {
      leetcodeStats = await repository.getLeetCodeStats();
    } catch (e) {
      debugPrint('❌ LeetCode failed: $e');
      errors.add('LeetCode: $e');
      leetcodeStats = mock.leetcodeStats;
    }

    // ── WakaTime ──
    try {
      wakaTimeStats = await repository.getWakaTimeStats();
    } catch (e) {
      debugPrint('❌ WakaTime failed: $e');
      errors.add('WakaTime: $e');
      wakaTimeStats = const WakaTimeStats(
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

    // ── Local-only data (always succeeds — mock) ──
    try {
      final localResults = await Future.wait([
        repository.getGoals(),
        repository.getWeeklyReport(),
        repository.getWeeklyGoalStats(),
        repository.getGoalTemplates(),
        repository.getCategoryStreaks(),
        repository.getBadges(),
        repository.getActivityFeed(),
      ]);
      goals = localResults[0] as List<Goal>;
      weeklyReport = localResults[1] as WeeklyReport;
      weeklyGoalStats = localResults[2] as List<WeeklyGoalStat>;
      goalTemplates = localResults[3] as List<GoalTemplate>;
      categoryStreaks = localResults[4] as Map<String, CategoryStreak>;
      badges = localResults[5] as List<AppBadge>;
      activityFeed = localResults[6] as List<ActivityItem>;
    } catch (e) {
      debugPrint('❌ Local data failed: $e');
      errors.add('Local: $e');
    }

    if (errors.isNotEmpty) {
      errorMessage = errors.join('\n');
      debugPrint('⚠️ Data loading completed with errors:\n$errorMessage');
    }

    isLoading = false;
    notifyListeners();
  }

  // Goal Manipulation Methods

  void toggleGoal(String id) {
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      goals[index].completed = !goals[index].completed;
      notifyListeners();
    }
  }

  void addGoal(String title, String category) {
    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      completed: false,
      category: category,
    );
    goals.insert(0, newGoal);
    notifyListeners();
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // ─── News ───

  Future<void> loadNewsFeed({String source = 'all'}) async {
    isLoadingNews = true;
    notifyListeners();
    try {
      newsFeed = await repository.getNewsFeed(source: source);
    } catch (e) {
      debugPrint('News feed error: $e');
      newsFeed = mock.newsFeed;
    }
    isLoadingNews = false;
    notifyListeners();
  }

  Future<void> loadTrendingRepos() async {
    try {
      trendingRepos = await repository.getTrendingRepos();
      notifyListeners();
    } catch (e) {
      debugPrint('Trending repos error: $e');
      trendingRepos = mock.trendingRepos;
    }
  }

  // ─── AI ───

  Future<void> loadAiInsights(String screenContext) async {
    if (aiInsights.containsKey(screenContext)) return;
    try {
      final stats = _getStatsForContext(screenContext);
      final insights = await repository.getAiInsights(screenContext, stats);
      aiInsights[screenContext] = insights;
      notifyListeners();
    } catch (e) {
      debugPrint('AI insights error for $screenContext: $e');
    }
  }

  Future<void> loadAiSummary(String screenContext) async {
    if (aiSummaries.containsKey(screenContext)) return;
    try {
      final stats = _getStatsForContext(screenContext);
      final summary = await repository.getAiSummary(screenContext, stats);
      aiSummaries[screenContext] = summary;
      notifyListeners();
    } catch (e) {
      debugPrint('AI summary error for $screenContext: $e');
    }
  }

  Future<String> chat(String message, List<ChatMessage> history) async {
    final context = <String, dynamic>{};
    if (userData != null) {
      context['github'] = {
        'todayCommits': githubStats?.todayCommits ?? 0,
        'streak': userData!.streak,
        'totalRepos': userData!.totalRepos,
        'totalStars': userData!.totalStars,
        'totalCommits': userData!.totalCommits,
      };
    }
    if (leetcodeStats != null) {
      context['leetcode'] = {
        'totalSolved': leetcodeStats!.totalSolved,
        'totalQuestions': leetcodeStats!.totalQuestions,
        'ranking': leetcodeStats!.ranking,
        'acceptanceRate': leetcodeStats!.acceptanceRate,
      };
    }
    context['goals'] = goals.map((g) => {
      'title': g.title,
      'completed': g.completed,
      'category': g.category,
    }).toList();

    return await repository.sendChatMessage(message, history, context);
  }

  Map<String, dynamic> _getStatsForContext(String context) {
    switch (context) {
      case 'dashboard':
        return {
          'streak': userData?.streak ?? 0,
          'todayCommits': githubStats?.todayCommits ?? 0,
          'totalSolved': leetcodeStats?.totalSolved ?? 0,
          'goalsCompleted': goals.where((g) => g.completed).length,
          'goalsTotal': goals.length,
        };
      case 'github':
        return {
          'todayCommits': githubStats?.todayCommits ?? 0,
          'totalCommits': userData?.totalCommits ?? 0,
          'totalRepos': userData?.totalRepos ?? 0,
          'streak': userData?.streak ?? 0,
          'weeklyCommits': githubStats?.weeklyCommits.map((w) => {'day': w.day, 'commits': w.commits}).toList() ?? [],
        };
      case 'leetcode':
        return {
          'totalSolved': leetcodeStats?.totalSolved ?? 0,
          'totalQuestions': leetcodeStats?.totalQuestions ?? 0,
          'ranking': leetcodeStats?.ranking ?? 0,
          'acceptanceRate': leetcodeStats?.acceptanceRate ?? 0,
          'easy': {'solved': leetcodeStats?.easy.solved ?? 0, 'total': leetcodeStats?.easy.total ?? 0},
          'medium': {'solved': leetcodeStats?.medium.solved ?? 0, 'total': leetcodeStats?.medium.total ?? 0},
          'hard': {'solved': leetcodeStats?.hard.solved ?? 0, 'total': leetcodeStats?.hard.total ?? 0},
        };
      case 'goals':
        return {
          'goals': goals.map((g) => {'title': g.title, 'completed': g.completed, 'category': g.category}).toList(),
          'streak': userData?.streak ?? 0,
        };
      case 'wakatime':
        return {
          'todayText': wakaTimeStats?.todayText ?? '',
          'weekText': wakaTimeStats?.weekText ?? '',
          'dailyAverage': wakaTimeStats?.dailyAverage ?? '',
          'languages': wakaTimeStats?.languages.map((l) => {'name': l.name, 'percent': l.percent}).toList() ?? [],
          'editors': wakaTimeStats?.editors.map((e) => {'name': e.name, 'text': e.text}).toList() ?? [],
        };
      default:
        return {};
    }
  }

  /// Tests connection to a given backend URL.
  Future<({bool ok, int latencyMs, String? error})?> testConnection(String url) async {
    if (repository is ApiDataRepository) {
      return (repository as ApiDataRepository).testConnection(url);
    }
    return null;
  }
}
