import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  AuthRepositoryImpl(this._localDataSource);

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    final email = firebaseUser.email;
    if (email == null) return null;

    // Fetch user from local DB using email
    final userModel = await _localDataSource.getUserByEmail(email);
    return userModel?.toEntity();
  }

  @override
  Future<User?> getUserByRegNo(String regNo) async {
    final userModel = await _localDataSource.getUserByRegNo(regNo);
    return userModel?.toEntity();
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    final userModel = await _localDataSource.getUserByEmail(email);
    return userModel?.toEntity();
  }

  @override
  Future<User?> login(String email, String password) async {
    // 1. Authenticate with Firebase
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Fetch User Details from Local DB
    final userModel = await _localDataSource.getUserByEmail(email);
    return userModel?.toEntity();
  }

  @override
  Future<void> saveUser(User user) async {
    // 1. Create User in Firebase
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );

    // 2. Save User Details to Local DB
    await _localDataSource.insertUser(UserModel.fromEntity(user));
  }

  @override
  Future<void> updateUser(User user) async {
    await _localDataSource.updateUser(UserModel.fromEntity(user));
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not logged in');
    }

    // 1. Re-authenticate
    final credential = fb_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // 2. Update Firebase Password
    await user.updatePassword(newPassword);

    // 3. Update Local DB Password
    final localUser = await _localDataSource.getUserByEmail(user.email!);
    if (localUser != null) {
      final updatedEntity = localUser.toEntity().copyWith(
        password: newPassword,
      );
      await _localDataSource.updateUser(UserModel.fromEntity(updatedEntity));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteUser(String userId) async {
    // Start with local deletion
    await _localDataSource.deleteUser(userId);

    // Then delete from Firebase
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
