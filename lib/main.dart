import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'theme_provider.dart';
import 'notifications_service.dart';
import 'onboarding_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'history_screen.dart';
import 'camera_screen.dart';
import 'login_screen.dart';
import 'about_screen.dart';
import 'tips_library_screen.dart';
import 'achievements_screen.dart';
import 'otp_verification_screen.dart';
import 'reset_password_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bymsesfomceglnmxsxtz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5bXNlc2ZvbWNlZ2xubXhzeHR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5OTY5MTUsImV4cCI6MjA5MzU3MjkxNX0.L0bpy3N5Uxt5geqftgvW-K9YpwAAv0n7SxbknRnjE-o',
  );
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  final themeProvider = await ThemeProvider.create();
  await NotificationService.init();
  await NotificationService.scheduleWeeklySummary();

  runApp(
    AppThemeProvider(
      themeProvider: themeProvider,
      child: MyApp(
        isLoggedIn: isLoggedIn,
        hasSeenOnboarding: hasSeenOnboarding,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool hasSeenOnboarding;
  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.hasSeenOnboarding,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = AppThemeProvider.of(context);
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        Widget initialHome;
        if (!widget.hasSeenOnboarding) {
          initialHome = OnboardingScreen(isLoggedIn: widget.isLoggedIn);
        } else {
          initialHome = widget.isLoggedIn ? const MainScreen() : const LoginScreen();
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'ConfidAI',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: initialHome,
        );
      },
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
  String? _avatarPath;
  String _userName = 'User';

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = const ['ConfidAI', 'Session History', 'Profile'];

  @override
  void initState() {
    super.initState();
    _loadDrawerProfile();
  }

  Future<void> _loadDrawerProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    final avatar = prefs.getString('user_avatar_path');
    if (mounted) {
      setState(() {
        _userName = name;
        _avatarPath = avatar;
      });
    }
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

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, Color primaryColor) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: primaryColor),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: getAvatarImageProvider(_avatarPath),
                      child: getAvatarImageProvider(_avatarPath) == null
                          ? Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const Text('ConfidAI Companion',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _drawerItem(Icons.home_rounded, 'Home', () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              }, primaryColor),
              _drawerItem(Icons.history_rounded, 'History', () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              }, primaryColor),
              _drawerItem(Icons.person_rounded, 'Profile', () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              }, primaryColor),
              const Divider(),
              _drawerItem(Icons.settings_rounded, 'Settings', () async {
                Navigator.pop(context);
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                if (updated == true) {
                  _loadDrawerProfile();
                }
              }, primaryColor),
              _drawerItem(Icons.notifications_rounded, 'Notifications', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              }, primaryColor),
              _drawerItem(Icons.bar_chart_rounded, 'Progress Report', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProgressReportScreen()));
              }, primaryColor),
              _drawerItem(Icons.help_outline_rounded, 'Help & Support', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
              }, primaryColor),
              _drawerItem(Icons.info_outline_rounded, 'About App', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              }, primaryColor),
              _drawerItem(Icons.lightbulb_outline_rounded, 'Tips Library', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TipsLibraryScreen()));
              }, primaryColor),
              _drawerItem(Icons.emoji_events_outlined, 'Achievements', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()));
              }, primaryColor),
              const Spacer(),
              const Divider(),
              _drawerItem(Icons.logout_rounded, 'Logout', () {
                Navigator.pop(context);
                _logout();
              }, primaryColor),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
}

