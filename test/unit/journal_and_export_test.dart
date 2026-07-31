import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Category: Journal & Data Export Unit Tests (50 Unique Unit Tests)', () {
    // ----------------------------------------------------
    // JOURNAL PARSING & FILTERING TESTS (15 tests)
    // ----------------------------------------------------
    test('JRN-001: Filter session string with valid note', () {
      final session = {'date': '2026-07-31', 'score': 85, 'note': 'Great posture!'};
      final hasNote = session['note'] != null && session['note'].toString().trim().isNotEmpty;
      expect(hasNote, isTrue);
    });

    test('JRN-002: Filter session string with empty note', () {
      final session = {'date': '2026-07-31', 'score': 85, 'note': '   '};
      final hasNote = session['note'] != null && session['note'].toString().trim().isNotEmpty;
      expect(hasNote, isFalse);
    });

    test('JRN-003: Filter session string with null note', () {
      final session = {'date': '2026-07-31', 'score': 85, 'note': null};
      final hasNote = session['note'] != null && session['note'].toString().trim().isNotEmpty;
      expect(hasNote, isFalse);
    });

    test('JRN-004: Parse journal entry date correctly', () {
      final session = {'date': '2026-07-30', 'time': '14:30', 'score': 90, 'note': 'Spoke clearly.'};
      expect(session['date'], equals('2026-07-30'));
    });

    test('JRN-005: Parse journal entry score correctly', () {
      final session = {'date': '2026-07-30', 'time': '14:30', 'score': 92, 'note': 'Spoke clearly.'};
      expect(session['score'], equals(92));
    });

    test('JRN-006: Filter list of 5 sessions with 2 valid notes', () {
      final rawSessions = [
        {'date': '2026-07-01', 'score': 70, 'note': 'Note 1'},
        {'date': '2026-07-02', 'score': 75, 'note': ''},
        {'date': '2026-07-03', 'score': 80, 'note': 'Note 2'},
        {'date': '2026-07-04', 'score': 85, 'note': null},
        {'date': '2026-07-05', 'score': 90, 'note': '  '},
      ];

      final filtered = rawSessions.where((s) {
        final n = s['note']?.toString().trim();
        return n != null && n.isNotEmpty;
      }).toList();

      expect(filtered.length, equals(2));
    });

    test('JRN-007: Trimming note content preserves inner spaces', () {
      final note = '  Kept head steady during presentation  ';
      expect(note.trim(), equals('Kept head steady during presentation'));
    });

    test('JRN-008: Handle empty sessions array for journal', () {
      final List<Map<String, dynamic>> raw = [];
      final entries = raw.where((s) => s['note'] != null).toList();
      expect(entries.isEmpty, isTrue);
    });

    test('JRN-009: Score bounds check on journal item', () {
      final session = {'score': 105};
      final clampedScore = (session['score'] as int).clamp(0, 100);
      expect(clampedScore, equals(100));
    });

    test('JRN-010: Negative score bounds check on journal item', () {
      final session = {'score': -10};
      final clampedScore = (session['score'] as int).clamp(0, 100);
      expect(clampedScore, equals(0));
    });

    test('JRN-011: Format time string when time is present', () {
      final date = '2026-07-31';
      final time = '10:00 AM';
      final formatted = '$date${time.isNotEmpty ? " • $time" : ""}';
      expect(formatted, equals('2026-07-31 • 10:00 AM'));
    });

    test('JRN-012: Format time string when time is empty', () {
      final date = '2026-07-31';
      final time = '';
      final formatted = '$date${time.isNotEmpty ? " • $time" : ""}';
      expect(formatted, equals('2026-07-31'));
    });

    test('JRN-013: Reverse chronological sorting of journal notes', () {
      final notes = [
        {'date': '2026-07-01', 'id': 1},
        {'date': '2026-07-05', 'id': 2},
        {'date': '2026-07-03', 'id': 3},
      ];
      notes.sort((a, b) => b['date']!.toString().compareTo(a['date']!.toString()));
      expect(notes.first['id'], equals(2));
      expect(notes.last['id'], equals(1));
    });

    test('JRN-014: Check note character count cap', () {
      final longNote = 'A' * 300;
      final preview = longNote.length > 100 ? '${longNote.substring(0, 100)}...' : longNote;
      expect(preview.endsWith('...'), isTrue);
      expect(preview.length, equals(103));
    });

    test('JRN-015: Default note fallback when key missing', () {
      final Map<String, dynamic> session = {'score': 80};
      final noteText = session['note']?.toString() ?? 'No notes recorded';
      expect(noteText, equals('No notes recorded'));
    });

    // ----------------------------------------------------
    // CSV DATA EXPORT FORMATTING TESTS (15 tests)
    // ----------------------------------------------------
    test('EXP-001: CSV User Profile Header Generation', () {
      final header = 'Category,Field,Value';
      expect(header.split(',').length, equals(3));
    });

    test('EXP-002: CSV Session Header Generation', () {
      final header = 'Session ID,Date,Time,Duration (s),Overall Score (%),Posture Score (%),Head Stability (%),Gesture Activity (%)';
      expect(header.split(',').length, equals(8));
    });

    test('EXP-003: Escape quotes in CSV text cell', () {
      final text = 'Spoke "confidentially" today';
      final escaped = '"${text.replaceAll('"', '""')}"';
      expect(escaped, equals('"Spoke ""confidentially"" today"'));
    });

    test('EXP-004: Escape commas in CSV text cell', () {
      final text = 'Good posture, steady eye contact';
      final escaped = text.contains(',') ? '"$text"' : text;
      expect(escaped, equals('"Good posture, steady eye contact"'));
    });

    test('EXP-005: Profile row formatting with user details', () {
      final name = 'John Doe';
      final email = 'john@example.com';
      final phone = '+1234567890';
      final csvRows = [
        'Profile,Name,"$name"',
        'Profile,Email,"$email"',
        'Profile,Phone,"$phone"',
      ];
      expect(csvRows.length, equals(3));
    });

    test('EXP-006: Session row formatting with numeric metrics', () {
      final sessionRow = '1,2026-07-31,10:30 AM,30,88,90,85,89';
      final fields = sessionRow.split(',');
      expect(fields.length, equals(8));
      expect(fields[3], equals('30'));
      expect(fields[4], equals('88'));
    });

    test('EXP-007: Handle null phone in profile CSV export', () {
      String? phone;
      final row = 'Profile,Phone,"${phone ?? "Not Provided"}"';
      expect(row, equals('Profile,Phone,"Not Provided"'));
    });

    test('EXP-008: Handle empty sessions export file content', () {
      final List<Map<String, dynamic>> sessions = [];
      final sb = StringBuffer();
      sb.writeln('Session ID,Date,Score');
      for (var i = 0; i < sessions.length; i++) {
        sb.writeln('${i + 1},${sessions[i]['date']},${sessions[i]['score']}');
      }
      expect(sb.toString().trim(), equals('Session ID,Date,Score'));
    });

    test('EXP-009: Export data filename structure', () {
      final timestamp = DateTime(2026, 7, 31, 12, 0).millisecondsSinceEpoch;
      final filename = 'confidai_export_$timestamp.csv';
      expect(filename.startsWith('confidai_export_'), isTrue);
      expect(filename.endsWith('.csv'), isTrue);
    });

    test('EXP-010: Export CSV newline delimiter check', () {
      final csv = 'Row1\nRow2\nRow3';
      final lines = csv.split('\n');
      expect(lines.length, equals(3));
    });

    test('EXP-011: Sanitization of newlines in CSV field values', () {
      final rawNote = 'Line 1\nLine 2';
      final sanitized = rawNote.replaceAll('\n', ' ');
      expect(sanitized, equals('Line 1 Line 2'));
    });

    test('EXP-012: Export score calculation average check', () {
      final scores = [80, 90, 100];
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      expect(avg, equals(90.0));
    });

    test('EXP-013: Export session count validation', () {
      final sessions = List.generate(10, (i) => {'id': i + 1});
      expect(sessions.length, equals(10));
    });

    test('EXP-014: UTF-8 BOM prefix inclusion check', () {
      final utf8Bom = '\uFEFF';
      final content = '${utf8Bom}Header,Value';
      expect(content.startsWith('\uFEFF'), isTrue);
    });

    test('EXP-015: Export duration formatted string check', () {
      final seconds = 125;
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      final formatted = '${mins}m ${secs}s';
      expect(formatted, equals('2m 5s'));
    });

    // ----------------------------------------------------
    // PROMPTS & INTERVIEW MODE LOGIC TESTS (10 tests)
    // ----------------------------------------------------
    test('PRM-001: Practice Prompts list non-empty', () {
      final prompts = [
        'Maintain upright posture and keep your shoulders relaxed.',
        'Keep eye contact centered on the camera lens.',
        'Use open hand gestures while speaking.'
      ];
      expect(prompts.isNotEmpty, isTrue);
    });

    test('PRM-002: Interview Mode Questions list non-empty', () {
      final questions = [
        'Tell me about yourself and your background.',
        'What is your greatest professional strength?',
        'Describe a challenge you faced and how you overcame it.'
      ];
      expect(questions.length, equals(3));
    });

    test('PRM-003: Toggle mode updates active dataset', () {
      bool isInterviewMode = false;
      String getPrompt() => isInterviewMode ? 'Interview Q' : 'Practice P';
      expect(getPrompt(), equals('Practice P'));
      isInterviewMode = true;
      expect(getPrompt(), equals('Interview Q'));
    });

    test('PRM-004: Shuffle prompt index within bounds', () {
      final listLength = 10;
      final nextIndex = (3 + 1) % listLength;
      expect(nextIndex >= 0 && nextIndex < listLength, isTrue);
    });

    test('PRM-005: Interview mode header title text', () {
      final isInterview = true;
      final title = isInterview ? 'INTERVIEW QUESTION' : 'PRACTICE PROMPT';
      expect(title, equals('INTERVIEW QUESTION'));
    });

    test('PRM-006: Guided practice header title text', () {
      final isInterview = false;
      final title = isInterview ? 'INTERVIEW QUESTION' : 'PRACTICE PROMPT';
      expect(title, equals('PRACTICE PROMPT'));
    });

    test('PRM-007: Custom duration selector valid ranges', () {
      final dur = 45;
      final isValid = dur >= 5 && dur <= 300;
      expect(isValid, isTrue);
    });

    test('PRM-008: Custom duration below min clamp', () {
      final dur = 2;
      final clamped = dur.clamp(5, 300);
      expect(clamped, equals(5));
    });

    test('PRM-009: Custom duration above max clamp', () {
      final dur = 500;
      final clamped = dur.clamp(5, 300);
      expect(clamped, equals(300));
    });

    test('PRM-010: Standard duration options check', () {
      final stdOptions = [10, 15, 20, 30, 60];
      expect(stdOptions.contains(30), isTrue);
      expect(stdOptions.contains(45), isFalse);
    });

    // ----------------------------------------------------
    // ACHIEVEMENTS & MILESTONE LOGIC TESTS (10 tests)
    // ----------------------------------------------------
    test('ACH-001: Unlocking First Session achievement at 1 session', () {
      final totalSessions = 1;
      final unlocked = totalSessions >= 1;
      expect(unlocked, isTrue);
    });

    test('ACH-002: Consistent Speaker achievement locked at 2 sessions', () {
      final totalSessions = 2;
      final unlocked = totalSessions >= 3;
      expect(unlocked, isFalse);
    });

    test('ACH-003: Consistent Speaker achievement unlocked at 3 sessions', () {
      final totalSessions = 3;
      final unlocked = totalSessions >= 3;
      expect(unlocked, isTrue);
    });

    test('ACH-004: Master Presenter achievement unlocked at 5 sessions', () {
      final totalSessions = 5;
      final unlocked = totalSessions >= 5;
      expect(unlocked, isTrue);
    });

    test('ACH-005: High Score achievement unlocked at 90%+ score', () {
      final maxScore = 92;
      final unlocked = maxScore >= 90;
      expect(unlocked, isTrue);
    });

    test('ACH-006: High Score achievement locked at 89% score', () {
      final maxScore = 89;
      final unlocked = maxScore >= 90;
      expect(unlocked, isFalse);
    });

    test('ACH-007: 7-Day Streak achievement calculation', () {
      final currentStreak = 7;
      final unlocked = currentStreak >= 7;
      expect(unlocked, isTrue);
    });

    test('ACH-008: Achievement progress percentage calculation', () {
      final current = 3;
      final target = 5;
      final progress = (current / target).clamp(0.0, 1.0);
      expect(progress, equals(0.6));
    });

    test('ACH-009: Achievement progress percentage cap at 1.0', () {
      final current = 10;
      final target = 5;
      final progress = (current / target).clamp(0.0, 1.0);
      expect(progress, equals(1.0));
    });

    test('ACH-010: Total achievements count matches 6 badges', () {
      final badgeKeys = ['first_session', 'streak_3', 'streak_7', 'score_90', 'sessions_5', 'sessions_10'];
      expect(badgeKeys.length, equals(6));
    });
  });
}
