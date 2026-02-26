import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
//  USER
// ══════════════════════════════════════════════════════════════════

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

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        name: json['name'] ?? '',
        username: json['username'] ?? '',
        avatar: json['avatar'] ?? '',
        streak: json['streak'] ?? 0,
        longestStreak: json['longestStreak'] ?? 0,
        totalCommits: json['totalCommits'] ?? 0,
        totalRepos: json['totalRepos'] ?? 0,
        totalStars: json['totalStars'] ?? 0,
        joinedDate: json['joinedDate'] ?? '',
      );
}

// ══════════════════════════════════════════════════════════════════
//  GITHUB
// ══════════════════════════════════════════════════════════════════

class WeeklyCommit {
  final String day;
  final int commits;
  const WeeklyCommit({required this.day, required this.commits});

  factory WeeklyCommit.fromJson(Map<String, dynamic> json) => WeeklyCommit(
        day: json['day'] ?? '',
        commits: json['commits'] ?? 0,
      );
}

class Contribution {
  final String date;
  final int count;
  final int level;
  const Contribution({required this.date, required this.count, required this.level});

  factory Contribution.fromJson(Map<String, dynamic> json) => Contribution(
        date: json['date'] ?? '',
        count: json['count'] ?? 0,
        level: json['level'] ?? 0,
      );
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

  factory Repository.fromJson(Map<String, dynamic> json) {
    Color color;
    try {
      final hex = (json['languageColor'] ?? '#888888').toString().replaceAll('#', '');
      color = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      color = const Color(0xFF888888);
    }

    return Repository(
      name: json['name'] ?? '',
      language: json['language'] ?? 'Unknown',
      languageColor: color,
      stars: json['stars'] ?? 0,
      commits: json['commits'] ?? 0,
      lastActive: json['lastActive'] ?? '',
    );
  }
}

class PullRequestStats {
  final int open;
  final int merged;
  final int closed;
  const PullRequestStats({required this.open, required this.merged, required this.closed});

  factory PullRequestStats.fromJson(Map<String, dynamic> json) => PullRequestStats(
        open: json['open'] ?? 0,
        merged: json['merged'] ?? 0,
        closed: json['closed'] ?? 0,
      );
}

class IssueStats {
  final int open;
  final int closed;
  const IssueStats({required this.open, required this.closed});

  factory IssueStats.fromJson(Map<String, dynamic> json) => IssueStats(
        open: json['open'] ?? 0,
        closed: json['closed'] ?? 0,
      );
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

  factory GitHubStats.fromJson(Map<String, dynamic> json) => GitHubStats(
        todayCommits: json['todayCommits'] ?? 0,
        weeklyCommits: (json['weeklyCommits'] as List? ?? [])
            .map((e) => WeeklyCommit.fromJson(e))
            .toList(),
        monthlyContributions: (json['monthlyContributions'] as List? ?? [])
            .map((e) => Contribution.fromJson(e))
            .toList(),
        recentRepos: (json['recentRepos'] as List? ?? [])
            .map((e) => Repository.fromJson(e))
            .toList(),
        pullRequests: PullRequestStats.fromJson(json['pullRequests'] ?? {}),
        issues: IssueStats.fromJson(json['issues'] ?? {}),
      );
}

// ══════════════════════════════════════════════════════════════════
//  LEETCODE
// ══════════════════════════════════════════════════════════════════

class DifficultyCount {
  final int solved;
  final int total;
  const DifficultyCount({required this.solved, required this.total});

  factory DifficultyCount.fromJson(Map<String, dynamic> json) => DifficultyCount(
        solved: json['solved'] ?? 0,
        total: json['total'] ?? 0,
      );
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

  factory Submission.fromJson(Map<String, dynamic> json) => Submission(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        difficulty: json['difficulty'] ?? 'Medium',
        status: json['status'] ?? '',
        time: json['time'] ?? '',
        runtime: json['runtime'] ?? '',
      );
}

