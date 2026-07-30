class AppValidators {
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final trimmed = email.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9.\_%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(trimmed);
  }

  static bool isValidPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    return password.length >= 6;
  }

  static bool isStrongPassword(String? password) {
    if (password == null || password.length < 8) return false;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasUpper && hasLower && hasDigit && hasSpecial;
  }

  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return cleaned.length >= 7 && cleaned.length <= 15 && RegExp(r'^\d+$').hasMatch(cleaned);
  }

  static bool isValidOtp(String? otp) {
    if (otp == null || otp.trim().isEmpty) return false;
    final trimmed = otp.trim();
    return trimmed.length == 6 && RegExp(r'^\d{6}$').hasMatch(trimmed);
  }
}

class ScoreCalculator {
  static int calculateOverallScore({
    required int postureScore,
    required int headStabilityScore,
    required int gestureScore,
  }) {
    final posture = postureScore.clamp(0, 100);
    final head = headStabilityScore.clamp(0, 100);
    final gesture = gestureScore.clamp(0, 100);
    return ((posture * 0.4) + (head * 0.3) + (gesture * 0.3)).round();
  }

  static int calculateScoreDifference(int currentScore, int previousScore) {
    return currentScore - previousScore;
  }

  static String formatScoreDelta(int diff) {
    if (diff > 0) return '+$diff%';
    return '$diff%';
  }
}

class StreakDateUtils {
  static String formatDateKey(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatDurationSeconds(int seconds) {
    if (seconds < 0) return '00:00';
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  static int calculateStreakCount(Set<String> sessionDates, DateTime today) {
    int streak = 0;
    DateTime checkDate = today;
    while (true) {
      final key = formatDateKey(checkDate);
      if (sessionDates.contains(key)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
