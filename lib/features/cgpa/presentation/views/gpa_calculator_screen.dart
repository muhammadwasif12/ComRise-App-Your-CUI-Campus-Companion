// lib/views/Cgpa/gpa_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';
import 'package:comrise_cui/features/Cgpa/data/models/course_model.dart';

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final List<CourseModel> courses = [];
  double? calculatedGPA;
  double? totalPercentage;

  @override
  void initState() {
    super.initState();
    _addEmptyCourse();
  }

  void _addEmptyCourse() {
    setState(() {
      courses.add(
        CourseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '',
          code: '',
          creditHours: 3,
          theoryMarks: 0,
          labMarks: 0,
          hasLab: false,
        ),
      );
    });
  }

  void _removeCourse(int index) {
    if (courses.length > 1) {
      setState(() {
        courses.removeAt(index);
      });
    }
  }

 void _calculateGPA() {
    if (courses.every((c) => c.theoryMarks == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter marks for at least one course'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    double totalWeightedPoints = 0;
    double totalCredits = 0;
    double totalMarks = 0;
    int validCourses = 0;

    for (var course in courses) {
      if (course.theoryMarks > 0) {
        // FIX: Call calculateGradePoint() instead of gradePoint()
        course.calculateGradePoint();
        totalWeightedPoints += course.weightedGradePoints;
        totalCredits += course.creditHours;
        totalMarks += course.equivalentMarks();
        validCourses++;
      }
    }

    setState(() {
      calculatedGPA = totalWeightedPoints / totalCredits;
      totalPercentage = totalMarks / validCourses;
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
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('GPA Calculated'),
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
                    'Your GPA',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    calculatedGPA!.toStringAsFixed(2),
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
              'Percentage',
              '${totalPercentage!.toStringAsFixed(1)}%',
            ),
            _buildResultRow(
              'Total Credits',
              courses
                  .where((c) => c.theoryMarks > 0)
                  .fold(0.0, (sum, c) => sum + c.creditHours)
                  .toStringAsFixed(0),
            ),
            _buildResultRow('Grade', _getLetterGrade(calculatedGPA!)),
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

  String _getLetterGrade(double gpa) {
    if (gpa >= 4.00) return 'A+';
    if (gpa >= 3.66) return 'A-';
    if (gpa >= 3.33) return 'B+';
    if (gpa >= 3.00) return 'B';
    if (gpa >= 2.66) return 'B-';
    if (gpa >= 2.33) return 'C+';
    if (gpa >= 2.00) return 'C';
    if (gpa >= 1.66) return 'C-';
    if (gpa >= 1.00) return 'D';
    return 'F';
  }

  void _resetCalculator() {
    setState(() {
      courses.clear();
      calculatedGPA = null;
      totalPercentage = null;
      _addEmptyCourse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('GPA Calculator'),
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
            _buildInstructionsCard(),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: courses.length,
              itemBuilder: (context, index) => _buildCourseCard(index),
            ),
            const SizedBox(height: 20),
            _buildAddCourseButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculateGPA,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.calculate),
        label: const Text('Calculate GPA'),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: AppColors.darkSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Enter course name, credit hours, and marks. Toggle lab if course has practical component.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(int index) {
    final course = courses[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
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
              Expanded(
                child: Text(
                  'Course ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              if (courses.length > 1)
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () => _removeCourse(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Course Name',
              hintText: 'e.g., Data Structures',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.book),
            ),
            onChanged: (value) => course.name = value,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Credit Hours',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      course.creditHours = double.tryParse(value) ?? 3;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Theory Marks',
                    hintText: '0-100',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      course.theoryMarks = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: course.hasLab,
                onChanged: (value) {
                  setState(() {
                    course.hasLab = value ?? false;
                  });
                },
              ),
              const Text('Has Lab Component'),
            ],
          ),
          if (course.hasLab) ...[
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Lab Marks',
                hintText: '0-100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  course.labMarks = double.tryParse(value) ?? 0;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddCourseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: _addEmptyCourse,
        icon: const Icon(Icons.add),
        label: const Text('Add Another Course'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
