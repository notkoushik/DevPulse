import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../data/models.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';

const _difficultyColors = {
  'Easy': Color(0xFF34D1A0),
  'Medium': Color(0xFFF0C95C),
  'Hard': Color(0xFFE8646A),
};

class LeetCodeScreen extends StatelessWidget {
  const LeetCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final provider = context.watch<DataProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          'Error loading data: ${provider.errorMessage}',
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

    final stats = provider.leetcodeStats!;
    final totalProgress = (stats.totalSolved / stats.totalQuestions * 100).round();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 120.0,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'LeetCode',
                  style: GoogleFonts.instrumentSerif(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    color: theme.text,
                  ),
                ),
                background: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    'PROBLEM SOLVING',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: theme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

          // ── Total Solved Card ──
          _buildTotalSolvedCard(theme, totalProgress),
          const SizedBox(height: 12),

          // ── Difficulty Breakdown ──
          _buildDifficultyBreakdown(theme, stats),
          const SizedBox(height: 16),

          // ── Metrics Row ──
          _buildMetricsRow(theme),
          const SizedBox(height: 20),

          // ── Weekly Progress Chart ──
          _buildWeeklyProgressChart(theme, stats),
          const SizedBox(height: 20),

              // ── Recent Submissions ──
              _buildRecentSubmissions(theme, stats),
            ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1)),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSolvedCard(DevPulseTheme theme, int totalProgress) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL SOLVED',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: theme.textDim,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '342',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 42,
                        color: theme.text,
                      ),
                    ),
                    Text(
                      ' / 3250',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 12,
                      color: DevPulseColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '#48,523',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Right side - Progress Ring
            ProgressRing(
              progress: totalProgress.toDouble(),
              size: 76,
              strokeWidth: 3.5,
              color: DevPulseColors.warning,
              child: Text(
                '$totalProgress%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  color: theme.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBreakdown(
      DevPulseTheme theme, LeetCodeStats stats) {
    final difficulties = [
      {'label': 'Easy', 'solved': 187, 'total': 830},
      {'label': 'Medium', 'solved': 128, 'total': 1725},
      {'label': 'Hard', 'solved': 27, 'total': 695},
    ];

    return Row(
      children: difficulties.asMap().entries.map((entry) {
        final i = entry.key;
        final d = entry.value;
        final label = d['label'] as String;
        final solved = d['solved'] as int;
        final total = d['total'] as int;
        final pct = (solved / total * 100).round();
        final color = _difficultyColors[label]!;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 6,
              right: i == 2 ? 0 : 6,
            ),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$solved',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 22,
                                    color: theme.text,
                                  ),
                                ),
                                Text(
                                  ' / $total',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.textDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: theme.fill,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: pct / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.0,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsRow(DevPulseTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Acceptance rate
          Row(
            children: [
              Icon(Icons.trending_up, size: 12, color: DevPulseColors.success),
              const SizedBox(width: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '67.8%',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTertiary,
                      ),
                    ),
                    TextSpan(
                      text: ' acceptance',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Rating
          Row(
            children: [
              Icon(Icons.military_tech, size: 12, color: DevPulseColors.primary),
              const SizedBox(width: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '1687',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTertiary,
                      ),
                    ),
                    TextSpan(
                      text: ' rating',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Badges
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '12',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTertiary,
                  ),
                ),
                TextSpan(
                  text: ' badges',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressChart(
      DevPulseTheme theme, LeetCodeStats stats) {
    final weeklyProgress = stats.weeklyProgress;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THIS WEEK',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.5,
                color: theme.textDim,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(weeklyProgress),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dayNames.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                dayNames[index],
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.textDim,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 24,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 3,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.borderSubtle,
                        strokeWidth: 0.5,
                        dashArray: [4, 4],
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(weeklyProgress),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<WeeklyProgress> weeklyProgress) {
    if (weeklyProgress.isEmpty) return 10;
    double max = 0;
    for (final entry in weeklyProgress) {
      final val = entry.solved.toDouble();
      if (val > max) max = val;
    }
    return (max * 1.3).ceilToDouble();
  }

  List<BarChartGroupData> _buildBarGroups(
      List<WeeklyProgress> weeklyProgress) {
    return List.generate(
      weeklyProgress.length > 7 ? 7 : weeklyProgress.length,
      (index) {
        final count = weeklyProgress[index].solved.toDouble();
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count,
              color: const Color(0xFFF0C95C),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentSubmissions(
      DevPulseTheme theme, LeetCodeStats stats) {
    final submissions = stats.recentSubmissions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SUBMISSIONS',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.5,
                color: theme.textDim,
              ),
            ),
            Text(
              'All >',
              style: TextStyle(
                fontSize: 11,
                color: theme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Submission list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final submission = submissions[index];
            final accepted = submission.status == 'Accepted';
            final title = submission.title;
            final difficulty = submission.difficulty;
            final runtime = submission.runtime;
            final time = submission.time;
            final diffColor =
                _difficultyColors[difficulty] ?? const Color(0xFF34D1A0);

            return Container(
              decoration: BoxDecoration(
                border: index < submissions.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: theme.borderSubtle,
                          width: 0.5,
                        ),
                      )
                    : null,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  // Status icon
                  Icon(
                    accepted ? Icons.check_circle : Icons.cancel,
                    size: 13,
                    color: accepted
                        ? DevPulseColors.success
                        : DevPulseColors.danger,
                  ),
                  const SizedBox(width: 10),
                  // Title and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              difficulty.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                color: diffColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (accepted && runtime.isNotEmpty) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  '\u00b7',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: theme.textDim,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.schedule,
                                size: 8,
                                color: theme.textDim,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                runtime,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.textDim,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Time
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
          },
        ),
      ],
    );
  }
}
