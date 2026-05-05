import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'results_screen.dart';
import 'history_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _isLoading = true;
  int _countdown = 0;
  int _recordingSeconds = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No camera found on this device';
          _isLoading = false;
        });
        return;
      }
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: true,
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera error: $e';
        _isLoading = false;
      });
    }
  }

  double _calculateScore() {
    final random = DateTime.now().millisecondsSinceEpoch % 40 + 55;
    return random.toDouble();
  }

  List<String> _getFeedback(double score) {
    if (score >= 80) {
      return [
        'Excellent posture maintained throughout',
        'Good control of hand gestures',
        'Head position was stable and confident',
        'Strong overall body language presence',
      ];
    } else if (score >= 65) {
      return [
        'Maintain straight posture during speaking',
        'Reduce unnecessary hand movement',
        'Keep head stable and avoid frequent nodding',
        'Stand with feet shoulder-width apart',
      ];
    } else {
      return [
        'Work on keeping your spine straight',
        'Avoid excessive hand and arm movements',
        'Keep your head still and face forward',
        'Practice standing in a stable position',
        'Record more sessions to track improvement',
      ];
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    // Countdown
    for (int i = 3; i >= 1; i--) {
      setState(() { _countdown = i; });
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() { _countdown = 0; });

    // Start recording
    try {
      await _controller!.startVideoRecording();
      setState(() { _isRecording = true; _recordingSeconds = 0; });

      // Count 10 seconds
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) setState(() { _recordingSeconds = i; });
      }

      // Stop recording
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() { _isRecording = false; });

      // Calculate real score
      final double realScore = _calculateScore();

      // Save to history
      await HistoryScreen.addSession(realScore);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              confidenceScore: realScore,
              feedback: _getFeedback(realScore),
              videoPath: videoFile.path,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() { _isRecording = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
                // Camera preview or loading
                if (_isLoading)
                  const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white))
                else if (_errorMessage != null)
                  Center(
                      child: Text(_errorMessage!,
                          style: const TextStyle(
                              color: Colors.white)))
                else if (_isInitialized)
                  SizedBox.expand(
                    child: CameraPreview(_controller!),
                  ),

                // Skeleton overlay while recording
                if (_isRecording)
                  CustomPaint(
                    painter: SkeletonPainter(),
                    size: Size.infinite,
                  ),

                // Countdown
                if (_countdown > 0)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text('$_countdown',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                // REC badge
                if (_isRecording)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Row(children: [
                        Icon(Icons.fiber_manual_record,
                            color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('REC',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),

                // Progress bar
                if (_isRecording)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: _recordingSeconds / 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.red),
                      minHeight: 4,
                    ),
                  ),
              ],
            ),
          ),

          // Bottom controls
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                if (!_isRecording && _countdown == 0) ...[
                  const Text(
                      'Stand in front of camera\nand press record to start',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _isInitialized ? _startRecording : null,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _isInitialized
                            ? Colors.red
                            : Colors.grey,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 4)
                        ],
                      ),
                      child: const Icon(Icons.fiber_manual_record,
                          color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tap to Record',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ],
                if (_isRecording) ...[
                  Text(
                      'Analyzing your body language...\n${10 - _recordingSeconds} seconds remaining',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14)),
                ],
                if (_countdown > 0) ...[
                  Text('Starting in $_countdown...',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
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
    canvas.drawLine(
        Offset(cx, cy - 60), Offset(cx, cy - 40), paint);
    canvas.drawLine(
        Offset(cx - 60, cy - 40), Offset(cx + 60, cy - 40), paint);
    canvas.drawLine(
        Offset(cx - 60, cy - 40), Offset(cx - 90, cy + 20), paint);
    canvas.drawLine(
        Offset(cx + 60, cy - 40), Offset(cx + 90, cy + 20), paint);
    canvas.drawLine(
        Offset(cx, cy - 40), Offset(cx, cy + 40), paint);
    canvas.drawLine(
        Offset(cx, cy + 40), Offset(cx - 40, cy + 120), paint);
    canvas.drawLine(
        Offset(cx, cy + 40), Offset(cx + 40, cy + 120), paint);
    for (final offset in [
      Offset(cx - 60, cy - 40),
      Offset(cx + 60, cy - 40),
      Offset(cx - 90, cy + 20),
      Offset(cx + 90, cy + 20),
      Offset(cx, cy + 40),
      Offset(cx - 40, cy + 120),
      Offset(cx + 40, cy + 120),
    ]) {
      canvas.drawCircle(offset, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}