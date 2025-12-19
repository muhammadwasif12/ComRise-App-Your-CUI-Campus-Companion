// lib/features/cgpa/data/models/course_model.dart
import '../../domain/entities/course.dart';

class CourseModel extends Course {
  CourseModel({
    required super.id,
    required super.name,
    required super.code,
    required super.creditHours,
    super.theoryMarks,
    super.labMarks,
    super.hasLab,
    super.letterGrade,
    super.gradePoint,
  });

  factory CourseModel.fromEntity(Course course) {
    return CourseModel(
      id: course.id,
      name: course.name,
      code: course.code,
      creditHours: course.creditHours,
      theoryMarks: course.theoryMarks,
      labMarks: course.labMarks,
      hasLab: course.hasLab,
      letterGrade: course.letterGrade,
      gradePoint: course.gradePoint,
    );
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      creditHours: (json['creditHours'] as num).toDouble(),
      theoryMarks: (json['theoryMarks'] as num?)?.toDouble() ?? 0.0,
      labMarks: (json['labMarks'] as num?)?.toDouble() ?? 0.0,
      hasLab: (json['hasLab'] as int) == 1,
      letterGrade: json['letterGrade'] as String?,
      gradePoint: (json['gradePoint'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'creditHours': creditHours,
      'theoryMarks': theoryMarks,
      'labMarks': labMarks,
      'hasLab': hasLab ? 1 : 0,
      'letterGrade': letterGrade,
      'gradePoint': gradePoint,
    };
  }

  Course toEntity() {
    return Course(
      id: id,
      name: name,
      code: code,
      creditHours: creditHours,
      theoryMarks: theoryMarks,
      labMarks: labMarks,
      hasLab: hasLab,
      letterGrade: letterGrade,
      gradePoint: gradePoint,
    );
  }
}
