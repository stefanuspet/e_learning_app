import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/attendance/attendance_form_screen.dart';
import 'screens/attendance/attendance_history_screen.dart';
import 'screens/grades/grade_list_screen.dart';
import 'screens/grades/grade_detail_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/profile/profile_screen.dart';

// Define routes
final Map<String, WidgetBuilder> routes = {
  '/': (context) => const DashboardScreen(),
  '/login': (context) => const LoginScreen(),
  '/dashboard': (context) => const DashboardScreen(),
  '/attendance': (context) => const AttendanceFormScreen(),
  '/attendance/history': (context) => const AttendanceHistoryScreen(),
  '/grades': (context) => const GradeListScreen(),
  '/notifications': (context) => const NotificationScreen(),
  '/profile': (context) => const ProfileScreen(),
};

// For routes that need parameters
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/grades/subject':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GradeDetailScreen(subjectId: args['subjectId']),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}