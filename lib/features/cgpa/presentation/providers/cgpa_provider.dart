import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/semester.dart';
import '../../domain/repositories/cgpa_repository.dart';
import '../../data/repositories/cgpa_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/semester_model.dart';
import '../../data/datasources/cgpa_local_datasource.dart';

/// CGPA State Model
class CgpaState {
  final List<Semester> semesters;
  final Map<String, dynamic>? statistics;

  const CgpaState({this.semesters = const [], this.statistics});

  double get cgpa => (statistics?['cgpa'] as double?) ?? 0.0;
  int get totalCredits => (statistics?['totalCredits'] as int?) ?? 0;
  double get averageGPA => (statistics?['averageGPA'] as double?) ?? 0.0;
}

/// ------------------------------
/// Local Datasource Provider
/// ------------------------------
final cgpaLocalDatasourceProvider = Provider<CgpaLocalDatasource>((ref) {
  return CgpaLocalDatasource();
});

/// ------------------------------
/// Repository Provider
/// ------------------------------
final cgpaRepositoryProvider = Provider<CgpaRepository>((ref) {
  return CgpaRepositoryImpl(ref.watch(cgpaLocalDatasourceProvider));
});

/// ------------------------------
/// CGPA AsyncNotifier
/// ------------------------------
class CgpaNotifier extends AsyncNotifier<CgpaState> {
  late final CgpaRepository _repository;
  late final String _userId;

  @override
  Future<CgpaState> build() async {
    _repository = ref.watch(cgpaRepositoryProvider);

    final authAsync = ref.watch(authProvider);

    // Wait for auth state
    final user = authAsync.asData?.value;

    if (user == null) {
      return const CgpaState();
    }

    _userId = user.id;

    return await _loadSemesters();
  }

  /// Load all semesters + stats
  Future<CgpaState> _loadSemesters() async {
    final semesters = await _repository.getSemesters(_userId);
    final stats = await _repository.getStatistics(_userId);

    final semesterModels = semesters
        .map((s) => s is SemesterModel ? s : SemesterModel.fromEntity(s))
        .toList();

    return CgpaState(semesters: semesterModels, statistics: stats);
  }

  /// Refresh
  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await _loadSemesters());
  }

  /// Add Semester
  Future<void> addSemester(Semester semester) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.saveSemester(semester, _userId);
      return await _loadSemesters();
    });
  }

  /// Update Semester
  Future<void> updateSemester(Semester semester) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.updateSemester(semester);
      return await _loadSemesters();
    });
  }

  /// Delete Semester
  Future<void> deleteSemester(String semesterId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.deleteSemester(semesterId);
      return await _loadSemesters();
    });
  }
}

/// ------------------------------
/// Provider
/// ------------------------------
final cgpaProvider = AsyncNotifierProvider.autoDispose<CgpaNotifier, CgpaState>(
  CgpaNotifier.new,
);
