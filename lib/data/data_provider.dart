import 'package:flutter/material.dart';
import 'models.dart';
import 'repository.dart';

class DataProvider extends ChangeNotifier {
  final DataRepository repository;

  DataProvider({required this.repository}) {
    // Automatically load data when instantiated
    loadAllData();
  }

  bool isLoading = true;
  String? errorMessage;

  UserData? userData;
  GitHubStats? githubStats;
  LeetCodeStats? leetcodeStats;
  List<Goal> goals = [];
  WeeklyReport? weeklyReport;
  List<WeeklyGoalStat> weeklyGoalStats = [];
  List<GoalTemplate> goalTemplates = [];
  Map<String, CategoryStreak> categoryStreaks = {};
  List<AppBadge> badges = [];
  List<ActivityItem> activityFeed = [];

  Future<void> loadAllData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Fetch all data concurrently
      final results = await Future.wait([
        repository.getUserData(),
        repository.getGitHubStats(),
        repository.getLeetCodeStats(),
        repository.getGoals(),
        repository.getWeeklyReport(),
        repository.getWeeklyGoalStats(),
        repository.getGoalTemplates(),
        repository.getCategoryStreaks(),
        repository.getBadges(),
        repository.getActivityFeed(),
      ]);

      userData = results[0] as UserData;
      githubStats = results[1] as GitHubStats;
      leetcodeStats = results[2] as LeetCodeStats;
      goals = results[3] as List<Goal>;
      weeklyReport = results[4] as WeeklyReport;
      weeklyGoalStats = results[5] as List<WeeklyGoalStat>;
      goalTemplates = results[6] as List<GoalTemplate>;
      categoryStreaks = results[7] as Map<String, CategoryStreak>;
      badges = results[8] as List<AppBadge>;
      activityFeed = results[9] as List<ActivityItem>;

    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
    goals.insert(0, newGoal); // Add to top usually makes sense
    notifyListeners();
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }
}
