import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (kIsWeb || _isInitialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(initSettings);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  static Future<void> scheduleWeeklySummary() async {
    if (kIsWeb) return;
    if (!_isInitialized) {
      await init();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawSessions = prefs.getStringList('sessions') ?? [];

      int count = 0;
      int scoreSum = 0;

      for (final raw in rawSessions) {
        try {
          final session = jsonDecode(raw) as Map<String, dynamic>;
          count++;
          scoreSum += (session['score'] as num? ?? 0).toInt();
        } catch (_) {}
      }

      final avgScore = count > 0 ? (scoreSum / count).round() : 0;
      final bodyText = count > 0
          ? "You practiced $count times this week, average score $avgScore%! 🎯"
          : "Keep your momentum going! Record a session to test your body language. 🚀";

      const androidDetails = AndroidNotificationDetails(
        'weekly_summary_channel',
        'Weekly Summary',
        channelDescription:
            'Weekly body language progress report notification',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.periodicallyShow(
        1001,
        'Weekly Progress Summary',
        bodyText,
        RepeatInterval.weekly,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    } catch (e) {
      debugPrint('Schedule weekly summary error: $e');
    }
  }
}
