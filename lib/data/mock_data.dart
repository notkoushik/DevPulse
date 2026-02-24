import 'package:flutter/material.dart';
import 'models.dart';

final userData = UserData(
  name: 'Koushik',
  username: 'notkoushik',
  avatar: '',
  streak: 47,
  longestStreak: 52,
  totalCommits: 1284,
  totalRepos: 18,
  totalStars: 93,
  joinedDate: '2024-03-15',
);

final githubStats = GitHubStats(
  todayCommits: 7,
  weeklyCommits: const [
    WeeklyCommit(day: 'Mon', commits: 5),
    WeeklyCommit(day: 'Tue', commits: 8),
    WeeklyCommit(day: 'Wed', commits: 3),
    WeeklyCommit(day: 'Thu', commits: 12),
    WeeklyCommit(day: 'Fri', commits: 6),
    WeeklyCommit(day: 'Sat', commits: 9),
    WeeklyCommit(day: 'Sun', commits: 7),
  ],
  monthlyContributions: _generateContributions(),
  recentRepos: const [
    Repository(
      name: 'devpulse-backend',
      language: 'TypeScript',
      languageColor: Color(0xFF3178C6),
      stars: 12,
      commits: 34,
      lastActive: '2h ago',
    ),
    Repository(
      name: 'flutter-dashboard',
      language: 'Dart',
      languageColor: Color(0xFF00B4AB),
      stars: 8,
      commits: 21,
      lastActive: '5h ago',
    ),
    Repository(
      name: 'leetcode-solutions',
      language: 'Python',
      languageColor: Color(0xFF3572A5),
      stars: 45,
      commits: 156,
      lastActive: '1d ago',
    ),
    Repository(
      name: 'portfolio-v3',
      language: 'React',
      languageColor: Color(0xFF61DAFB),
      stars: 23,
      commits: 67,
      lastActive: '3d ago',
    ),
    Repository(
      name: 'ml-experiments',
      language: 'Jupyter',
      languageColor: Color(0xFFF37626),
      stars: 5,
      commits: 12,
      lastActive: '1w ago',
    ),
  ],
  pullRequests: const PullRequestStats(open: 3, merged: 28, closed: 2),
  issues: const IssueStats(open: 5, closed: 42),
);

final leetcodeStats = LeetCodeStats(
  totalSolved: 342,
  totalQuestions: 3250,
  ranking: 48523,
  acceptanceRate: 67.8,
  easy: const DifficultyCount(solved: 142, total: 830),
  medium: const DifficultyCount(solved: 156, total: 1720),
  hard: const DifficultyCount(solved: 44, total: 700),
  recentSubmissions: const [
    Submission(
      id: 1,
      title: 'Two Sum',
      difficulty: 'Easy',
      status: 'Accepted',
      time: '2h ago',
      runtime: '76ms',
    ),
    Submission(
      id: 2,
      title: 'Merge K Sorted Lists',
      difficulty: 'Hard',
      status: 'Accepted',
      time: '4h ago',
      runtime: '112ms',
    ),
    Submission(
      id: 3,
      title: 'LRU Cache',
      difficulty: 'Medium',
      status: 'Accepted',
      time: '1d ago',
      runtime: '89ms',
    ),
    Submission(
      id: 4,
      title: 'Binary Tree Level Order',
      difficulty: 'Medium',
      status: 'Wrong Answer',
      time: '1d ago',
      runtime: '—',
    ),
    Submission(
      id: 5,
      title: 'Valid Parentheses',
      difficulty: 'Easy',
      status: 'Accepted',
      time: '2d ago',
      runtime: '56ms',
    ),
  ],
  weeklyProgress: const [
    WeeklyProgress(day: 'Mon', solved: 3),
    WeeklyProgress(day: 'Tue', solved: 5),
    WeeklyProgress(day: 'Wed', solved: 2),
    WeeklyProgress(day: 'Thu', solved: 4),
    WeeklyProgress(day: 'Fri', solved: 6),
    WeeklyProgress(day: 'Sat', solved: 3),
    WeeklyProgress(day: 'Sun', solved: 4),
  ],
  contestRating: 1687,
  badges: 12,
);

final goals = [
  Goal(
    id: '1',
    title: 'Solve 3 LeetCode problems',
    completed: true,
    category: 'leetcode',
    date: '2026-02-22',
  ),
  Goal(
    id: '2',
    title: 'Push DevPulse backend API',
    completed: true,
    category: 'github',
    date: '2026-02-22',
  ),
  Goal(
    id: '3',
    title: 'Review Flutter WebSocket docs',
    completed: false,
    category: 'learning',
    date: '2026-02-22',
  ),
  Goal(
    id: '4',
    title: 'Write unit tests for services',
    completed: false,
    category: 'github',
    date: '2026-02-22',
  ),
  Goal(
    id: '5',
    title: 'Study system design patterns',
    completed: false,
    category: 'learning',
    date: '2026-02-22',
  ),
];

