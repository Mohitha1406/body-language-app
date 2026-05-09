import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'history_screen.dart';
import 'camera_screen.dart';
import 'login_screen.dart';
import 'about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bymsesfomceglnmxsxtz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5bXNlc2ZvbWNlZ2xubXhzeHR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5OTY5MTUsImV4cCI6MjA5MzU3MjkxNX0.L0bpy3N5Uxt5geqftgvW-K9YpwAAv0n7SxbknRnjE-o',
  );
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConfidAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1A73E8),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── NOTIFICATIONS SCREEN ────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {'icon': '🎯', 'title': 'Practice Reminder', 'body': 'You haven\'t practiced today. Record a session to keep your streak!', 'time': '2 hours ago'},
      {'icon': '🏆', 'title': 'New Achievement', 'body': 'Congratulations! You completed 3 sessions this week.', 'time': 'Yesterday'},
      {'icon': '💡', 'title': 'Tip of the Day', 'body': 'Maintain eye contact for at least 60% of your presentation for maximum impact.', 'time': '2 days ago'},
      {'icon': '📈', 'title': 'Progress Update', 'body': 'Your posture score improved by 15% compared to last week. Keep it up!', 'time': '3 days ago'},
      {'icon': '🎉', 'title': 'Welcome to ConfidAI', 'body': 'Start your first analysis to get your baseline confidence score.', 'time': '1 week ago'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: Text(n['icon']!,
                          style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(n['title']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1A1A2E))),
                          Text(n['time']!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(n['body']!,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── PROGRESS REPORT SCREEN ───────────────────────────────────────
class ProgressReportScreen extends StatefulWidget {
  const ProgressReportScreen({super.key});

  @override
  State<ProgressReportScreen> createState() =>
      _ProgressReportScreenState();
}

class _ProgressReportScreenState
    extends State<ProgressReportScreen> {
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('sessions') ?? [];
    setState(() {
      _sessions = raw
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final avgScore = _sessions.isEmpty
        ? 0
        : (_sessions.map((s) => s['score'] as int).reduce((a, b) => a + b) /
                _sessions.length)
            .round();
    final bestScore = _sessions.isEmpty
        ? 0
        : _sessions
            .map((s) => s['score'] as int)
            .reduce((a, b) => a > b ? a : b);
    final totalSessions = _sessions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Progress Report',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                    child: _summaryCard(
                        'Total Sessions',
                        '$totalSessions',
                        Icons.video_library_rounded,
                        const Color(0xFF1A73E8))),
                const SizedBox(width: 12),
                Expanded(
                    child: _summaryCard(
                        'Best Score',
                        '$bestScore%',
                        Icons.emoji_events_rounded,
                        const Color(0xFFF59E0B))),
                const SizedBox(width: 12),
                Expanded(
                    child: _summaryCard(
                        'Average',
                        '$avgScore%',
                        Icons.trending_up_rounded,
                        const Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 24),

            // Score level
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Performance Level',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 16),
                  _levelBar('Beginner', 0, 40, avgScore,
                      const Color(0xFFEF4444)),
                  const SizedBox(height: 8),
                  _levelBar('Developing', 40, 65, avgScore,
                      const Color(0xFFF59E0B)),
                  const SizedBox(height: 8),
                  _levelBar('Proficient', 65, 80, avgScore,
                      const Color(0xFF1A73E8)),
                  const SizedBox(height: 8),
                  _levelBar('Expert', 80, 100, avgScore,
                      const Color(0xFF10B981)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Session history list
            const Text('Session History',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            if (_sessions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No sessions yet',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14)),
                      Text(
                          'Record your first analysis to see progress',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_sessions.length, (i) {
                final s = _sessions[i];
                final score = s['score'] as int;
                Color scoreColor = score >= 75
                    ? const Color(0xFF10B981)
                    : score >= 50
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFEF4444);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: scoreColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('$score%',
                              style: TextStyle(
                                  color: scoreColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Session ${_sessions.length - i}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1A1A2E))),
                            Text(s['date'] ?? '',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500])),
                          ],
                        ),
                      ),
                      Icon(
                        score >= 75
                            ? Icons.trending_up_rounded
                            : Icons.trending_flat_rounded,
                        color: scoreColor,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _levelBar(String label, int min, int max,
      int currentScore, Color color) {
    final isCurrentLevel =
        currentScore >= min && currentScore < max;
    return Row(
      children: [
        SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: isCurrentLevel
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCurrentLevel
                        ? color
                        : Colors.grey[600]))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (max - min) / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                  isCurrentLevel ? color : color.withOpacity(0.3)),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$min-$max%',
            style:
                TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }
}

// ── HELP & SUPPORT SCREEN ────────────────────────────────────────
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How does the AI analyze my body language?',
        'a':
            'ConfidAI uses Google MediaPipe\'s Pose Landmarker to detect 33 body landmarks from your video. It analyzes shoulder alignment for posture, nose movement for head stability, and wrist visibility for gesture detection.'
      },
      {
        'q': 'Why is my score always the same?',
        'a':
            'Make sure you are standing in front of the camera and fully visible. The AI needs to detect your shoulders, head, and hands. Good lighting also helps improve detection accuracy.'
      },
      {
        'q': 'What is a good Confidence Score?',
        'a':
            'Scores above 75% are considered Proficient. Scores above 85% are Expert level. Most beginners start between 50-65% and improve with regular practice.'
      },
      {
        'q': 'How often should I practice?',
        'a':
            'We recommend practicing at least once daily. Consistent practice of 10-second sessions over 2 weeks shows significant improvement in most users.'
      },
      {
        'q': 'Does the app work without internet?',
        'a':
            'The AI analysis requires an internet connection to send your video to our backend server. Login and session history viewing can work offline.'
      },
      {
        'q': 'How is my data protected?',
        'a':
            'Your videos are processed and immediately deleted from our servers. We only store your score and session metadata. All data is encrypted using Supabase\'s enterprise-grade security.'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Help & Support',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
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
                  Icon(Icons.support_agent_rounded,
                      color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('How can we help?',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        SizedBox(height: 4),
                        Text(
                            'Find answers to common questions below',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Frequently Asked Questions',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            ...faqs.map((faq) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6)
                    ],
                  ),
                  child: ExpansionTile(
                    title: Text(faq['q']!,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E))),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 16),
                        child: Text(faq['a']!,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.5)),
                      )
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contact Us',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 12),
                  _contactRow(Icons.email_rounded,
                      'mohithapapudesi14@gmail.com'),
                  const SizedBox(height: 8),
                  _contactRow(Icons.language_rounded,
                      'confidai-b469a.web.app'),
                  const SizedBox(height: 8),
                  _contactRow(Icons.code_rounded,
                      'github.com/Mohitha1406/body-language-app'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1A73E8), size: 18),
        const SizedBox(width: 10),
        Text(text,
            style: TextStyle(
                fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }
}

