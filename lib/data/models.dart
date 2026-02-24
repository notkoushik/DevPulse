import 'package:flutter/material.dart';

class UserData {
  final String name;
  final String username;
  final String avatar;
  final int streak;
  final int longestStreak;
  final int totalCommits;
  final int totalRepos;
  final int totalStars;
  final String joinedDate;

  const UserData({
    required this.name,
    required this.username,
    required this.avatar,
    required this.streak,
    required this.longestStreak,
    required this.totalCommits,
    required this.totalRepos,
    required this.totalStars,
    required this.joinedDate,
  });
}

class WeeklyCommit {
  final String day;
  final int commits;

  const WeeklyCommit({required this.day, required this.commits});
}

class Contribution {
  final String date;
  final int count;
  final int level;

  const Contribution({
    required this.date,
    required this.count,
    required this.level,
  });
}

class Repository {
  final String name;
  final String language;
  final Color languageColor;
  final int stars;
  final int commits;
  final String lastActive;

  const Repository({
    required this.name,
    required this.language,
    required this.languageColor,
    required this.stars,
    required this.commits,
    required this.lastActive,
  });
}

class PullRequestStats {
  final int open;
  final int merged;
  final int closed;

  const PullRequestStats({
    required this.open,
    required this.merged,
    required this.closed,
  });
}

class IssueStats {
  final int open;
  final int closed;

  const IssueStats({required this.open, required this.closed});
}

class GitHubStats {
  final int todayCommits;
  final List<WeeklyCommit> weeklyCommits;
  final List<Contribution> monthlyContributions;
  final List<Repository> recentRepos;
  final PullRequestStats pullRequests;
  final IssueStats issues;

  const GitHubStats({
    required this.todayCommits,
    required this.weeklyCommits,
    required this.monthlyContributions,
    required this.recentRepos,
    required this.pullRequests,
    required this.issues,
  });
}

class DifficultyCount {
  final int solved;
  final int total;

  const DifficultyCount({required this.solved, required this.total});
}

class Submission {
  final int id;
  final String title;
  final String difficulty;
  final String status;
  final String time;
  final String runtime;

  const Submission({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.status,
    required this.time,
    required this.runtime,
  });
}

class WeeklyProgress {
  final String day;
  final int solved;

  const WeeklyProgress({required this.day, required this.solved});
}

class LeetCodeStats {
  final int totalSolved;
  final int totalQuestions;
  final int ranking;
  final double acceptanceRate;
  final DifficultyCount easy;
  final DifficultyCount medium;
  final DifficultyCount hard;
  final List<Submission> recentSubmissions;
  final List<WeeklyProgress> weeklyProgress;
  final int contestRating;
  final int badges;

  const LeetCodeStats({
    required this.totalSolved,
    required this.totalQuestions,
    required this.ranking,
    required this.acceptanceRate,
    required this.easy,
    required this.medium,
    required this.hard,
    required this.recentSubmissions,
    required this.weeklyProgress,
    required this.contestRating,
    required this.badges,
  });
}

class Goal {
  final String id;
  final String title;
  bool completed;
  final String category;
  final String? date;

  Goal({
    required this.id,
    required this.title,
    required this.completed,
    required this.category,
    this.date,
  });
}

class WeeklyGoalStat {
  final String day;
  final int completed;
  final int total;

  const WeeklyGoalStat({
    required this.day,
    required this.completed,
    required this.total,
  });
}

class GoalTemplate {
  final String title;
  final String category;

  const GoalTemplate({required this.title, required this.category});
}

class CategoryStreak {
  final int current;
  final int best;

  const CategoryStreak({required this.current, required this.best});
}

class AppBadge {
  final String id;
  final String icon;
  final String label;
  final String condition;
  final bool unlocked;
  final Color color;
  final int progress;

  const AppBadge({
    required this.id,
    required this.icon,
    required this.label,
    required this.condition,
    required this.unlocked,
    required this.color,
    required this.progress,
  });
}

class DayStats {
  final String day;
  final int commits;
  final int lc;

  const DayStats({required this.day, required this.commits, required this.lc});
}

class LCSolvedBreakdown {
  final int total;
  final int easy;
  final int medium;
  final int hard;

  const LCSolvedBreakdown({
    required this.total,
    required this.easy,
    required this.medium,
    required this.hard,
  });
}

class WeeklyReport {
  final String weekRange;
  final int totalCommits;
  final int lastWeekCommits;
  final LCSolvedBreakdown lcSolved;
  final int goalsCompleted;
  final int goalsTotal;
  final int streak;
  final DayStats bestDay;
  final DayStats weakestDay;
  final String tip;

  const WeeklyReport({
    required this.weekRange,
    required this.totalCommits,
    required this.lastWeekCommits,
    required this.lcSolved,
    required this.goalsCompleted,
    required this.goalsTotal,
    required this.streak,
    required this.bestDay,
    required this.weakestDay,
    required this.tip,
  });
}

class ActivityItem {
  final int id;
  final String type;
  final String message;
  final String repo;
  final String time;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.message,
    required this.repo,
    required this.time,
  });
}
