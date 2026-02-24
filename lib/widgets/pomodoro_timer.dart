import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum PomodoroMode { work, shortBreak, longBreak }

class PomodoroModeConfig {
  final String label;
  final int duration;
  final Color color;

  const PomodoroModeConfig({
    required this.label,
    required this.duration,
    required this.color,
  });
}

const _modes = {
  PomodoroMode.work: PomodoroModeConfig(
    label: 'Focus',
    duration: 25 * 60,
    color: Color(0xFF8B72FF),
  ),
  PomodoroMode.shortBreak: PomodoroModeConfig(
    label: 'Short Break',
    duration: 5 * 60,
    color: Color(0xFF34D1A0),
  ),
  PomodoroMode.longBreak: PomodoroModeConfig(
    label: 'Long Break',
    duration: 15 * 60,
    color: Color(0xFF6AB8E8),
  ),
};

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => const PomodoroTimer(),
    );
  }

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  PomodoroMode _mode = PomodoroMode.work;
  late int _timeLeft;
  bool _isRunning = false;
  int _sessionsCompleted = 0;
  Timer? _timer;

  PomodoroModeConfig get _currentMode => _modes[_mode]!;
  int get _totalDuration => _currentMode.duration;
  double get _progress => ((_totalDuration - _timeLeft) / _totalDuration) * 100;

  @override
  void initState() {
    super.initState();
    _timeLeft = _modes[PomodoroMode.work]!.duration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        if (_mode == PomodoroMode.work) {
          _sessionsCompleted++;
          if (_sessionsCompleted % 4 == 0) {
            _switchMode(PomodoroMode.longBreak);
          } else {
            _switchMode(PomodoroMode.shortBreak);
          }
        } else {
          _switchMode(PomodoroMode.work);
        }
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _totalDuration;
    });
  }

  void _switchMode(PomodoroMode mode) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _mode = mode;
      _timeLeft = _modes[mode]!.duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final minutes = _timeLeft ~/ 60;
    final seconds = _timeLeft % 60;

    const ringSize = 240.0;
    const strokeWidth = 4.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: theme.overlayHeavy),
            ),
          ),
          // Timer Card
          Center(
            child: Container(
              width: 380,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POMODORO',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.5,
                              color: theme.textDim,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Focus Timer',
                            style: GoogleFonts.instrumentSerif(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: theme.text,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.fill,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 14, color: theme.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Mode Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.fill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: PomodoroMode.values.map((mode) {
                        final isActive = _mode == mode;
                        final config = _modes[mode]!;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _switchMode(mode),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? theme.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isActive
                                    ? [const BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))]
                                    : null,
                              ),
                              child: Text(
                                config.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 0.3,
                                  color: isActive ? theme.text : theme.textDim,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Timer Ring
                  SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(ringSize, ringSize),
                          painter: _TimerRingPainter(
                            progress: _progress / 100,
                            strokeWidth: strokeWidth,
                            color: _currentMode.color,
                            trackColor: theme.ringTrack,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 56,
                                letterSpacing: -2,
                                color: theme.text,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentMode.label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1,
                                color: _currentMode.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _resetTimer,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.fill,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.refresh, size: 18, color: theme.textMuted),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _toggleTimer,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _currentMode.color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.fill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_sessionsCompleted',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                color: theme.text,
                                height: 1,
                              ),
                            ),
                            Text(
                              'DONE',
                              style: TextStyle(
                                fontSize: 7,
                                letterSpacing: 1,
                                color: theme.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Session Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(4, (i) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _sessionsCompleted % 4
                                ? _currentMode.color
                                : theme.fill2,
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        'until long break',
                        style: TextStyle(fontSize: 9, color: theme.textDim),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  _TimerRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
