// lib/features/home/presentation/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:comrise_cui/features/home/presentation/widgets/cgpa_home_card.dart';
import 'package:comrise_cui/features/home/presentation/widgets/feature_card.dart';
import 'package:comrise_cui/features/home/presentation/widgets/quick_access_section.dart';
import 'package:comrise_cui/features/home/presentation/widgets/header_widget.dart';
import 'package:comrise_cui/core/routing/app_routes.dart';
import 'package:comrise_cui/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // Watch Auth Provider for User Name
    final authState = ref.watch(authProvider);
    final user = authState.value;
    // Extract first name
    final fullName = user?.name ?? 'Student';
    final firstName = fullName.split(' ').first;

    // Colors for University Tips FeatureCard
    final tipsGradient = [const Color(0xFFFF512F), const Color(0xFFDD2476)];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              HeaderWidget(
                userName: firstName, // Dynamic First Name
                notificationCount: 3,
                onNotificationTap: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      const QuickAccessSection(),
                      const SizedBox(height: 12),

                      // Replaced DailyMotivationWidget with FeatureCard to match other cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FeatureCard(
                          icon: FontAwesomeIcons.fireFlameCurved,
                          title: 'University Tips',
                          subtitle: 'Fuel your day with inspiration and growth',
                          gradientColors: tipsGradient,
                          route: AppRoutes.motivation,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            top: 140,
            left: 20,
            right: 20,
            child: CgpaHomeCard(),
          ),
        ],
      ),
    );
  }
}
