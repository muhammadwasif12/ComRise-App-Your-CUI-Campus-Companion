// lib/core/utils/grade_utils.dart
class GradeUtils {
  // COMSATS Grading System
  static String getLetterGrade(double marks) {
    if (marks >= 85) return 'A';
    if (marks >= 80) return 'A-';
    if (marks >= 75) return 'B+';
    if (marks >= 71) return 'B';
    if (marks >= 68) return 'B-';
    if (marks >= 64) return 'C+';
    if (marks >= 61) return 'C';
    if (marks >= 58) return 'C-';
    if (marks >= 54) return 'D+';
    if (marks >= 50) return 'D';
    return 'F';
  }

  static double getGradePoint(double marks) {
    if (marks >= 85) return 4.00;
    if (marks >= 80) return 3.66;
    if (marks >= 75) return 3.33;
    if (marks >= 71) return 3.00;
    if (marks >= 68) return 2.66;
    if (marks >= 64) return 2.33;
    if (marks >= 61) return 2.00;
    if (marks >= 58) return 1.66;
    if (marks >= 54) return 1.30;
    if (marks >= 50) return 1.00;
    return 0.00;
  }

  static double marksFromGradePoint(double gradePoint) {
    if (gradePoint >= 4.00) return 85.0;
    if (gradePoint >= 3.66) return 80.0;
    if (gradePoint >= 3.33) return 75.0;
    if (gradePoint >= 3.00) return 71.0;
    if (gradePoint >= 2.66) return 68.0;
    if (gradePoint >= 2.33) return 64.0;
    if (gradePoint >= 2.00) return 61.0;
    if (gradePoint >= 1.66) return 58.0;
    if (gradePoint >= 1.30) return 54.0;
    if (gradePoint >= 1.00) return 50.0;
    return 0.0;
  }

  static String getPerformanceLevel(double gpa) {
    if (gpa >= 3.7) return 'Excellent';
    if (gpa >= 3.3) return 'Very Good';
    if (gpa >= 3.0) return 'Good';
    if (gpa >= 2.5) return 'Satisfactory';
    if (gpa >= 2.0) return 'Pass';
    return 'Needs Improvement';
  }

  static List<Map<String, dynamic>> getAllGrades() {
    return [
      {'grade': 'A', 'range': '85-100', 'gp': 4.00},
      {'grade': 'A-', 'range': '80-84', 'gp': 3.66},
      {'grade': 'B+', 'range': '75-79', 'gp': 3.33},
      {'grade': 'B', 'range': '71-74', 'gp': 3.00},
      {'grade': 'B-', 'range': '68-70', 'gp': 2.66},
      {'grade': 'C+', 'range': '64-67', 'gp': 2.33},
      {'grade': 'C', 'range': '61-63', 'gp': 2.00},
      {'grade': 'C-', 'range': '58-60', 'gp': 1.66},
      {'grade': 'D+', 'range': '54-57', 'gp': 1.30},
      {'grade': 'D', 'range': '50-53', 'gp': 1.00},
      {'grade': 'F', 'range': '< 50', 'gp': 0.00},
    ];
  }

  // Calculate weighted internal marks
  static double calculateInternalMarks({
    required double assignments,
    required double quizzes,
    required double midterm,
    required double finalExam,
  }) {
    return (assignments * 0.10) +
        (quizzes * 0.15) +
        (midterm * 0.25) +
        (finalExam * 0.50);
  }

  // Calculate required GPA for target CGPA
  static double calculateRequiredGPA({
    required double currentCGPA,
    required double completedCredits,
    required double targetCGPA,
    required double upcomingCredits,
  }) {
    final totalCredits = completedCredits + upcomingCredits;
    return (targetCGPA * totalCredits - currentCGPA * completedCredits) /
        upcomingCredits;
  }

  // Calculate maximum possible CGPA
  static double calculateMaxPossibleCGPA({
    required double currentCGPA,
    required double completedCredits,
    required double upcomingCredits,
  }) {
    final totalCredits = completedCredits + upcomingCredits;
    return (currentCGPA * completedCredits + 4.0 * upcomingCredits) /
        totalCredits;
  }

  // Calculate merit for COMSATS admission
  static double calculateMerit({
    required double matricPercentage,
    required double interPercentage,
    required double ntsPercentage,
    bool isHafiz = false,
  }) {
    final matricWeightage = matricPercentage * 0.10;
    final interWeightage = interPercentage * 0.40;
    final ntsWeightage = ntsPercentage * 0.50;
    final hafizBonus = isHafiz ? 20.0 : 0.0;

    return matricWeightage + interWeightage + ntsWeightage + hafizBonus;
  }

  // Check merit eligibility
  static Map<String, dynamic> checkEligibility({
    required double matricPercentage,
    required double interPercentage,
    required double ntsPercentage,
  }) {
    final issues = <String>[];
    bool isEligible = true;

    if (interPercentage < 60.0) {
      isEligible = false;
      issues.add('FSC/Intermediate marks must be at least 60%');
    }

    if (matricPercentage < 50.0) {
      isEligible = false;
      issues.add('Matric marks must be at least 50%');
    }

    if (ntsPercentage < 50.0) {
      isEligible = false;
      issues.add('NTS Test marks must be at least 50%');
    }

    return {'isEligible': isEligible, 'issues': issues};
  }
}
