import 'package:flutter/material.dart';
import 'results_screen.dart';
import 'history_screen.dart';
import 'dart:math';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isRecording = false;
  int _countdown = 0;
  int _recordingSeconds = 0;

  double _generateScore() {
    final random = Random();
    return 55 + random.nextInt(40).toDouble();
  }

  void _startRecording() async {
    setState(() => _countdown = 3);

    for (int i = 3; i >= 1; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown = i - 1;
          if (i == 1) _isRecording = true;
        });
      }
    }

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _recordingSeconds = i + 1);
      }
    }

    if (mounted) {
      final score = _generateScore();
      HistoryScreen.addSession(score);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            confidenceScore: score,
            feedback: _getFeedback(score),
          ),
        ),
      );
    }
  }

  List<String> _getFeedback(double score) {
    if (score >= 75) {
      return [
        'Great posture! Keep maintaining this during presentations',
        'Good hand gesture control — very professional',
        'Excellent head stability throughout the session',
        'Keep up this confident body language!',
      ];
    } else if (score >= 55) {
      return [
        'Maintain straight posture during speaking',
        'Reduce unnecessary hand movement',
        'Keep head stable and avoid frequent nodding',
        'Stand with feet shoulder-width apart for stability',
      ];
    } else {
      return [
        'Focus on keeping your spine straight throughout',
        'Try to minimize excessive body swaying',
        'Control hand gestures — use them purposefully only',
        'Practice standing still with weight evenly distributed',
        'Maintain eye contact with your audience',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Record Analysis'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF1A1A2E),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRecording
                            ? Icons.fiber_manual_record
                            : Icons.videocam_rounded,
                        color: _isRecording ? Colors.red : Colors.white54,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isRecording
                            ? 'Recording... ${_recordingSeconds}s / 10s'
                            : 'Camera will appear here\non your Android phone',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (_isRecording)
                  CustomPaint(
                    painter: SkeletonPainter(),
                    size: Size.infinite,
                  ),
                if (_countdown > 0)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        '$_countdown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (_isRecording)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.fiber_manual_record,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('REC',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                if (_isRecording)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: _recordingSeconds / 10,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.red),
                      minHeight: 4,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                if (!_isRecording && _countdown == 0) ...[
                  const Text(
                    'Stand in front of camera\nand press record to start',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _startRecording,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.fiber_manual_record,
                          color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tap to Record',
                      style:
                          TextStyle(color: Colors.white54, fontSize: 12)),
                ],
                if (_isRecording) ...[
                  Text(
                    'Analyzing your body language...\n${10 - _recordingSeconds} seconds remaining',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                  ),
                ],
                if (_countdown > 0 && !_isRecording) ...[
                  Text(
                    'Starting in $_countdown...',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(Offset(cx, cy - 80), 20, dotPaint);
    canvas.drawLine(Offset(cx, cy - 60), Offset(cx, cy - 40), paint);
    canvas.drawLine(
        Offset(cx - 60, cy - 40), Offset(cx + 60, cy - 40), paint);
    canvas.drawLine(
        Offset(cx - 60, cy - 40), Offset(cx - 90, cy + 20), paint);
    canvas.drawLine(
        Offset(cx + 60, cy - 40), Offset(cx + 90, cy + 20), paint);
    canvas.drawLine(Offset(cx, cy - 40), Offset(cx, cy + 40), paint);
    canvas.drawLine(
        Offset(cx - 40, cy + 40), Offset(cx + 40, cy + 40), paint);
    canvas.drawLine(
        Offset(cx - 40, cy + 40), Offset(cx - 50, cy + 120), paint);
    canvas.drawLine(
        Offset(cx + 40, cy + 40), Offset(cx + 50, cy + 120), paint);

    for (final point in [
      Offset(cx, cy - 80),
      Offset(cx - 60, cy - 40),
      Offset(cx + 60, cy - 40),
      Offset(cx - 90, cy + 20),
      Offset(cx + 90, cy + 20),
      Offset(cx - 40, cy + 40),
      Offset(cx + 40, cy + 40),
      Offset(cx - 50, cy + 120),
      Offset(cx + 50, cy + 120),
    ]) {
      canvas.drawCircle(point, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}