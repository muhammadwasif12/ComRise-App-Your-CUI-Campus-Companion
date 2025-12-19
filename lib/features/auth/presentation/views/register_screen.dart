import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';
import 'package:comrise_cui/core/utils/constants.dart';
import '../providers/auth_provider.dart';
import '../../../home/presentation/views/home_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regNoController = TextEditingController();
  final _sessionController = TextEditingController(); // Starting Batch
  final _semesterController = TextEditingController(); // Current Semester
  final _passwordController = TextEditingController();
  final _cgpaController = TextEditingController();

  String _selectedDepartment = AppConstants.departments[8]; // Default BSE
  bool _isFirstSemester = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _sessionController.addListener(_recalculateSemester);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _regNoController.dispose();
    _sessionController.dispose();
    _semesterController.dispose();
    _passwordController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  void _recalculateSemester() {
    final sessionText = _sessionController.text.trim().toUpperCase();
    if (sessionText.length != 4) return;

    final type = sessionText.substring(0, 2);
    final yearStr = sessionText.substring(2);
    final yearShort = int.tryParse(yearStr);

    if ((type != 'FA' && type != 'SP') || yearShort == null) return;

    final yearFull = 2000 + yearShort;
    DateTime startDate = type == 'SP'
        ? DateTime(yearFull, 2, 1)
        : DateTime(yearFull, 9, 1);

    DateTime now = DateTime.now();

    if (now.isBefore(startDate)) {
      if (!_isFirstSemester) _semesterController.text = '1';
      return;
    }

    int semesterCount = 1;
    DateTime iterator = startDate;

    while (true) {
      DateTime nextSemStart;
      if (iterator.month == 2) {
        nextSemStart = DateTime(iterator.year, 9, 1);
      } else {
        nextSemStart = DateTime(iterator.year + 1, 2, 1);
      }
      if (now.isBefore(nextSemStart)) break;
      semesterCount++;
      iterator = nextSemStart;
    }

    if (semesterCount > 14) semesterCount = 14;

    if (!_isFirstSemester) {
      _semesterController.text = semesterCount.toString();
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _profileImage = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      double? cgpa;
      if (!_isFirstSemester && _cgpaController.text.isNotEmpty) {
        cgpa = double.tryParse(_cgpaController.text);
      }

      int batchYear = 2021;
      final sessionText = _sessionController.text.trim().toUpperCase();
      if (sessionText.length >= 4) {
        batchYear = 2000 + int.parse(sessionText.substring(2, 4));
      }

      final finalSem = _isFirstSemester
          ? 1
          : (int.tryParse(_semesterController.text) ?? 1);

      String currentTerm =
          (DateTime.now().month >= 2 && DateTime.now().month < 9)
          ? 'Spring ${DateTime.now().year}'
          : 'Fall ${DateTime.now().year}';

      final finalSemInfo = 'Semester $finalSem ($currentTerm)';

      final success = await ref
          .read(authProvider.notifier)
          .register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            regNo: _regNoController.text.trim().toUpperCase(),
            password: _passwordController.text,
            department: _selectedDepartment,
            currentSemester: finalSemInfo,
            semesterNumber: finalSem,
            batchStartYear: batchYear,
            cgpa: cgpa,
            isFirstSemester: _isFirstSemester,
            profilePicturePath: _profileImage?.path,
          );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else if (mounted) {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error?.toString() ?? 'Registration failed',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: Color(0x4DFFFFFF),
          selectionHandleColor: Colors.white,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
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
        ),
        body: Stack(
          children: [
            _buildBackground(isDark),
            Positioned(
              top: -50,
              right: -50,
              child: FadeInDown(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.lightPrimary.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        FadeInDown(child: _buildHeader()),
                        const SizedBox(height: 30),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: _buildGlassForm(isDark),
                        ),
                        const SizedBox(height: 30),
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: _buildBackButton(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Join ComRise',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Create your student account',
          style: GoogleFonts.rubik(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white60
                : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassForm(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                (isDark ? Colors.white : Colors.black).withOpacity(0.03),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(child: _buildProfilePictureSection(isDark)),
                  const SizedBox(height: 30),

                  GlowingTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Muhammad Wasif',
                    icon: Icons.person_outline,
                    isDark: isDark,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Added Email Field
                  GlowingTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'student@example.com',
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final regex = RegExp(
                        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                      );
                      if (!regex.hasMatch(value)) return 'Invalid email format';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  GlowingTextField(
                    controller: _regNoController,
                    label: 'Registration No',
                    hint: 'FA21-BSE-001',
                    icon: Icons.badge_outlined,
                    isDark: isDark,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final regex = RegExp(
                        r'^(FA|SP)\d{2}-[A-Za-z]{3}-\d{3}$',
                        caseSensitive: false,
                      );
                      if (!regex.hasMatch(value)) return 'Format: FA21-BSE-001';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  GlowingTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Create password',
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    isPassword: true,
                    obscure: _obscurePassword,
                    onToggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (value) {
                      if (value == null || value.length < 6)
                        return 'Min 6 chars';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDropdown<String>(
                          value: _selectedDepartment,
                          label: 'Department',
                          icon: Icons.school,
                          isDark: isDark,
                          items: AppConstants.departments
                              .map(
                                (dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedDepartment = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: GlowingTextField(
                          controller: _sessionController,
                          label: 'Starting Batch',
                          hint: 'Ex: FA21',
                          icon: Icons.date_range,
                          isDark: isDark,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.length != 4)
                              return 'Ex: FA21';
                            final regex = RegExp(
                              r'^(FA|SP)\d{2}$',
                              caseSensitive: false,
                            );
                            if (!regex.hasMatch(value)) return 'Ex: FA21';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (!_isFirstSemester) ...[
                    GlowingTextField(
                      controller: _semesterController,
                      label: 'Current Semester',
                      hint: 'Ex: 1, 2, 8...',
                      icon: Icons.timeline,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        int? val = int.tryParse(value);
                        if (val == null || val < 1 || val > 14) return '1-14';
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        'First Semester Student?',
                        style: GoogleFonts.rubik(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Check this if you are new',
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      value: _isFirstSemester,
                      activeColor: AppColors.success,
                      checkColor: Colors.white,
                      side: BorderSide(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isFirstSemester = value ?? false;
                          if (_isFirstSemester) {
                            _cgpaController.clear();
                            _semesterController.text = '1';
                          } else {
                            _recalculateSemester();
                          }
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (!_isFirstSemester) ...[
                    FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      child: GlowingTextField(
                        controller: _cgpaController,
                        label: 'Current CGPA',
                        hint: '3.50',
                        icon: Icons.grade_outlined,
                        isDark: isDark,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final d = double.tryParse(value);
                          if (d == null || d < 0 || d > 4.0) return '0.0 - 4.0';
                          return null;
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(bool isDark) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white10 : Colors.black12,
              image: _profileImage != null
                  ? DecorationImage(
                      image: FileImage(_profileImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black26,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _profileImage == null
                ? Icon(
                    Icons.add_a_photo_outlined,
                    color: isDark ? Colors.white54 : Colors.black54,
                    size: 32,
                  )
                : null,
          ),
        ),
        GestureDetector(
          onTap: () {
            if (_profileImage != null) {
              setState(() => _profileImage = null);
            } else {
              _pickImage();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _profileImage != null
                  ? AppColors.error
                  : AppColors.lightPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _profileImage != null ? Icons.close : Icons.add,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required bool isDark,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: isDark ? Colors.white54 : Colors.black54,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              isDense: true,
            ),
            dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
            style: GoogleFonts.rubik(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            items: items,
            onChanged: onChanged,
            icon: Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(_isLoading ? 0.2 : 0.4),
            blurRadius: _isLoading ? 10 : 20,
            offset: Offset(0, _isLoading ? 4 : 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [AppColors.success, Color(0xFF00A844)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : _handleRegister,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Create Account',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: GoogleFonts.rubik(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
          children: [
            TextSpan(
              text: 'Sign In',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.bold,
                color: AppColors.lightPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlowingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isPassword;
  final bool obscure;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const GlowingTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    required this.isDark,
    this.isPassword = false,
    this.obscure = false,
    this.onToggleVisibility,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<GlowingTextField> createState() => _GlowingTextFieldState();
}

class _GlowingTextFieldState extends State<GlowingTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: widget.isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFocused
                    ? AppColors.lightPrimary
                    : (widget.isDark ? Colors.white12 : Colors.black12),
                width: 1.5,
              ),
              boxShadow: [
                if (_isFocused)
                  BoxShadow(
                    color: AppColors.lightPrimary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscure,
              style: GoogleFonts.rubik(
                color: widget.isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textCapitalization: widget.textCapitalization,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  widget.icon,
                  color: _isFocused
                      ? AppColors.lightPrimary
                      : (widget.isDark ? Colors.white54 : Colors.black54),
                  size: 20,
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          widget.obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: widget.isDark
                              ? Colors.white54
                              : Colors.black54,
                          size: 20,
                        ),
                        onPressed: widget.onToggleVisibility,
                      )
                    : null,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: GoogleFonts.rubik(
                  color: widget.isDark ? Colors.white24 : Colors.black26,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