const weeklyGoalStats = [
  WeeklyGoalStat(day: 'Mon', completed: 4, total: 5),
  WeeklyGoalStat(day: 'Tue', completed: 5, total: 5),
  WeeklyGoalStat(day: 'Wed', completed: 3, total: 4),
  WeeklyGoalStat(day: 'Thu', completed: 4, total: 4),
  WeeklyGoalStat(day: 'Fri', completed: 2, total: 5),
  WeeklyGoalStat(day: 'Sat', completed: 3, total: 3),
  WeeklyGoalStat(day: 'Sun', completed: 2, total: 5),
];

const goalTemplates = [
  GoalTemplate(title: 'Solve 1 LeetCode Easy', category: 'leetcode'),
  GoalTemplate(title: 'Solve 1 LeetCode Medium', category: 'leetcode'),
  GoalTemplate(title: 'Push 1 commit', category: 'github'),
  GoalTemplate(title: 'Read 1 tech article', category: 'learning'),
  GoalTemplate(title: 'Work on portfolio 30 mins', category: 'github'),
  GoalTemplate(title: "Review yesterday's code", category: 'github'),
];

const categoryStreaks = {
  'leetcode': CategoryStreak(current: 12, best: 28),
  'github': CategoryStreak(current: 47, best: 52),
  'learning': CategoryStreak(current: 3, best: 14),
};

const badges = [
  AppBadge(id: 'fire7', icon: 'flame', label: 'On Fire', condition: '7-day streak', unlocked: true, color: Color(0xFFE8646A), progress: 100),
  AppBadge(id: 'consistent', icon: 'zap', label: 'Consistent', condition: '30-day streak', unlocked: true, color: Color(0xFFF0C95C), progress: 100),
  AppBadge(id: 'solver50', icon: 'brain', label: 'Problem Solver', condition: '50 LC solved', unlocked: true, color: Color(0xFF8B72FF), progress: 100),
  AppBadge(id: 'prolific', icon: 'rocket', label: 'Prolific', condition: '100 commits', unlocked: true, color: Color(0xFF34D1A0), progress: 100),
  AppBadge(id: 'century', icon: 'trophy', label: 'Centurion', condition: '100-day streak', unlocked: false, color: Color(0xFF6AB8E8), progress: 47),
  AppBadge(id: 'hard100', icon: 'star', label: 'Hard Grinder', condition: '100 LC Hard', unlocked: false, color: Color(0xFFE8646A), progress: 44),
  AppBadge(id: 'legend', icon: 'diamond', label: 'Legend', condition: '365-day streak', unlocked: false, color: Color(0xFFF0C95C), progress: 13),
];

const weeklyReport = WeeklyReport(
  weekRange: 'Feb 17 – 23, 2026',
  totalCommits: 50,
  lastWeekCommits: 47,
  lcSolved: LCSolvedBreakdown(total: 27, easy: 12, medium: 11, hard: 4),
  goalsCompleted: 18,
  goalsTotal: 21,
  streak: 47,
  bestDay: DayStats(day: 'Thursday', commits: 12, lc: 4),
  weakestDay: DayStats(day: 'Wednesday', commits: 3, lc: 2),
  tip: 'You tend to slow down mid-week. Try setting lighter goals on Wednesdays.',
);

const activityFeed = [
  ActivityItem(id: 1, type: 'commit', message: 'feat: add WebSocket connection handler', repo: 'devpulse-backend', time: '32m ago'),
  ActivityItem(id: 2, type: 'leetcode', message: 'Solved: Two Sum (Easy)', repo: '', time: '2h ago'),
  ActivityItem(id: 3, type: 'goal', message: 'Completed: Solve 3 LeetCode problems', repo: '', time: '2h ago'),
  ActivityItem(id: 4, type: 'commit', message: 'fix: PostgreSQL connection pooling', repo: 'devpulse-backend', time: '4h ago'),
  ActivityItem(id: 5, type: 'pr', message: 'PR merged: Add auth middleware', repo: 'devpulse-backend', time: '6h ago'),
];

List<Contribution> _generateContributions() {
  final contributions = <Contribution>[];
  final today = DateTime(2026, 2, 22);

  for (int i = 0; i < 91; i++) {
    final date = today.subtract(Duration(days: i));
    final count = (date.day * 7 + date.month * 3 + i) % 12;
    int level = 0;
    if (count > 0) level = 1;
    if (count > 3) level = 2;
    if (count > 6) level = 3;
    if (count > 9) level = 4;
    contributions.add(Contribution(
      date: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      count: count,
      level: level,
    ));
  }
  return contributions.reversed.toList();
}
