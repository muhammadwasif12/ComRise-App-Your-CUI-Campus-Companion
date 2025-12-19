// lib/features/home/presentation/widgets/cgpa_home_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';
import '../../../cgpa/presentation/routes/cgpa_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cgpa/presentation/providers/cgpa_provider.dart';
import '../../../../core/utils/grade_utils.dart';

class CgpaHomeCard extends ConsumerWidget {
  const CgpaHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    // Improved visibility colors for Dark Mode
    final mainTextColor = isDark ? Colors.white : primaryColor;
    final accentTextColor = isDark ? secondaryColor : primaryColor;

    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    final gradientColors = isDark
        ? AppColors.darkPrimaryGradient
        : AppColors.lightPrimaryGradient;

    // Watch user and CGPA state
    final authAsync = ref.watch(authProvider);
    final user = authAsync.value;

    final cgpaAsync = ref.watch(cgpaProvider);

    if (user == null) {
      return const SizedBox.shrink();
    }

    // Extract CGPA data from AsyncValue
    final cgpaState = cgpaAsync.value;
    final calculatedCgpa = cgpaState?.cgpa ?? 0.0;
    final hasSemesters = cgpaState?.semesters.isNotEmpty ?? false;

    // If user hasn't added semesters yet, show the profile CGPA. Otherwise show calculated.
    final displayCgpa = hasSemesters ? calculatedCgpa : (user.cgpa ?? 0.0);

    final semester = user.currentSemester;
    final performanceLevel = GradeUtils.getPerformanceLevel(displayCgpa);
    final isLoading = cgpaAsync.isLoading;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, CgpaRoutes.cgpaHub),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.18),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[1].withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            // CGPA Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current CGPA',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else ...[
                        Text(
                          displayCgpa.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: mainTextColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ 4.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!isLoading && displayCgpa > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        performanceLevel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: accentTextColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: 46,
              color: isDark
                  ? AppColors.darkCardBorder
                  : AppColors.lightCardBorder,
            ),
            const SizedBox(width: 14),

            // Semester Section
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                AppColors.darkPrimary.withValues(alpha: 0.2),
                                AppColors.darkSecondary.withValues(alpha: 0.2),
                              ]
                            : [
                                const Color(0xFFEAF0FF),
                                const Color(0xFFDCE6FF),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'SEMESTER',
                      style: TextStyle(
                        fontSize: 9,
                        color: accentTextColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    semester,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