class WeeklyProgress {
  final String day;
  final int solved;
  const WeeklyProgress({required this.day, required this.solved});

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) => WeeklyProgress(
        day: json['day'] ?? '',
        solved: json['solved'] ?? 0,
      );
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

  factory LeetCodeStats.fromJson(Map<String, dynamic> json) => LeetCodeStats(
        totalSolved: json['totalSolved'] ?? 0,
        totalQuestions: json['totalQuestions'] ?? 0,
        ranking: json['ranking'] ?? 0,
        acceptanceRate: (json['acceptanceRate'] ?? 0).toDouble(),
        easy: DifficultyCount.fromJson(json['easy'] ?? {}),
        medium: DifficultyCount.fromJson(json['medium'] ?? {}),
        hard: DifficultyCount.fromJson(json['hard'] ?? {}),
        recentSubmissions: (json['recentSubmissions'] as List? ?? [])
            .map((e) => Submission.fromJson(e))
            .toList(),
        weeklyProgress: (json['weeklyProgress'] as List? ?? [])
            .map((e) => WeeklyProgress.fromJson(e))
            .toList(),
        contestRating: json['contestRating'] ?? 0,
        badges: json['badges'] ?? 0,
      );
}

// ══════════════════════════════════════════════════════════════════
//  WAKATIME (NEW)
// ══════════════════════════════════════════════════════════════════

class WakaLanguage {
  final String name;
  final double percent;
  final int totalSeconds;
  final String text;
  final String color;

  const WakaLanguage({
    required this.name,
    required this.percent,
    required this.totalSeconds,
    required this.text,
    required this.color,
  });

  factory WakaLanguage.fromJson(Map<String, dynamic> json) => WakaLanguage(
        name: json['name'] ?? '',
        percent: (json['percent'] ?? 0).toDouble(),
        totalSeconds: (json['totalSeconds'] ?? 0).toInt(),
        text: json['text'] ?? '',
        color: json['color'] ?? '#888888',
      );
}

class WakaEditor {
  final String name;
  final double percent;
  final String text;

  const WakaEditor({required this.name, required this.percent, required this.text});

  factory WakaEditor.fromJson(Map<String, dynamic> json) => WakaEditor(
        name: json['name'] ?? '',
        percent: (json['percent'] ?? 0).toDouble(),
        text: json['text'] ?? '',
      );
}

class WakaProject {
  final String name;
  final double percent;
  final int totalSeconds;
  final String text;

  const WakaProject({
    required this.name,
    required this.percent,
    required this.totalSeconds,
    required this.text,
  });

  factory WakaProject.fromJson(Map<String, dynamic> json) => WakaProject(
        name: json['name'] ?? '',
        percent: (json['percent'] ?? 0).toDouble(),
        totalSeconds: (json['totalSeconds'] ?? 0).toInt(),
        text: json['text'] ?? '',
      );
}

class WakaDailyTime {
  final String date;
  final int totalSeconds;
  final String text;

  const WakaDailyTime({required this.date, required this.totalSeconds, required this.text});

  factory WakaDailyTime.fromJson(Map<String, dynamic> json) => WakaDailyTime(
        date: json['date'] ?? '',
        totalSeconds: (json['totalSeconds'] ?? 0).toInt(),
        text: json['text'] ?? '',
      );
}

class WakaTimeStats {
  final String todayText;
  final int todaySeconds;
  final String weekText;
  final int weekSeconds;
  final String dailyAverage;
  final List<WakaLanguage> languages;
  final List<WakaEditor> editors;
  final List<WakaProject> projects;
  final List<WakaDailyTime> dailyCoding;

  const WakaTimeStats({
    required this.todayText,
    required this.todaySeconds,
    required this.weekText,
    required this.weekSeconds,
    required this.dailyAverage,
    required this.languages,
    required this.editors,
    required this.projects,
    required this.dailyCoding,
  });

