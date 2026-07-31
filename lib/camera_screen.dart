import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:math';
import 'results_screen.dart';
import 'history_screen.dart';
import 'theme_provider.dart';

// TODO: set this to your deployed backend URL, e.g. https://your-backend.onrender.com — a LAN IP will never work for a deployed web app.
const String kBackendBaseUrl = 'https://body-language-app.onrender.com';

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
  bool _isAnalyzing = false;
  int _countdown = 0;
  int _recordingSeconds = 0;
  int _selectedDuration = 15;
  String? _errorMessage;

  final List<String> _prompts = const [
    "Pretend you're introducing yourself to a new team",
    "Explain your favorite hobby in 30 seconds",
    "Practice answering: tell me about yourself",
    "Describe a challenge you overcame recently",
    "Give a 30-second elevator pitch for a business idea",
    "Explain a complex concept to a beginner",
    "Practice presenting a project status update",
    "Deliver an inspiring opening line for a speech",
    "Practice handling a tough interview question",
  ];
  late String _currentPrompt;

  @override
  void initState() {
    super.initState();
    _currentPrompt = _prompts[Random().nextInt(_prompts.length)];
    _initCamera();
  }

  void _shufflePrompt() {
    final random = Random();
    String nextPrompt;
    do {
      nextPrompt = _prompts[random.nextInt(_prompts.length)];
    } while (nextPrompt == _currentPrompt && _prompts.length > 1);

    setState(() {
      _currentPrompt = nextPrompt;
    });
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

  Future<Map<String, dynamic>> _analyzeWithAI(XFile videoFile) async {
    final uri = Uri.parse('$kBackendBaseUrl/analyze');
    final request = http.MultipartRequest('POST', uri);
    final bytes = await videoFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes(
        'video',
        bytes,
        filename: 'video.mp4',
      ),
    );

    final response =
        await request.send().timeout(const Duration(seconds: 120));
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(body);
    } else {
      throw Exception('Server returned status code ${response.statusCode}');
    }
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

    for (int i = 3; i >= 1; i--) {
      setState(() {
        _countdown = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() {
      _countdown = 0;
    });

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      for (int i = 1; i <= _selectedDuration; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _recordingSeconds = i;
          });
        }
      }

      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isAnalyzing = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analyzing with AI... please wait a few seconds'),
            duration: Duration(seconds: 30),
          ),
        );
      }

      Map<String, dynamic> result;
      try {
        result = await _analyzeWithAI(videoFile);
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Analysis failed: $e'),
              duration: const Duration(seconds: 8),
            ),
          );
        }
        return;
      }

      final double realScore =
          (result['confidence_score'] as num?)?.toDouble() ?? 0.0;
      final double postureScore =
          (result['posture_score'] as num?)?.toDouble() ?? 0.0;
      final double headScore =
          (result['head_stability_score'] as num?)?.toDouble() ?? 0.0;
      final double gestureScore =
          (result['gesture_score'] as num?)?.toDouble() ?? 0.0;

      final List<String> aiTips = result['tips'] != null
          ? List<String>.from(result['tips'])
          : _getFeedback(realScore);

      await HistoryScreen.addSession(
        realScore,
        postureScore: postureScore,
        headStabilityScore: headScore,
        gestureScore: gestureScore,
        duration: '$_selectedDuration sec',
        videoPath: videoFile.path,
      );
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              confidenceScore: realScore,
              postureScore: postureScore,
              headStabilityScore: headScore,
              gestureScore: gestureScore,
              feedback: aiTips,
              videoPath: videoFile.path,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isAnalyzing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? videoFile =
          await picker.pickVideo(source: ImageSource.gallery);
      if (videoFile == null) return;

      setState(() {
        _isAnalyzing = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analyzing with AI... please wait a few seconds'),
            duration: Duration(seconds: 30),
          ),
        );
      }

      Map<String, dynamic> result;
      try {
        result = await _analyzeWithAI(videoFile);
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Analysis failed: $e'),
              duration: const Duration(seconds: 8),
            ),
          );
        }
        return;
      }

      final double realScore =
          (result['confidence_score'] as num?)?.toDouble() ?? 0.0;
      final double postureScore =
          (result['posture_score'] as num?)?.toDouble() ?? 0.0;
      final double headScore =
          (result['head_stability_score'] as num?)?.toDouble() ?? 0.0;
      final double gestureScore =
          (result['gesture_score'] as num?)?.toDouble() ?? 0.0;

      final List<String> aiTips = result['tips'] != null
          ? List<String>.from(result['tips'])
          : _getFeedback(realScore);

      await HistoryScreen.addSession(
        realScore,
        postureScore: postureScore,
        headStabilityScore: headScore,
        gestureScore: gestureScore,
        duration: 'Gallery Video',
        videoPath: videoFile.path,
      );
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              confidenceScore: realScore,
              postureScore: postureScore,
              headStabilityScore: headScore,
              gestureScore: gestureScore,
              feedback: aiTips,
              videoPath: videoFile.path,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting video: $e')),
        );
      }
    }
  }

  Future<void> _showCustomDurationDialog() async {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    double tempVal = _selectedDuration.toDouble().clamp(5.0, 60.0);
    final TextEditingController controller =
        TextEditingController(text: '${tempVal.toInt()}');

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Custom Duration'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select recording duration (5 to 60 seconds):',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Text(
                    '${tempVal.toInt()} sec',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                  Slider(
                    value: tempVal,
                    min: 5.0,
                    max: 60.0,
                    divisions: 55,
                    activeColor: primaryColor,
                    label: '${tempVal.toInt()}s',
                    onChanged: (val) {
                      setDialogState(() {
                        tempVal = val;
                        controller.text = '${val.toInt()}';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Exact Seconds (5 - 60)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed >= 5 && parsed <= 60) {
                        setDialogState(() {
                          tempVal = parsed.toDouble();
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final parsed =
                        int.tryParse(controller.text) ?? tempVal.toInt();
                    final finalVal = parsed.clamp(5, 60);
                    setState(() {
                      _selectedDuration = finalVal;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Set Duration'),
                ),
              ],
            );
          },
        );
      },
    );
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
                if (_isLoading)
                  const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                else if (_errorMessage != null)
                  Center(
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.white)))
                else if (_isInitialized && _controller != null)
                  ClipRect(
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 100,
                          height: 100 * _controller!.value.aspectRatio,
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ),
                  ),

                if (!_isRecording &&
                    _countdown == 0 &&
                    !_isAnalyzing &&
                    !_isLoading &&
                    _errorMessage == null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded,
                              color: Color(0xFFF59E0B), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Practice Prompt',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentPrompt,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.shuffle_rounded,
                                color: Colors.white, size: 20),
                            onPressed: _shufflePrompt,
                            tooltip: 'Shuffle prompt',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.greenAccent),
                          SizedBox(height: 24),
                          Text(
                            'AI is analyzing your\nbody language...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Processing MediaPipe pose data...',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
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
                      child: Text('$_countdown',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold)),
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

                if (_isRecording)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: _recordingSeconds / _selectedDuration,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isRecording && _countdown == 0 && !_isAnalyzing) ...[
                  const Text('Select Duration',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...[10, 15, 20, 30, 60].map((dur) {
                          final isSelected = _selectedDuration == dur;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text('${dur}s',
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              selected: isSelected,
                              selectedColor: Colors.white,
                              backgroundColor: Colors.white12,
                              showCheckmark: false,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedDuration = dur);
                                }
                              },
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(
                              ![10, 15, 20, 30, 60].contains(_selectedDuration)
                                  ? 'Custom (${_selectedDuration}s)'
                                  : 'Custom',
                              style: TextStyle(
                                  color: ![10, 15, 20, 30, 60]
                                          .contains(_selectedDuration)
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            selected: ![10, 15, 20, 30, 60]
                                .contains(_selectedDuration),
                            selectedColor: Colors.white,
                            backgroundColor: Colors.white12,
                            showCheckmark: false,
                            onSelected: (selected) {
                              _showCustomDurationDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gallery Upload Button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _pickVideoFromGallery,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white38, width: 1.5),
                              ),
                              child: const Icon(Icons.photo_library_rounded,
                                  color: Colors.white, size: 26),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text('Gallery',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(width: 36),
                      // Live Record Button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _isInitialized ? _startRecording : null,
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: _isInitialized ? Colors.red : Colors.grey,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.red.withOpacity(0.4),
                                      blurRadius: 16,
                                      spreadRadius: 3)
                                ],
                              ),
                              child: const Icon(Icons.fiber_manual_record,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Record ($_selectedDuration s)',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
                if (_isRecording) ...[
                  Text(
                      'Recording body language...\n${_selectedDuration - _recordingSeconds} seconds remaining',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
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


