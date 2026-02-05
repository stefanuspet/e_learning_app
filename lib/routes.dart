import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/attendance/attendance_form_screen.dart';
import 'screens/attendance/attendance_history_screen.dart';
import 'screens/grades/grade_list_screen.dart';
import 'screens/grades/grade_detail_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/assignments/assignment_list_screen.dart';
import 'screens/assignments/assignment_detail_screen.dart';
import 'screens/materials/material_list_screen.dart';
import 'screens/materials/material_detail_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/quiz/quiz_list_screen.dart';
import 'screens/quiz/quiz_detail_screen.dart';
import 'screens/extracurricular/extracurricular_list_screen.dart';
import 'screens/extracurricular/extracurricular_detail_screen.dart';
import 'screens/classroom/classroom_screen.dart';
import 'screens/discussions/discussion_list_screen.dart';
import 'screens/discussions/discussion_thread_screen.dart';

// Define routes
final Map<String, WidgetBuilder> routes = {
  // Mulai dari SplashScreen supaya bisa cek status auth dulu,
  // lalu arahkan ke login atau dashboard sesuai token.
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/dashboard': (context) => const DashboardScreen(),
  '/attendance': (context) => const AttendanceFormScreen(),
  '/attendance/history': (context) => const AttendanceHistoryScreen(),
  '/grades': (context) => const GradeListScreen(),
  '/assignments': (context) => const AssignmentListScreen(),
  '/notifications': (context) => const NotificationScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/materials': (context) => const MaterialListScreen(),
  '/schedule': (context) => const ScheduleScreen(),
  '/quizzes': (context) => const QuizListScreen(),
  '/extracurriculars': (context) =>
      const ExtracurricularListScreen(),
  '/classroom': (context) => const ClassroomScreen(),
};

// For routes that need parameters
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name ?? '';

    switch (name) {
      case '/grades/subject':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GradeDetailScreen(subjectId: args['subjectId']),
        );
    }

    // Dynamic routes for assignments detail, from notifications
    if (name.startsWith('/assignments/')) {
      final idString = name.split('/').last;
      final assignmentId = int.tryParse(idString);

      if (assignmentId != null) {
        return MaterialPageRoute(
          builder: (_) =>
              AssignmentDetailScreen(assignmentId: assignmentId),
        );
      }
    }

    // Dynamic routes for materials detail, from notifications
    if (name.startsWith('/materials/')) {
      final idString = name.split('/').last;
      final materialId = int.tryParse(idString);

      if (materialId != null) {
        return MaterialPageRoute(
          builder: (_) => MaterialDetailScreen(materialId: materialId),
        );
      }
    }

    // Dynamic route for quiz detail (optional, e.g. from notifications)
    if (name.startsWith('/quizzes/')) {
      final idString = name.split('/').last;
      final quizId = int.tryParse(idString);

      if (quizId != null) {
        return MaterialPageRoute(
          builder: (_) => QuizDetailScreen(quizId: quizId),
        );
      }
    }

    // Dynamic route for extracurricular detail
    if (name.startsWith('/extracurriculars/')) {
      final idString = name.split('/').last;
      final id = int.tryParse(idString);

      if (id != null) {
        return MaterialPageRoute(
          builder: (_) => ExtracurricularDetailScreen(id: id),
        );
      }
    }

    // Subject discussions routes (need subject id in arguments)
    if (name == '/subjects/discussions') {
      final args = settings.arguments as Map<String, dynamic>?;
      final subjectId = args?['subjectId'] as int?;
      if (subjectId != null) {
        return MaterialPageRoute(
          builder: (_) => DiscussionListScreen(subjectId: subjectId),
        );
      }
    }

    if (name == '/subjects/discussions/thread') {
      final args = settings.arguments as Map<String, dynamic>?;
      final subjectId = args?['subjectId'] as int?;
      final threadId = args?['threadId'] as int?;
      if (subjectId != null && threadId != null) {
        return MaterialPageRoute(
          builder: (_) => DiscussionThreadScreen(
            subjectId: subjectId,
            threadId: threadId,
          ),
        );
      }
    }

    // Fallback
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for $name'),
        ),
      ),
    );
  }
}
