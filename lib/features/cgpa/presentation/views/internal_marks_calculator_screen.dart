// lib/views/Cgpa/internal_marks_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';

class InternalMarksCalculatorScreen extends StatefulWidget {
  const InternalMarksCalculatorScreen({super.key});

  @override
  State<InternalMarksCalculatorScreen> createState() =>
      _InternalMarksCalculatorScreenState();
}

class _InternalMarksCalculatorScreenState
    extends State<InternalMarksCalculatorScreen> {
  final TextEditingController _assignmentController = TextEditingController();
  final TextEditingController _quizController = TextEditingController();
  final TextEditingController _midtermController = TextEditingController();
  final TextEditingController _finalController = TextEditingController();

  double? totalMarks;
  double? gradePoint;
  String? letterGrade;

  // COMSATS Grading System (Corrected)
  String _getLetterGrade(double marks) {
    if (marks >= 85) return 'A';
    if (marks >= 80) return 'A-';
    if (marks >= 75) return 'B+';
    if (marks >= 71) return 'B';
    if (marks >= 68) return 'B-';
    if (marks >= 64) return 'C+';
    if (marks >= 61) return 'C';
    if (marks >= 58) return 'C-';
    if (marks >= 54) return 'D+';
    if (marks >= 50) return 'D';
    return 'F';
  }

  double _getGradePoint(double marks) {
    if (marks >= 85) return 4.00;
    if (marks >= 80) return 3.66;
    if (marks >= 75) return 3.33;
    if (marks >= 71) return 3.00;
    if (marks >= 68) return 2.66;
    if (marks >= 64) return 2.33;
    if (marks >= 61) return 2.00;
    if (marks >= 58) return 1.66;
    if (marks >= 54) return 1.30;
    if (marks >= 50) return 1.00;
    return 0.00;
  }

  void _calculateMarks() {
    final assignment = double.tryParse(_assignmentController.text);
    final quiz = double.tryParse(_quizController.text);
    final midterm = double.tryParse(_midtermController.text);
    final finalExam = double.tryParse(_finalController.text);

    if (assignment == null ||
        quiz == null ||
        midterm == null ||
        finalExam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // COMSATS Internal Distribution:
    // Assignments: 10%
    // Quizzes: 15%
    // Midterm: 25%
    // Final: 50%
    final assignmentContribution = assignment * 0.10;
    final quizContribution = quiz * 0.15;
    final midtermContribution = midterm * 0.25;
    final finalContribution = finalExam * 0.50;

    setState(() {
      totalMarks =
          assignmentContribution +
          quizContribution +
          midtermContribution +
          finalContribution;
      letterGrade = _getLetterGrade(totalMarks!);
      gradePoint = _getGradePoint(totalMarks!);
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.assignment_turned_in,
              color: AppColors.success,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('Internal Marks Calculated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.lightPrimaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Marks',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalMarks!.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildResultRow('Letter Grade', letterGrade!),
            _buildResultRow('Grade Points', gradePoint!.toStringAsFixed(2)),
            _buildResultRow('Status', totalMarks! >= 50 ? 'Pass' : 'Fail'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCalculator();
            },
            child: const Text('New Calculation'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _resetCalculator() {
    setState(() {
      _assignmentController.clear();
      _quizController.clear();
      _midtermController.clear();
      _finalController.clear();
      totalMarks = null;
      gradePoint = null;
      letterGrade = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Internal Marks Calculator'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCalculator,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildDistributionCard(),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Your Marks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMarksField(
                    controller: _assignmentController,
                    label: 'Assignments Marks',
                    hint: 'Out of 100',
                    icon: Icons.assignment,
                    weightage: '10%',
                  ),
                  const SizedBox(height: 16),
                  _buildMarksField(
                    controller: _quizController,
                    label: 'Quizzes Marks',
                    hint: 'Out of 100',
                    icon: Icons.quiz,
                    weightage: '15%',
                  ),
                  const SizedBox(height: 16),
                  _buildMarksField(
                    controller: _midtermController,
                    label: 'Midterm Marks',
                    hint: 'Out of 100',
                    icon: Icons.edit_note,
                    weightage: '25%',
                  ),
                  const SizedBox(height: 16),
                  _buildMarksField(
                    controller: _finalController,
                    label: 'Final Exam Marks',
                    hint: 'Out of 100',
                    icon: Icons.school,
                    weightage: '50%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculateMarks,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.calculate),
        label: const Text('Calculate'),
      ),
    );
  }

  Widget _buildInfoCard() {
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkPrimaryDark.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.darkPrimaryDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Enter your marks obtained out of 100 for each component. The calculator will compute your final marks based on COMSATS weightage.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'COMSATS Marks Distribution',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDistributionRow('Assignments', '10%', AppColors.success),
          const SizedBox(height: 8),
          _buildDistributionRow('Quizzes', '15%', AppColors.darkSecondary),
          const SizedBox(height: 8),
          _buildDistributionRow('Midterm Exam', '25%', AppColors.warning),
          const SizedBox(height: 8),
          _buildDistributionRow('Final Exam', '50%', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(String label, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMarksField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String weightage,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        suffixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            weightage,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  @override
  void dispose() {
    _assignmentController.dispose();
    _quizController.dispose();
    _midtermController.dispose();
    _finalController.dispose();
    super.dispose();
  }
}
