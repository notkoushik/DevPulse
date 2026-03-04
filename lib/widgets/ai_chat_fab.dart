import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../screens/ai_chat_screen.dart';

class AiChatFab extends StatelessWidget {
  const AiChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AiChatScreen.show(context),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DevPulseColors.primary,
              Color(0xFF6B5CE7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: DevPulseColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome,
          size: 22,
          color: Colors.white,
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            delay: 2.seconds,
            duration: 1500.ms,
            color: Colors.white.withValues(alpha: 0.15),
          ),
    );
  }
}
