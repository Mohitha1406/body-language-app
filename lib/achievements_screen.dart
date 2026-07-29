import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('sessions') ?? [];
    if (mounted) {
      setState(() {
        _sessions = raw
            .map((s) => jsonDecode(s) as Map<String, dynamic>)
            .toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSessions = _sessions.length;
    final bestScore = _sessions.isEmpty
        ? 0
        : _sessions
            .map((s) => (s['score'] as num).toInt())
            .reduce((a, b) => a > b ? a : b);

    final badges = [
      {
        'title': 'First Session',
        'desc': 'Complete your 1st analysis session',
        'icon': Icons.stars_rounded,
        'unlocked': totalSessions >= 1,
        'color': const Color(0xFF1A73E8),
      },
      {
        'title': '3-Day Streak',
        'desc': 'Complete 3 practice sessions',
        'icon': Icons.local_fire_department_rounded,
        'unlocked': totalSessions >= 3,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Score 75+',
        'desc': 'Reach a confidence score of 75%',
        'icon': Icons.emoji_events_rounded,
        'unlocked': bestScore >= 75,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Master 90+',
        'desc': 'Reach an expert score of 90%',
        'icon': Icons.workspace_premium_rounded,
        'unlocked': bestScore >= 90,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Dedicated Practitioner',
        'desc': 'Complete 5 practice sessions',
        'icon': Icons.fitness_center_rounded,
        'unlocked': totalSessions >= 5,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Body Language Pro',
        'desc': 'Complete 10 total sessions',
        'icon': Icons.psychology_rounded,
        'unlocked': totalSessions >= 10,
        'color': const Color(0xFF06B6D4),
      },
    ];

    final unlockedCount = badges.where((b) => b['unlocked'] as bool).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Achievements',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A73E8)))
          : SingleChildScrollView(
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
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.military_tech_rounded,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$unlockedCount of ${badges.length} Unlocked',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: badges.isEmpty
                                      ? 0
                                      : unlockedCount / badges.length,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.greenAccent),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Badges',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      final isUnlocked = badge['unlocked'] as bool;
                      final color = badge['color'] as Color;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isUnlocked
                              ? Border.all(
                                  color: color.withOpacity(0.3), width: 1.5)
                              : Border.all(color: Colors.grey.withOpacity(0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? color.withOpacity(0.12)
                                        : Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    badge['icon'] as IconData,
                                    color: isUnlocked
                                        ? color
                                        : Colors.grey[400],
                                    size: 28,
                                  ),
                                ),
                                if (!isUnlocked)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lock_rounded,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              badge['title'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isUnlocked
                                    ? const Color(0xFF1A1A2E)
                                    : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge['desc'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: isUnlocked
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
