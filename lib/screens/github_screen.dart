import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/contribution_grid.dart';

class GitHubScreen extends StatelessWidget {
  const GitHubScreen({super.key});

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

    final stats = provider.githubStats!;
    final weeklyCommits = stats.weeklyCommits;
    final weekTotal =
        weeklyCommits.fold<int>(0, (sum, day) => sum + day.commits);
    final weekAvg = (weekTotal / 7).round();
    final repos = stats.recentRepos;
    final username = provider.userData?.username ?? '';

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
                  'GitHub',
                  style: GoogleFonts.instrumentSerif(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    color: theme.text,
                  ),
                ),
                background: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    '@$username',
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
                  contributions: stats.monthlyContributions
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
                color: theme.textDim,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: repos.length,
            itemBuilder: (context, index) {
              final repo = repos[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  delay: 0.5 + (index * 0.1),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.book,
                                size: 14,
                                color: theme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                repo.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.text,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: repo.languageColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            repo.language,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.star_border,
                              size: 12, color: theme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${repo.stars}',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textMuted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            repo.lastActive,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.textGhost,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1)),
          ),
        ),
      ],
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
