import 'models.dart';
import 'mock_data.dart' as mock;

abstract class DataRepository {
  Future<UserData> getUserData();
  Future<GitHubStats> getGitHubStats();
  Future<LeetCodeStats> getLeetCodeStats();
  Future<List<Goal>> getGoals();
  Future<WeeklyReport> getWeeklyReport();
  Future<List<WeeklyGoalStat>> getWeeklyGoalStats();
  Future<List<GoalTemplate>> getGoalTemplates();
  Future<Map<String, CategoryStreak>> getCategoryStreaks();
  Future<List<AppBadge>> getBadges();
  Future<List<ActivityItem>> getActivityFeed();
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
  Future<List<Goal>> getGoals() async {
    await _delay();
    // Return a copy so we can mutate it safely
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
}
