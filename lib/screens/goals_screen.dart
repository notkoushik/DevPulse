import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/models.dart';
import '../data/mock_data.dart' as data;
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/pomodoro_timer.dart';

// ---------- category config ----------

class _CategoryInfo {
  final IconData icon;
  final Color color;
  final String label;
  const _CategoryInfo(this.icon, this.color, this.label);
}

final Map<String, _CategoryInfo> _categoryConfig = {
  'leetcode': const _CategoryInfo(Icons.code, Color(0xFFF0C95C), 'LeetCode'),
  'github': const _CategoryInfo(Icons.commit, Color(0xFF8B72FF), 'GitHub'),
  'learning':
      const _CategoryInfo(Icons.menu_book, Color(0xFF6AB8E8), 'Learning'),
};

// =====================================================================
//  GoalsScreen
// =====================================================================

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late List<Goal> _goals;
  String _newTitle = '';
  String _newCategory = 'learning';

  @override
  void initState() {
    super.initState();
    _goals = List<Goal>.from(data.goals);
  }

  // ---------- helpers ----------

  void _toggleGoal(String id) {
    setState(() {
      final goal = _goals.firstWhere((g) => g.id == id);
      goal.completed = !goal.completed;
    });
  }

  void _deleteGoal(String id) {
    setState(() {
      _goals.removeWhere((g) => g.id == id);
    });
  }

  void _addGoal({String? title, String? category}) {
    final goalTitle = title ?? _newTitle;
    final goalCategory = category ?? _newCategory;
    if (goalTitle.trim().isEmpty) return;
    setState(() {
      _goals.add(Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: goalTitle.trim(),
        completed: false,
        category: goalCategory,
      ));
    });
  }

  void _showAddGoalSheet() {
    String sheetTitle = '';
    String sheetCategory = 'learning';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = AppTheme.of(ctx);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    top: BorderSide(color: theme.border, width: 1),
                    left: BorderSide(color: theme.border, width: 1),
                    right: BorderSide(color: theme.border, width: 1),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New Goal',
                            style: GoogleFonts.instrumentSerif(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: theme.text,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.close,
                                size: 20, color: theme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title text field
                      TextField(
                        autofocus: true,
                        style: TextStyle(color: theme.text, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'What do you want to accomplish?',
                          hintStyle:
                              TextStyle(color: theme.textGhost, fontSize: 14),
                          filled: true,
                          fillColor: theme.fill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.border, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.border, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: DevPulseColors.primary, width: 1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (val) {
                          setSheetState(() {
                            sheetTitle = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category selector
                      Row(
                        children: _categoryConfig.entries.map((entry) {
                          final key = entry.key;
                          final info = entry.value;
                          final isSelected = sheetCategory == key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  sheetCategory = key;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? info.color.withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isSelected ? info.color : theme.border,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(info.icon,
                                        size: 14, color: info.color),
                                    const SizedBox(width: 6),
                                    Text(
                                      info.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? info.color
                                            : theme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: sheetTitle.trim().isEmpty
                              ? null
                              : () {
                                  _addGoal(
                                      title: sheetTitle,
                                      category: sheetCategory);
                                  Navigator.pop(context);
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: sheetTitle.trim().isEmpty
                                  ? DevPulseColors.primary.withOpacity(0.4)
                                  : DevPulseColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Add Goal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: sheetTitle.trim().isEmpty
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =====================================================================
  //  Build
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final done = _goals.where((g) => g.completed).length;
    final total = _goals.length;
    final pct = total > 0 ? ((done / total) * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 24),
          _buildProgressCard(theme, done, total, pct),
          const SizedBox(height: 12),
          _buildCategoryStreaks(theme),
          const SizedBox(height: 12),
          _buildWeekChart(theme),
          const SizedBox(height: 12),
          _buildQuickAddTemplates(theme),
          const SizedBox(height: 20),
          _buildGoalsList(theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // =====================================================================
  //  1. Header
  // =====================================================================

  Widget _buildHeader(DevPulseTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DAILY TRACKER',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                color: theme.textMuted,
              ),
            ),
            Text(
              'Goals',
              style: GoogleFonts.instrumentSerif(
                fontSize: 28,
                fontStyle: FontStyle.italic,
                color: theme.text,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => PomodoroTimer.show(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.fill2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timer,
                  size: 16,
                  color: DevPulseColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showAddGoalSheet,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DevPulseColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =====================================================================
  //  2. Progress Card
  // =====================================================================

  Widget _buildProgressCard(DevPulseTheme theme, int done, int total, int pct) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: theme.textDim,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$done',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 38,
                      color: theme.text,
                    ),
                  ),
                  Text(
                    ' / $total',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textDim,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 12,
                    color: DevPulseColors.danger,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '12 day streak',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ProgressRing(
            progress: pct / 100,
            size: 72,
            strokeWidth: 3.5,
            color: DevPulseColors.success,
            child: Text(
              '$pct%',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  //  3. Category Streaks
  // =====================================================================

  Widget _buildCategoryStreaks(DevPulseTheme theme) {
    return Row(
      children: _categoryConfig.entries.map((entry) {
        final key = entry.key;
        final info = entry.value;
        final streak = data.categoryStreaks[key];
        final current = streak?.current ?? 0;
        final best = streak?.best ?? 0;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: key == 'leetcode' ? 0 : 6,
              right: key == 'learning' ? 0 : 6,
            ),
            child: GlassCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                children: [
                  Icon(info.icon, size: 13, color: info.color),
                  const SizedBox(height: 6),
                  Text(
                    '$current',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 18,
                      color: theme.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.label,
                    style: TextStyle(
                      fontSize: 8,
                      color: theme.textDim,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'best: $best',
                    style: TextStyle(
                      fontSize: 8,
                      color: theme.textGhost,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // =====================================================================
  //  4. This Week Chart
  // =====================================================================

  Widget _buildWeekChart(DevPulseTheme theme) {
    final stats = data.weeklyGoalStats;
    final todayIndex = DateTime.now().weekday - 1;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              color: theme.textDim,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(stats.length, (i) {
                final stat = stats[i];
                final pct = stat.total > 0
                    ? (stat.completed / stat.total * 100).round()
                    : 0;
                final barHeight = (pct / 100 * 52).clamp(2.0, 52.0);
                final allDone = pct == 100;
                final isToday = i == todayIndex;

                Color barColor;
                if (allDone) {
                  barColor = DevPulseColors.success;
                } else if (isToday) {
                  barColor = DevPulseColors.primary;
                } else {
                  barColor = theme.barInactive;
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 18,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stat.day,
                      style: TextStyle(
                        fontSize: 9,
                        color: isToday ? theme.textMuted : theme.textGhost,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  //  5. Quick Add Templates
  // =====================================================================

  Widget _buildQuickAddTemplates(DevPulseTheme theme) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 12,
                color: DevPulseColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                'QUICK ADD',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: theme.textDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.goalTemplates.map((template) {
              return GestureDetector(
                onTap: () => _addGoal(
                  title: template.title,
                  category: template.category,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.border, width: 1),
                  ),
                  child: Text(
                    template.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  //  6. Goals List
  // =====================================================================

  Widget _buildGoalsList(DevPulseTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "TODAY'S GOALS",
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.2,
                color: theme.textDim,
              ),
            ),
            Text(
              'swipe to delete',
              style: TextStyle(
                fontSize: 9,
                color: theme.textGhost,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_goals.isEmpty)
          _buildEmptyState(theme)
        else
          Column(
            children: _goals.map((goal) {
              final catInfo = _categoryConfig[goal.category];
              final catColor = catInfo?.color ?? DevPulseColors.info;
              final catLabel = catInfo?.label ?? goal.category;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Dismissible(
                  key: ValueKey(goal.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: DevPulseColors.danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: DevPulseColors.danger,
                      size: 20,
                    ),
                  ),
                  onDismissed: (_) => _deleteGoal(goal.id),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleGoal(goal.id),
                          child: goal.completed
                              ? Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: DevPulseColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.circle_outlined,
                                  size: 20,
                                  color: theme.textFaint,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            goal.title,
                            style: TextStyle(
                              fontSize: 13,
                              color: goal.completed
                                  ? theme.textDim
                                  : theme.textSecondary,
                              decoration: goal.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            catLabel,
                            style: TextStyle(
                              fontSize: 9,
                              color: catColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState(DevPulseTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.gps_fixed,
              size: 32,
              color: theme.textGhost,
            ),
            const SizedBox(height: 12),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 14,
                color: theme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showAddGoalSheet,
              child: const Text(
                'Tap + to add your first',
                style: TextStyle(
                  fontSize: 12,
                  color: DevPulseColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
