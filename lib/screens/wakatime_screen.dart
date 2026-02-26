import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../data/models.dart';
import '../widgets/glass_card.dart';

class WakaTimeScreen extends StatelessWidget {
  const WakaTimeScreen({super.key});

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

    final stats = provider.wakaTimeStats;
    if (stats == null) {
      return Center(
        child: Text(
          'No WakaTime data available',
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

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
                  'Coding Time',
                  style: GoogleFonts.instrumentSerif(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    color: theme.text,
                  ),
                ),
                background: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    'WAKATIME',
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

              // ── Hero: Today's Coding Time ──
              _buildTodayHero(theme, stats),
              const SizedBox(height: 12),

              // ── This Week Stats Row ──
              _buildWeekRow(theme, stats),
              const SizedBox(height: 16),

              // ── Daily Coding Chart ──
              _buildDailyChart(theme, stats),
              const SizedBox(height: 16),

              // ── Languages Breakdown ──
              if (stats.languages.isNotEmpty) ...[
                _buildLanguagesCard(theme, stats),
                const SizedBox(height: 16),
              ],

              // ── Projects List ──
              if (stats.projects.isNotEmpty) ...[
                _buildProjectsCard(theme, stats),
                const SizedBox(height: 16),
              ],

              // ── Editors ──
              if (stats.editors.isNotEmpty) ...[
                _buildEditorsCard(theme, stats),
              ],
            ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1)),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  TODAY HERO CARD
  // ══════════════════════════════════════════════════════════════
  Widget _buildTodayHero(DevPulseTheme theme, WakaTimeStats stats) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      stats.todayText,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 36,
                        color: theme.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DevPulseColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, size: 12, color: DevPulseColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 10,
                          color: DevPulseColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  WEEK STATS ROW
  // ══════════════════════════════════════════════════════════════
  Widget _buildWeekRow(DevPulseTheme theme, WakaTimeStats stats) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            delay: 0.1,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THIS WEEK',
                  style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: theme.textDim),
                ),
                const SizedBox(height: 8),
                Text(
                  stats.weekText,
                  style: GoogleFonts.jetBrainsMono(fontSize: 20, color: theme.text),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            delay: 0.2,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY AVG',
                  style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: theme.textDim),
                ),
                const SizedBox(height: 8),
                Text(
                  stats.dailyAverage,
                  style: GoogleFonts.jetBrainsMono(fontSize: 20, color: theme.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  DAILY CODING BAR CHART
  // ══════════════════════════════════════════════════════════════
  Widget _buildDailyChart(DevPulseTheme theme, WakaTimeStats stats) {
    final days = stats.dailyCoding;
    if (days.isEmpty) return const SizedBox.shrink();

    final maxSeconds = days.map((d) => d.totalSeconds).fold<int>(0, (a, b) => a > b ? a : b);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LAST 7 DAYS',
              style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: theme.textDim),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((day) {
                  final ratio = maxSeconds > 0
                      ? (day.totalSeconds / maxSeconds).clamp(0.05, 1.0)
                      : 0.05;
                  final label = day.date.length >= 10
                      ? day.date.substring(8, 10) // DD
                      : day.date;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            day.text,
                            style: TextStyle(fontSize: 8, color: theme.textMuted),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 80 * ratio,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  DevPulseColors.primary.withOpacity(0.6),
                                  DevPulseColors.primary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: TextStyle(fontSize: 9, color: theme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LANGUAGES BREAKDOWN
  // ══════════════════════════════════════════════════════════════
  Widget _buildLanguagesCard(DevPulseTheme theme, WakaTimeStats stats) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LANGUAGES',
              style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: theme.textDim),
            ),
            const SizedBox(height: 16),
            ...stats.languages.map((lang) {
              Color color;
              try {
                final hex = lang.color.replaceAll('#', '');
                color = Color(int.parse('FF$hex', radix: 16));
              } catch (_) {
                color = DevPulseColors.primary;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              lang.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.text,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${lang.percent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: lang.percent / 100,
                        backgroundColor: theme.fill2,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  PROJECTS LIST
  // ══════════════════════════════════════════════════════════════
  Widget _buildProjectsCard(DevPulseTheme theme, WakaTimeStats stats) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROJECTS',
              style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: theme.textDim),
            ),
            const SizedBox(height: 12),
            ...stats.projects.map((project) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.folder_outlined,
                            size: 14, color: DevPulseColors.warning),
                        const SizedBox(width: 8),
                        Text(
                          project.name,
                          style: TextStyle(fontSize: 13, color: theme.text),
                        ),
                      ],
                    ),
                    Text(
                      project.text,
                      style: TextStyle(fontSize: 11, color: theme.textMuted),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  EDITORS CHIPS
  // ══════════════════════════════════════════════════════════════
  Widget _buildEditorsCard(DevPulseTheme theme, WakaTimeStats stats) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EDITORS',
              style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: theme.textDim),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.editors.map((editor) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.fill2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _editorIcon(editor.name),
                        size: 14,
                        color: DevPulseColors.info,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        editor.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.text,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        editor.text,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _editorIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('code') || lower.contains('vs')) return Icons.code;
    if (lower.contains('android')) return Icons.android;
    if (lower.contains('intellij') || lower.contains('idea')) return Icons.analytics;
    if (lower.contains('vim')) return Icons.terminal;
    return Icons.edit;
  }
}
