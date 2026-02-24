import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'github_screen.dart';
import 'leetcode_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    GitHubScreen(),
    LeetCodeScreen(),
    GoalsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
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
  _NavItem(icon: Icons.terminal_rounded, label: 'LeetCode'),
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
                              ),
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
                              ),
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
