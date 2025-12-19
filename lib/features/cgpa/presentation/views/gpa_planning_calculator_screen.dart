// lib/views/Cgpa/gpa_planning_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';

class GpaPlanningCalculatorScreen extends StatefulWidget {
  const GpaPlanningCalculatorScreen({super.key});

  @override
  State<GpaPlanningCalculatorScreen> createState() =>
      _GpaPlanningCalculatorScreenState();
}

class _GpaPlanningCalculatorScreenState
    extends State<GpaPlanningCalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _currentCgpaController = TextEditingController();
  final _completedCreditsController = TextEditingController();
  final _targetCgpaController = TextEditingController();
  final _upcomingCreditsController = TextEditingController();

  // Results
  double? requiredGPA;
  bool isCalculated = false;
  bool isPossible = true;
  String? statusMessage;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _currentCgpaController.dispose();
    _completedCreditsController.dispose();
    _targetCgpaController.dispose();
    _upcomingCreditsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _calculateRequiredGPA() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        double currentCgpa = double.parse(_currentCgpaController.text);
        double completedCredits = double.parse(
          _completedCreditsController.text,
        );
        double targetCgpa = double.parse(_targetCgpaController.text);
        double upcomingCredits = double.parse(_upcomingCreditsController.text);

        // Formula: Required GPA = (Target CGPA × Total Credits - Current CGPA × Completed Credits) / Upcoming Credits
        double totalCredits = completedCredits + upcomingCredits;
        requiredGPA =
            (targetCgpa * totalCredits - currentCgpa * completedCredits) /
            upcomingCredits;

        // Check if it's possible (max GPA is 4.0)
        isPossible = requiredGPA! <= 4.0;

        // Generate status message
        if (requiredGPA! < 0) {
          statusMessage =
              "🎉 Congratulations! Your current CGPA already exceeds your target!";
          isPossible = true;
        } else if (requiredGPA! > 4.0) {
          statusMessage =
              "⚠️ Target not achievable! Even with perfect 4.0 GPA, you can reach ${_calculateMaxPossibleCgpa(currentCgpa, completedCredits, upcomingCredits).toStringAsFixed(2)} CGPA.";
        } else if (requiredGPA! >= 3.66) {
          statusMessage =
              "💪 Challenge ahead! You need A- or better grades in all courses.";
        } else if (requiredGPA! >= 3.0) {
          statusMessage =
              "📚 Achievable! Maintain B or better grades to reach your goal.";
        } else {
          statusMessage = "✅ Easily achievable! Stay focused and consistent.";
        }

        isCalculated = true;
        _animationController.forward(from: 0);
      });
    }
  }

  double _calculateMaxPossibleCgpa(
    double currentCgpa,
    double completedCredits,
    double upcomingCredits,
  ) {
    double totalCredits = completedCredits + upcomingCredits;
    return (currentCgpa * completedCredits + 4.0 * upcomingCredits) /
        totalCredits;
  }

  String _getGradeRange(double gpa) {
    if (gpa >= 3.66) return "A- to A (80-100%)";
    if (gpa >= 3.33) return "B+ to A- (75-84%)";
    if (gpa >= 3.0) return "B to B+ (71-79%)";
    if (gpa >= 2.66) return "B- to B (68-74%)";
    if (gpa >= 2.33) return "C+ to B- (64-70%)";
    if (gpa >= 2.0) return "C to C+ (61-67%)";
    if (gpa >= 1.66) return "C- to C (58-63%)";
    if (gpa >= 1.30) return "D+ to C- (54-60%)";
    if (gpa >= 1.0) return "D to D+ (50-57%)";
    return "Below D (< 50%)";
  }

  void _resetForm() {
    setState(() {
      _currentCgpaController.clear();
      _completedCreditsController.clear();
      _targetCgpaController.clear();
      _upcomingCreditsController.clear();
      requiredGPA = null;
      isCalculated = false;
      isPossible = true;
      statusMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('GPA Planning Calculator'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? AppColors.darkHeaderGradient
                  : AppColors.lightHeaderGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? AppColors.darkPrimaryGradient
                        : AppColors.lightPrimaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary)
                              .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.track_changes, size: 50, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Plan Your Academic Goal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Calculate the GPA needed to achieve your target CGPA',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Current Academic Status Section
              _buildSectionTitle('📊 Current Academic Status', isDark),
              const SizedBox(height: 16),

              _buildInputCard(
                controller: _currentCgpaController,
                label: 'Current CGPA',
                hint: 'e.g., 3.25',
                icon: Icons.school,
                isDark: isDark,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final gpa = double.tryParse(value);
                  if (gpa == null || gpa < 0 || gpa > 4.0) {
                    return 'Enter valid CGPA (0.0 - 4.0)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildInputCard(
                controller: _completedCreditsController,
                label: 'Completed Credit Hours',
                hint: 'e.g., 60',
                icon: Icons.done_all,
                isDark: isDark,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final credits = double.tryParse(value);
                  if (credits == null || credits <= 0) {
                    return 'Enter valid credit hours';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Target Goals Section
              _buildSectionTitle('🎯 Your Target Goals', isDark),
              const SizedBox(height: 16),

              _buildInputCard(
                controller: _targetCgpaController,
                label: 'Target CGPA',
                hint: 'e.g., 3.50',
                icon: Icons.flag,
                isDark: isDark,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final gpa = double.tryParse(value);
                  if (gpa == null || gpa < 0 || gpa > 4.0) {
                    return 'Enter valid CGPA (0.0 - 4.0)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildInputCard(
                controller: _upcomingCreditsController,
                label: 'Upcoming Semester Credit Hours',
                hint: 'e.g., 18',
                icon: Icons.calendar_today,
                isDark: isDark,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final credits = double.tryParse(value);
                  if (credits == null || credits <= 0) {
                    return 'Enter valid credit hours';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Calculate Button
              ElevatedButton(
                onPressed: _calculateRequiredGPA,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calculate),
                    SizedBox(width: 8),
                    Text(
                      'Calculate Required GPA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Results Section
              if (isCalculated) ...[
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Status Message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isPossible && requiredGPA! >= 0
                              ? (isDark
                                    ? AppColors.darkPrimary.withOpacity(0.2)
                                    : AppColors.lightPrimary.withOpacity(0.1))
                              : (isDark
                                    ? AppColors.warning.withOpacity(0.2)
                                    : AppColors.warning.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPossible && requiredGPA! >= 0
                                ? (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary)
                                : AppColors.warning,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPossible && requiredGPA! >= 0
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: isPossible && requiredGPA! >= 0
                                  ? (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.lightPrimary)
                                  : AppColors.warning,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                statusMessage!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Required GPA Display
                      if (requiredGPA! >= 0 && requiredGPA! <= 4.0) ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? AppColors.darkPrimaryGradient
                                  : AppColors.lightPrimaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.lightPrimary)
                                        .withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Required Semester GPA',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                requiredGPA!.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'out of 4.0',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Grade Range Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkCardBorder
                                  : AppColors.lightCardBorder,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.3 : 0.05,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.grade,
                                    color: isDark
                                        ? AppColors.darkAccent
                                        : AppColors.lightAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Grade Requirements',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                'Target Grade Range',
                                _getGradeRange(requiredGPA!),
                                Icons.emoji_events,
                                isDark,
                              ),
                              Divider(
                                height: 24,
                                color: isDark
                                    ? AppColors.darkCardBorder
                                    : AppColors.lightCardBorder,
                              ),
                              _buildInfoRow(
                                'Maximum Possible CGPA',
                                _calculateMaxPossibleCgpa(
                                  double.parse(_currentCgpaController.text),
                                  double.parse(
                                    _completedCreditsController.text,
                                  ),
                                  double.parse(_upcomingCreditsController.text),
                                ).toStringAsFixed(2),
                                Icons.trending_up,
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Reset Button
                      OutlinedButton(
                        onPressed: _resetForm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh),
                            SizedBox(width: 8),
                            Text(
                              'Calculate Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType:
            keyboardType ??
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        validator: validator,
        style: TextStyle(
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        title: Row(
          children: [
            Icon(
              Icons.info,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              'How It Works',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This calculator helps you determine the GPA needed in your upcoming semester to achieve your target CGPA.\n',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                'Formula:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Required GPA = (Target CGPA × Total Credits - Current CGPA × Completed Credits) ÷ Upcoming Credits',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Example:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Current CGPA: 3.0\n'
                '• Completed Credits: 60\n'
                '• Target CGPA: 3.3\n'
                '• Upcoming Credits: 18\n\n'
                'Required GPA = (3.3 × 78 - 3.0 × 60) ÷ 18\n'
                'Required GPA = 3.7\n\n'
                'You need to achieve 3.7 GPA (A- grade) in the upcoming semester!',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got It!',
              style: TextStyle(
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
