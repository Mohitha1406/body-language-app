import 'package:flutter/material.dart';
import 'theme_provider.dart';

class TipsLibraryScreen extends StatelessWidget {
  const TipsLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;

    final categories = [
      {
        'title': 'Posture & Body Alignment',
        'icon': Icons.accessibility_new_rounded,
        'color': primaryColor,
        'tips': [
          {
            'headline': 'Keep Spine Straight & Shoulders Relaxed',
            'detail':
                'Align your ears, shoulders, and hips. Avoid slumping or leaning heavily to one side. Roll your shoulders back and down to reduce tension.'
          },
          {
            'headline': 'Balanced Weight Distribution',
            'detail':
                'Stand with feet shoulder-width apart. Distribute your body weight evenly on both feet to project stability and confidence.'
          },
          {
            'headline': 'Neutral Head Angle',
            'detail':
                'Keep your chin parallel to the floor. Tilting up can look aggressive or arrogant, while tilting down suggests submissiveness.'
          },
          {
            'headline': 'Open Torso Angle',
            'detail':
                'Face the audience directly without angling your chest away or crossing your arms, showing transparency and engagement.'
          },
        ]
      },
      {
        'title': 'Hand Gestures & Movement',
        'icon': Icons.pan_tool_rounded,
        'color': const Color(0xFF10B981),
        'tips': [
          {
            'headline': 'Use Open Palm Gestures',
            'detail':
                'Showing open palms signals honesty, openness, and trust. Keep hands visible in the "gesture box" between your waist and chest.'
          },
          {
            'headline': 'Avoid Fidgeting & Self-Touching',
            'detail':
                'Minimize touching your face, neck, hair, or adjusting clothes. Fidgeting signals nervousness or insecurity.'
          },
          {
            'headline': 'Purposeful Gesture Timing',
            'detail':
                'Emphasize key points with smooth, deliberate hand movements. Match your gesture pace to your speaking cadence.'
          },
          {
            'headline': 'The Steeple Gesture',
            'detail':
                'Lightly touch your fingertips together to form a steeple shape when listening or speaking to demonstrate deep reflection and authority.'
          },
        ]
      },
      {
        'title': 'Eye Contact & Facial Expressions',
        'icon': Icons.visibility_rounded,
        'color': const Color(0xFFF59E0B),
        'tips': [
          {
            'headline': 'The 60/40 Rule',
            'detail':
                'Maintain direct eye contact 60% to 70% of the time when speaking. Staring continuously can feel intense; looking away too much signals disinterest.'
          },
          {
            'headline': 'Triangular Gaze Technique',
            'detail':
                'Shift your gaze naturally between the left eye, right eye, and mouth/bridge of nose of your listener to keep eye contact natural.'
          },
          {
            'headline': 'Genuine Smiling (Duchenne Smile)',
            'detail':
                'Engage both your mouth and the muscles around your eyes for authentic warmth and rapport.'
          },
          {
            'headline': 'Micro-Expression Awareness',
            'detail':
                'Avoid tight jaw clenching or furrowed brows. Keep facial muscles relaxed to remain approachable and cool under pressure.'
          },
        ]
      },
      {
        'title': 'Voice Projection & Cadence',
        'icon': Icons.record_voice_over_rounded,
        'color': const Color(0xFF8B5CF6),
        'tips': [
          {
            'headline': 'Diaphragmatic Breathing',
            'detail':
                'Breathe deeply from your lower abdomen rather than shallow chest breaths. Deep breathing steadies your voice and prevents trembling.'
          },
          {
            'headline': 'Strategic Pauses',
            'detail':
                'Embrace short 1-2 second pauses instead of filler words ("um", "ah", "like"). Pauses command attention and allow listeners to process.'
          },
          {
            'headline': 'Pacing & Articulation',
            'detail':
                'Speak at a measured pace (approx. 130-150 words per minute). Enunciate key terms clearly to project clarity and mastery.'
          },
          {
            'headline': 'Pitch & Intonation Control',
            'detail':
                'Vary your voice pitch to keep listeners engaged. Avoid upward inflection at the end of statements ("uptalk"), which makes statements sound like weak questions.'
          },
        ]
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Tips Library',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Master Body Language',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        SizedBox(height: 4),
                        Text(
                            'Explore essential tips by category to boost your presence and confidence',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...categories.map((cat) {
              final title = cat['title'] as String;
              final icon = cat['icon'] as IconData;
              final color = cat['color'] as Color;
              final tips = cat['tips'] as List<Map<String, String>>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: tips.map((tip) {
                            return Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.15),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded,
                                          size: 16, color: color),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          tip['headline']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: Color(0xFF1A1A2E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    tip['detail']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
