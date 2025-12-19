// lib/features/cgpa/presentation/screens/cgpa_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:comrise_cui/core/theme/theme_colors.dart';
import 'package:comrise_cui/features/cgpa/presentation/routes/cgpa_routes.dart';
import '../widgets/calculator_card.dart';

class CgpaHubScreen extends ConsumerStatefulWidget {
  const CgpaHubScreen({super.key});

  @override
  ConsumerState<CgpaHubScreen> createState() => _CgpaHubScreenState();
}

class _CgpaHubScreenState extends ConsumerState<CgpaHubScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(primaryColor, isDark),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Replaced CgpaOverviewCard with CGPA Tracker Card
                    CalculatorCard(
                      title: 'CGPA Tracker',
                      description: 'Track academic journey with analytics',
                      icon: FontAwesomeIcons.chartColumn,
                      color: const Color(0xFF00BCD4),
                      onTap: () =>
                          Navigator.pushNamed(context, CgpaRoutes.cgpaTracker),
                    ),
                    const SizedBox(height: 32),
                    _buildAllCalculatorsSection(isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Color primaryColor, bool isDark) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                      const Color(0xFF1a237e),
                    ]
                  : [
                      primaryColor,
                      primaryColor.withOpacity(0.85),
                      const Color(0xFF3949ab),
                    ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.only(top: 100, left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'COMSATS Official',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'GPA & CGPA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Calculator Suite',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Professional tools for academic excellence',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [], // Removed all actions as requested
    );
  }

  Widget _buildAllCalculatorsSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'All Calculators',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '5 Tools', // Updated count
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a calculator to get started',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          CalculatorCard(
            title: 'GPA Calculator',
            description: 'Calculate semester GPA from course grades',
            icon: FontAwesomeIcons.calculator,
            color: const Color(0xFF4CAF50),
            tag: 'Most Used',
            onTap: () => Navigator.pushNamed(context, CgpaRoutes.gpaCalculator),
          ),
          CalculatorCard(
            title: 'CGPA Calculator',
            description: 'Calculate cumulative GPA across semesters',
            icon: FontAwesomeIcons.chartLine,
            color: const Color(0xFF2196F3),
            onTap: () =>
                Navigator.pushNamed(context, CgpaRoutes.cgpaCalculator),
          ),
          CalculatorCard(
            title: 'Internal Marks Calculator',
            description: 'Calculate GPA from assignments & exams',
            icon: FontAwesomeIcons.fileLines,
            color: const Color(0xFF9C27B0),
            onTap: () => Navigator.pushNamed(context, CgpaRoutes.internalMarks),
          ),
          CalculatorCard(
            title: 'GPA Planning',
            description: 'Plan your target GPA for next semester',
            icon: FontAwesomeIcons.route,
            color: const Color(0xFFFF9800),
            tag: 'New',
            onTap: () => Navigator.pushNamed(context, CgpaRoutes.gpaPlanning),
          ),
          CalculatorCard(
            title: 'Merit Calculator',
            description: 'Calculate university admission merit',
            icon: FontAwesomeIcons.graduationCap,
            color: const Color(0xFFE91E63),
            onTap: () =>
                Navigator.pushNamed(context, CgpaRoutes.meritCalculator),
          ),
          // CGPA Tracker moved to top
        ],
      ),
    );
  }
}
