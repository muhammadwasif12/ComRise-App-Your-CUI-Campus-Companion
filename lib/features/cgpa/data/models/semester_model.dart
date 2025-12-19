// lib/features/cgpa/data/models/semester_model.dart
import '../../domain/entities/semester.dart';
import 'course_model.dart';

class SemesterModel extends Semester {
  // FIXED: Removed 'const' keyword from constructor
  SemesterModel({
    required super.id,
    required super.name,
    required super.session,
    List<CourseModel>? courses,
    super.gpa,
    super.percentage,
    required super.createdAt,
  }) : super(courses: courses);

  // Convenience getter for typed course access
  List<CourseModel>? get courseModels => courses?.cast<CourseModel>();

  // Convert Entity → Model (map courses to CourseModel)
  factory SemesterModel.fromEntity(Semester semester) {
    return SemesterModel(
      id: semester.id,
      name: semester.name,
      session: semester.session,
      courses: semester.courses
          ?.map((course) => CourseModel.fromEntity(course))
          .toList(),
      gpa: semester.gpa,
      percentage: semester.percentage,
      createdAt: semester.createdAt,
    );
  }

  // From JSON → Model
  factory SemesterModel.fromJson(
    Map<String, dynamic> json, {
    List<CourseModel>? courses,
  }) {
    return SemesterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      session: json['session'] as String,
      courses: courses,
      gpa: (json['gpa'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'session': session,
      'gpa': gpa,
      'percentage': percentage,
      'totalCreditHours': totalCreditHours,
      'createdAt': createdAt.toIso8601String(),
      'courses': courseModels?.map((course) => course.toJson()).toList(),
    };
  }

  // Convert Model → Entity (map CourseModel → Course)
  Semester toEntity() {
    return Semester(
      id: id,
      name: name,
      session: session,
      courses: courseModels?.map((course) => course.toEntity()).toList(),
      gpa: gpa,
      percentage: percentage,
      createdAt: createdAt,
    );
  }
}
