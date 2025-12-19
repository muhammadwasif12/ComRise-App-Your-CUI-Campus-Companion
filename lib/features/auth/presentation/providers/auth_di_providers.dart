import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_helper_provider.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// Auth Local Data Source Provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return AuthLocalDataSource(dbHelper);
});

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});
