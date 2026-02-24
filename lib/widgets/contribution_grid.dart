import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ContributionGrid extends StatelessWidget {
  final List<ContributionData> contributions;

  const ContributionGrid({super.key, required this.contributions});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final data = contributions.length > 91
        ? contributions.sublist(contributions.length - 91)
        : contributions;

    final levelColors = [
      theme.gridEmpty,
      const Color(0xFF34D1A0).withValues(alpha: 0.25),
      const Color(0xFF34D1A0).withValues(alpha: 0.45),
      const Color(0xFF34D1A0).withValues(alpha: 0.65),
      const Color(0xFF34D1A0).withValues(alpha: 0.90),
    ];

    final weeks = <List<ContributionData>>[];
    for (int i = 0; i < data.length; i += 7) {
      weeks.add(data.sublist(i, (i + 7).clamp(0, data.length)));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: weeks.map((week) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                children: week.map((day) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.5),
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: levelColors[day.level.clamp(0, 4)],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Less',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 0.5,
                color: theme.textDim,
              ),
            ),
            const SizedBox(width: 6),
            ...levelColors.map((color) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                )),
            const SizedBox(width: 6),
            Text(
              'More',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 0.5,
                color: theme.textDim,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ContributionData {
  final String date;
  final int count;
  final int level;

  const ContributionData({
    required this.date,
    required this.count,
    required this.level,
  });
}
