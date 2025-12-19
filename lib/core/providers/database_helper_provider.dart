import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';

// Database Helper (Shared Core Provider)
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});
