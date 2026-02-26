import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import 'dashboard_screen.dart';
import 'github_screen.dart';
import 'leetcode_screen.dart';
import 'wakatime_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final _screens = const [
    DashboardScreen(),
    GitHubScreen(),
    LeetCodeScreen(),
    WakaTimeScreen(),
    GoalsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final provider = context.watch<DataProvider>();

    Color auraColor = DevPulseColors.primary;
    if (!provider.isLoading && provider.userData != null) {
      if (_currentIndex == 1) {
        final commits = provider.githubStats?.todayCommits ?? 0;
        auraColor = commits > 2 ? DevPulseColors.success : DevPulseColors.primary;
      } else if (_currentIndex == 2) {
        final solved = provider.leetcodeStats?.weeklyProgress.last.solved ?? 0;
        auraColor = solved > 0 ? DevPulseColors.warning : DevPulseColors.primary;
      } else if (_currentIndex == 3) {
        auraColor = DevPulseColors.info; // WakaTime
      } else if (_currentIndex == 4) {
        auraColor = DevPulseColors.danger; // Goals
      } else if (_currentIndex == 5) {
        auraColor = DevPulseColors.info; // Profile
      }
    }

    return Scaffold(
      backgroundColor: theme.bg,
      body: Stack(
        children: [
          // Dynamic Background Aura
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            top: -150,
            left: (_currentIndex * 60.0) - 100,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    auraColor.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              physics: const BouncingScrollPhysics(),
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i != _currentIndex) {
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        },
        theme: theme,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

const _navItems = [
  _NavItem(icon: Icons.dashboard_rounded, label: 'Home'),
  _NavItem(icon: Icons.code_rounded, label: 'GitHub'),
  _NavItem(icon: Icons.terminal_rounded, label: 'LC'),
  _NavItem(icon: Icons.timer_rounded, label: 'Waka'),
  _NavItem(icon: Icons.flag_rounded, label: 'Goals'),
  _NavItem(icon: Icons.person_rounded, label: 'Profile'),
];

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final DevPulseTheme theme;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: theme.nav,
            border: Border(top: BorderSide(color: theme.borderSubtle, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_navItems.length, (i) {
                      final item = _navItems[i];
                      final isActive = i == currentIndex;
                      return GestureDetector(
                        onTap: () => onTap(i),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 56,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Active indicator dot
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                width: 16,
                                height: 2,
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF8B72FF)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              Icon(
                                item.icon,
                                size: 20,
                                color: isActive
                                    ? theme.navActive
                                    : theme.navInactive,
                              )
                                  .animate(target: isActive ? 1 : 0)
                                  .scaleXY(
                                      begin: 1.0,
                                      end: 1.2,
                                      duration: 300.ms,
                                      curve: Curves.easeOutBack)
                                  .shimmer(
                                      duration: 500.ms,
                                      color: theme.navActive.withOpacity(0.5)),
                              const SizedBox(height: 4),
                              Text(
                                item.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                  color: isActive
                                      ? theme.textTertiary
                                      : theme.navInactive,
                                ),
                              )
                                  .animate(target: isActive ? 1 : 0)
                                  .fadeIn(duration: 200.ms)
                                  .slideY(
                                      begin: 0.2, end: 0, duration: 200.ms),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Home indicator
                Center(
                  child: Container(
                    width: 134,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: theme.homeIndicator,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
