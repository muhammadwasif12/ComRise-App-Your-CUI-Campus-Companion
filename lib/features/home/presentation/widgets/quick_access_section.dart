import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:comrise_cui/features/Home/presentation/widgets/feature_card.dart';
import 'package:comrise_cui/core/routing/app_routes.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? AppColors.darkPrimaryGradient
                        : [
                            AppColors.lightSecondary,
                            const Color.fromARGB(255, 47, 82, 160),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  FontAwesomeIcons.boltLightning,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Feature cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: const [
              FeatureCard(
                icon: FontAwesomeIcons.commentDots,
                title: 'Self Chat',
                subtitle: 'Save notes, reminders & drafts',
                gradientColors: [
                  Color(0xFF00BCD4),
                  Color.fromARGB(255, 17, 114, 127),
                ],
                route: AppRoutes.selfChat,
              ),
              SizedBox(height: 12),
              FeatureCard(
                icon: FontAwesomeIcons.calendarDays,
                title: 'Date Sheet',
                subtitle: 'View your exam/timetable schedule quickly',
                gradientColors: [
                  Color(0xFF5E35B1),
                  Color.fromARGB(255, 57, 28, 106),
                ],
                route: AppRoutes.dateSheet,
              ),
              SizedBox(height: 12),

              FeatureCard(
                icon: FontAwesomeIcons.calculator,
                title: 'CGPA Tracker',
                subtitle: 'Track your semester GPA & progress',
                gradientColors: [
                  Color.fromARGB(255, 24, 77, 184),
                  Color.fromARGB(255, 10, 34, 96),
                ],
                route: AppRoutes.cgpa,
              ),
              SizedBox(height: 12),
              FeatureCard(
                icon: FontAwesomeIcons.bookOpenReader,
                title: 'Class Diary',
                subtitle: 'Organize each class diary easily',
                gradientColors: [
                  Color(0xFF00C853),
                  Color.fromARGB(255, 44, 99, 10),
                ],
                route: AppRoutes.notes,
              ),
              SizedBox(height: 12),
              FeatureCard(
                icon: 'assets/screen/roadmap.png',
                title: 'Skill Roadmaps',
                subtitle: 'Explore Flutter, Python, Web & more',
                gradientColors: [
                  Color(0xFF9C27B0),
                  Color.fromARGB(255, 102, 19, 116),
                ],
                route: AppRoutes.roadmap,
              ),
              SizedBox(height: 12),
              FeatureCard(
                icon: 'assets/screen/assignment.png',
                title: 'Assignment Builder',
                subtitle: 'Create & manage all your work',
                gradientColors: [
                  Color(0xFFFF6D00),
                  Color.fromARGB(255, 132, 77, 23),
                ],
                route: AppRoutes.assignment,
              ),

              SizedBox(height: 12),
              FeatureCard(
                icon: FontAwesomeIcons.userGear,
                title: 'Profile & Settings',
                subtitle: 'Manage your account preferences',
                gradientColors: [
                  Color(0xFF546E7A),
                  Color.fromARGB(255, 19, 66, 89),
                ],
                route: AppRoutes.profile,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
