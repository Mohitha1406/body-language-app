import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:confidai/theme_provider.dart';

void main() {
  group('Category: Data Serialization & Theme State Tests (40 Unique Unit Tests)', () {
    // ----------------------------------------------------
    // SESSION HISTORY JSON SERIALIZATION TESTS (20 tests)
    // ----------------------------------------------------
    test('DATA-001: Serialize complete session object to JSON', () {
      final session = {
        'date': '30 Jul 2026',
        'time': '10:30 AM',
        'duration': '02:45',
        'score': 88,
        'posture_score': 90,
        'head_stability_score': 85,
        'gesture_score': 88,
      };
      final jsonString = jsonEncode(session);
      expect(jsonString, contains('"score":88'));
      expect(jsonString, contains('"date":"30 Jul 2026"'));
    });

    test('DATA-002: Deserialize valid session JSON string', () {
      final jsonString = '{"date":"30 Jul 2026","time":"10:30 AM","duration":"02:45","score":88}';
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded['score'], equals(88));
      expect(decoded['duration'], equals('02:45'));
    });

    test('DATA-003: Fallback missing posture_score to overall score', () {
      final map = {'score': 80};
      final posture = (map['posture_score'] as num?)?.toInt() ?? map['score'] as int;
      expect(posture, equals(80));
    });

    test('DATA-004: Fallback missing head_stability_score to overall score', () {
      final map = {'score': 75};
      final head = (map['head_stability_score'] as num?)?.toInt() ?? map['score'] as int;
      expect(head, equals(75));
    });

    test('DATA-005: Fallback missing gesture_score to overall score', () {
      final map = {'score': 92};
      final gesture = (map['gesture_score'] as num?)?.toInt() ?? map['score'] as int;
      expect(gesture, equals(92));
    });

    test('DATA-006: Fallback missing score to zero', () {
      final map = <String, dynamic>{};
      final score = (map['score'] as num?)?.toInt() ?? 0;
      expect(score, equals(0));
    });

    test('DATA-007: Parse integer score passed as double in JSON', () {
      final map = {'score': 85.5};
      final score = (map['score'] as num).toInt();
      expect(score, equals(85));
    });

    test('DATA-008: Format CSV row from session data', () {
      final s = {
        'date': '30 Jul 2026',
        'time': '10:30 AM',
        'duration': '01:30',
        'score': 85,
        'posture_score': 88,
        'head_stability_score': 82,
        'gesture_score': 85
      };
      final csvRow = '"${s['date']}","${s['time']}","${s['duration']}",${s['score']},${s['posture_score']},${s['head_stability_score']},${s['gesture_score']}';
      expect(csvRow, equals('"30 Jul 2026","10:30 AM","01:30",85,88,82,85'));
    });

    test('DATA-009: Format CSV header string', () {
      const header = 'Date,Time,Duration,Overall Score %,Posture Score %,Head Stability Score %,Gesture Score %';
      expect(header, contains('Overall Score %'));
    });

    test('DATA-010: JSON list encoding of multiple session records', () {
      final list = [
        {'score': 80, 'date': '30 Jul 2026'},
        {'score': 90, 'date': '29 Jul 2026'}
      ];
      final jsonStr = jsonEncode(list);
      expect(jsonStr, contains('80'));
      expect(jsonStr, contains('90'));
    });

    test('DATA-011: JSON list decoding of session history array', () {
      final jsonStr = '[{"score":80},{"score":90}]';
      final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
      expect(list.length, equals(2));
      expect(list[0]['score'], equals(80));
    });

    test('DATA-012: Empty session history array parsing', () {
      final jsonStr = '[]';
      final list = jsonDecode(jsonStr) as List;
      expect(list.isEmpty, isTrue);
    });

    test('DATA-013: Session date fallback to empty string', () {
      final map = <String, dynamic>{};
      final date = map['date'] as String? ?? '';
      expect(date, isEmpty);
    });

    test('DATA-014: Session time fallback to empty string', () {
      final map = <String, dynamic>{};
      final time = map['time'] as String? ?? '';
      expect(time, isEmpty);
    });

    test('DATA-015: Session duration fallback to empty string', () {
      final map = <String, dynamic>{};
      final duration = map['duration'] as String? ?? '';
      expect(duration, isEmpty);
    });

    test('DATA-016: Max score extraction from session list', () {
      final sessions = [{'score': 70}, {'score': 95}, {'score': 85}];
      final bestScore = sessions.map((s) => s['score'] as int).reduce((a, b) => a > b ? a : b);
      expect(bestScore, equals(95));
    });

    test('DATA-017: Average score calculation from session list', () {
      final sessions = [{'score': 70}, {'score': 90}, {'score': 80}];
      final avg = (sessions.map((s) => s['score'] as int).reduce((a, b) => a + b) / sessions.length).round();
      expect(avg, equals(80));
    });

    test('DATA-018: Total session count computation', () {
      final sessions = [{'score': 70}, {'score': 90}, {'score': 80}];
      expect(sessions.length, equals(3));
    });

    test('DATA-019: Session list sorting by score descending', () {
      final sessions = [{'score': 70}, {'score': 95}, {'score': 85}];
      sessions.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      expect(sessions[0]['score'], equals(95));
    });

    test('DATA-020: Session list sorting by score ascending', () {
      final sessions = [{'score': 70}, {'score': 95}, {'score': 85}];
      sessions.sort((a, b) => (a['score'] as int).compareTo(b['score'] as int));
      expect(sessions[0]['score'], equals(70));
    });

    // ----------------------------------------------------
    // THEME PROVIDER STATE TESTS (20 tests)
    // ----------------------------------------------------
    test('DATA-021: ThemeProvider default blue accent color', () {
      final provider = ThemeProvider();
      expect(provider.accentName, equals('blue'));
    });

    test('DATA-022: ThemeProvider default dark mode setting is false', () {
      final provider = ThemeProvider();
      expect(provider.isDarkMode, isFalse);
    });

    test('DATA-023: Switch accent color to orange', () {
      final provider = ThemeProvider();
      provider.setAccentColor('orange');
      expect(provider.accentName, equals('orange'));
    });

    test('DATA-024: Switch accent color to green', () {
      final provider = ThemeProvider();
      provider.setAccentColor('green');
      expect(provider.accentName, equals('green'));
    });

    test('DATA-025: Switch accent color to blue', () {
      final provider = ThemeProvider();
      provider.setAccentColor('orange');
      provider.setAccentColor('blue');
      expect(provider.accentName, equals('blue'));
    });

    test('DATA-026: Primary color for blue accent (0xFF1A73E8)', () {
      final provider = ThemeProvider();
      provider.setAccentColor('blue');
      expect(provider.primaryColor.value, equals(0xFF1A73E8));
    });

    test('DATA-027: Primary color for orange accent (0xFFC84B31)', () {
      final provider = ThemeProvider();
      provider.setAccentColor('orange');
      expect(provider.primaryColor.value, equals(0xFFC84B31));
    });

    test('DATA-028: Primary color for green accent (0xFF1B5E20)', () {
      final provider = ThemeProvider();
      provider.setAccentColor('green');
      expect(provider.primaryColor.value, equals(0xFF1B5E20));
    });

    test('DATA-029: Toggle dark mode from false to true', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);
      expect(provider.isDarkMode, isTrue);
    });

    test('DATA-030: Toggle dark mode from true to false', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);
      provider.setDarkMode(false);
      expect(provider.isDarkMode, isFalse);
    });

    test('DATA-031: Invalid accent name falls back to blue primary color', () {
      final provider = ThemeProvider();
      provider.setAccentColor('unknown_color');
      expect(provider.primaryColor.value, equals(0xFF1A73E8));
    });

    test('DATA-032: ThemeData brightness matches dark mode false', () {
      final provider = ThemeProvider();
      expect(provider.themeData.brightness, equals(Brightness.light));
    });

    test('DATA-033: ThemeData brightness matches dark mode true', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);
      expect(provider.themeData.brightness, equals(Brightness.dark));
    });

    test('DATA-034: ThemeData scaffold background in light mode', () {
      final provider = ThemeProvider();
      expect(provider.themeData.scaffoldBackgroundColor.value, equals(0xFFF5F7FF));
    });

    test('DATA-035: ThemeData scaffold background in dark mode', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);
      expect(provider.themeData.scaffoldBackgroundColor.value, equals(0xFF121212));
    });

    test('DATA-036: ThemeProvider listener notification count on accent change', () {
      final provider = ThemeProvider();
      int callCount = 0;
      provider.addListener(() => callCount++);
      provider.setAccentColor('orange');
      expect(callCount, equals(1));
    });

    test('DATA-037: ThemeProvider listener notification count on dark mode toggle', () {
      final provider = ThemeProvider();
      int callCount = 0;
      provider.addListener(() => callCount++);
      provider.setDarkMode(true);
      expect(callCount, equals(1));
    });

    test('DATA-038: Ignore redundant dark mode toggle call', () {
      final provider = ThemeProvider();
      int callCount = 0;
      provider.addListener(() => callCount++);
      provider.setDarkMode(false);
      expect(callCount, equals(0));
    });

    test('DATA-039: Ignore redundant accent color set call', () {
      final provider = ThemeProvider();
      int callCount = 0;
      provider.addListener(() => callCount++);
      provider.setAccentColor('blue');
      expect(callCount, equals(0));
    });

    test('DATA-040: ThemeProvider rapid color switching integrity', () {
      final provider = ThemeProvider();
      provider.setAccentColor('orange');
      provider.setAccentColor('green');
      provider.setAccentColor('blue');
      provider.setAccentColor('orange');
      expect(provider.accentName, equals('orange'));
    });
  });
}
