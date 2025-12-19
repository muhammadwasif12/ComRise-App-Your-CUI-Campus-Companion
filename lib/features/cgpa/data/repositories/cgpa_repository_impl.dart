// lib/features/cgpa/data/repositories/cgpa_repository_impl.dart
import '../../domain/entities/semester.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/cgpa_repository.dart';
import '../datasources/cgpa_local_datasource.dart';
import '../models/semester_model.dart';
import '../models/course_model.dart';

class CgpaRepositoryImpl implements CgpaRepository {
  final CgpaLocalDatasource _localDataSource;

  CgpaRepositoryImpl(this._localDataSource);

  @override
  Future<List<Semester>> getSemesters(String userId) async {
    final semesterModels = await _localDataSource.getSemesters(userId);
    return semesterModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveSemester(Semester semester, String userId) async {
    final model = SemesterModel.fromEntity(semester);

    // Save semester record
    await _localDataSource.saveSemester(model, userId);

    // Save courses
    for (final course in semester.courses ?? []) {
      await saveCourse(course, semester.id);
    }
  }

  @override
  Future<void> updateSemester(Semester semester) async {
    await _localDataSource.updateSemester(SemesterModel.fromEntity(semester));

    // Update courses if they exist
    if (semester.courses != null) {
      for (final course in semester.courses!) {
        await updateCourse(course);
      }
    }
  }

  @override
  Future<void> deleteSemester(String semesterId) async {
    await _localDataSource.deleteSemester(semesterId);
    // Courses are automatically deleted by the datasource (CASCADE DELETE)
  }

  @override
  Future<void> saveCourse(Course course, String semesterId) async {
    await _localDataSource.insertCourse(
      CourseModel.fromEntity(course),
      semesterId,
    );
  }

  @override
  Future<void> updateCourse(Course course) async {
    await _localDataSource.updateCourse(CourseModel.fromEntity(course));
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _localDataSource.deleteCourse(courseId);
  }

  @override
  Future<Map<String, dynamic>> getStatistics(String userId) async {
    final semesters = await getSemesters(userId);

    if (semesters.isEmpty) {
      return {
        'totalSemesters': 0,
        'totalCredits': 0,
        'cgpa': 0.0,
        'highestGPA': 0.0,
        'lowestGPA': 0.0,
        'averageGPA': 0.0,
      };
    }

    int totalCredits = 0;
    double totalWeightedGPA = 0;
    double highestGPA = 0;
    double lowestGPA = 4.0;
    int validSemesters = 0;

    for (final semester in semesters) {
      final gpa = semester.gpa ?? 0.0;
      final credits = semester.totalCreditHours;

      // Only count semesters with actual courses
      if (gpa > 0 && credits > 0) {
        totalCredits += credits;
        totalWeightedGPA += gpa * credits;
        validSemesters++;

        if (gpa > highestGPA) highestGPA = gpa;
        if (gpa < lowestGPA) lowestGPA = gpa;
      }
    }

    final cgpa = totalCredits > 0 ? totalWeightedGPA / totalCredits : 0.0;
    final avgGPA = validSemesters > 0
        ? semesters
                  .where((s) => (s.gpa ?? 0) > 0)
                  .fold(0.0, (sum, s) => sum + (s.gpa ?? 0)) /
              validSemesters
        : 0.0;

    return {
      'totalSemesters': semesters.length,
      'totalCredits': totalCredits,
      'cgpa': cgpa,
      'highestGPA': highestGPA,
      'lowestGPA': lowestGPA == 4.0 ? 0.0 : lowestGPA,
      'averageGPA': avgGPA,
    };
  }
}
