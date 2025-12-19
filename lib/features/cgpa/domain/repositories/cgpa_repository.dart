// lib/features/cgpa/domain/repositories/cgpa_repository.dart

import '../entities/semester.dart';
import '../entities/course.dart';

abstract class CgpaRepository {
  /// Get all semesters for a user
  Future<List<Semester>> getSemesters(String userId);

  /// Get statistics (CGPA, total credits, average GPA)
  Future<Map<String, dynamic>> getStatistics(String userId);

  /// Save a new semester
  Future<void> saveSemester(Semester semester, String userId);

  /// Update an existing semester
  Future<void> updateSemester(Semester semester);

  /// Delete a semester
  Future<void> deleteSemester(String semesterId);

  /// Save a new course to a semester
  Future<void> saveCourse(Course course, String semesterId);

  /// Update an existing course
  Future<void> updateCourse(Course course);

  /// Delete a course
  Future<void> deleteCourse(String courseId);
}
