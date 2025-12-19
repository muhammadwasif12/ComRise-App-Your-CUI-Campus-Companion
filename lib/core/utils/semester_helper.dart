class SemesterHelper {
  /// Get current semester based on current date
  /// Fall: September - December (FA)
  /// Spring: February - July (SP)
  static String getCurrentSemester() {
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    // Fall semester: September (9) to December (12)
    if (month >= 9 && month <= 12) {
      return 'FA${year.toString().substring(2)}';
    }
    // Spring semester: February (2) to July (7)
    else if (month >= 2 && month <= 7) {
      return 'SP${year.toString().substring(2)}';
    }
    // January: Previous year's Fall semester
    else {
      return 'FA${(year - 1).toString().substring(2)}';
    }
  }

  /// Get semester display name
  static String getSemesterDisplayName(String semester) {
    if (semester.startsWith('FA')) {
      return 'Fall ${semester.substring(2)}';
    } else if (semester.startsWith('SP')) {
      return 'Spring ${semester.substring(2)}';
    }
    return semester;
  }

  /// Calculate batch end year (4 years from start)
  static int calculateBatchEndYear(int startYear) {
    return startYear + 4;
  }

  /// Generate batch years list
  static List<int> generateBatchYears() {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => currentYear - 5 + index);
  }
}
