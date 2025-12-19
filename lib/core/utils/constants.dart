// lib/core/utils/constants.dart
class AppConstants {
  // Grade Scale
  static const double maxGPA = 4.0;
  static const double minPassingGPA = 2.0;

  // Credit Hours
  static const int minCreditsPerSemester = 12;
  static const int maxCreditsPerSemester = 21;
  static const int typicalCreditsPerSemester = 18;

  // Semesters
  static const List<String> semesterNames = [
    'Fall 2023',
    'Spring 2024',
    'Fall 2024',
    'Spring 2025',
    'Fall 2025',
    'Spring 2026',
    'Fall 2026',
    'Spring 2027',
  ];

  // Departments
  static const List<String> departments = [
    'BBA',
    'BBC',
    'BCE',
    'BCS',
    'BEE',
    'BEN',
    'BMD',
    'BME',
    'BSE',
    'BSM',
    'BTY',
    'CVE',
    'FSN',
    'PCS',
    'PMI',
    'PMS',
    'PMT',
    'RBS',
    'RCS',
    'REE',
    'RMS',
    'RMT',
  ];

  // Education Levels (for Merit Calculator)
  static const List<String> educationLevels = ['FSC', 'A-Level', 'DAE', 'ICS'];

  // Assessment Weightage
  static const double assignmentsWeightage = 0.10;
  static const double quizzesWeightage = 0.15;
  static const double midtermWeightage = 0.25;
  static const double finalWeightage = 0.50;

  // Merit Weightage
  static const double matricWeightage = 0.10;
  static const double interWeightage = 0.40;
  static const double ntsWeightage = 0.50;
  static const double hafizBonus = 20.0;

  // Performance Thresholds
  static const double excellentThreshold = 3.7;
  static const double veryGoodThreshold = 3.3;
  static const double goodThreshold = 3.0;
  static const double satisfactoryThreshold = 2.5;
}
