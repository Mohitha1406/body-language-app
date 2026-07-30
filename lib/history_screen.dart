import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'theme_provider.dart';
import 'main.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();

  static Future<void> addSession(
    double score, {
    double postureScore = 0.0,
    double headStabilityScore = 0.0,
    double gestureScore = 0.0,
    String duration = '15 sec',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> sessions =
        prefs.getStringList('sessions') ?? [];
    final now = DateTime.now();
    final session = jsonEncode({
      'date':
          '${now.day} ${_month(now.month)} ${now.year}',
      'time':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      'score': score.toInt(),
      'posture_score': postureScore.toInt(),
      'head_stability_score': headStabilityScore.toInt(),
      'gesture_score': gestureScore.toInt(),
      'duration': duration,
      'rating': 0,
    });
    sessions.insert(0, session);
    await prefs.setStringList('sessions', sessions);
  }

  static String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw =
        prefs.getStringList('sessions') ?? [];
    setState(() {
      _sessions = raw
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .toList();
      _loading = false;
    });
  }

  Future<void> _deleteSession(int index) async {
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
      if (index >= 0 && index < raw.length) {
        raw.removeAt(index);
        await prefs.setStringList('sessions', raw);
        _loadSessions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session deleted')),
          );
        }
      }
    }
  }

  Color _scoreColor(int score) {
    if (score >= 75) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppThemeProvider.of(context).primaryColor;
    final isDark = AppThemeProvider.of(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FF),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF1A73E8)))
          : _sessions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,
                          size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No sessions yet',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey)),
                      Text('Start your first analysis!',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    final rating = session['rating'] as int? ?? 0;

                    return Dismissible(
                      key: Key('session_${index}_${session['date']}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('Delete Session',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text(
                                'Delete this session? This cannot be undone.'),
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
                      },
                      onDismissed: (direction) async {
                        final prefs = await SharedPreferences.getInstance();
                        final List<String> raw =
                            prefs.getStringList('sessions') ?? [];
                        if (index >= 0 && index < raw.length) {
                          raw.removeAt(index);
                          await prefs.setStringList('sessions', raw);
                          _loadSessions();
                        }
                      },
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete_forever_rounded,
                            color: Colors.white, size: 28),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SessionDetailScreen(session: session),
                            ),
                          );
                          _loadSessions();
                        },
                        child: Container(
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
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: _scoreColor(session['score'])
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                      '${session['score']}%',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _scoreColor(
                                              session['score']))),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(session['date'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1A1A2E))),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${session['time']} · ${session['duration']}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500])),
                                    if (session['note'] != null &&
                                        session['note'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        session['note'].toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                    if (rating > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: List.generate(
                                          rating,
                                          (i) => const Icon(
                                            Icons.star_rounded,
                                            size: 14,
                                            color: Color(0xFFF59E0B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 20, color: Colors.grey),
                                onPressed: () => _deleteSession(index),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}