// lib/views/Cgpa/merit_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';

class MeritCalculatorScreen extends StatefulWidget {
  const MeritCalculatorScreen({super.key});

  @override
  State<MeritCalculatorScreen> createState() => _MeritCalculatorScreenState();
}

class _MeritCalculatorScreenState extends State<MeritCalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Education Level
  String selectedEducation = 'FSC';
  final List<String> educationLevels = ['FSC', 'A-Level', 'DAE', 'ICS'];

  // Matric/O-Level Controllers
  final _matricObtainedController = TextEditingController();
  final _matricTotalController = TextEditingController(text: '1100');

  // FSC/A-Level/Intermediate Controllers
  final _interObtainedController = TextEditingController();
  final _interTotalController = TextEditingController(text: '1100');

  // Entry Test Controllers
  final _testObtainedController = TextEditingController();
  final _testTotalController = TextEditingController(text: '100');

  // Hafiz-e-Quran Bonus
  bool isHafiz = false;

  // Results
  double? totalMerit;
  double? matricPercentage;
  double? interPercentage;
  double? testPercentage;
  double? matricWeightage;
  double? interWeightage;
  double? testWeightage;
  double? hafizBonus;
  bool isCalculated = false;

  // Eligibility
  bool isEligible = false;
  List<String> eligibilityIssues = [];

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _matricObtainedController.dispose();
    _matricTotalController.dispose();
    _interObtainedController.dispose();
    _interTotalController.dispose();
    _testObtainedController.dispose();
    _testTotalController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _calculateMerit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Parse values
        double matricObtained = double.parse(_matricObtainedController.text);
        double matricTotal = double.parse(_matricTotalController.text);
        double interObtained = double.parse(_interObtainedController.text);
        double interTotal = double.parse(_interTotalController.text);
        double testObtained = double.parse(_testObtainedController.text);
        double testTotal = double.parse(_testTotalController.text);

        // Calculate percentages
        matricPercentage = (matricObtained / matricTotal) * 100;
        interPercentage = (interObtained / interTotal) * 100;
        testPercentage = (testObtained / testTotal) * 100;

        // Calculate weightages (COMSATS Formula - Updated)
        // Matric: 10%, FSC/Inter: 40%, Entry Test (NTS): 50%
        matricWeightage = matricPercentage! * 0.10;
        interWeightage = interPercentage! * 0.40;
        testWeightage = testPercentage! * 0.50;

        // Hafiz-e-Quran Bonus (20 marks)
        hafizBonus = isHafiz ? 20.0 : 0.0;

        // Total Merit
        totalMerit =
            matricWeightage! + interWeightage! + testWeightage! + hafizBonus!;

        // Check Eligibility
        eligibilityIssues.clear();
        isEligible = true;

        // Minimum 60% in FSC/Inter (as per COMSATS criteria)
        if (interPercentage! < 60.0) {
          isEligible = false;
          eligibilityIssues.add('FSC/Intermediate marks must be at least 60%');
        }

        // Minimum 50% in Matric
        if (matricPercentage! < 50.0) {
          isEligible = false;
          eligibilityIssues.add('Matric marks must be at least 50%');
        }

        // Minimum 50% in Entry Test
        if (testPercentage! < 50.0) {
          isEligible = false;
          eligibilityIssues.add('NTS Test marks must be at least 50%');
        }

        isCalculated = true;
        _animationController.forward(from: 0);
      });
    }
  }

  String _getMeritCategory() {
    if (totalMerit! >= 85) return 'Excellent';
    if (totalMerit! >= 75) return 'Very Good';
    if (totalMerit! >= 65) return 'Good';
    if (totalMerit! >= 55) return 'Average';
    return 'Below Average';
  }

  Color _getMeritColor(bool isDark) {
    if (totalMerit! >= 85) {
      return isDark ? AppColors.success : AppColors.success;
    }
    if (totalMerit! >= 75) {
      return isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    }
    if (totalMerit! >= 65) {
      return isDark ? AppColors.warning : AppColors.warning;
    }
    if (totalMerit! >= 55) {
      return isDark ? AppColors.warningDark : AppColors.warning;
    }
    return AppColors.error;
  }

  void _resetForm() {
    setState(() {
      _matricObtainedController.clear();
      _matricTotalController.text = '1100';
      _interObtainedController.clear();
      _interTotalController.text = '1100';
      _testObtainedController.clear();
      _testTotalController.text = '100';
      isHafiz = false;
      totalMerit = null;
      isCalculated = false;
      isEligible = false;
      eligibilityIssues.clear();
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
        title: const Text('COMSATS Merit Calculator'),
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
                    Icon(Icons.military_tech, size: 50, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'COMSATS University Admission',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Calculate your admission merit for COMSATS',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Education Level Selection
              _buildSectionTitle('🎓 Education Background', isDark),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedEducation,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                    ),
                    items: educationLevels.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value == 'FSC'
                              ? 'FSC (Pre-Engineering/Medical)'
                              : value == 'A-Level'
                              ? 'A-Level'
                              : value == 'DAE'
                              ? 'DAE (Diploma)'
                              : 'ICS (Computer Science)',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedEducation = newValue!;
                        // Update total marks based on education level
                        if (selectedEducation == 'A-Level') {
                          _interTotalController.text = '850';
                        } else {
                          _interTotalController.text = '1100';
                        }
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Matric/O-Level Section
              _buildSectionTitle('📚 Matric/O-Level Marks', isDark),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard(
                      controller: _matricObtainedController,
                      label: 'Obtained Marks',
                      hint: 'e.g., 950',
                      icon: Icons.edit,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final marks = double.tryParse(value);
                        final total = double.parse(_matricTotalController.text);
                        if (marks == null || marks < 0 || marks > total) {
                          return 'Invalid marks';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputCard(
                      controller: _matricTotalController,
                      label: 'Total Marks',
                      hint: '1100',
                      icon: Icons.numbers,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final marks = double.tryParse(value);
                        if (marks == null || marks <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // FSC/Intermediate Section
              _buildSectionTitle('📖 $selectedEducation Marks', isDark),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard(
                      controller: _interObtainedController,
                      label: 'Obtained Marks',
                      hint: selectedEducation == 'A-Level'
                          ? 'e.g., 700'
                          : 'e.g., 950',
                      icon: Icons.edit,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final marks = double.tryParse(value);
                        final total = double.parse(_interTotalController.text);
                        if (marks == null || marks < 0 || marks > total) {
                          return 'Invalid marks';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputCard(
                      controller: _interTotalController,
                      label: 'Total Marks',
                      hint: selectedEducation == 'A-Level' ? '850' : '1100',
                      icon: Icons.numbers,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final marks = double.tryParse(value);
                        if (marks == null || marks <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Entry Test Section
              _buildSectionTitle('✍️ NTS Test Marks', isDark),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard(
                      controller: _testObtainedController,
                      label: 'Obtained Marks',
                      hint: 'e.g., 75',
                      icon: Icons.edit,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final marks = double.tryParse(value);
                        final total = double.parse(_testTotalController.text);
                        if (marks == null || marks < 0 || marks > total) {
                          return 'Invalid marks';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputCard(
                      controller: _testTotalController,
                      label: 'Total Marks',
                      hint: '100',
                      icon: Icons.numbers,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final marks = double.tryParse(value);
                        if (marks == null || marks <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Hafiz-e-Quran Bonus
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_stories,
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.lightAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hafiz-e-Quran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+20 marks bonus',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isHafiz,
                      activeColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      onChanged: (value) {
                        setState(() {
                          isHafiz = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Calculate Button
              ElevatedButton(
                onPressed: _calculateMerit,
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
                    Icon(Icons.calculate_outlined, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Calculate Merit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Results Section
              if (isCalculated) ...[
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        // Eligibility Status
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isEligible
                                ? (isDark
                                      ? AppColors.successDark.withOpacity(0.3)
                                      : AppColors.success.withOpacity(0.1))
                                : (isDark
                                      ? AppColors.error.withOpacity(0.2)
                                      : AppColors.error.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isEligible
                                  ? AppColors.success
                                  : AppColors.error,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isEligible ? Icons.check_circle : Icons.cancel,
                                size: 60,
                                color: isEligible
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isEligible
                                    ? 'Eligible for Admission'
                                    : 'Not Eligible',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              if (!isEligible) ...[
                                const SizedBox(height: 12),
                                ...eligibilityIssues.map(
                                  (issue) => Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber,
                                          size: 16,
                                          color: AppColors.error,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            issue,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                        .lightTextSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Total Merit Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getMeritColor(isDark).withOpacity(0.8),
                                _getMeritColor(isDark).withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _getMeritColor(isDark).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Total Merit Score',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${totalMerit!.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontSize: 48,
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
                                  _getMeritCategory(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Breakdown Card
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
                                    Icons.bar_chart,
                                    color: isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.lightPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Merit Breakdown',
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
                              const SizedBox(height: 20),

                              // Matric
                              _buildBreakdownRow(
                                'Matric/O-Level',
                                matricPercentage!,
                                matricWeightage!,
                                10,
                                isDark ? AppColors.cyan : AppColors.cyanDark,
                                isDark,
                              ),
                              const SizedBox(height: 12),

                              // FSC/Inter
                              _buildBreakdownRow(
                                selectedEducation,
                                interPercentage!,
                                interWeightage!,
                                40,
                                AppColors.warning,
                                isDark,
                              ),
                              const SizedBox(height: 12),

                              // Entry Test
                              _buildBreakdownRow(
                                'NTS Test',
                                testPercentage!,
                                testWeightage!,
                                50,
                                AppColors.success,
                                isDark,
                              ),

                              if (isHafiz) ...[
                                const SizedBox(height: 12),
                                _buildBreakdownRow(
                                  'Hafiz-e-Quran Bonus',
                                  0,
                                  hafizBonus!,
                                  0,
                                  isDark
                                      ? AppColors.purple
                                      : AppColors.purpleDark,
                                  isDark,
                                  isBonus: true,
                                ),
                              ],

                              Divider(
                                height: 32,
                                color: isDark
                                    ? AppColors.darkCardBorder
                                    : AppColors.lightCardBorder,
                              ),

                              // Total
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Merit',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${totalMerit!.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Tips Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkPrimary.withOpacity(0.2)
                                : AppColors.lightPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary)
                                      .withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.lightPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Admission Tips',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTipItem(
                                'Merit varies by program and campus',
                                isDark,
                              ),
                              _buildTipItem(
                                'CS/SE programs have higher merit requirements',
                                isDark,
                              ),
                              _buildTipItem(
                                'Check official COMSATS website for cutoff merits',
                                isDark,
                              ),
                              _buildTipItem(
                                'Apply to multiple programs for better chances',
                                isDark,
                              ),
                            ],
                          ),
                        ),

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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  Widget _buildBreakdownRow(
    String title,
    double percentage,
    double weightage,
    int weightPercentage,
    Color color,
    bool isDark, {
    bool isBonus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            if (!isBonus)
              Text(
                '$weightPercentage%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isBonus)
                    Text(
                      '${percentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: isBonus
                          ? 1.0
                          : (weightage /
                                (weightPercentage == 0
                                    ? 20
                                    : weightPercentage)),
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${weightage.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipItem(String tip, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
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
              'Merit Formula',
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
                'COMSATS University uses the following merit formula:\n',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              _buildFormulaItem('Matric/O-Level', '10%', isDark),
              _buildFormulaItem('FSC/A-Level/Intermediate', '40%', isDark),
              _buildFormulaItem('NTS Test', '50%', isDark),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Formula:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Merit = (Matric% × 0.10) + (Inter% × 0.40) + (NTS% × 0.50) + Hafiz Bonus',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Minimum Requirements:',
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
                '• Matric: At least 50%\n'
                '• FSC/Intermediate: At least 60%\n'
                '• NTS Test: At least 50%\n',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hafiz-e-Quran Bonus:',
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
                '• Additional 20 marks for Hafiz-e-Quran certificate holders\n',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        (isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary)
                            .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Note: Merit requirements vary by program and campus. Check official COMSATS website for specific cutoffs.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Example Calculation:',
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
                'Matric: 950/1100 = 86.36%\n'
                'FSC: 980/1100 = 89.09%\n'
                'NTS Test: 75/100 = 75%\n\n'
                'Merit = (86.36 × 0.10) + (89.09 × 0.40) + (75 × 0.50)\n'
                'Merit = 8.64 + 35.64 + 37.5\n'
                'Merit = 81.78%',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
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

  Widget _buildFormulaItem(String title, String percentage, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              percentage,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
