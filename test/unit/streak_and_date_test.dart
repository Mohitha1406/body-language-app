import 'package:flutter_test/flutter_test.dart';
import 'package:confidai/validators.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Category: Streak & Date Logic Tests (40 Unique Unit Tests)', () {
    // ----------------------------------------------------
    // DATE KEY FORMATTING TESTS (15 tests)
    // ----------------------------------------------------
    test('DATE-001: Format date key for January 1st', () {
      final date = DateTime(2026, 1, 1);
      expect(StreakDateUtils.formatDateKey(date), equals('1 Jan 2026'));
    });

    test('DATE-002: Format date key for July 30th', () {
      final date = DateTime(2026, 7, 30);
      expect(StreakDateUtils.formatDateKey(date), equals('30 Jul 2026'));
    });

    test('DATE-003: Format date key for December 31st', () {
      final date = DateTime(2026, 12, 31);
      expect(StreakDateUtils.formatDateKey(date), equals('31 Dec 2026'));
    });

    test('DATE-004: Format date key for leap year February 29th', () {
      final date = DateTime(2028, 2, 29);
      expect(StreakDateUtils.formatDateKey(date), equals('29 Feb 2028'));
    });

    test('DATE-005: Format date key for March 15th', () {
      final date = DateTime(2026, 3, 15);
      expect(StreakDateUtils.formatDateKey(date), equals('15 Mar 2026'));
    });

    test('DATE-006: Format date key for April 5th', () {
      final date = DateTime(2026, 4, 5);
      expect(StreakDateUtils.formatDateKey(date), equals('5 Apr 2026'));
    });

    test('DATE-007: Format date key for May 20th', () {
      final date = DateTime(2026, 5, 20);
      expect(StreakDateUtils.formatDateKey(date), equals('20 May 2026'));
    });

    test('DATE-008: Format date key for June 10th', () {
      final date = DateTime(2026, 6, 10);
      expect(StreakDateUtils.formatDateKey(date), equals('10 Jun 2026'));
    });

    test('DATE-009: Format date key for August 14th', () {
      final date = DateTime(2026, 8, 14);
      expect(StreakDateUtils.formatDateKey(date), equals('14 Aug 2026'));
    });

    test('DATE-010: Format date key for September 9th', () {
      final date = DateTime(2026, 9, 9);
      expect(StreakDateUtils.formatDateKey(date), equals('9 Sep 2026'));
    });

    test('DATE-011: Format date key for October 25th', () {
      final date = DateTime(2026, 10, 25);
      expect(StreakDateUtils.formatDateKey(date), equals('25 Oct 2026'));
    });

    test('DATE-012: Format date key for November 18th', () {
      final date = DateTime(2026, 11, 18);
      expect(StreakDateUtils.formatDateKey(date), equals('18 Nov 2026'));
    });

    test('DATE-013: Format date key across century change (2100)', () {
      final date = DateTime(2100, 1, 1);
      expect(StreakDateUtils.formatDateKey(date), equals('1 Jan 2100'));
    });

    test('DATE-014: Date key consistency with single digit day', () {
      final date = DateTime(2026, 7, 4);
      expect(StreakDateUtils.formatDateKey(date), equals('4 Jul 2026'));
    });

    test('DATE-015: Date key consistency with double digit day', () {
      final date = DateTime(2026, 7, 24);
      expect(StreakDateUtils.formatDateKey(date), equals('24 Jul 2026'));
    });

    // ----------------------------------------------------
    // DURATION CONVERSION TESTS (15 tests)
    // ----------------------------------------------------
    test('DUR-016: Format 0 seconds to 00:00', () {
      expect(StreakDateUtils.formatDurationSeconds(0), equals('00:00'));
    });

    test('DUR-017: Format 45 seconds to 00:45', () {
      expect(StreakDateUtils.formatDurationSeconds(45), equals('00:45'));
    });

    test('DUR-018: Format 60 seconds to 01:00', () {
      expect(StreakDateUtils.formatDurationSeconds(60), equals('01:00'));
    });

    test('DUR-019: Format 125 seconds to 02:05', () {
      expect(StreakDateUtils.formatDurationSeconds(125), equals('02:05'));
    });

    test('DUR-020: Format 600 seconds to 10:00', () {
      expect(StreakDateUtils.formatDurationSeconds(600), equals('10:00'));
    });

    test('DUR-021: Format 3599 seconds to 59:59', () {
      expect(StreakDateUtils.formatDurationSeconds(3599), equals('59:59'));
    });

    test('DUR-022: Format negative seconds to 00:00 default', () {
      expect(StreakDateUtils.formatDurationSeconds(-10), equals('00:00'));
    });

    test('DUR-023: Format 1 second to 00:01', () {
      expect(StreakDateUtils.formatDurationSeconds(1), equals('00:01'));
    });

    test('DUR-024: Format 9 seconds to 00:09', () {
      expect(StreakDateUtils.formatDurationSeconds(9), equals('00:09'));
    });

    test('DUR-025: Format 10 seconds to 00:10', () {
      expect(StreakDateUtils.formatDurationSeconds(10), equals('00:10'));
    });

    test('DUR-026: Format 119 seconds to 01:59', () {
      expect(StreakDateUtils.formatDurationSeconds(119), equals('01:59'));
    });

    test('DUR-027: Format 180 seconds to 03:00', () {
      expect(StreakDateUtils.formatDurationSeconds(180), equals('03:00'));
    });

    test('DUR-028: Format 300 seconds to 05:00', () {
      expect(StreakDateUtils.formatDurationSeconds(300), equals('05:00'));
    });

    test('DUR-029: Format 90 seconds to 01:30', () {
      expect(StreakDateUtils.formatDurationSeconds(90), equals('01:30'));
    });

    test('DUR-030: Format 150 seconds to 02:30', () {
      expect(StreakDateUtils.formatDurationSeconds(150), equals('02:30'));
    });

    // ----------------------------------------------------
    // STREAK COUNTER LOGIC TESTS (10 tests)
    // ----------------------------------------------------
    test('STREAK-031: Active 3-day streak today', () {
      final today = DateTime(2026, 7, 30);
      final set = {
        '30 Jul 2026',
        '29 Jul 2026',
        '28 Jul 2026',
      };
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(3));
    });

    test('STREAK-032: No session today results in 0 streak', () {
      final today = DateTime(2026, 7, 30);
      final set = {
        '29 Jul 2026',
        '28 Jul 2026',
      };
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(0));
    });

    test('STREAK-033: Active 1-day streak (only today)', () {
      final today = DateTime(2026, 7, 30);
      final set = {'30 Jul 2026'};
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(1));
    });

    test('STREAK-034: Empty session dates set results in 0 streak', () {
      final today = DateTime(2026, 7, 30);
      expect(StreakDateUtils.calculateStreakCount({}, today), equals(0));
    });

    test('STREAK-035: Active 7-day streak', () {
      final today = DateTime(2026, 7, 30);
      final set = {
        '30 Jul 2026', '29 Jul 2026', '28 Jul 2026', '27 Jul 2026',
        '26 Jul 2026', '25 Jul 2026', '24 Jul 2026'
      };
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(7));
    });

    test('STREAK-036: Broken streak middle gap (30th, 29th present; 28th missing)', () {
      final today = DateTime(2026, 7, 30);
      final set = {'30 Jul 2026', '29 Jul 2026', '27 Jul 2026'};
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(2));
    });

    test('STREAK-037: Month boundary streak transition (1 Aug 2026 & 31 Jul 2026)', () {
      final today = DateTime(2026, 8, 1);
      final set = {'1 Aug 2026', '31 Jul 2026', '30 Jul 2026'};
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(3));
    });

    test('STREAK-038: Year boundary streak transition (1 Jan 2027 & 31 Dec 2026)', () {
      final today = DateTime(2027, 1, 1);
      final set = {'1 Jan 2027', '31 Dec 2026'};
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(2));
    });

    test('STREAK-039: Large 30-day streak calculation', () {
      final today = DateTime(2026, 7, 30);
      final set = <String>{};
      for (int i = 0; i < 30; i++) {
        set.add(StreakDateUtils.formatDateKey(today.subtract(Duration(days: i))));
      }
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(30));
    });

    test('STREAK-040: Duplicate entries in session dates handled safely', () {
      final today = DateTime(2026, 7, 30);
      final set = {'30 Jul 2026', '30 Jul 2026', '29 Jul 2026'};
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(2));
    });

    test('STREAK-041: Streak calculation for leap day February 29', () {
      final leapDay = DateTime(2028, 2, 29);
      final set = {'29 Feb 2028', '28 Feb 2028'};
      expect(StreakDateUtils.calculateStreakCount(set, leapDay), equals(2));
    });

    test('STREAK-042: Streak calculation for single day session on Jan 1', () {
      final newYear = DateTime(2026, 1, 1);
      final set = {'1 Jan 2026'};
      expect(StreakDateUtils.calculateStreakCount(set, newYear), equals(1));
    });

    test('STREAK-043: Duration formatting for 3600 seconds (60:00)', () {
      expect(StreakDateUtils.formatDurationSeconds(3600), equals('60:00'));
    });

    test('STREAK-044: Duration formatting for 59 seconds (00:59)', () {
      expect(StreakDateUtils.formatDurationSeconds(59), equals('00:59'));
    });

    test('STREAK-045: Duration formatting for 61 seconds (01:01)', () {
      expect(StreakDateUtils.formatDurationSeconds(61), equals('01:01'));
    });

    test('STREAK-046: Format date key for December 1st', () {
      expect(StreakDateUtils.formatDateKey(DateTime(2026, 12, 1)), equals('1 Dec 2026'));
    });

    test('STREAK-047: Format date key for February 1st', () {
      expect(StreakDateUtils.formatDateKey(DateTime(2026, 2, 1)), equals('1 Feb 2026'));
    });

    test('STREAK-048: Streak calculation with future date entry ignored', () {
      final today = DateTime(2026, 7, 30);
      final set = {'31 Jul 2026', '30 Jul 2026', '29 Jul 2026'};
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(2));
    });

    test('STREAK-049: Duration formatting for 1000 seconds (16:40)', () {
      expect(StreakDateUtils.formatDurationSeconds(1000), equals('16:40'));
    });

    test('STREAK-050: Streak calculation for 14 continuous days across two months', () {
      final today = DateTime(2026, 8, 7);
      final set = <String>{};
      for (int i = 0; i < 14; i++) {
        set.add(StreakDateUtils.formatDateKey(today.subtract(Duration(days: i))));
      }
      expect(StreakDateUtils.calculateStreakCount(set, today), equals(14));
    });
  });
}

