import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static DatabaseHelper get instance => _instance;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'comrise_cui.db');

    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        regNo TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        department TEXT NOT NULL,
        currentSemester TEXT NOT NULL,
        semesterNumber INTEGER NOT NULL,
        batch TEXT NOT NULL,
        batchStartYear INTEGER NOT NULL,
        batchEndYear INTEGER NOT NULL,
        cgpa REAL,
        isFirstSemester INTEGER NOT NULL DEFAULT 0,
        profilePicturePath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await _createNotesTable(db);
    await _createDatesheetsTable(db);
  }

  Future<void> _createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'text',
        filePath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createDatesheetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE datesheets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        day TEXT NOT NULL,
        time TEXT NOT NULL,
        course TEXT NOT NULL,
        batch TEXT NOT NULL,
        section TEXT NOT NULL,
        room TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN password TEXT DEFAULT ""');
      await db.execute(
        'ALTER TABLE users ADD COLUMN semesterNumber INTEGER DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN batchStartYear INTEGER DEFAULT 2024',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN batchEndYear INTEGER DEFAULT 2028',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN isFirstSemester INTEGER DEFAULT 0',
      );
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN profilePicturePath TEXT');
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT DEFAULT ""');
    }

    if (oldVersion < 5) {
      await _createNotesTable(db);
    }

    if (oldVersion < 6) {
      // Check if notes table exists, if so add columns
      try {
        await db.execute(
          "ALTER TABLE notes ADD COLUMN type TEXT NOT NULL DEFAULT 'text'",
        );
        await db.execute("ALTER TABLE notes ADD COLUMN filePath TEXT");
      } catch (e) {
        // Table might not exist yet if oldVersion was < 5 and we just created it in the previous block
        // In that case _createNotesTable already has the columns.
      }
    }
    if (oldVersion < 7) {
      await _createDatesheetsTable(db);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
