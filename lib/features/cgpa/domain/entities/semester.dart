// lib/features/cgpa/domain/entities/semester.dart
import 'course.dart';

class Semester {
  final String id;
  final String name;
  final String session;
  List<Course>? courses;
  final double? gpa;
  final double? percentage;
  final DateTime createdAt;

  Semester({
    required this.id,
    required this.name,
    required this.session,
    this.courses,
    this.gpa,
    this.percentage,
    required this.createdAt,
  });

  int get totalCreditHours {
    return courses?.fold(
          0,
          (sum, course) => sum! + course.creditHours.toInt(),
        ) ??
        0;
  }

  double calculateGPA() {
    if (courses == null || courses!.isEmpty) return 0.0;

    double totalWeightedPoints = 0;
    double totalCredits = 0;

    for (final course in courses!) {
      if (course.gradePoint != null) {
        totalWeightedPoints += course.weightedGradePoints;
        totalCredits += course.creditHours;
      }
    }

    return totalCredits > 0 ? totalWeightedPoints / totalCredits : 0.0;
  }

  Semester copyWith({
    String? id,
    String? name,
    String? session,
    List<Course>? courses,
    double? gpa,
    double? percentage,
    DateTime? createdAt,
  }) {
    return Semester(
      id: id ?? this.id,
      name: name ?? this.name,
      session: session ?? this.session,
      courses: courses ?? this.courses,
      gpa: gpa ?? this.gpa,
      percentage: percentage ?? this.percentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
