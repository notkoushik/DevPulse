import 'models.dart';
import 'mock_data.dart' as mock;

abstract class DataRepository {
  Future<UserData> getUserData();
  Future<GitHubStats> getGitHubStats();
  Future<LeetCodeStats> getLeetCodeStats();
  Future<WakaTimeStats> getWakaTimeStats();
  Future<List<Goal>> getGoals();
  Future<WeeklyReport> getWeeklyReport();
  Future<List<WeeklyGoalStat>> getWeeklyGoalStats();
  Future<List<GoalTemplate>> getGoalTemplates();
  Future<Map<String, CategoryStreak>> getCategoryStreaks();
  Future<List<AppBadge>> getBadges();
  Future<List<ActivityItem>> getActivityFeed();

  // News
  Future<List<NewsItem>> getNewsFeed({String source = 'all'});
  Future<List<AiNewsItem>> getAiNewsFeed();
  Future<List<TrendingRepo>> getTrendingRepos();

  // AI
  Future<List<AiInsight>> getAiInsights(String context, Map<String, dynamic> stats);
  Future<String> getAiSummary(String context, Map<String, dynamic> stats);
  Future<String> sendChatMessage(String message, List<ChatMessage> history, Map<String, dynamic> context);

  // Cache
  Future<void> invalidateCache();
}

/// A repository that returns the mock data asynchronously to simulate
/// a network request. Once the backend is ready, this can easily
/// be swapped with an ApiDataRepository.
class MockDataRepository implements DataRepository {
  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<UserData> getUserData() async {
    await _delay();
    return mock.userData;
  }

  @override
  Future<GitHubStats> getGitHubStats() async {
    await _delay();
    return mock.githubStats;
  }

  @override
  Future<LeetCodeStats> getLeetCodeStats() async {
    await _delay();
    return mock.leetcodeStats;
  }

  @override
  Future<WakaTimeStats> getWakaTimeStats() async {
    await _delay();
    return const WakaTimeStats(
      todayText: '4 hrs 32 mins',
      todaySeconds: 16320,
      weekText: '28 hrs 15 mins',
      weekSeconds: 101700,
      dailyAverage: '4 hrs 2 mins',
      languages: [],
      editors: [],
      projects: [],
      dailyCoding: [],
    );
  }

  @override
  Future<List<Goal>> getGoals() async {
    await _delay();
    return List<Goal>.from(mock.goals);
  }

  @override
  Future<WeeklyReport> getWeeklyReport() async {
    await _delay();
    return mock.weeklyReport;
  }

  @override
  Future<List<WeeklyGoalStat>> getWeeklyGoalStats() async {
    await _delay();
    return mock.weeklyGoalStats;
  }

  @override
  Future<List<GoalTemplate>> getGoalTemplates() async {
    await _delay();
    return mock.goalTemplates;
  }

  @override
  Future<Map<String, CategoryStreak>> getCategoryStreaks() async {
    await _delay();
    return mock.categoryStreaks;
  }

  @override
  Future<List<AppBadge>> getBadges() async {
    await _delay();
    return mock.badges;
  }

  @override
  Future<List<ActivityItem>> getActivityFeed() async {
    await _delay();
    return mock.activityFeed;
  }

  // News
  @override
  Future<List<NewsItem>> getNewsFeed({String source = 'all'}) async {
    await _delay();
    return mock.newsFeed;
  }

  @override
  Future<List<AiNewsItem>> getAiNewsFeed() async {
    await _delay();
    return [];
  }

  @override
  Future<List<TrendingRepo>> getTrendingRepos() async {
    await _delay();
    return mock.trendingRepos;
  }

  // AI
  @override
  Future<List<AiInsight>> getAiInsights(String context, Map<String, dynamic> stats) async {
    await _delay();
    return [];
  }

  @override
  Future<String> getAiSummary(String context, Map<String, dynamic> stats) async {
    await _delay();
    return '';
  }

  @override
  Future<String> sendChatMessage(String message, List<ChatMessage> history, Map<String, dynamic> context) async {
    await _delay();
    return 'Mock AI response';
  }

  @override
  Future<void> invalidateCache() async {
    await _delay();
  }
}