// ── HOME SCREEN ──────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';
  String _userInitials = 'U';
  int _latestScore = -1;
  int _bestScore = -1;
  int _totalSessions = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    final List<String> raw =
        prefs.getStringList('sessions') ?? [];

    int latestScore = -1;
    int bestScore = -1;

    if (raw.isNotEmpty) {
      final sessions = raw
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .toList();
      latestScore = sessions.first['score'] as int;
      bestScore = sessions
          .map((s) => s['score'] as int)
          .reduce((a, b) => a > b ? a : b);
    }

    if (mounted) {
      setState(() {
        _userName = name;
        _userInitials = name
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join();
        _latestScore = latestScore;
        _bestScore = bestScore;
        _totalSessions = raw.length;
      });
    }
  }

  String _getScoreMessage() {
    if (_latestScore == -1) return 'No sessions yet — start your first analysis!';
    if (_latestScore >= 80) return 'Excellent! Keep it up! 🔥';
    if (_latestScore >= 65) return 'Good job! Keep practicing!';
    return 'Keep going — you\'re improving!';
  }

  Color _getScoreColor() {
    if (_latestScore == -1) return Colors.white;
    if (_latestScore >= 75) return const Color(0xFF10B981);
    if (_latestScore >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _tipCard(String emoji, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E))),
                Text(desc,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, $_userName 👋',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 4),
                        Text('Ready to improve your body language?',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF1A73E8),
                      radius: 22,
                      child: Text(_userInitials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF1A73E8).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Latest Score',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        _latestScore == -1 ? '-- %' : '$_latestScore%',
                        style: TextStyle(
                            color: _latestScore == -1
                                ? Colors.white
                                : _getScoreColor(),
                            fontSize: 48,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(_getScoreMessage(),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statChip('Sessions', '$_totalSessions'),
                          const SizedBox(width: 12),
                          _statChip('Best Score',
                              _bestScore == -1 ? '--' : '$_bestScore%'),
                          const SizedBox(width: 12),
                          _statChip('Streak', '$_totalSessions days'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CameraScreen()));
                    _loadData();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A73E8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.videocam_rounded,
                              color: Color(0xFF1A73E8), size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start New Analysis',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A2E))),
                              SizedBox(height: 4),
                              Text('Record video and get confidence score',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Quick Tips',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 12),
                _tipCard('🧍', 'Straight Posture',
                    'Keep your spine straight and shoulders relaxed'),
                _tipCard('🤲', 'Controlled Gestures',
                    'Use purposeful hand movements to emphasize points'),
                _tipCard('👁️', 'Eye Contact',
                    'Maintain steady eye contact with your audience'),
                _tipCard('🎙️', 'Steady Head',
                    'Avoid excessive nodding or head movements'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── PROFILE SCREEN ───────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'User';
  String _userEmail = '';
  String _userInitials = 'U';
  int _totalSessions = 0;
  int _bestScore = -1;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    final email = prefs.getString('user_email') ?? '';
    final List<String> raw = prefs.getStringList('sessions') ?? [];

    int bestScore = -1;
    if (raw.isNotEmpty) {
      final sessions =
          raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
      bestScore = sessions
          .map((s) => s['score'] as int)
          .reduce((a, b) => a > b ? a : b);
    }

    setState(() {
      _userName = name;
      _userEmail = email;
      _userInitials = name
          .trim()
          .split(' ')
          .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
          .take(2)
          .join();
      _totalSessions = raw.length;
      _bestScore = bestScore;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _profileStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A73E8))),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _settingItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1A73E8), size: 22),
            const SizedBox(width: 14),
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E))),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF1A73E8),
                child: Text(_userInitials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Text(_userName,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              Text(_userEmail,
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _profileStat('$_totalSessions', 'Sessions'),
                  _profileStat(
                      _bestScore == -1 ? '--' : '$_bestScore%',
                      'Best Score'),
                  _profileStat('$_totalSessions', 'Streak'),
                ],
              ),
              const SizedBox(height: 32),
              _settingItem(
                Icons.notifications_rounded,
                'Notifications',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              ),
              _settingItem(
                Icons.bar_chart_rounded,
                'Progress Report',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProgressReportScreen()),
                ),
              ),
              _settingItem(
                Icons.help_outline_rounded,
                'Help & Support',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen()),
                ),
              ),
              _settingItem(
                Icons.info_outline_rounded,
                'About App',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AboutScreen()),
                ),
              ),
              const SizedBox(height: 8),
              _settingItem(
                Icons.logout_rounded,
                'Logout',
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}