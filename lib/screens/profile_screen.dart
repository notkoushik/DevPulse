import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../data/data_provider.dart';
import '../data/api_repository.dart';
import '../widgets/glass_card.dart';

void _showWeeklyReport(BuildContext context, dynamic report) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) {
      final t = AppTheme.of(ctx);
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 380,
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.borderSubtle),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Report',
                            style: GoogleFonts.instrumentSerif(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.weekRange,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: t.textMuted,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Icon(Icons.close, size: 20, color: t.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Streak section
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 24, color: DevPulseColors.danger),
                        const SizedBox(width: 8),
                        Text(
                          '${report.streak}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'day streak',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: t.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2x2 stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _reportStatCell(
                          t,
                          'Total Commits',
                          '${report.totalCommits}',
                          report.totalCommits - report.lastWeekCommits >= 0
                              ? '+${report.totalCommits - report.lastWeekCommits}'
                              : '${report.totalCommits - report.lastWeekCommits}',
                          report.totalCommits - report.lastWeekCommits >= 0
                              ? DevPulseColors.success
                              : DevPulseColors.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _reportStatCell(
                          t,
                          'LC Solved',
                          '${report.lcSolved.easy + report.lcSolved.medium + report.lcSolved.hard}',
                          '${report.lcSolved.easy}E · ${report.lcSolved.medium}M · ${report.lcSolved.hard}H',
                          t.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _reportStatCell(
                          t,
                          'Goals Done',
                          '${report.goalsCompleted}/${report.goalsTotal}',
                          '${((report.goalsCompleted / report.goalsTotal) * 100).round()}%',
                          DevPulseColors.success,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Best day
                  Row(
                    children: [
                      Icon(Icons.trending_up,
                          size: 16, color: DevPulseColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${report.bestDay.day} — ${report.bestDay.commits} commits, ${report.bestDay.lc} LC',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: t.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Weakest day
                  Row(
                    children: [
                      Icon(Icons.trending_down,
                          size: 16, color: DevPulseColors.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${report.weakestDay.day} — ${report.weakestDay.commits} commits, ${report.weakestDay.lc} LC',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: t.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tip
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DevPulseColors.warning.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 16, color: DevPulseColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            report.tip,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: t.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Share button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.share, size: 16, color: t.text),
                      label: Text(
                        'Share Report Card',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: t.text,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: t.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _reportStatCell(
  dynamic t,
  String label,
  String value,
  String sub,
  Color subColor,
) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: t.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: t.borderSubtle),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: t.textDim,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: t.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: subColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final provider = context.watch<DataProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.userData == null) {
      return Center(
        child: Text(
          'Error loading profile: ${provider.errorMessage ?? "Unknown"}',
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

    final user = provider.userData!;
    final lcStats = provider.leetcodeStats!;
    final badges = provider.badges;
    final report = provider.weeklyReport!;

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
                  'Profile',
                  style: GoogleFonts.instrumentSerif(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    color: theme.text,
                  ),
                ),
                background: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    'SETTINGS & STATS',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: theme.textMuted,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              // ── 1. Profile Header ──
              _buildProfileHeader(context, theme, user),
              const SizedBox(height: 24),

              // ── 2. Stats Grid ──
              _buildStatsGrid(context, theme, user, lcStats),
              const SizedBox(height: 16),

              // ── 3. Weekly Report Card ──
              _buildWeeklyReportCard(context, theme, report),
              const SizedBox(height: 16),

              // ── 4. Connected Accounts ──
              _buildConnectedAccounts(context, theme, user),
              const SizedBox(height: 16),

              // ── 5. Achievements ──
              _buildAchievements(context, theme, badges),
              const SizedBox(height: 16),

              // ── 6. Settings ──
              _buildSettings(context, theme, themeProvider),
              const SizedBox(height: 24),

              // ── 7. Footer ──
              Text(
                'DevPulse v1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: theme.textInvisible,
                ),
              ),
              const SizedBox(height: 32),
            ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1)),
          ),
        ),
      ],
    );
  }

  // ── 1. Profile Header ──
  Widget _buildProfileHeader(BuildContext context, dynamic theme, dynamic user) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: DevPulseColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              user.name.substring(0, 1),
              style: GoogleFonts.instrumentSerif(
                fontSize: 28,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Name
        Text(
          user.name,
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: theme.text,
          ),
        ),
        const SizedBox(height: 4),
        // Username
        Text(
          '@${user.username}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: theme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        // Joined date
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 11, color: theme.textDim),
            const SizedBox(width: 4),
            Text(
              'Joined March 2024',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: theme.textDim,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 2. Stats Grid ──
  Widget _buildStatsGrid(
      BuildContext context, dynamic theme, dynamic user, dynamic lcStats) {
    final provider = context.read<DataProvider>();
    final completedGoals = provider.goals.where((g) => g.completed).length;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            theme,
            Icons.local_fire_department,
            DevPulseColors.danger,
            '${user.streak}',
            'STREAK',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            theme,
            Icons.commit,
            DevPulseColors.primary,
            '${user.totalCommits}',
            'COMMITS',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            theme,
            Icons.code,
            DevPulseColors.warning,
            '${lcStats.totalSolved}',
            'SOLVED',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            theme,
            Icons.track_changes,
            DevPulseColors.success,
            '$completedGoals',
            'GOALS',
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    dynamic theme,
    IconData icon,
    Color iconColor,
    String value,
    String label,
  ) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Column(
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              color: theme.textDim,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Weekly Report Card ──
  Widget _buildWeeklyReportCard(
      BuildContext context, dynamic theme, dynamic report) {
    final commitDiff = report.totalCommits - report.lastWeekCommits;
    final totalLc =
        report.lcSolved.easy + report.lcSolved.medium + report.lcSolved.hard;
    final goalsPercent =
        ((report.goalsCompleted / report.goalsTotal) * 100).round();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY REPORT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => _showWeeklyReport(context, report),
                child: Text(
                  'Expand >',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: DevPulseColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3-column row
          Row(
            children: [
              // Commits
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${report.totalCommits}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          commitDiff >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 12,
                          color: commitDiff >= 0
                              ? DevPulseColors.success
                              : DevPulseColors.danger,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          commitDiff >= 0 ? '+$commitDiff' : '$commitDiff',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: commitDiff >= 0
                                ? DevPulseColors.success
                                : DevPulseColors.danger,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'COMMITS',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        color: theme.textDim,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // LC Solved
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$totalLc',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.lcSolved.easy}E · ${report.lcSolved.medium}M · ${report.lcSolved.hard}H',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: theme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LC SOLVED',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        color: theme.textDim,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Goals
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$goalsPercent%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.goalsCompleted}/${report.goalsTotal}',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: theme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GOALS',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        color: theme.textDim,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. Connected Accounts ──
  Widget _buildConnectedAccounts(
      BuildContext context, dynamic theme, dynamic user) {
    final provider = context.read<DataProvider>();
    final lcUsername = provider.leetcodeUsername ?? '';
    final ghUsername = provider.githubUsername?.isNotEmpty == true
        ? provider.githubUsername!
        : user.username as String;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONNECTED',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditAccountsDialog(context, theme),
                child: Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: DevPulseColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // GitHub
          _connectedAccountRow(
            theme,
            Icons.code,
            theme.text,
            'GitHub',
            '@$ghUsername',
          ),

          Container(
            height: 1,
            color: theme.borderSubtle,
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),

          // LeetCode
          _connectedAccountRow(
            theme,
            Icons.code,
            DevPulseColors.warning,
            'LeetCode',
            lcUsername.isNotEmpty ? '@$lcUsername' : 'Tap Edit to configure',
          ),
        ],
      ),
    );
  }

  void _showEditAccountsDialog(BuildContext context, dynamic theme) {
    final provider = context.read<DataProvider>();
    final githubCtrl = TextEditingController(
        text: provider.githubUsername?.isNotEmpty == true
            ? provider.githubUsername!
            : provider.userData?.username ?? '');
    final leetcodeCtrl = TextEditingController(
        text: provider.leetcodeUsername ?? '');
    final wakatimeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Connected Accounts',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.text,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _accountField(theme, 'GitHub Username', githubCtrl, 'e.g. octocat'),
                const SizedBox(height: 12),
                _accountField(theme, 'LeetCode Username', leetcodeCtrl, 'e.g. leetcoder'),
                const SizedBox(height: 12),
                _accountField(theme, 'WakaTime API Key', wakatimeCtrl, 'waka_xxxx-xxxx'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(fontSize: 13, color: theme.textMuted),
              ),
            ),
            TextButton(
              onPressed: () async {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) return;

                final updates = <String, dynamic>{
                  'id': userId,
                  'updated_at': DateTime.now().toIso8601String(),
                };
                if (githubCtrl.text.trim().isNotEmpty) {
                  updates['github_username'] = githubCtrl.text.trim();
                }
                if (leetcodeCtrl.text.trim().isNotEmpty) {
                  updates['leetcode_username'] = leetcodeCtrl.text.trim();
                }
                if (wakatimeCtrl.text.trim().isNotEmpty) {
                  updates['wakatime_api_key'] = wakatimeCtrl.text.trim();
                }

                try {
                  await Supabase.instance.client
                      .from('profiles')
                      .upsert(updates);
                  
                  await provider.repository.invalidateCache();
                  
                  if (ctx.mounted) Navigator.pop(ctx);
                  provider.loadAllData();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Save & Reload',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: DevPulseColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _accountField(
      dynamic theme, String label, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: GoogleFonts.jetBrainsMono(fontSize: 13, color: theme.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: theme.textMuted),
        hintText: hint,
        hintStyle: TextStyle(color: theme.textDim, fontSize: 12),
        filled: true,
        fillColor: theme.fill2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _connectedAccountRow(
    dynamic theme,
    IconData icon,
    Color iconColor,
    String name,
    String username,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.text,
                ),
              ),
              Text(
                username,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Connected',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: DevPulseColors.success,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.open_in_new, size: 13, color: theme.textDim),
      ],
    );
  }

  // ── 5. Achievements ──
  Widget _buildAchievements(
      BuildContext context, dynamic theme, List<dynamic> badges) {
    final unlocked = badges.where((b) => b.unlocked).toList();
    final locked = badges.where((b) => !b.unlocked).toList();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACHIEVEMENTS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.textDim,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '${unlocked.length}/${badges.length}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: theme.textDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Badge list
          ...unlocked.map((badge) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _unlockedBadgeRow(theme, badge),
              )),
          ...locked.map((badge) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _lockedBadgeRow(theme, badge),
              )),
        ],
      ),
    );
  }

  Widget _unlockedBadgeRow(dynamic theme, dynamic badge) {
    final Color badgeColor = badge.color;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: badgeColor.withOpacity(0.15)),
          ),
          child: Center(
            child: Text(
              badge.label.substring(0, 1),
              style: GoogleFonts.instrumentSerif(
                fontSize: 17,
                color: badgeColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.text,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: DevPulseColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'UNLOCKED',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: DevPulseColors.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lockedBadgeRow(dynamic theme, dynamic badge) {
    final Color badgeColor = badge.color;
    final double progress = badge.progress;

    return Opacity(
      opacity: 0.6,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withOpacity(0.15)),
            ),
            child: Center(
              child: Icon(Icons.lock, size: 16, color: theme.textDim),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.textDim,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.condition,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: theme.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 96,
                  height: 2,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.fill,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: theme.textDim,
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Settings ──
  Widget _buildSettings(
      BuildContext context, dynamic theme, ThemeProvider themeProvider) {
    final settings = [
      _SettingItem(
        icon: Icons.notifications_outlined,
        iconColor: DevPulseColors.warning,
        label: 'Notifications',
        value: 'On',
      ),
      _SettingItem(
        icon: themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
        iconColor: DevPulseColors.primary,
        label: 'Appearance',
        isThemeToggle: true,
      ),
      _SettingItem(
        icon: Icons.track_changes,
        iconColor: DevPulseColors.success,
        label: 'Daily Target',
        value: '5 goals',
      ),
      _SettingItem(
        icon: Icons.shield_outlined,
        iconColor: DevPulseColors.info,
        label: 'Privacy',
      ),
      _SettingItem(
        icon: Icons.dns_outlined,
        iconColor: DevPulseColors.warning,
        label: 'Server IP',
        isServerIP: true,
      ),
      _SettingItem(
        icon: Icons.help_outline,
        iconColor: theme.textMuted,
        label: 'Help',
      ),
      _SettingItem(
        icon: Icons.logout,
        iconColor: DevPulseColors.danger,
        label: 'Sign Out',
        isSignOut: true,
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: List.generate(settings.length, (i) {
          final item = settings[i];
          final isLast = i == settings.length - 1;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (item.isThemeToggle) {
                themeProvider.toggleTheme();
              } else if (item.isServerIP) {
                _showServerIPDialog(context, theme);
              } else if (item.isSignOut) {
                await Supabase.instance.client.auth.signOut();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(color: theme.borderSubtle),
                      ),
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 18, color: item.iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: item.isSignOut
                            ? DevPulseColors.danger
                            : theme.text,
                      ),
                    ),
                  ),
                  if (item.isThemeToggle)
                    GestureDetector(
                      onTap: () => themeProvider.toggleTheme(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DevPulseColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: DevPulseColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          themeProvider.isDark ? 'Dark' : 'Light',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: DevPulseColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else if (item.value != null)
                    Text(
                      item.value!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.textMuted,
                      ),
                    ),
                  if (!item.isSignOut) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, size: 16, color: theme.textDim),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showServerIPDialog(BuildContext context, dynamic theme) {
    final provider = context.read<DataProvider>();
    final repo = provider.repository;
    String currentUrl = '';
    if (repo is ApiDataRepository) {
      currentUrl = repo.baseUrl;
    }
    final controller = TextEditingController(text: currentUrl);

    // Mutable state for the dialog
    bool isTesting = false;
    bool? testPassed;
    String testMessage = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Server Configuration',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter the backend API base URL:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Read-only URL display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.fill2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'https://devpulse-8gkb.onrender.com/api',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: theme.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Test Connection Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: isTesting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : Icon(
                                Icons.wifi_tethering,
                                size: 16,
                                color: theme.textSecondary,
                              ),
                        label: Text(
                          isTesting ? 'Testing...' : 'Test Connection',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.textSecondary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: isTesting
                            ? null
                            : () async {
                                setDialogState(() {
                                  isTesting = true;
                                  testPassed = null;
                                  testMessage = '';
                                });
                                final result = await provider
                                    .testConnection('https://devpulse-8gkb.onrender.com/api');
                                setDialogState(() {
                                  isTesting = false;
                                  if (result == null) {
                                    testPassed = false;
                                    testMessage = 'Not using API repository';
                                  } else {
                                    testPassed = result.ok;
                                    testMessage = result.ok
                                        ? 'Connected (${result.latencyMs}ms)'
                                        : result.error ?? 'Connection failed';
                                  }
                                });
                              },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Connection Status Indicator
                    if (testPassed != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (testPassed!
                                  ? DevPulseColors.success
                                  : DevPulseColors.danger)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (testPassed!
                                    ? DevPulseColors.success
                                    : DevPulseColors.danger)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              testPassed!
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              size: 16,
                              color: testPassed!
                                  ? DevPulseColors.success
                                  : DevPulseColors.danger,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                testMessage,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: DevPulseColors.primary, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _quickIPChip(BuildContext context, TextEditingController controller,
      dynamic theme, String label, String ip) {
    return const SizedBox.shrink(); // Legacy function, no longer used
  }
}

class _SettingItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final bool isThemeToggle;
  final bool isSignOut;
  final bool isServerIP;

  _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.isThemeToggle = false,
    this.isSignOut = false,
    this.isServerIP = false,
  });
}
