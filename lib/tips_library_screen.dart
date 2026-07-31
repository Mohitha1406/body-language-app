import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';

class TipsLibraryScreen extends StatefulWidget {
  const TipsLibraryScreen({super.key});

  @override
  State<TipsLibraryScreen> createState() => _TipsLibraryScreenState();

  static List<Map<String, dynamic>> getCategories(Color primaryColor, {String lang = 'en'}) {
    final isHindi = lang == 'hi';

    return [
      {
        'categoryKey': 'posture',
        'title': isHindi ? 'मुद्रा और शरीर का संरेखण' : 'Posture & Body Alignment',
        'icon': Icons.accessibility_new_rounded,
        'color': primaryColor,
        'tips': [
          {
            'headline': isHindi
                ? 'रीढ़ सीधी रखें और कंधों को आराम दें'
                : 'Keep Spine Straight & Shoulders Relaxed',
            'detail': isHindi
                ? 'अपने कानों, कंधों और कूल्हों को एक सीध में रखें। झुकने या एक तरफ झुकने से बचें। तनाव कम करने के लिए अपने कंधों को पीछे और नीचे की ओर रोल करें।'
                : 'Align your ears, shoulders, and hips. Avoid slumping or leaning heavily to one side. Roll your shoulders back and down to reduce tension.'
          },
          {
            'headline': isHindi ? 'संतुलित वजन वितरण' : 'Balanced Weight Distribution',
            'detail': isHindi
                ? 'पैरों को कंधे की चौड़ाई के बराबर रखकर खड़े हों। स्थिरता और आत्मविश्वास दिखाने के लिए दोनों पैरों पर अपने शरीर का वजन समान रूप से वितरित करें।'
                : 'Stand with feet shoulder-width apart. Distribute your body weight evenly on both feet to project stability and confidence.'
          },
          {
            'headline': isHindi ? 'तटस्थ सिर कोण' : 'Neutral Head Angle',
            'detail': isHindi
                ? 'अपनी ठुड्डी को फर्श के समानांतर रखें। ऊपर की ओर झुकना आक्रामक लग सकता है, जबकि नीचे की ओर झुकना अधीनता का सुझाव देता है।'
                : 'Keep your chin parallel to the floor. Tilting up can look aggressive or arrogant, while tilting down suggests submissiveness.'
          },
          {
            'headline': isHindi ? 'खुला धड़ कोण' : 'Open Torso Angle',
            'detail': isHindi
                ? 'अपनी छाती को दूर किए बिना या अपनी बाहों को मोड़े बिना सीधे दर्शकों का सामना करें, जिससे पारदर्शिता और जुड़ाव बना रहे।'
                : 'Face the audience directly without angling your chest away or crossing your arms, showing transparency and engagement.'
          },
        ]
      },
      {
        'categoryKey': 'gesture',
        'title': isHindi ? 'हाथों के इशारे और हलचल' : 'Hand Gestures & Movement',
        'icon': Icons.pan_tool_rounded,
        'color': const Color(0xFF10B981),
        'tips': [
          {
            'headline': isHindi ? 'खुली हथेली के इशारों का प्रयोग करें' : 'Use Open Palm Gestures',
            'detail': isHindi
                ? 'खुली हथेलियां दिखाना ईमानदारी, खुलेपन और विश्वास का संकेत देता है। हाथों को कमर और छाती के बीच दृश्यमान रखें।'
                : 'Showing open palms signals honesty, openness, and trust. Keep hands visible in the "gesture box" between your waist and chest.'
          },
          {
            'headline': isHindi ? 'बेचैनी और खुद को छूने से बचें' : 'Avoid Fidgeting & Self-Touching',
            'detail': isHindi
                ? 'अपने चेहरे, गर्दन, बालों को छूने या कपड़े ठीक करने को कम से कम करें। छटपटाहट घबराहट का संकेत देती है।'
                : 'Minimize touching your face, neck, hair, or adjusting clothes. Fidgeting signals nervousness or insecurity.'
          },
          {
            'headline': isHindi ? 'उद्देश्यपूर्ण इशारा समय' : 'Purposeful Gesture Timing',
            'detail': isHindi
                ? 'सहज, विचारशील हाथ की हरकतों के साथ मुख्य बिंदुओं पर जोर दें। अपने बोलने की गति से अपने इशारों की गति का मिलान करें।'
                : 'Emphasize key points with smooth, deliberate hand movements. Match your gesture pace to your speaking cadence.'
          },
          {
            'headline': isHindi ? 'स्टीपल गेस्चर तकनीक' : 'The Steeple Gesture',
            'detail': isHindi
                ? 'गहरे विचार और अधिकार को प्रदर्शित करने के लिए सुनते या बोलते समय अपनी उंगलियों के सिरों को आपस में हल्का स्पर्श करें।'
                : 'Lightly touch your fingertips together to form a steeple shape when listening or speaking to demonstrate deep reflection and authority.'
          },
        ]
      },
      {
        'categoryKey': 'head',
        'title': isHindi ? 'आंखों का संपर्क और चेहरे के भाव' : 'Eye Contact & Facial Expressions',
        'icon': Icons.visibility_rounded,
        'color': const Color(0xFFF59E0B),
        'tips': [
          {
            'headline': isHindi ? '60/40 का नियम' : 'The 60/40 Rule',
            'detail': isHindi
                ? 'बोलते समय 60% से 70% समय सीधा आंख का संपर्क बनाए रखें। लगातार घूरना असहज लग सकता है; बहुत अधिक दूर देखना अनिच्छा दर्शाता है।'
                : 'Maintain direct eye contact 60% to 70% of the time when speaking. Staring continuously can feel intense; looking away too much signals disinterest.'
          },
          {
            'headline': isHindi ? 'त्रिकोणीय दृष्टि तकनीक' : 'Triangular Gaze Technique',
            'detail': isHindi
                ? 'आंखों के संपर्क को स्वाभाविक रखने के लिए अपनी दृष्टि को श्रोता की बाईं आंख, दाईं आंख और नाक के बीच स्थानांतरित करें।'
                : 'Shift your gaze naturally between the left eye, right eye, and mouth/bridge of nose of your listener to keep eye contact natural.'
          },
          {
            'headline': isHindi ? 'सच्ची मुस्कान (डूशेन स्माइल)' : 'Genuine Smiling (Duchenne Smile)',
            'detail': isHindi
                ? 'प्रामाणिक गर्मजोशी के लिए अपने मुंह और अपनी आंखों के आसपास की मांसपेशियों दोनों को संलग्न करें।'
                : 'Engage both your mouth and the muscles around your eyes for authentic warmth and rapport.'
          },
          {
            'headline': isHindi ? 'सूक्ष्म अभिव्यक्ति जागरूकता' : 'Micro-Expression Awareness',
            'detail': isHindi
                ? 'जबड़े को भींचने या भौहें सिकोड़ने से बचें। तनाव में भी सुलभ रहने के लिए चेहरे की मांसपेशियों को शिथिल रखें।'
                : 'Avoid tight jaw clenching or furrowed brows. Keep facial muscles relaxed to remain approachable and cool under pressure.'
          },
        ]
      },
      {
        'categoryKey': 'voice',
        'title': isHindi ? 'आवाज का प्रक्षेपण और ताल' : 'Voice Projection & Cadence',
        'icon': Icons.record_voice_over_rounded,
        'color': const Color(0xFF8B5CF6),
        'tips': [
          {
            'headline': isHindi ? 'डायफ्रामिक सांस लेना' : 'Diaphragmatic Breathing',
            'detail': isHindi
                ? 'छाती से सांस लेने के बजाय पेट से गहरी सांस लें। गहरी सांस लेने से आपकी आवाज स्थिर रहती है।'
                : 'Breathe deeply from your lower abdomen rather than shallow chest breaths. Deep breathing steadies your voice and prevents trembling.'
          },
          {
            'headline': isHindi ? 'रणनीतिक ठहराव' : 'Strategic Pauses',
            'detail': isHindi
                ? 'अनावश्यक शब्दों के बजाय छोटे 1-2 सेकंड के ठहराव का उपयोग करें। ठहराव ध्यान आकर्षित करता है।'
                : 'Embrace short 1-2 second pauses instead of filler words ("um", "ah", "like"). Pauses command attention and allow listeners to process.'
          },
          {
            'headline': isHindi ? 'गति और स्पष्टता' : 'Pacing & Articulation',
            'detail': isHindi
                ? 'मापी गई गति से बोलें (लगभग 130-150 शब्द प्रति मिनट)। स्पष्टता दर्शाने के लिए मुख्य शब्दों का स्पष्ट उच्चारण करें।'
                : 'Speak at a measured pace (approx. 130-150 words per minute). Enunciate key terms clearly to project clarity and mastery.'
          },
          {
            'headline': isHindi ? 'पिच और टोन नियंत्रण' : 'Pitch & Intonation Control',
            'detail': isHindi
                ? 'श्रोताओं को जोड़े रखने के लिए अपनी आवाज की पिच बदलें। वाक्यों के अंत में अनावश्यक ऊंची टोन से बचें।'
                : 'Vary your voice pitch to keep listeners engaged. Avoid upward inflection at the end of statements ("uptalk"), which makes statements sound like weak questions.'
          },
        ]
      },
    ];
  }
}

class _TipsLibraryScreenState extends State<TipsLibraryScreen> {
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _language = prefs.getString('language') ?? 'en';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;
    final categories = TipsLibraryScreen.getCategories(primaryColor, lang: _language);
    final isHindi = _language == 'hi';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: Text(isHindi ? 'टिप्स लाइब्रेरी' : 'Tips Library',
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            isHindi
                                ? 'बॉडी लैंग्वेज में महारत हासिल करें'
                                : 'Master Body Language',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                            isHindi
                                ? 'अपनी उपस्थिति और आत्मविश्वास बढ़ाने के लिए श्रेणी के अनुसार टिप्स देखें'
                                : 'Explore essential tips by category to boost your presence and confidence',
                            style: const TextStyle(
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
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
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
                                color: isDark
                                    ? const Color(0xFF2D2D2D)
                                    : const Color(0xFFF8FAFC),
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1A1A2E),
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
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey[700],
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
