// Mock data for DevPulse

export const userData = {
  name: "Koushik",
  username: "notkoushik",
  avatar: "",
  streak: 47,
  longestStreak: 52,
  totalCommits: 1284,
  totalRepos: 18,
  totalStars: 93,
  joinedDate: "2024-03-15",
};

export const githubStats = {
  todayCommits: 7,
  weeklyCommits: [
    { day: "Mon", commits: 5 },
    { day: "Tue", commits: 8 },
    { day: "Wed", commits: 3 },
    { day: "Thu", commits: 12 },
    { day: "Fri", commits: 6 },
    { day: "Sat", commits: 9 },
    { day: "Sun", commits: 7 },
  ],
  monthlyContributions: generateContributions(),
  recentRepos: [
    {
      name: "devpulse-backend",
      language: "TypeScript",
      languageColor: "#3178c6",
      stars: 12,
      commits: 34,
      lastActive: "2h ago",
    },
    {
      name: "flutter-dashboard",
      language: "Dart",
      languageColor: "#00B4AB",
      stars: 8,
      commits: 21,
      lastActive: "5h ago",
    },
    {
      name: "leetcode-solutions",
      language: "Python",
      languageColor: "#3572A5",
      stars: 45,
      commits: 156,
      lastActive: "1d ago",
    },
    {
      name: "portfolio-v3",
      language: "React",
      languageColor: "#61dafb",
      stars: 23,
      commits: 67,
      lastActive: "3d ago",
    },
    {
      name: "ml-experiments",
      language: "Jupyter",
      languageColor: "#F37626",
      stars: 5,
      commits: 12,
      lastActive: "1w ago",
    },
  ],
  pullRequests: { open: 3, merged: 28, closed: 2 },
  issues: { open: 5, closed: 42 },
};

export const leetcodeStats = {
  totalSolved: 342,
  totalQuestions: 3250,
  ranking: 48523,
  acceptanceRate: 67.8,
  easy: { solved: 142, total: 830 },
  medium: { solved: 156, total: 1720 },
  hard: { solved: 44, total: 700 },
  recentSubmissions: [
    {
      id: 1,
      title: "Two Sum",
      difficulty: "Easy",
      status: "Accepted",
      time: "2h ago",
      runtime: "76ms",
    },
    {
      id: 2,
      title: "Merge K Sorted Lists",
      difficulty: "Hard",
      status: "Accepted",
      time: "4h ago",
      runtime: "112ms",
    },
    {
      id: 3,
      title: "LRU Cache",
      difficulty: "Medium",
      status: "Accepted",
      time: "1d ago",
      runtime: "89ms",
    },
    {
      id: 4,
      title: "Binary Tree Level Order",
      difficulty: "Medium",
      status: "Wrong Answer",
      time: "1d ago",
      runtime: "—",
    },
    {
      id: 5,
      title: "Valid Parentheses",
      difficulty: "Easy",
      status: "Accepted",
      time: "2d ago",
      runtime: "56ms",
    },
  ],
  weeklyProgress: [
    { day: "Mon", solved: 3 },
    { day: "Tue", solved: 5 },
    { day: "Wed", solved: 2 },
    { day: "Thu", solved: 4 },
    { day: "Fri", solved: 6 },
    { day: "Sat", solved: 3 },
    { day: "Sun", solved: 4 },
  ],
  contestRating: 1687,
  badges: 12,
};

export const goals = [
  {
    id: "1",
    title: "Solve 3 LeetCode problems",
    completed: true,
    category: "leetcode",
    date: "2026-02-22",
  },
  {
    id: "2",
    title: "Push DevPulse backend API",
    completed: true,
    category: "github",
    date: "2026-02-22",
  },
  {
    id: "3",
    title: "Review Flutter WebSocket docs",
    completed: false,
    category: "learning",
    date: "2026-02-22",
  },
  {
    id: "4",
    title: "Write unit tests for services",
    completed: false,
    category: "github",
    date: "2026-02-22",
  },
  {
    id: "5",
    title: "Study system design patterns",
    completed: false,
    category: "learning",
    date: "2026-02-22",
  },
];

