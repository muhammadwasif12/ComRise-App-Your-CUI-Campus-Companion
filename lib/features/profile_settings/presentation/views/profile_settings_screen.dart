import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';
import 'package:comrise_cui/core/utils/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/views/login_screen.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cgpaController = TextEditingController();

  String? _selectedDepartment;
  int? _selectedSemesterNumber;
  bool _isEditing = false;
  bool _isSaving = false;
  File? _newProfileImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(authProvider).value;
    if (user != null) {
      _nameController.text = user.name;
      if (user.cgpa != null) {
        _cgpaController.text = user.cgpa.toString();
      }
      _selectedDepartment = user.department;
      _selectedSemesterNumber = user.semesterNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _newProfileImage = File(pickedFile.path);
        });

        // Auto-save the profile picture
        await _saveProfilePicture();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error picking image: $e', isError: true);
      }
    }
  }

  Future<void> _saveProfilePicture() async {
    if (_newProfileImage == null) return;

    setState(() => _isSaving = true);

    try {
      await ref
          .read(authProvider.notifier)
          .updateProfile(profilePicturePath: _newProfileImage!.path);

      if (mounted) {
        _showSnackBar('Profile picture updated successfully!');
        setState(() => _newProfileImage = null);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update profile picture', isError: true);
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      double? cgpa;
      if (_cgpaController.text.isNotEmpty) {
        cgpa = double.tryParse(_cgpaController.text);
      }

      await ref
          .read(authProvider.notifier)
          .updateProfile(
            name: _nameController.text.trim(),
            department: _selectedDepartment,
            semesterNumber: _selectedSemesterNumber,
          );

      if (cgpa != null) {
        await ref.read(authProvider.notifier).updateCgpa(cgpa);
      }

      if (mounted) {
        _showSnackBar('Profile updated successfully!');
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update profile', isError: true);
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete Account',
      message:
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
      confirmText: 'Delete',
      isDangerous: true,
    );

    if (confirmed == true) {
      // Second confirmation
      final doubleConfirmed = await _showConfirmDialog(
        title: 'Final Confirmation',
        message:
            'This will permanently delete ALL your data. Are you absolutely sure?',
        confirmText: 'Yes, Delete Everything',
        isDangerous: true,
      );

      if (doubleConfirmed == true) {
        await ref.read(authProvider.notifier).deleteAccount();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous
                  ? AppColors.error
                  : AppColors.darkPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(authProvider);

    return Scaffold(
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user found'));
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? AppColors.darkHeaderGradient
                    : AppColors.lightHeaderGradient,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildProfileHeader(user, isDark),
                          const SizedBox(height: 32),
                          _buildInfoCard(user, isDark),
                          const SizedBox(height: 20),
                          _buildActionButtons(isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Profile & Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _loadUserData(); // Reset form when canceling edit
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(user, bool isDark) {
    final profileImagePath = _newProfileImage?.path ?? user.profilePicturePath;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: profileImagePath == null
                    ? LinearGradient(
                        colors: isDark
                            ? AppColors.darkHeaderGradient
                            : AppColors.lightHeaderGradient,
                      )
                    : null,
                image: profileImagePath != null
                    ? DecorationImage(
                        image: FileImage(File(profileImagePath)),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkPrimary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: profileImagePath == null
                  ? Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.white.withOpacity(0.8),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.darkPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.regNo,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Name
            _buildInfoField(
              label: 'Full Name',
              controller: _nameController,
              icon: Icons.person_outline,
              isDark: isDark,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Department
            _isEditing
                ? _buildDropdownField(
                    label: 'Department',
                    value: _selectedDepartment,
                    items: AppConstants.departments,
                    icon: Icons.school,
                    isDark: isDark,
                    onChanged: (value) {
                      setState(() => _selectedDepartment = value);
                    },
                  )
                : _buildInfoField(
                    label: 'Department',
                    initialValue: user.department,
                    icon: Icons.school,
                    isDark: isDark,
                    enabled: false,
                  ),
            const SizedBox(height: 16),

            // Semester
            _isEditing
                ? _buildDropdownField<int>(
                    label: 'Current Semester',
                    value: _selectedSemesterNumber,
                    items: List.generate(8, (i) => i + 1),
                    icon: Icons.format_list_numbered,
                    isDark: isDark,
                    itemBuilder: (value) => 'Semester $value',
                    onChanged: (value) {
                      setState(() => _selectedSemesterNumber = value);
                    },
                  )
                : _buildInfoField(
                    label: 'Current Semester',
                    initialValue: 'Semester ${user.semesterNumber}',
                    icon: Icons.format_list_numbered,
                    isDark: isDark,
                    enabled: false,
                  ),
            const SizedBox(height: 16),

            // Batch
            _buildInfoField(
              label: 'Batch',
              initialValue: user.batch,
              icon: Icons.calendar_month,
              isDark: isDark,
              enabled: false,
            ),
            const SizedBox(height: 16),

            // CGPA
            _buildInfoField(
              label: 'CGPA',
              controller: _cgpaController,
              icon: Icons.grade,
              isDark: isDark,
              enabled: _isEditing,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final cgpa = double.tryParse(value);
                  if (cgpa == null || cgpa < 0 || cgpa > 4.0) {
                    return 'Please enter a valid CGPA (0.0 - 4.0)';
                  }
                }
                return null;
              },
            ),

            if (_isEditing) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required IconData icon,
    required bool isDark,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(enabled ? 0.05 : 0.02)
            : Colors.grey.withOpacity(enabled ? 0.05 : 0.02),
      ),
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required IconData icon,
    required bool isDark,
    required void Function(T?) onChanged,
    String Function(T)? itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemBuilder != null ? itemBuilder(item) : item.toString(),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        _buildActionButton(
          label: 'Logout',
          icon: Icons.logout,
          color: AppColors.darkPrimary,
          onTap: _handleLogout,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: 'Delete Account',
          icon: Icons.delete_forever,
          color: AppColors.error,
          onTap: _handleDeleteAccount,
          isDark: isDark,
          isDangerous: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    bool isDangerous = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
