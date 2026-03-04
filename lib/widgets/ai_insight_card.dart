import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import 'glass_card.dart';

class AiInsightCard extends StatelessWidget {
  final String text;
  final String type;
  final bool isLoading;

  const AiInsightCard({
    super.key,
    required this.text,
    this.type = 'tip',
    this.isLoading = false,
  });

  IconData get _icon {
    switch (type) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'suggestion':
        return Icons.lightbulb_outline_rounded;
      case 'streak':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.auto_awesome;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'warning':
        return DevPulseColors.warning;
      case 'achievement':
        return DevPulseColors.success;
      case 'suggestion':
        return DevPulseColors.info;
      case 'streak':
        return DevPulseColors.danger;
      default:
        return DevPulseColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (isLoading) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: DevPulseColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 14,
                color: DevPulseColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.fill2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 140,
                    decoration: BoxDecoration(
                      color: theme.fill,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: theme.fill3),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _icon,
              size: 14,
              color: _iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 9,
                      color: DevPulseColors.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Insight',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.5,
                        color: DevPulseColors.primary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A column of AI insight cards that auto-loads when built.
class AiInsightSection extends StatefulWidget {
  final String screenContext;

  const AiInsightSection({super.key, required this.screenContext});

  @override
  State<AiInsightSection> createState() => _AiInsightSectionState();
}

class _AiInsightSectionState extends State<AiInsightSection> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      // Delay to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider =
              context.read<DataProvider>();
          provider.loadAiInsights(widget.screenContext);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final insights = provider.aiInsights[widget.screenContext];

    if (insights == null) {
      return const AiInsightCard(text: '', isLoading: true);
    }

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: insights.map((insight) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AiInsightCard(text: insight.text, type: insight.type),
        );
      }).toList(),
    );
  }
}
