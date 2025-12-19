import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User?> getUserByRegNo(String regNo);
  Future<User?> getUserByEmail(String email);
  Future<User?> login(String email, String password);
  Future<void> saveUser(User user);
  Future<void> updateUser(User user);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> logout();
  Future<void> deleteUser(String userId);
}
