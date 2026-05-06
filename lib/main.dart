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
      title: 'Body Language AI',
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A73E8),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                    Icons.accessibility_new_rounded,
                    size: 60,
                    color: Color(0xFF1A73E8)),
              ),
              const SizedBox(height: 24),
              const Text('Body Language AI',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('Analyze. Improve. Confidence.',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 0.5)),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            ],
          ),
        ),
      ),
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
    if (_latestScore == -1) {
      return 'No sessions yet — start your first analysis!';
    }
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
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
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
              style: const TextStyle(
                  color: Colors.white70, fontSize: 10)),
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
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600])),
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
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('Hello, $_userName 👋',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 4),
                        Text(
                            'Ready to improve your body language?',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600])),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor:
                          const Color(0xFF1A73E8),
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
                      colors: [
                        Color(0xFF1A73E8),
                        Color(0xFF0D47A1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF1A73E8)
                              .withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text('Your Latest Score',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        _latestScore == -1
                            ? '-- %'
                            : '$_latestScore%',
                        style: TextStyle(
                            color: _latestScore == -1
                                ? Colors.white
                                : _getScoreColor(),
                            fontSize: 48,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _getScoreMessage(),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statChip('Sessions',
                              '$_totalSessions'),
                          const SizedBox(width: 12),
                          _statChip(
                              'Best Score',
                              _bestScore == -1
                                  ? '--'
                                  : '$_bestScore%'),
                          const SizedBox(width: 12),
                          _statChip('Streak',
                              '$_totalSessions days'),
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
                            builder: (_) =>
                                const CameraScreen()));
                    _loadData();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black
                                .withOpacity(0.06),
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
                            color: const Color(0xFF1A73E8)
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: const Icon(
                              Icons.videocam_rounded,
                              color: Color(0xFF1A73E8),
                              size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Start New Analysis',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Color(
                                          0xFF1A1A2E))),
                              SizedBox(height: 4),
                              Text(
                                  'Record video and get confidence score',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey,
                            size: 16),
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
    final List<String> raw =
        prefs.getStringList('sessions') ?? [];

    int bestScore = -1;
    if (raw.isNotEmpty) {
      final sessions = raw
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .toList();
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
        MaterialPageRoute(
            builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _profileStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 16),
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
              style: TextStyle(
                  fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _settingItem(IconData icon, String title,
      {VoidCallback? onTap}) {
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
            Icon(icon,
                color: const Color(0xFF1A73E8), size: 22),
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
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600])),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _profileStat(
                      '$_totalSessions', 'Sessions'),
                  _profileStat(
                      _bestScore == -1
                          ? '--'
                          : '$_bestScore%',
                      'Best Score'),
                  _profileStat(
                      '$_totalSessions', 'Streak'),
                ],
              ),
              const SizedBox(height: 32),
              _settingItem(
                  Icons.notifications_rounded,
                  'Notifications'),
              _settingItem(
                  Icons.bar_chart_rounded,
                  'Progress Report'),
              _settingItem(
                  Icons.help_outline_rounded,
                  'Help & Support'),
              _settingItem(
                Icons.info_outline_rounded,
                'About App',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const AboutScreen()),
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