  factory WakaTimeStats.fromJson(Map<String, dynamic> json) {
    final today = json['today'] ?? {};
    final week = json['week'] ?? {};
    return WakaTimeStats(
      todayText: today['text'] ?? '0 hrs 0 mins',
      todaySeconds: (today['totalSeconds'] ?? 0).toInt(),
      weekText: week['text'] ?? '0 hrs',
      weekSeconds: (week['totalSeconds'] ?? 0).toInt(),
      dailyAverage: week['dailyAverage'] ?? '0 hrs',
      languages: (json['languages'] as List? ?? [])
          .map((e) => WakaLanguage.fromJson(e))
          .toList(),
      editors: (json['editors'] as List? ?? [])
          .map((e) => WakaEditor.fromJson(e))
          .toList(),
      projects: (json['projects'] as List? ?? [])
          .map((e) => WakaProject.fromJson(e))
          .toList(),
      dailyCoding: (json['dailyCoding'] as List? ?? [])
          .map((e) => WakaDailyTime.fromJson(e))
          .toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  GOALS
// ══════════════════════════════════════════════════════════════════

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

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        completed: json['completed'] ?? false,
        category: json['category'] ?? '',
        date: json['date'],
      );
}

class WeeklyGoalStat {
  final String day;
  final int completed;
  final int total;
  const WeeklyGoalStat({required this.day, required this.completed, required this.total});

  factory WeeklyGoalStat.fromJson(Map<String, dynamic> json) => WeeklyGoalStat(
        day: json['day'] ?? '',
        completed: json['completed'] ?? 0,
        total: json['total'] ?? 0,
      );
}

class GoalTemplate {
  final String title;
  final String category;
  const GoalTemplate({required this.title, required this.category});

  factory GoalTemplate.fromJson(Map<String, dynamic> json) => GoalTemplate(
        title: json['title'] ?? '',
        category: json['category'] ?? '',
      );
}

class CategoryStreak {
  final int current;
  final int best;
  const CategoryStreak({required this.current, required this.best});

  factory CategoryStreak.fromJson(Map<String, dynamic> json) => CategoryStreak(
        current: json['current'] ?? 0,
        best: json['best'] ?? 0,
      );
}

// ══════════════════════════════════════════════════════════════════
//  BADGES & REPORTS
// ══════════════════════════════════════════════════════════════════

class AppBadge {
  final String id;
  final String icon;
  final String label;
  final String condition;
  final bool unlocked;
  final Color color;
  final double progress;

  const AppBadge({
    required this.id,
    required this.icon,
    required this.label,
    required this.condition,
    required this.unlocked,
    required this.color,
    required this.progress,
  });

  factory AppBadge.fromJson(Map<String, dynamic> json) {
    Color color;
    try {
      final hex = (json['color'] ?? '#888888').toString().replaceAll('#', '');
      color = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      color = const Color(0xFF888888);
    }
    return AppBadge(
      id: json['id'] ?? '',
      icon: json['icon'] ?? '🏆',
      label: json['label'] ?? '',
      condition: json['condition'] ?? '',
      unlocked: json['unlocked'] ?? false,
      color: color,
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }
}

class DayStats {
  final String day;
  final int commits;
  final int lc;
  const DayStats({required this.day, required this.commits, required this.lc});

  factory DayStats.fromJson(Map<String, dynamic> json) => DayStats(
        day: json['day'] ?? '',
        commits: json['commits'] ?? 0,
        lc: json['lc'] ?? 0,
      );
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

  factory LCSolvedBreakdown.fromJson(Map<String, dynamic> json) => LCSolvedBreakdown(
        total: json['total'] ?? 0,
        easy: json['easy'] ?? 0,
        medium: json['medium'] ?? 0,
        hard: json['hard'] ?? 0,
      );
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

  factory WeeklyReport.fromJson(Map<String, dynamic> json) => WeeklyReport(
        weekRange: json['weekRange'] ?? '',
        totalCommits: json['totalCommits'] ?? 0,
        lastWeekCommits: json['lastWeekCommits'] ?? 0,
        lcSolved: LCSolvedBreakdown.fromJson(json['lcSolved'] ?? {}),
        goalsCompleted: json['goalsCompleted'] ?? 0,
        goalsTotal: json['goalsTotal'] ?? 0,
        streak: json['streak'] ?? 0,
        bestDay: DayStats.fromJson(json['bestDay'] ?? {}),
        weakestDay: DayStats.fromJson(json['weakestDay'] ?? {}),
        tip: json['tip'] ?? '',
      );
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

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
        id: json['id'] ?? 0,
        type: json['type'] ?? '',
        message: json['message'] ?? '',
        repo: json['repo'] ?? '',
        time: json['time'] ?? '',
      );
}
