import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart' as data;
import '../data/models.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/pomodoro_timer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getMotivation(int streak, int best) {
    final gap = best - streak;
    if (gap <= 0) return "You're on your longest streak ever!";
    if (gap <= 3) return '$gap day${gap == 1 ? '' : 's'} to beat your record!';
    if (gap <= 10) return 'Only $gap days to your personal best.';
    return 'Keep going — $gap days to your all-time best.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    final streak = data.userData.streak;
    final longestStreak = data.userData.longestStreak;
    final todayCommits = data.githubStats.todayCommits;
    final yesterdayCommits = data.githubStats.weeklyCommits[5].commits;
    final totalRepos = data.userData.totalRepos;
    final totalStars = data.userData.totalStars;
    final weeklyCommits = data.githubStats.weeklyCommits;

    final lcToday = data.leetcodeStats.weeklyProgress[6].solved;
    final lcYesterday = data.leetcodeStats.weeklyProgress[5].solved;
    final totalSolved = data.leetcodeStats.totalSolved;
    final weeklyProgress = data.leetcodeStats.weeklyProgress;

    final goals = data.goals;
    final activityFeed = data.activityFeed;

    final completedGoals = goals.where((g) => g.completed).length;
    final totalGoals = goals.length;
    final goalPct =
        totalGoals > 0 ? ((completedGoals / totalGoals) * 100).round() : 0;
    final goalProgress = goalPct.toDouble();

    final streakProgress = longestStreak > 0
        ? (streak / longestStreak * 100).clamp(0.0, 100.0)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Header ──
          _buildHeader(theme),
          const SizedBox(height: 24),

          // ── 2. Daily Briefing Banner ──
          _buildDailyBriefing(
            theme,
            yesterdayCommits: yesterdayCommits,
            lcYesterday: lcYesterday,
            streak: streak,
          ),
          const SizedBox(height: 16),

          // ── 3. Streak Card ──
          _buildStreakCard(
            theme,
            streak: streak,
            longestStreak: longestStreak,
            streakProgress: streakProgress,
          ),
          const SizedBox(height: 16),

          // ── 4. Stat Tiles ──
          _buildStatTiles(
            theme,
            todayCommits: todayCommits,
            lcToday: lcToday,
            totalSolved: totalSolved,
            totalRepos: totalRepos,
            totalStars: totalStars,
            completedGoals: completedGoals,
            totalGoals: totalGoals,
          ),
          const SizedBox(height: 16),

          // ── 5. Pomodoro Quick Access ──
          _buildPomodoroQuickAccess(context, theme),
          const SizedBox(height: 16),

          // ── 6. Today's Progress ──
          _buildTodaysProgress(
            theme,
            goalProgress: goalProgress,
            goalPct: goalPct,
            todayCommits: todayCommits,
            lcToday: lcToday,
          ),
          const SizedBox(height: 16),

          // ── 7. 7-Day Activity Chart ──
          _buildWeeklyActivityChart(
            theme,
            weeklyCommits: weeklyCommits,
            weeklyProgress: weeklyProgress,
          ),
          const SizedBox(height: 24),

          // ── 8. Activity Feed ──
          _buildActivityFeed(theme, activityFeed: activityFeed),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── 1. Header ──
  Widget _buildHeader(DevPulseTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUNDAY, FEB 22',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: theme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Good evening, ${data.userData.name}',
          style: GoogleFonts.instrumentSerif(
            fontSize: 28,
            fontStyle: FontStyle.italic,
            color: theme.text,
          ),
        ),
      ],
    );
  }

  // ── 2. Daily Briefing Banner ──
  Widget _buildDailyBriefing(
    DevPulseTheme theme, {
    required int yesterdayCommits,
    required int lcYesterday,
    required int streak,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      delay: 0.1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: DevPulseColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.wb_sunny,
              size: 14,
              color: DevPulseColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yesterday: $yesterdayCommits commits · $lcYesterday LC solved',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suggestion: Solve 1 Medium problem today',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your streak is at $streak days — don\'t break it!',
                  style: const TextStyle(
                    fontSize: 11,
                    color: DevPulseColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Streak Card ──
  Widget _buildStreakCard(
    DevPulseTheme theme, {
    required int streak,
    required int longestStreak,
    required double streakProgress,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      delay: 0.2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STREAK',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: theme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$streak',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 42,
                        color: theme.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'days',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: theme.ringTrack,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Container(
                              width:
                                  constraints.maxWidth * (streakProgress / 100),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    DevPulseColors.danger,
                                    DevPulseColors.warning,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getMotivation(streak, longestStreak),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 22,
                color: DevPulseColors.danger,
              ),
              const SizedBox(height: 8),
              Text(
                'Best',
                style: TextStyle(
                  fontSize: 9,
                  color: theme.textDim,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$longestStreak',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  color: theme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. Stat Tiles ──
  Widget _buildStatTiles(
    DevPulseTheme theme, {
    required int todayCommits,
    required int lcToday,
    required int totalSolved,
    required int totalRepos,
    required int totalStars,
    required int completedGoals,
    required int totalGoals,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statTile(
            theme,
            icon: Icons.flash_on,
            iconColor: DevPulseColors.primary,
            value: '$todayCommits+$lcToday',
            label: 'TODAY',
            delay: 0.3,
          ),
          const SizedBox(width: 10),
          _statTile(
            theme,
            icon: Icons.code,
            iconColor: DevPulseColors.warning,
            value: '$totalSolved',
            label: 'LC SOLVED',
            delay: 0.35,
          ),
          const SizedBox(width: 10),
          _statTile(
            theme,
            icon: Icons.inventory_2,
            iconColor: DevPulseColors.info,
            value: '$totalRepos',
            label: null,
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 9,
                  color: theme.textDim,
                ),
                const SizedBox(width: 2),
                Text(
                  '$totalStars',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.0,
                    color: theme.textDim,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            delay: 0.4,
          ),
          const SizedBox(width: 10),
          _statTile(
            theme,
            icon: Icons.track_changes,
            iconColor: DevPulseColors.success,
            value: '$completedGoals/$totalGoals',
            label: 'GOALS',
            delay: 0.45,
          ),
        ],
      ),
    );
  }

  Widget _statTile(
    DevPulseTheme theme, {
    required IconData icon,
    required Color iconColor,
    required String value,
    String? label,
    Widget? trailingWidget,
    required double delay,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      delay: delay,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 24,
                color: theme.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.0,
                  color: theme.textDim,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }

  // ── 5. Pomodoro Quick Access ──
  Widget _buildPomodoroQuickAccess(BuildContext context, DevPulseTheme theme) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      delay: 0.5,
      onTap: () => PomodoroTimer.show(context),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DevPulseColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.timer,
              size: 18,
              color: DevPulseColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Timer',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '25 min Pomodoro session',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textDim,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: theme.textGhost,
          ),
        ],
      ),
    );
  }

  // ── 6. Today's Progress ──
  Widget _buildTodaysProgress(
    DevPulseTheme theme, {
    required double goalProgress,
    required int goalPct,
    required int todayCommits,
    required int lcToday,
  }) {
    final commitProgress = ((todayCommits / 10) * 100).clamp(0.0, 100.0);
    final lcProgress = ((lcToday / 5) * 100).clamp(0.0, 100.0);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      delay: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S PROGRESS",
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              color: theme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _progressItem(
                theme,
                progress: goalProgress,
                color: DevPulseColors.success,
                centerText: '$goalPct%',
                label: 'GOALS',
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.fill,
              ),
              _progressItem(
                theme,
                progress: commitProgress,
                color: DevPulseColors.primary,
                centerText: '$todayCommits',
                label: 'COMMITS',
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.fill,
              ),
              _progressItem(
                theme,
                progress: lcProgress,
                color: DevPulseColors.warning,
                centerText: '$lcToday',
                label: 'LC',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressItem(
    DevPulseTheme theme, {
    required double progress,
    required Color color,
    required String centerText,
    required String label,
  }) {
    return Column(
      children: [
        ProgressRing(
          progress: progress,
          size: 60,
          strokeWidth: 3,
          color: color,
          child: Text(
            centerText,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: theme.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.0,
            color: theme.textDim,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── 7. 7-Day Activity Chart ──
  Widget _buildWeeklyActivityChart(
    DevPulseTheme theme, {
    required List<WeeklyCommit> weeklyCommits,
    required List<WeeklyProgress> weeklyProgress,
  }) {
    const maxBarHeight = 72.0;
    const commitColor = Color(0xFF8B72FF);
    const lcColor = Color(0xFFF0C95C);

    // Find the max total to scale bars
    double maxTotal = 0;
    for (int i = 0; i < weeklyCommits.length; i++) {
      final commits = weeklyCommits[i].commits.toDouble();
      final lc = i < weeklyProgress.length
          ? weeklyProgress[i].solved.toDouble()
          : 0.0;
      if (commits + lc > maxTotal) maxTotal = commits + lc;
    }
    if (maxTotal == 0) maxTotal = 1;

    final todayIndex = weeklyCommits.length - 1;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      delay: 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-DAY ACTIVITY',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: theme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Details >',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(weeklyCommits.length, (index) {
              final commits = weeklyCommits[index].commits.toDouble();
              final lc = index < weeklyProgress.length
                  ? weeklyProgress[index].solved.toDouble()
                  : 0.0;
              final dayLabel = weeklyCommits[index].day;
              final isToday = index == todayIndex;

              final commitHeight = (commits / maxTotal) * maxBarHeight;
              final lcHeight = (lc / maxTotal) * maxBarHeight;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: maxBarHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (lcHeight > 0)
                              Container(
                                height: lcHeight,
                                decoration: BoxDecoration(
                                  color: lcColor
                                      .withValues(alpha: isToday ? 1.0 : 0.3),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(3),
                                    topRight: Radius.circular(3),
                                  ),
                                ),
                              ),
                            if (commitHeight > 0)
                              Container(
                                height: commitHeight,
                                decoration: BoxDecoration(
                                  color: commitColor
                                      .withValues(alpha: isToday ? 1.0 : 0.3),
                                  borderRadius: BorderRadius.only(
                                    topLeft: lcHeight > 0
                                        ? Radius.zero
                                        : const Radius.circular(3),
                                    topRight: lcHeight > 0
                                        ? Radius.zero
                                        : const Radius.circular(3),
                                    bottomLeft: const Radius.circular(3),
                                    bottomRight: const Radius.circular(3),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 9,
                          color: theme.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: commitColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Commits',
                style: TextStyle(
                  fontSize: 9,
                  color: theme.textDim,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: lcColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'LeetCode',
                style: TextStyle(
                  fontSize: 9,
                  color: theme.textDim,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 8. Activity Feed ──
  Widget _buildActivityFeed(
    DevPulseTheme theme, {
    required List<ActivityItem> activityFeed,
  }) {
    final items = activityFeed.take(4).toList();

    IconData iconForType(String type) {
      switch (type) {
        case 'commit':
          return Icons.commit;
        case 'leetcode':
          return Icons.code;
        case 'goal':
          return Icons.check_circle;
        case 'pr':
          return Icons.call_merge;
        default:
          return Icons.circle;
      }
    }

    Color colorForType(String type) {
      switch (type) {
        case 'commit':
          return DevPulseColors.primary;
        case 'leetcode':
          return DevPulseColors.warning;
        case 'goal':
          return DevPulseColors.success;
        case 'pr':
          return DevPulseColors.info;
        default:
          return DevPulseColors.primary;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ACTIVITY',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.5,
            color: theme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          final type = item.type;
          final message = item.message;
          final time = item.time;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.borderSubtle,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  iconForType(type),
                  size: 16,
                  color: colorForType(type),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTertiary,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textGhost,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
