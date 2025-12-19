import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Service for securely storing and retrieving sensitive data
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Keys
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyProfilePicturePath = 'profile_picture_path';

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// Save complete user data as JSON
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _storage.write(key: _keyUserData, value: jsonString);
    await _storage.write(key: _keyIsLoggedIn, value: 'true');
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = await _storage.read(key: _keyUserData);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Save profile picture path
  Future<void> saveProfilePicturePath(String path) async {
    await _storage.write(key: _keyProfilePicturePath, value: path);
  }

  /// Get profile picture path
  Future<String?> getProfilePicturePath() async {
    return await _storage.read(key: _keyProfilePicturePath);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }

  /// Clear all user data (logout)
  Future<void> clearUserData() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserData);
    await _storage.delete(key: _keyIsLoggedIn);
    // Note: We keep profile picture path for re-login unless account is deleted
  }

  /// Delete all data including profile picture (account deletion)
  Future<void> deleteAllData() async {
    await _storage.deleteAll();
  }

  /// Update specific user field
  Future<void> updateUserField(String key, dynamic value) async {
    final userData = await getUserData();
    if (userData != null) {
      userData[key] = value;
      await saveUserData(userData);
    }
  }
}
