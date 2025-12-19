import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final DatabaseHelper _dbHelper;

  AuthLocalDataSource(this._dbHelper);

  Future<UserModel?> getCurrentUser() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', limit: 1);

    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  Future<UserModel?> getUserByRegNo(String regNo) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'regNo = ?',
      whereArgs: [regNo],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  Future<void> insertUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteAllUsers() async {
    final db = await _dbHelper.database;
    await db.delete('users');
  }

  Future<void> deleteUser(String userId) async {
    final db = await _dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}
