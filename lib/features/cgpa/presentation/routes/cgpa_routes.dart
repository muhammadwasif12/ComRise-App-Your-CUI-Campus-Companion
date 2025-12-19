// lib/features/cgpa/presentation/routes/cgpa_routes.dart

import 'package:flutter/material.dart';
import '../views/cgpa_hub_screen.dart';
import '../views/cgpa_calculator_screen.dart';
import '../views/gpa_calculator_screen.dart';
import '../views/gpa_planning_calculator_screen.dart';
import '../views/internal_marks_calculator_screen.dart';
import '../views/merit_calculator_screen.dart';
import '../views/cgpa_tracker_screen.dart';

class CgpaRoutes {
  // Prevent instantiation
  CgpaRoutes._();

  // Route names
  static const String cgpaHub = '/cgpa';
  static const String gpaCalculator = '/cgpa/gpa-calculator';
  static const String cgpaCalculator = '/cgpa/cgpa-calculator';
  static const String internalMarks = '/cgpa/internal-marks';
  static const String gpaPlanning = '/cgpa/gpa-planning';
  static const String meritCalculator = '/cgpa/merit-calculator';
  static const String cgpaTracker = '/cgpa/tracker';

  // Route generator for CGPA module
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case cgpaHub:
        return _buildRoute(const CgpaHubScreen());

      case gpaCalculator:
        return _buildRoute(const GpaCalculatorScreen());

      case cgpaCalculator:
        return _buildRoute(const CgpaCalculatorScreen());

      case internalMarks:
        return _buildRoute(const InternalMarksCalculatorScreen());

      case gpaPlanning:
        return _buildRoute(const GpaPlanningCalculatorScreen());

      case meritCalculator:
        return _buildRoute(const MeritCalculatorScreen());

      case cgpaTracker:
        return _buildRoute(const CgpaTrackerScreen());

      default:
        return null; // Let main router handle it
    }
  }

  // Helper method with slide transition
  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: const RouteSettings(),
    );
  }

  // Get all CGPA routes as a Map (for debugging/reference)
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      cgpaHub: (context) => const CgpaHubScreen(),
      gpaCalculator: (context) => const GpaCalculatorScreen(),
      cgpaCalculator: (context) => const CgpaCalculatorScreen(),
      internalMarks: (context) => const InternalMarksCalculatorScreen(),
      gpaPlanning: (context) => const GpaPlanningCalculatorScreen(),
      meritCalculator: (context) => const MeritCalculatorScreen(),
      cgpaTracker: (context) => const CgpaTrackerScreen(),
    };
  }
}