// ── NOTIFICATIONS & SETTINGS SCREEN ────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = AppThemeProvider.of(context);
    final primaryColor = themeProvider.primaryColor;
    final isDark = themeProvider.isDarkMode;

    final notifications = [
      {'icon': '🎯', 'title': 'Practice Reminder', 'body': 'You haven\'t practiced today. Record a session to keep your streak!', 'time': '2 hours ago'},
      {'icon': '🏆', 'title': 'New Achievement', 'body': 'Congratulations! You completed 3 sessions this week.', 'time': 'Yesterday'},
      {'icon': '💡', 'title': 'Tip of the Day', 'body': 'Maintain eye contact for at least 60% of your presentation for maximum impact.', 'time': '2 days ago'},
      {'icon': '📈', 'title': 'Progress Update', 'body': 'Your posture score improved by 15% compared to last week. Keep it up!', 'time': '3 days ago'},
      {'icon': '🎉', 'title': 'Welcome to ConfidAI', 'body': 'Start your first analysis to get your baseline confidence score.', 'time': '1 week ago'},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Notifications',
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

            Text('Recent Notifications',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            ...notifications.map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                          color: primaryColor.withOpacity(0.12),
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A2E))),
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
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey[600],
                                    height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _colorSwatch(
      BuildContext context, String code, String label, Color color) {
    final themeProvider = AppThemeProvider.of(context);
    final isSelected = themeProvider.accentName == code;

    return GestureDetector(
      onTap: () => themeProvider.setAccentColor(code),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: isSelected ? 10 : 4)
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey)),
        ],
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

  void _compareLast2Sessions() {
    if (_sessions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Need at least 2 practice sessions to compare')),
      );
      return;
    }

    final s1 = _sessions[0];
    final s2 = _sessions[1];

    final score1 = (s1['score'] as num?)?.toInt() ?? 0;
    final score2 = (s2['score'] as num?)?.toInt() ?? 0;

    final posture1 = (s1['posture_score'] as num?)?.toInt() ?? score1;
    final posture2 = (s2['posture_score'] as num?)?.toInt() ?? score2;

    final head1 = (s1['head_stability_score'] as num?)?.toInt() ?? score1;
    final head2 = (s2['head_stability_score'] as num?)?.toInt() ?? score2;

    final gesture1 = (s1['gesture_score'] as num?)?.toInt() ?? score1;
    final gesture2 = (s2['gesture_score'] as num?)?.toInt() ?? score2;

    Widget metricRow(String name, int val1, int val2) {
      final diff = val1 - val2;
      final diffText = diff > 0 ? '+$diff%' : '$diff%';
      final diffColor = diff > 0
          ? const Color(0xFF10B981)
          : diff < 0
              ? const Color(0xFFEF4444)
              : Colors.grey;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13)),
            ),
            Expanded(
              flex: 2,
              child: Text('$val2%',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ),
            Expanded(
              flex: 2,
              child: Text('$val1%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            Expanded(
              flex: 2,
              child: Text(diffText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: diffColor,
                      fontSize: 13)),
            ),
          ],
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = AppThemeProvider.of(context).isDarkMode;
        final primaryColor = AppThemeProvider.of(context).primaryColor;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Compare Last 2 Sessions',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  Expanded(
                    flex: 2,
                    child: Text('Session 2\n(${s2['date'] ?? ''})',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Session 1 (Latest)\n(${s1['date'] ?? ''})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryColor)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Diff',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ),
                ],
              ),
              const Divider(height: 24),
              metricRow('Overall Score', score1, score2),
              metricRow('Posture', posture1, posture2),
              metricRow('Head Stability', head1, head2),
              metricRow('Gestures', gesture1, gesture2),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _exportCsv() {
    if (_sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No session history to export')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln(
        'Date,Time,Duration,Overall Score %,Posture Score %,Head Stability Score %,Gesture Score %');

    for (final s in _sessions) {
      final date = s['date'] ?? '';
      final time = s['time'] ?? '';
      final duration = s['duration'] ?? '';
      final score = s['score'] ?? 0;
      final posture = s['posture_score'] ?? score;
      final head = s['head_stability_score'] ?? score;
      final gesture = s['gesture_score'] ?? score;

      buffer.writeln(
          '"$date","$time","$duration",$score,$posture,$head,$gesture');
    }

    Share.share(
      buffer.toString(),
      subject: 'ConfidAI_Session_History.csv',
    );
  }

  Widget _buildStreakCalendar(BuildContext context) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;
    final now = DateTime.now();

    // Generate last 28 days (4 rows of 7 days)
    final days = List.generate(28, (i) => now.subtract(Duration(days: 27 - i)));

    // Extract completed session dates set
    final Set<String> sessionDates = _sessions.map((s) {
      return s['date'] as String? ?? '';
    }).toSet();

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Streak Calendar (Last 28 Days)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              Icon(Icons.calendar_month_rounded, color: primaryColor, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              const months = [
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
              ];
              final dateKey =
                  '${day.day} ${months[day.month - 1]} ${day.year}';
              final hasSession = sessionDates.contains(dateKey);

              return Container(
                decoration: BoxDecoration(
                  color: hasSession
                      ? primaryColor
                      : (isDark ? Colors.white10 : Colors.grey[100]),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasSession
                        ? primaryColor
                        : (isDark ? Colors.white24 : Colors.grey[300]!),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          hasSession ? FontWeight.bold : FontWeight.normal,
                      color: hasSession
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey[600]),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;

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
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Progress Report',
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
            Row(
              children: [
                Expanded(
                    child: _summaryCard(
                        'Total Sessions',
                        '$totalSessions',
                        Icons.video_library_rounded,
                        primaryColor,
                        isDark)),
                const SizedBox(width: 12),
                Expanded(
                    child: _summaryCard(
                        'Best Score',
                        '$bestScore%',
                        Icons.emoji_events_rounded,
                        const Color(0xFFF59E0B),
                        isDark)),
                const SizedBox(width: 12),
                Expanded(
                    child: _summaryCard(
                        'Average',
                        '$avgScore%',
                        Icons.trending_up_rounded,
                        const Color(0xFF10B981),
                        isDark)),
              ],
            ),
            const SizedBox(height: 24),

            // Performance Level
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                  Text('Performance Level',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                  const SizedBox(height: 16),
                  _levelBar('Beginner', 0, 40, avgScore,
                      const Color(0xFFEF4444)),
                  const SizedBox(height: 8),
                  _levelBar('Developing', 40, 65, avgScore,
                      const Color(0xFFF59E0B)),
                  const SizedBox(height: 8),
                  _levelBar('Proficient', 65, 80, avgScore, primaryColor),
                  const SizedBox(height: 8),
                  _levelBar('Expert', 80, 100, avgScore,
                      const Color(0xFF10B981)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Streak Calendar View
            _buildStreakCalendar(context),

            // Compare Last 2 Sessions Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _compareLast2Sessions,
                icon: const Icon(Icons.compare_arrows_rounded),
                label: const Text('Compare Last 2 Sessions',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // CSV Export Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _exportCsv,
                icon: Icon(Icons.file_download_outlined, color: primaryColor),
                label: Text('Export Session History (CSV)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: primaryColor)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Session History',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            if (_sessions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionDetailScreen(session: s),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A2E))),
                              Text(s['date'] ?? '',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey[400],
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

  Widget _summaryCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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

// ── SESSION DETAIL SCREEN ─────────────────────────────────────────
class SessionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> session;

  const SessionDetailScreen({super.key, required this.session});

  Future<void> _deleteSession(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Session',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Delete this session? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> raw = prefs.getStringList('sessions') ?? [];
      raw.removeWhere((s) {
        final Map<String, dynamic> decoded = jsonDecode(s);
        return decoded['date'] == session['date'] &&
            decoded['time'] == session['time'];
      });
      await prefs.setStringList('sessions', raw);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Widget _scoreBar(BuildContext context, String label, double value) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              Text('${(value * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                  value <= 0 ? Colors.red : primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;

    final double overallScore = (session['score'] as num?)?.toDouble() ?? 0.0;
    final double postureScore =
        (session['posture_score'] as num?)?.toDouble() ?? overallScore;
    final double headScore =
        (session['head_stability_score'] as num?)?.toDouble() ?? overallScore;
    final double gestureScore =
        (session['gesture_score'] as num?)?.toDouble() ?? overallScore;
    final String date = session['date'] as String? ?? 'Session Detail';
    final String time = session['time'] as String? ?? '';
    final String duration = session['duration'] as String? ?? '';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Session Breakdown',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _deleteSession(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${overallScore.toInt()}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$time · $duration',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _scoreBar(context, 'Posture Alignment',
                      (postureScore / 100).clamp(0.0, 1.0)),
                  _scoreBar(context, 'Head Stability',
                      (headScore / 100).clamp(0.0, 1.0)),
                  _scoreBar(context, 'Hand Gestures',
                      (gestureScore / 100).clamp(0.0, 1.0)),
                  _scoreBar(context, 'Overall Presence',
                      (overallScore / 100).clamp(0.0, 1.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── HELP & SUPPORT SCREEN ────────────────────────────────────────
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;

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
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Help & Support',
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
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
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
            Text('Frequently Asked Questions',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            ...faqs.map((faq) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6)
                    ],
                  ),
                  child: ExpansionTile(
                    title: Text(faq['q']!,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E))),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 16),
                        child: Text(faq['a']!,
                            style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[600],
                                height: 1.5)),
                      )
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                  Text('Contact Us',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                  const SizedBox(height: 12),
                  _contactRow(context, Icons.email_rounded,
                      'mohithapapudesi14@gmail.com'),
                  const SizedBox(height: 8),
                  _contactRow(context, Icons.language_rounded,
                      'confidai-b469a.web.app'),
                  const SizedBox(height: 8),
                  _contactRow(context, Icons.code_rounded,
                      'github.com/Mohitha1406/body-language-app'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(BuildContext context, IconData icon, String text) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 18),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(
                fontSize: 13, color: Colors.grey)),
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
  String? _avatarPath;
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
    final avatar = prefs.getString('user_avatar_path');
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
        _avatarPath = avatar;
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

  Widget _tipCard(BuildContext context, String emoji, String title, String desc) {
    final isDark = AppThemeProvider.of(context).isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                Text(desc,
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
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
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E))),
                        const SizedBox(height: 4),
                        Text('Ready to improve your body language?',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        );
                        _loadData();
                      },
                      child: CircleAvatar(
                        backgroundColor: primaryColor,
                        radius: 22,
                        backgroundImage: getAvatarImageProvider(_avatarPath),
                        child: getAvatarImageProvider(_avatarPath) == null
                            ? Text(_userInitials,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14))
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: primaryColor.withOpacity(0.3),
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
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                            color: primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.videocam_rounded,
                              color: primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start New Analysis',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A2E))),
                              const SizedBox(height: 4),
                              const Text('Record video and get confidence score',
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
                Text('Quick Tips',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                const SizedBox(height: 12),
                _tipCard(context, '🧍', 'Straight Posture',
                    'Keep your spine straight and shoulders relaxed'),
                _tipCard(context, '🤲', 'Controlled Gestures',
                    'Use purposeful hand movements to emphasize points'),
                _tipCard(context, '👁️', 'Eye Contact',
                    'Maintain steady eye contact with your audience'),
                _tipCard(context, '🎙️', 'Steady Head',
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
  String? _userPhone;
  String _userInitials = 'U';
  String? _avatarPath;
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
    final phone = prefs.getString('user_phone');
    final avatar = prefs.getString('user_avatar_path');
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
      _userPhone = phone;
      _avatarPath = avatar;
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

  Widget _profileStat(BuildContext context, String value, String label) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _settingItem(BuildContext context, IconData icon, String title,
      {VoidCallback? onTap}) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
            Icon(icon, color: primaryColor, size: 22),
            const SizedBox(width: 14),
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
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
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: primaryColor,
                backgroundImage: getAvatarImageProvider(_avatarPath),
                child: getAvatarImageProvider(_avatarPath) == null
                    ? Text(_userInitials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(height: 16),
              Text(_userName,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              Text(_userEmail,
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey[600])),
              if (_userPhone != null && _userPhone!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(_userPhone!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _profileStat(context, '$_totalSessions', 'Sessions'),
                  _profileStat(
                      context,
                      _bestScore == -1 ? '--' : '$_bestScore%',
                      'Best Score'),
                  _profileStat(context, '$_totalSessions', 'Streak'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    );
                    if (updated == true) _loadUser();
                  },
                  icon: const Icon(Icons.settings_rounded, size: 18),
                  label: const Text('Settings',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _settingItem(
                context,
                Icons.settings_suggest_rounded,
                'Theme & Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              ),
              _settingItem(
                context,
                Icons.bar_chart_rounded,
                'Progress Report',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProgressReportScreen()),
                ),
              ),
              _settingItem(
                context,
                Icons.help_outline_rounded,
                'Help & Support',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen()),
                ),
              ),
              _settingItem(
                context,
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
                context,
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