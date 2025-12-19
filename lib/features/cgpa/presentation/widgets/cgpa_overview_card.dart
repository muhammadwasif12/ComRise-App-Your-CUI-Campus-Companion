// lib/features/cgpa/presentation/widgets/cgpa_overview_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';
import '../providers/cgpa_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/grade_utils.dart';

class CgpaOverviewCard extends ConsumerWidget {
  const CgpaOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? AppColors.darkPrimaryGradient
        : AppColors.lightPrimaryGradient;

    final authState = ref.watch(authProvider);
    final cgpaState = ref.watch(cgpaProvider);

    // Handle loading
    if (authState.isLoading || cgpaState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle errors
    if (authState.hasError || cgpaState.hasError) {
      return const Text("Error loading data");
    }

    final user = authState.value;
    if (user == null) return const SizedBox.shrink();

    // Extract CGPA data
    // Extract CGPA data
    final hasSemesters = cgpaState.value?.semesters.isNotEmpty ?? false;
    final calculatedCgpa = cgpaState.value?.cgpa ?? 0.0;

    // Fallback info
    final cgpa = hasSemesters ? calculatedCgpa : (user.cgpa ?? 0.0);

    final totalCredits = cgpaState.value?.totalCredits ?? 0;
    final avgGpa = cgpaState.value?.averageGPA ?? 0.0;
    final semesters = cgpaState.value?.semesters ?? [];

    final performanceLevel = GradeUtils.getPerformanceLevel(cgpa);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${user.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            user.regNo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Current CGPA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (cgpaState.isLoading)
            const CircularProgressIndicator(color: Colors.white)
          else
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: cgpa),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.currentSemester,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (cgpa > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cgpa >= 3.7
                        ? Icons.stars
                        : cgpa >= 3.3
                        ? Icons.trending_up
                        : Icons.show_chart,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    performanceLevel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat(
                'Total Credits',
                totalCredits.toString(),
                Icons.credit_card,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildQuickStat(
                'Semesters',
                semesters.length.toString(),
                Icons.calendar_today,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildQuickStat(
                'Avg GPA',
                avgGpa.toStringAsFixed(2),
                Icons.auto_graph,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }
}
