import 'package:flutter_test/flutter_test.dart';
import 'package:confidai/validators.dart';

void main() {
  group('Category: Score & Calculation Tests (40 Unique Unit Tests)', () {
    // ----------------------------------------------------
    // OVERALL SCORE CALCULATION TESTS (15 tests)
    // ----------------------------------------------------
    test('SCORE-001: Perfect scores calculation (100, 100, 100)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 100,
        headStabilityScore: 100,
        gestureScore: 100,
      );
      expect(score, equals(100));
    });

    test('SCORE-002: Zero scores calculation (0, 0, 0)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 0,
        headStabilityScore: 0,
        gestureScore: 0,
      );
      expect(score, equals(0));
    });

    test('SCORE-003: Weighted average score check (80 posture, 70 head, 90 gesture)', () {
      // 80*0.4 = 32, 70*0.3 = 21, 90*0.3 = 27 -> Sum = 80
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 80,
        headStabilityScore: 70,
        gestureScore: 90,
      );
      expect(score, equals(80));
    });

    test('SCORE-004: Posture heavy weighting check (100 posture, 0 head, 0 gesture)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 100,
        headStabilityScore: 0,
        gestureScore: 0,
      );
      expect(score, equals(40));
    });

    test('SCORE-005: Head stability weighting check (0 posture, 100 head, 0 gesture)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 0,
        headStabilityScore: 100,
        gestureScore: 0,
      );
      expect(score, equals(30));
    });

    test('SCORE-006: Gesture weighting check (0 posture, 0 head, 100 gesture)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 0,
        headStabilityScore: 0,
        gestureScore: 100,
      );
      expect(score, equals(30));
    });

    test('SCORE-007: Rounding floating point result (85 posture, 85 head, 85 gesture)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 85,
        headStabilityScore: 85,
        gestureScore: 85,
      );
      expect(score, equals(85));
    });

    test('SCORE-008: Overflow score clamping above 100 (120, 150, 110)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 120,
        headStabilityScore: 150,
        gestureScore: 110,
      );
      expect(score, equals(100));
    });

    test('SCORE-009: Negative score clamping below 0 (-20, -5, -50)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: -20,
        headStabilityScore: -5,
        gestureScore: -50,
      );
      expect(score, equals(0));
    });

    test('SCORE-010: Typical user performance (75 posture, 80 head, 65 gesture)', () {
      // 75*0.4 = 30, 80*0.3 = 24, 65*0.3 = 19.5 -> 73.5 -> 74
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 75,
        headStabilityScore: 80,
        gestureScore: 65,
      );
      expect(score, equals(74));
    });

    test('SCORE-011: Asymmetric performance (50 posture, 100 head, 100 gesture)', () {
      // 50*0.4 = 20, 100*0.3 = 30, 100*0.3 = 30 -> 80
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 50,
        headStabilityScore: 100,
        gestureScore: 100,
      );
      expect(score, equals(80));
    });

    test('SCORE-012: Lower mid-tier score (40, 45, 50)', () {
      // 40*0.4 = 16, 45*0.3 = 13.5, 50*0.3 = 15 -> 44.5 -> 45
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 40,
        headStabilityScore: 45,
        gestureScore: 50,
      );
      expect(score, equals(45));
    });

    test('SCORE-013: High mid-tier score (88, 92, 85)', () {
      // 88*0.4 = 35.2, 92*0.3 = 27.6, 85*0.3 = 25.5 -> 88.3 -> 88
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 88,
        headStabilityScore: 92,
        gestureScore: 85,
      );
      expect(score, equals(88));
    });

    test('SCORE-014: Single point granularity test (1, 1, 1)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 1,
        headStabilityScore: 1,
        gestureScore: 1,
      );
      expect(score, equals(1));
    });

    test('SCORE-015: Boundary test at 99 (99, 99, 99)', () {
      final score = ScoreCalculator.calculateOverallScore(
        postureScore: 99,
        headStabilityScore: 99,
        gestureScore: 99,
      );
      expect(score, equals(99));
    });

    // ----------------------------------------------------
    // SCORE DIFFERENCE & DELTA MATH TESTS (15 tests)
    // ----------------------------------------------------
    test('SCORE-016: Score improvement difference (85 vs 70)', () {
      expect(ScoreCalculator.calculateScoreDifference(85, 70), equals(15));
    });

    test('SCORE-017: Score decrease difference (60 vs 75)', () {
      expect(ScoreCalculator.calculateScoreDifference(60, 75), equals(-15));
    });

    test('SCORE-018: Equal scores difference (80 vs 80)', () {
      expect(ScoreCalculator.calculateScoreDifference(80, 80), equals(0));
    });

    test('SCORE-019: Format positive score delta (+15%)', () {
      expect(ScoreCalculator.formatScoreDelta(15), equals('+15%'));
    });

    test('SCORE-020: Format negative score delta (-10%)', () {
      expect(ScoreCalculator.formatScoreDelta(-10), equals('-10%'));
    });

    test('SCORE-021: Format zero score delta (0%)', () {
      expect(ScoreCalculator.formatScoreDelta(0), equals('0%'));
    });

    test('SCORE-022: Maximum score increase (100 vs 0)', () {
      expect(ScoreCalculator.calculateScoreDifference(100, 0), equals(100));
    });

    test('SCORE-023: Maximum score decrease (0 vs 100)', () {
      expect(ScoreCalculator.calculateScoreDifference(0, 100), equals(-100));
    });

    test('SCORE-024: Format large positive delta (+100%)', () {
      expect(ScoreCalculator.formatScoreDelta(100), equals('+100%'));
    });

    test('SCORE-025: Format large negative delta (-100%)', () {
      expect(ScoreCalculator.formatScoreDelta(-100), equals('-100%'));
    });

    test('SCORE-026: Single digit improvement formatting (+5%)', () {
      expect(ScoreCalculator.formatScoreDelta(5), equals('+5%'));
    });

    test('SCORE-027: Single digit decline formatting (-3%)', () {
      expect(ScoreCalculator.formatScoreDelta(-3), equals('-3%'));
    });

    test('SCORE-028: Large score scale math (95 vs 10)', () {
      expect(ScoreCalculator.calculateScoreDifference(95, 10), equals(85));
    });

    test('SCORE-029: Minimal score gain (71 vs 70)', () {
      expect(ScoreCalculator.calculateScoreDifference(71, 70), equals(1));
    });

    test('SCORE-030: Minimal score drop (69 vs 70)', () {
      expect(ScoreCalculator.calculateScoreDifference(69, 70), equals(-1));
    });

    // ----------------------------------------------------
    // METRIC RATIO & BOUNDARY TESTS (10 tests)
    // ----------------------------------------------------
    test('SCORE-031: Clamp posture lower bound', () {
      expect(ScoreCalculator.calculateOverallScore(postureScore: -100, headStabilityScore: 50, gestureScore: 50), equals(30));
    });

    test('SCORE-032: Clamp head stability lower bound', () {
      expect(ScoreCalculator.calculateOverallScore(postureScore: 50, headStabilityScore: -100, gestureScore: 50), equals(35));
    });

    test('SCORE-033: Clamp gesture lower bound', () {
      expect(ScoreCalculator.calculateOverallScore(postureScore: 50, headStabilityScore: 50, gestureScore: -100), equals(35));
    });

    test('SCORE-034: Clamp posture upper bound', () {
      expect(ScoreCalculator.calculateOverallScore(postureScore: 500, headStabilityScore: 50, gestureScore: 50), equals(70));
    });

    test('SCORE-035: Clamp head stability upper bound', () {
      expect(ScoreCalculator.calculateOverallScore(postureScore: 50, headStabilityScore: 500, gestureScore: 50), equals(65));
    });

    test('SCORE-036: Clamp gesture upper bound', () {
      expect(ScoreCalculator.calculateOverallScore(postureScore: 50, headStabilityScore: 50, gestureScore: 500), equals(65));
    });

    test('SCORE-037: Score thresholds for excellent grade (>= 85)', () {
      final score = ScoreCalculator.calculateOverallScore(postureScore: 90, headStabilityScore: 85, gestureScore: 85);
      expect(score >= 85, isTrue);
    });

    test('SCORE-038: Score thresholds for good grade (70 - 84)', () {
      final score = ScoreCalculator.calculateOverallScore(postureScore: 75, headStabilityScore: 75, gestureScore: 75);
      expect(score >= 70 && score < 85, isTrue);
    });

    test('SCORE-039: Score thresholds for needs improvement (< 70)', () {
      final score = ScoreCalculator.calculateOverallScore(postureScore: 60, headStabilityScore: 60, gestureScore: 60);
      expect(score < 70, isTrue);
    });

    test('SCORE-040: Score calculation consistency across 100 calls', () {
      for (int i = 0; i < 100; i++) {
        final s = ScoreCalculator.calculateOverallScore(postureScore: i, headStabilityScore: i, gestureScore: i);
        expect(s, equals(i));
      }
    });
  });
}
