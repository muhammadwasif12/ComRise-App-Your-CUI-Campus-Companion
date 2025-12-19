import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import 'auth_di_providers.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  late final AuthRepository _repository;

  @override
  Future<User?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    return await _repository.getCurrentUser();
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();

    try {
      final user = await _repository.login(email, password);
      if (user != null) {
        state = AsyncData(user);
        return true;
      } else {
        state = AsyncError(
          'Account exists but local data is missing.',
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      state = AsyncError('Login failed: ${e.toString()}', st);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String regNo,
    required String password,
    required String department,
    required String currentSemester,
    required int semesterNumber,
    required int batchStartYear,
    double? cgpa,
    bool isFirstSemester = false,
    String? profilePicturePath,
  }) async {
    state = const AsyncLoading();

    try {
      final normalizedRegNo = regNo.trim().toUpperCase();

      final existingUser = await _repository.getUserByRegNo(normalizedRegNo);
      if (existingUser != null) {
        state = AsyncError(
          'User with this registration number already exists',
          StackTrace.current,
        );
        return false;
      }

      final batchEndYear = batchStartYear + 4;
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        regNo: normalizedRegNo,
        email: email.trim(),
        password: password,
        department: department,
        currentSemester: currentSemester,
        semesterNumber: semesterNumber,
        batch: 'Batch $batchStartYear-$batchEndYear',
        batchStartYear: batchStartYear,
        batchEndYear: batchEndYear,
        cgpa: cgpa,
        isFirstSemester: isFirstSemester,
        profilePicturePath: profilePicturePath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.saveUser(user);
      state = AsyncData(user);
      return true;
    } catch (e, st) {
      state = AsyncError('Registration failed: ${e.toString()}', st);
      return false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _repository.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCgpa(double cgpa) async {
    final current = state.value;
    if (current == null) return;

    try {
      final updatedUser = current.copyWith(
        cgpa: cgpa,
        updatedAt: DateTime.now(),
      );

      await _repository.updateUser(updatedUser);
      state = AsyncData(updatedUser);
    } catch (e, st) {
      state = AsyncError('Failed to update CGPA: $e', st);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? department,
    int? semesterNumber,
    String? profilePicturePath,
  }) async {
    final current = state.value;
    if (current == null) return;

    try {
      final updatedUser = current.copyWith(
        name: name,
        department: department,
        semesterNumber: semesterNumber,
        profilePicturePath: profilePicturePath,
        updatedAt: DateTime.now(),
      );

      await _repository.updateUser(updatedUser);
      state = AsyncData(updatedUser);
    } catch (e, st) {
      state = AsyncError('Failed to update profile: $e', st);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    try {
      await _repository.logout();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError('Failed to logout: $e', st);
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();

    try {
      final current = state.value;
      if (current != null) {
        await _repository.deleteUser(current.id);
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError('Failed to delete account: $e', st);
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  () => AuthNotifier(),
);
