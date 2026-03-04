import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../data/models.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  /// Opens the AI chat as a full-screen modal.
  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const AiChatScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  static const List<String> _suggestions = [
    'How am I doing this week?',
    'What should I focus on?',
    'Analyze my LeetCode progress',
    'Suggest goals for tomorrow',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(
        role: 'user',
        content: trimmed,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final provider = context.read<DataProvider>();
      final response = await provider.chat(trimmed, _messages);

      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: response,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: 'Sorry, something went wrong. Please try again.',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.bg,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(theme),

          // ── Messages ──
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(theme)
                : _buildMessageList(theme),
          ),

          // ── Input bar ──
          _buildInputBar(theme),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  Header
  // ────────────────────────────────────────────────────────────────

  Widget _buildHeader(DevPulseTheme theme) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 12,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(color: theme.borderSubtle),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: DevPulseColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: DevPulseColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: theme.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isLoading ? 'Thinking...' : 'Ask me anything about your progress',
                      style: TextStyle(
                        fontSize: 11,
                        color: _isLoading
                            ? DevPulseColors.primary
                            : theme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.fill2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: theme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  // ────────────────────────────────────────────────────────────────
  //  Empty state with suggestion chips
  // ────────────────────────────────────────────────────────────────

  Widget _buildEmptyState(DevPulseTheme theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: DevPulseColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 28,
                color: DevPulseColors.primary,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 20),
            Text(
              'How can I help?',
              style: GoogleFonts.instrumentSerif(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                color: theme.text,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'I can analyze your coding stats, suggest\ngoals, and help you stay on track.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.textMuted,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 32),
            // Suggestion chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                return _buildSuggestionChip(theme, suggestion, index);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
      DevPulseTheme theme, String text, int index) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _suggestionIcon(index),
              size: 14,
              color: DevPulseColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: theme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (300 + index * 80).ms, duration: 400.ms)
        .slideY(begin: 0.15);
  }

  IconData _suggestionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.trending_up;
      case 1:
        return Icons.track_changes;
      case 2:
        return Icons.code;
      case 3:
        return Icons.lightbulb_outline;
      default:
        return Icons.auto_awesome;
    }
  }

  // ────────────────────────────────────────────────────────────────
  //  Message list
  // ────────────────────────────────────────────────────────────────

  Widget _buildMessageList(DevPulseTheme theme) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // The typing indicator sits at index 0 when loading (because reversed)
        if (_isLoading && index == 0) {
          return _buildTypingIndicator(theme);
        }

        final messageIndex = _isLoading
            ? _messages.length - index
            : _messages.length - 1 - index;

        if (messageIndex < 0 || messageIndex >= _messages.length) {
          return const SizedBox.shrink();
        }

        final message = _messages[messageIndex];
        final isUser = message.role == 'user';

        return _buildMessageBubble(theme, message, isUser, messageIndex);
      },
    );
  }

  Widget _buildMessageBubble(
    DevPulseTheme theme,
    ChatMessage message,
    bool isUser,
    int index,
  ) {
    final timeStr = _formatTime(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // AI avatar
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
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
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? DevPulseColors.primary.withValues(alpha: 0.2)
                        : theme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight:
                          isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: theme.border),
                  ),
                  child: _buildMessageContent(theme, message.content, isUser),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 9,
                    color: theme.textDim,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildMessageContent(
      DevPulseTheme theme, String content, bool isUser) {
    // Detect code blocks and render them differently
    final codeBlockPattern = RegExp(r'```(\w*)\n?([\s\S]*?)```');
    final matches = codeBlockPattern.allMatches(content).toList();

    if (matches.isEmpty) {
      return SelectableText(
        content,
        style: TextStyle(
          fontSize: 13,
          color: isUser ? theme.text : theme.textSecondary,
          height: 1.5,
        ),
      );
    }

    // Build rich content with code blocks
    final widgets = <Widget>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Text before the code block
      if (match.start > lastEnd) {
        final textBefore = content.substring(lastEnd, match.start).trim();
        if (textBefore.isNotEmpty) {
          widgets.add(
            SelectableText(
              textBefore,
              style: TextStyle(
                fontSize: 13,
                color: isUser ? theme.text : theme.textSecondary,
                height: 1.5,
              ),
            ),
          );
          widgets.add(const SizedBox(height: 8));
        }
      }

      // Code block
      final code = match.group(2)?.trim() ?? '';
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.fill2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.borderSubtle),
          ),
          child: SelectableText(
            code,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: theme.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));

      lastEnd = match.end;
    }

    // Text after the last code block
    if (lastEnd < content.length) {
      final textAfter = content.substring(lastEnd).trim();
      if (textAfter.isNotEmpty) {
        widgets.add(
          SelectableText(
            textAfter,
            style: TextStyle(
              fontSize: 13,
              color: isUser ? theme.text : theme.textSecondary,
              height: 1.5,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  Typing indicator
  // ────────────────────────────────────────────────────────────────

  Widget _buildTypingIndicator(DevPulseTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(theme, 0),
                const SizedBox(width: 4),
                _buildDot(theme, 1),
                const SizedBox(width: 4),
                _buildDot(theme, 2),
                const SizedBox(width: 8),
                Text(
                  'typing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildDot(DevPulseTheme theme, int index) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: DevPulseColors.primary.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .fadeIn(duration: 400.ms, delay: (index * 200).ms)
        .then()
        .fadeOut(duration: 400.ms)
        .then()
        .fadeIn(duration: 400.ms);
  }

  // ────────────────────────────────────────────────────────────────
  //  Input bar
  // ────────────────────────────────────────────────────────────────

  Widget _buildInputBar(DevPulseTheme theme) {
    return SafeArea(
      top: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              color: theme.surface.withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(color: theme.borderSubtle),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.fill2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.border),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.text,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask about your progress...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: theme.textDim,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (value) {
                        _sendMessage(value);
                        _focusNode.requestFocus();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? theme.fill2
                          : DevPulseColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      size: 20,
                      color: _isLoading
                          ? theme.textDim
                          : Colors.white,
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

  // ────────────────────────────────────────────────────────────────
  //  Helpers
  // ────────────────────────────────────────────────────────────────

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }
}
