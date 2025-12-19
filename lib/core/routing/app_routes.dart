// lib/core/routing/app_routes.dart

import 'package:flutter/material.dart';
import '../../features/cgpa/presentation/routes/cgpa_routes.dart';

// Import all your screens
import '../../features/assignment/presentation/views/assignment_builder_screen.dart';
import '../../features/cgpa/presentation/views/cgpa_hub_screen.dart';
import '../../features/class_diary/presentation/views/lectures_diary.dart';
import '../../features/datesheet_timetable/presentation/views/datesheet_screen.dart';
import '../../features/home/presentation/views/home_screen.dart';
import '../../features/motivation_uni_tips/presentation/views/uni_tips_screen.dart';
import '../../features/notifications/presentation/views/notifications_screen.dart';
import '../../features/roadmap/presentation/views/roadmap_screen.dart';
import '../../features/self_chat/presentation/views/selfchat_screen.dart';
import '../../features/profile_settings/presentation/views/profile_screen.dart';
import '../../features/profile_settings/presentation/views/profile_settings_screen.dart';

class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // Route names as constants
  static const String home = '/home';
  static const String cgpa = '/cgpa';
  static const String notes = '/notes';
  static const String roadmap = '/roadmap';
  static const String assignment = '/assignment';
  static const String selfChat = '/self-chat';
  static const String dateSheet = '/date-sheet';
  static const String profile = '/profile';
  static const String profileSettings = '/profile_settings';
  static const String motivation = '/motivation';
  static const String notifications = '/notifications';

  // Route generator method
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Check if route belongs to CGPA module first
    if (settings.name?.startsWith('/cgpa') ?? false) {
      final route = CgpaRoutes.generateRoute(settings);
      if (route != null) return route;
    }

    // Handle main app routes
    switch (settings.name) {
      case home:
        return _buildRoute(const HomeScreen());

      case cgpa:
        return _buildRoute(const CgpaHubScreen());

      case notes:
        return _buildRoute(const NotesScreen());

      case roadmap:
        return _buildRoute(const RoadmapScreen());

      case assignment:
        return _buildRoute(const AssignmentScreen());

      case selfChat:
        return _buildRoute(const SelfchatScreen());

      case dateSheet:
        return _buildRoute(const DatesheetScreen());

      case profile:
        return _buildRoute(const ProfileScreen());

      case profileSettings:
        return _buildRoute(const ProfileSettingsScreen());

      case motivation:
        return _buildRoute(const UniTipsScreen());

      case notifications:
        return _buildRoute(const NotificationServiceScreen());

      default:
        // Return 404 error page
        return _buildRoute(_ErrorScreen(routeName: settings.name ?? 'Unknown'));
    }
  }

  // Helper method to build routes
  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}

// Error screen for undefined routes
class _ErrorScreen extends StatelessWidget {
  final String routeName;

  const _ErrorScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error'), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              'Route not found!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Route: $routeName',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
