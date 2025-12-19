class User {
  final String id;
  final String name;
  final String regNo;
  final String email;
  final String password;
  final String department;
  final String currentSemester;
  final int semesterNumber; // 1-8
  final String batch;
  final int batchStartYear;
  final int batchEndYear;
  final double? cgpa;
  final bool isFirstSemester;
  final String? profilePicturePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.regNo,
    required this.email,
    required this.password,
    required this.department,
    required this.currentSemester,
    required this.semesterNumber,
    required this.batch,
    required this.batchStartYear,
    required this.batchEndYear,
    this.cgpa,
    this.isFirstSemester = false,
    this.profilePicturePath,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? regNo,
    String? email,
    String? password,
    String? department,
    String? currentSemester,
    int? semesterNumber,
    String? batch,
    int? batchStartYear,
    int? batchEndYear,
    double? cgpa,
    bool? isFirstSemester,
    String? profilePicturePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      regNo: regNo ?? this.regNo,
      email: email ?? this.email,
      password: password ?? this.password,
      department: department ?? this.department,
      currentSemester: currentSemester ?? this.currentSemester,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      batch: batch ?? this.batch,
      batchStartYear: batchStartYear ?? this.batchStartYear,
      batchEndYear: batchEndYear ?? this.batchEndYear,
      cgpa: cgpa ?? this.cgpa,
      isFirstSemester: isFirstSemester ?? this.isFirstSemester,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
