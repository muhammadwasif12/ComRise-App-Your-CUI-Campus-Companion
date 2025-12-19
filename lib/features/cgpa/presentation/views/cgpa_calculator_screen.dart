// lib/views/Cgpa/cgpa_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';

class CgpaCalculatorScreen extends StatefulWidget {
  const CgpaCalculatorScreen({super.key});

  @override
  State<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends State<CgpaCalculatorScreen> {
  final TextEditingController _previousCGPAController = TextEditingController();
  final TextEditingController _completedCreditsController =
      TextEditingController();
  final TextEditingController _currentGPAController = TextEditingController();
  final TextEditingController _currentCreditsController =
      TextEditingController();

  double? calculatedCGPA;

  void _calculateCGPA() {
    final prevCGPA = double.tryParse(_previousCGPAController.text);
    final completedCredits = double.tryParse(_completedCreditsController.text);
    final currentGPA = double.tryParse(_currentGPAController.text);
    final currentCredits = double.tryParse(_currentCreditsController.text);

    if (prevCGPA == null ||
        completedCredits == null ||
        currentGPA == null ||
        currentCredits == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (prevCGPA > 4.0 || currentGPA > 4.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPA cannot exceed 4.0'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final totalPoints =
        (prevCGPA * completedCredits) + (currentGPA * currentCredits);
    final totalCredits = completedCredits + currentCredits;

    setState(() {
      calculatedCGPA = totalPoints / totalCredits;
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
            Icon(Icons.school, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('CGPA Calculated'),
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
                    'Your CGPA',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    calculatedCGPA!.toStringAsFixed(2),
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
            _buildResultRow(
              'Performance',
              _getPerformanceLevel(calculatedCGPA!),
            ),
            _buildResultRow(
              'Total Credits',
              (double.parse(_completedCreditsController.text) +
                      double.parse(_currentCreditsController.text))
                  .toStringAsFixed(0),
            ),
            _buildResultRow(
              'Status',
              calculatedCGPA! >= 2.0 ? 'Good Standing' : 'Warning',
            ),
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

  String _getPerformanceLevel(double cgpa) {
    if (cgpa >= 3.7) return 'Excellent';
    if (cgpa >= 3.3) return 'Very Good';
    if (cgpa >= 3.0) return 'Good';
    if (cgpa >= 2.5) return 'Satisfactory';
    if (cgpa >= 2.0) return 'Pass';
    return 'Needs Improvement';
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
      _previousCGPAController.clear();
      _completedCreditsController.clear();
      _currentGPAController.clear();
      _currentCreditsController.clear();
      calculatedCGPA = null;
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
        title: const Text('CGPA Calculator'),
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
                    'Previous Semester Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _previousCGPAController,
                    decoration: const InputDecoration(
                      labelText: 'Previous CGPA',
                      hintText: 'e.g., 3.5',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                      helperText: 'Your CGPA before current semester',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _completedCreditsController,
                    decoration: const InputDecoration(
                      labelText: 'Completed Credit Hours',
                      hintText: 'e.g., 60',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                      helperText: 'Total credits earned so far',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Current Semester Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _currentGPAController,
                    decoration: const InputDecoration(
                      labelText: 'Current Semester GPA',
                      hintText: 'e.g., 3.8',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grade),
                      helperText: 'GPA of your current semester',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _currentCreditsController,
                    decoration: const InputDecoration(
                      labelText: 'Current Semester Credit Hours',
                      hintText: 'e.g., 18',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                      helperText: 'Credits enrolled this semester',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculateCGPA,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.calculate),
        label: const Text('Calculate CGPA'),
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
              color: AppColors.darkPrimaryDark.withOpacity(0.1),
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
              'Enter your previous CGPA and completed credits, then add current semester GPA to calculate your overall CGPA.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _previousCGPAController.dispose();
    _completedCreditsController.dispose();
    _currentGPAController.dispose();
    _currentCreditsController.dispose();
    super.dispose();
  }
}
