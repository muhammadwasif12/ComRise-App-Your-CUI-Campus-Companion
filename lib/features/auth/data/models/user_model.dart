import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.regNo,
    required super.email,
    required super.password,
    required super.department,
    required super.currentSemester,
    required super.semesterNumber,
    required super.batch,
    required super.batchStartYear,
    required super.batchEndYear,
    super.cgpa,
    super.isFirstSemester,
    super.profilePicturePath,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      regNo: user.regNo,
      email: user.email,
      password: user.password,
      department: user.department,
      currentSemester: user.currentSemester,
      semesterNumber: user.semesterNumber,
      batch: user.batch,
      batchStartYear: user.batchStartYear,
      batchEndYear: user.batchEndYear,
      cgpa: user.cgpa,
      isFirstSemester: user.isFirstSemester,
      profilePicturePath: user.profilePicturePath,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      regNo: json['regNo'] as String,
      email:
          json['email'] as String? ?? '', // Default for backward compatibility
      password: json['password'] as String,
      department: json['department'] as String,
      currentSemester: json['currentSemester'] as String,
      semesterNumber: json['semesterNumber'] as int,
      batch: json['batch'] as String,
      batchStartYear: json['batchStartYear'] as int,
      batchEndYear: json['batchEndYear'] as int,
      cgpa: json['cgpa'] as double?,
      isFirstSemester: (json['isFirstSemester'] as int) == 1,
      profilePicturePath: json['profilePicturePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'regNo': regNo,
      'email': email,
      'password': password,
      'department': department,
      'currentSemester': currentSemester,
      'semesterNumber': semesterNumber,
      'batch': batch,
      'batchStartYear': batchStartYear,
      'batchEndYear': batchEndYear,
      'cgpa': cgpa,
      'isFirstSemester': isFirstSemester ? 1 : 0,
      'profilePicturePath': profilePicturePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      regNo: regNo,
      email: email,
      password: password,
      department: department,
      currentSemester: currentSemester,
      semesterNumber: semesterNumber,
      batch: batch,
      batchStartYear: batchStartYear,
      batchEndYear: batchEndYear,
      cgpa: cgpa,
      isFirstSemester: isFirstSemester,
      profilePicturePath: profilePicturePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
