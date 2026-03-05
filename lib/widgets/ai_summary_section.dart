import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import 'glass_card.dart';

class AiSummarySection extends StatefulWidget {
  final String screenContext;

  const AiSummarySection({super.key, required this.screenContext});

  @override
  State<AiSummarySection> createState() => _AiSummarySectionState();
}

class _AiSummarySectionState extends State<AiSummarySection> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<DataProvider>();
          provider.loadAiSummary(widget.screenContext);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final provider = context.watch<DataProvider>();
    final summary = provider.aiSummaries[widget.screenContext];

    if (summary == null) {
      return GlassCard(
        padding: const EdgeInsets.all(20),
        delay: 0.1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                   Text(
                    'AI Daily Brief',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.0,
                      color: theme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                    width: 200,
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

    if (summary.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      delay: 0.1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                 Text(
                  'DEV PONTIFEX BRIEF', // Fun AI branding
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.0,
                    color: DevPulseColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