export const weeklyGoalStats = [
  { day: "Mon", completed: 4, total: 5 },
  { day: "Tue", completed: 5, total: 5 },
  { day: "Wed", completed: 3, total: 4 },
  { day: "Thu", completed: 4, total: 4 },
  { day: "Fri", completed: 2, total: 5 },
  { day: "Sat", completed: 3, total: 3 },
  { day: "Sun", completed: 2, total: 5 },
];

export const goalTemplates = [
  { title: "Solve 1 LeetCode Easy", category: "leetcode" },
  { title: "Solve 1 LeetCode Medium", category: "leetcode" },
  { title: "Push 1 commit", category: "github" },
  { title: "Read 1 tech article", category: "learning" },
  { title: "Work on portfolio 30 mins", category: "github" },
  { title: "Review yesterday's code", category: "github" },
];

export const categoryStreaks = {
  leetcode: { current: 12, best: 28 },
  github: { current: 47, best: 52 },
  learning: { current: 3, best: 14 },
};

export const badges = [
  { id: "fire7", icon: "flame", label: "On Fire", condition: "7-day streak", unlocked: true, color: "#e8646a", progress: 100 },
  { id: "consistent", icon: "zap", label: "Consistent", condition: "30-day streak", unlocked: true, color: "#f0c95c", progress: 100 },
  { id: "solver50", icon: "brain", label: "Problem Solver", condition: "50 LC solved", unlocked: true, color: "#8b72ff", progress: 100 },
  { id: "prolific", icon: "rocket", label: "Prolific", condition: "100 commits", unlocked: true, color: "#34d1a0", progress: 100 },
  { id: "century", icon: "trophy", label: "Centurion", condition: "100-day streak", unlocked: false, color: "#6ab8e8", progress: 47 },
  { id: "hard100", icon: "star", label: "Hard Grinder", condition: "100 LC Hard", unlocked: false, color: "#e8646a", progress: 44 },
  { id: "legend", icon: "diamond", label: "Legend", condition: "365-day streak", unlocked: false, color: "#f0c95c", progress: 13 },
];

export const weeklyReport = {
  weekRange: "Feb 17 – 23, 2026",
  totalCommits: 50,
  lastWeekCommits: 47,
  lcSolved: { total: 27, easy: 12, medium: 11, hard: 4 },
  goalsCompleted: 18,
  goalsTotal: 21,
  streak: 47,
  bestDay: { day: "Thursday", commits: 12, lc: 4 },
  weakestDay: { day: "Wednesday", commits: 3, lc: 2 },
  tip: "You tend to slow down mid-week. Try setting lighter goals on Wednesdays.",
};

function generateContributions() {
  const contributions: { date: string; count: number; level: number }[] = [];
  const today = new Date(2026, 1, 22);
  
  for (let i = 0; i < 91; i++) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    const count = Math.floor(Math.random() * 12);
    let level = 0;
    if (count > 0) level = 1;
    if (count > 3) level = 2;
    if (count > 6) level = 3;
    if (count > 9) level = 4;
    contributions.push({
      date: date.toISOString().split("T")[0],
      count,
      level,
    });
  }
  return contributions.reverse();
}

export const activityFeed = [
  {
    id: 1,
    type: "commit",
    message: "feat: add WebSocket connection handler",
    repo: "devpulse-backend",
    time: "32m ago",
  },
  {
    id: 2,
    type: "leetcode",
    message: "Solved: Two Sum (Easy)",
    repo: "",
    time: "2h ago",
  },
  {
    id: 3,
    type: "goal",
    message: "Completed: Solve 3 LeetCode problems",
    repo: "",
    time: "2h ago",
  },
  {
    id: 4,
    type: "commit",
    message: "fix: PostgreSQL connection pooling",
    repo: "devpulse-backend",
    time: "4h ago",
  },
  {
    id: 5,
    type: "pr",
    message: "PR merged: Add auth middleware",
    repo: "devpulse-backend",
    time: "6h ago",
  },
];
