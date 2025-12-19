// lib/features/cgpa/data/datasources/cgpa_local_datasource.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/semester_model.dart';
import '../models/course_model.dart';

class CgpaLocalDatasource {
  static Database? _database;

  // Table names
  static const String _semestersTable = 'semesters';
  static const String _coursesTable = 'courses';

  // Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cgpa_calculator.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Create semesters table
    await db.execute('''
      CREATE TABLE $_semestersTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        session TEXT NOT NULL,
        gpa REAL,
        percentage REAL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create courses table with foreign key to semesters
    await db.execute('''
      CREATE TABLE $_coursesTable (
        id TEXT PRIMARY KEY,
        semester_id TEXT NOT NULL,
        code TEXT NOT NULL,
        title TEXT NOT NULL,
        credit_hours REAL NOT NULL,
        grade TEXT,
        grade_point REAL,
        FOREIGN KEY (semester_id) REFERENCES $_semestersTable (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_semesters_user_id ON $_semestersTable (user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_courses_semester_id ON $_coursesTable (semester_id)
    ''');
  }

  // ==================== SEMESTER METHODS ====================

  /// Get all semesters for a user
  Future<List<SemesterModel>> getSemesters(String userId) async {
    try {
      final db = await database;

      // Query semesters
      final semesterMaps = await db.query(
        _semestersTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      // Convert to SemesterModel and load courses
      final semesters = <SemesterModel>[];
      for (final map in semesterMaps) {
        final courses = await getCourses(map['id'] as String);
        final semester = SemesterModel.fromJson({
          'id': map['id'],
          'name': map['name'],
          'session': map['session'],
          'gpa': map['gpa'],
          'percentage': map['percentage'],
          'createdAt': map['created_at'],
        }, courses: courses);
        semesters.add(semester);
      }

      return semesters;
    } catch (e) {
      print('Error loading semesters: $e');
      return [];
    }
  }

  /// Save a new semester
  Future<void> saveSemester(SemesterModel semester, String userId) async {
    try {
      final db = await database;

      await db.insert(_semestersTable, {
        'id': semester.id,
        'user_id': userId,
        'name': semester.name,
        'session': semester.session,
        'gpa': semester.gpa,
        'percentage': semester.percentage,
        'created_at': semester.createdAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error saving semester: $e');
      rethrow;
    }
  }

  /// Update an existing semester
  Future<void> updateSemester(SemesterModel semester) async {
    try {
      final db = await database;

      await db.update(
        _semestersTable,
        {
          'name': semester.name,
          'session': semester.session,
          'gpa': semester.gpa,
          'percentage': semester.percentage,
          'created_at': semester.createdAt.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [semester.id],
      );
    } catch (e) {
      print('Error updating semester: $e');
      rethrow;
    }
  }

  /// Delete a semester
  Future<void> deleteSemester(String semesterId) async {
    try {
      final db = await database;

      // Delete semester (courses will be deleted automatically due to CASCADE)
      await db.delete(
        _semestersTable,
        where: 'id = ?',
        whereArgs: [semesterId],
      );

      // Explicitly delete courses to ensure cleanup
      await db.delete(
        _coursesTable,
        where: 'semester_id = ?',
        whereArgs: [semesterId],
      );
    } catch (e) {
      print('Error deleting semester: $e');
      rethrow;
    }
  }

  /// Clear all semesters for a user
  Future<void> clearSemesters(String userId) async {
    try {
      final db = await database;

      // Get all semester IDs for this user
      final semesterMaps = await db.query(
        _semestersTable,
        columns: ['id'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Delete all courses for these semesters
      for (final map in semesterMaps) {
        await db.delete(
          _coursesTable,
          where: 'semester_id = ?',
          whereArgs: [map['id']],
        );
      }

      // Delete all semesters for this user
      await db.delete(
        _semestersTable,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error clearing semesters: $e');
      rethrow;
    }
  }

  // ==================== COURSE METHODS ====================

  /// Get all courses for a semester
  Future<List<CourseModel>> getCourses(String semesterId) async {
    try {
      final db = await database;

      final courseMaps = await db.query(
        _coursesTable,
        where: 'semester_id = ?',
        whereArgs: [semesterId],
        orderBy: 'code ASC',
      );

      return courseMaps.map((map) {
        return CourseModel.fromJson({
          'id': map['id'],
          'code': map['code'],
          'title': map['title'],
          'creditHours': map['credit_hours'],
          'grade': map['grade'],
          'gradePoint': map['grade_point'],
        });
      }).toList();
    } catch (e) {
      print('Error loading courses: $e');
      return [];
    }
  }

  /// Insert a new course
  Future<void> insertCourse(CourseModel course, String semesterId) async {
    try {
      final db = await database;

      await db.insert(_coursesTable, {
        'id': course.id,
        'semester_id': semesterId,
        'code': course.code,
        'title': course.name,
        'credit_hours': course.creditHours,
        'grade': course.letterGrade,
        'grade_point': course.gradePoint,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting course: $e');
      rethrow;
    }
  }

  /// Update an existing course
  Future<void> updateCourse(CourseModel course) async {
    try {
      final db = await database;

      await db.update(
        _coursesTable,
        {
          'code': course.code,
          'title': course.name,
          'credit_hours': course.creditHours,
          'grade': course.letterGrade,
          'grade_point': course.gradePoint,
        },
        where: 'id = ?',
        whereArgs: [course.id],
      );
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  /// Delete a course
  Future<void> deleteCourse(String courseId) async {
    try {
      final db = await database;

      await db.delete(_coursesTable, where: 'id = ?', whereArgs: [courseId]);
    } catch (e) {
      print('Error deleting course: $e');
      rethrow;
    }
  }

  /// Clear all courses for a semester
  Future<void> clearCourses(String semesterId) async {
    try {
      final db = await database;

      await db.delete(
        _coursesTable,
        where: 'semester_id = ?',
        whereArgs: [semesterId],
      );
    } catch (e) {
      print('Error clearing courses: $e');
      rethrow;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete entire database (for testing or reset)
  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cgpa_calculator.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
