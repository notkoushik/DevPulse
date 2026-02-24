import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart' as data;
import '../widgets/glass_card.dart';
import '../widgets/contribution_grid.dart';

class GitHubScreen extends StatelessWidget {
  const GitHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final stats = data.githubStats;
    final weeklyCommits = stats.weeklyCommits;
    final weekTotal =
        weeklyCommits.fold<int>(0, (sum, day) => sum + day.commits);
    final weekAvg = (weekTotal / 7).round();
    final repos = stats.recentRepos;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Header --
          Text(
            '@notkoushik',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'GitHub',
            style: GoogleFonts.instrumentSerif(
              fontSize: 28,
              fontStyle: FontStyle.italic,
              color: theme.text,
            ),
          ),
          const SizedBox(height: 20),

          // -- Key Numbers (2-column) --
          Row(
            children: [
              // Today
              Expanded(
                child: GlassCard(
                  delay: 0.1,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: theme.textDim,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '7',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 34,
                          color: theme.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'commits',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textDim,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_outward,
                            size: 10,
                            color: DevPulseColors.success,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+3 vs yesterday',
                            style: TextStyle(
                              fontSize: 10,
                              color: DevPulseColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // This Week
              Expanded(
                child: GlassCard(
                  delay: 0.2,
                  padding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 8),
                      Text(
                        '$weekTotal',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 34,
                          color: theme.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'total',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textDim,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$weekAvg/day avg',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // -- PR & Issues Row --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.call_merge,
                      size: 13,
                      color: DevPulseColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.pullRequests.merged} merged',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.error_outline,
                      size: 13,
                      color: DevPulseColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.issues.closed} closed',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${stats.pullRequests.open}',
                        style: TextStyle(
                          fontSize: 11,
                          color: DevPulseColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' open PRs',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // -- Weekly Activity Chart --
          GlassCard(
            delay: 0.3,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY ACTIVITY',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: theme.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 170,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: weeklyCommits
                              .map((d) => d.commits.toDouble())
                              .reduce((a, b) => a > b ? a : b) *
                          1.3,
                      barGroups:
                          weeklyCommits.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.commits.toDouble(),
                              color: const Color(0xFF8B72FF),
                              width: 18,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.fill,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ];
                              final index = value.toInt();
                              if (index >= 0 && index < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    days[index],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.textDim,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.textDim,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // -- Contributions Grid --
          GlassCard(
            delay: 0.4,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONTRIBUTIONS',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: theme.textMuted,
                      ),
                    ),
                    Text(
                      '90 days',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ContributionGrid(
                  contributions: data.githubStats.monthlyContributions
                      .map((c) => ContributionData(
                            date: c.date,
                            count: c.count,
                            level: c.level,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // -- Repositories List --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'REPOSITORIES',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: theme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...repos.map((repo) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.borderSubtle,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repo.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getLanguageColor(repo.language),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              repo.language,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.star,
                              size: 10,
                              color: DevPulseColors.warning,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${repo.stars}',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${repo.commits} commits',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textDim,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    repo.lastActive,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textGhost,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'javascript':
        return const Color(0xFFF7DF1E);
      case 'typescript':
        return const Color(0xFF3178C6);
      case 'python':
        return const Color(0xFF3572A5);
      case 'rust':
        return const Color(0xFFDEA584);
      case 'go':
        return const Color(0xFF00ADD8);
      case 'swift':
        return const Color(0xFFFA7343);
      case 'kotlin':
        return const Color(0xFFA97BFF);
      case 'java':
        return const Color(0xFFB07219);
      case 'c++':
        return const Color(0xFFF34B7D);
      case 'ruby':
        return const Color(0xFF701516);
      default:
        return const Color(0xFF8B72FF);
    }
  }
}
