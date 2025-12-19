// lib/features/cgpa/domain/entities/course.dart

class Course {
  final String id;
  String name;
  String code;
  double creditHours;
  double theoryMarks;
  double labMarks;
  bool hasLab;
  String? letterGrade;
  double? gradePoint;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.creditHours,
    this.theoryMarks = 0,
    this.labMarks = 0,
    this.hasLab = false,
    this.letterGrade,
    this.gradePoint,
  });

  /// Calculate equivalent marks based on theory and lab
  double equivalentMarks() {
    if (hasLab) {
      return (theoryMarks * 0.7) + (labMarks * 0.3);
    }
    return theoryMarks;
  }

  /// Calculate grade point based on equivalent marks
  void calculateGradePoint() {
    final marks = equivalentMarks();

    if (marks >= 85) {
      letterGrade = 'A+';
      gradePoint = 4.00;
    } else if (marks >= 80) {
      letterGrade = 'A';
      gradePoint = 4.00;
    } else if (marks >= 75) {
      letterGrade = 'A-';
      gradePoint = 3.66;
    } else if (marks >= 70) {
      letterGrade = 'B+';
      gradePoint = 3.33;
    } else if (marks >= 65) {
      letterGrade = 'B';
      gradePoint = 3.00;
    } else if (marks >= 60) {
      letterGrade = 'B-';
      gradePoint = 2.66;
    } else if (marks >= 55) {
      letterGrade = 'C+';
      gradePoint = 2.33;
    } else if (marks >= 50) {
      letterGrade = 'C';
      gradePoint = 2.00;
    } else if (marks >= 45) {
      letterGrade = 'C-';
      gradePoint = 1.66;
    } else if (marks >= 40) {
      letterGrade = 'D';
      gradePoint = 1.00;
    } else {
      letterGrade = 'F';
      gradePoint = 0.00;
    }
  }

  /// Get weighted grade points (grade point * credit hours)
  double get weightedGradePoints {
    return (gradePoint ?? 0) * creditHours;
  }

  /// Copy with method for creating modified copies
  Course copyWith({
    String? id,
    String? name,
    String? code,
    double? creditHours,
    double? theoryMarks,
    double? labMarks,
    bool? hasLab,
    String? letterGrade,
    double? gradePoint,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      creditHours: creditHours ?? this.creditHours,
      theoryMarks: theoryMarks ?? this.theoryMarks,
      labMarks: labMarks ?? this.labMarks,
      hasLab: hasLab ?? this.hasLab,
      letterGrade: letterGrade ?? this.letterGrade,
      gradePoint: gradePoint ?? this.gradePoint,
    );
  }
}
