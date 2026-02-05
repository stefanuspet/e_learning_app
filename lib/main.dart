import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api/api_client.dart';
import 'api/auth_api.dart';
import 'api/attendance_api.dart';
import 'api/grade_api.dart';
import 'api/notification_api.dart';
import 'api/dashboard_api.dart';
import 'api/assignment_api.dart';
import 'api/material_api.dart';
import 'api/discussion_api.dart';
import 'api/schedule_api.dart';
import 'api/quiz_api.dart';
import 'api/extracurricular_api.dart';
import 'api/classroom_api.dart';
import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/grade_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/assignment_provider.dart';
import 'providers/material_provider.dart';
import 'providers/discussion_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/extracurricular_provider.dart';
import 'providers/classroom_provider.dart';
import 'routes.dart';

// Global navigator key untuk navigasi tanpa BuildContext lokal
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient(
    onUnauthorized: () {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Set status auth menjadi unauthenticated dan bersihkan state user
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.logout();

        // Arahkan user ke halaman login dan hapus semua route sebelumnya
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    },
  );
  await apiClient.init();

  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  const MyApp({Key? key, required this.apiClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),

        ProxyProvider<ApiClient, AuthApi>(
          update: (_, apiClient, __) => AuthApi(apiClient),
        ),
        ProxyProvider<ApiClient, AttendanceApi>(
          update: (_, apiClient, __) => AttendanceApi(apiClient),
        ),
        ProxyProvider<ApiClient, GradeApi>(
          update: (_, apiClient, __) => GradeApi(apiClient),
        ),
        ProxyProvider<ApiClient, NotificationApi>(
          update: (_, apiClient, __) => NotificationApi(apiClient),
        ),
        ProxyProvider<ApiClient, DashboardApi>(
          update: (_, apiClient, __) => DashboardApi(apiClient),
        ),
        ProxyProvider<ApiClient, AssignmentApi>(
          update: (_, apiClient, __) => AssignmentApi(apiClient),
        ),
        ProxyProvider<ApiClient, MaterialApi>(
          update: (_, apiClient, __) => MaterialApi(apiClient),
        ),
        ProxyProvider<ApiClient, DiscussionApi>(
          update: (_, apiClient, __) => DiscussionApi(apiClient),
        ),
        ProxyProvider<ApiClient, ScheduleApi>(
          update: (_, apiClient, __) => ScheduleApi(apiClient),
        ),
        ProxyProvider<ApiClient, QuizApi>(
          update: (_, apiClient, __) => QuizApi(apiClient),
        ),
        ProxyProvider<ApiClient, ExtracurricularApi>(
          update: (_, apiClient, __) => ExtracurricularApi(apiClient),
        ),
        ProxyProvider<ApiClient, ClassroomApi>(
          update: (_, apiClient, __) => ClassroomApi(apiClient),
        ),

        ChangeNotifierProxyProvider<AuthApi, AuthProvider>(
          create: (context) => AuthProvider(
            Provider.of<AuthApi>(context, listen: false),
          ),
          update: (_, authApi, previous) => previous ?? AuthProvider(authApi),
        ),
        ChangeNotifierProxyProvider<AttendanceApi, AttendanceProvider>(
          create: (context) => AttendanceProvider(
            Provider.of<AttendanceApi>(context, listen: false),
          ),
          update: (_, attendanceApi, previous) =>
              previous ?? AttendanceProvider(attendanceApi),
        ),
        ChangeNotifierProxyProvider<GradeApi, GradeProvider>(
          create: (context) => GradeProvider(
            Provider.of<GradeApi>(context, listen: false),
          ),
          update: (_, gradeApi, previous) =>
              previous ?? GradeProvider(gradeApi),
        ),
        ChangeNotifierProxyProvider<NotificationApi, NotificationProvider>(
          create: (context) => NotificationProvider(
            Provider.of<NotificationApi>(context, listen: false),
          ),
          update: (_, notificationApi, previous) =>
              previous ?? NotificationProvider(notificationApi),
        ),
        ChangeNotifierProxyProvider<DashboardApi, DashboardProvider>(
          create: (context) => DashboardProvider(
            Provider.of<DashboardApi>(context, listen: false),
          ),
          update: (_, dashboardApi, previous) =>
              previous ?? DashboardProvider(dashboardApi),
        ),
        ChangeNotifierProxyProvider<AssignmentApi, AssignmentProvider>(
          create: (context) => AssignmentProvider(
            Provider.of<AssignmentApi>(context, listen: false),
          ),
          update: (_, assignmentApi, previous) =>
              previous ?? AssignmentProvider(assignmentApi),
        ),
        ChangeNotifierProxyProvider<MaterialApi, MaterialProvider>(
          create: (context) => MaterialProvider(
            Provider.of<MaterialApi>(context, listen: false),
          ),
          update: (_, materialApi, previous) =>
              previous ?? MaterialProvider(materialApi),
        ),
        ChangeNotifierProxyProvider<DiscussionApi, DiscussionProvider>(
          create: (context) => DiscussionProvider(
            Provider.of<DiscussionApi>(context, listen: false),
          ),
          update: (_, discussionApi, previous) =>
              previous ?? DiscussionProvider(discussionApi),
        ),
        ChangeNotifierProxyProvider<ScheduleApi, ScheduleProvider>(
          create: (context) => ScheduleProvider(
            Provider.of<ScheduleApi>(context, listen: false),
          ),
          update: (_, scheduleApi, previous) =>
              previous ?? ScheduleProvider(scheduleApi),
        ),
        ChangeNotifierProxyProvider<QuizApi, QuizProvider>(
          create: (context) => QuizProvider(
            Provider.of<QuizApi>(context, listen: false),
          ),
          update: (_, quizApi, previous) =>
              previous ?? QuizProvider(quizApi),
        ),
        ChangeNotifierProxyProvider<ExtracurricularApi,
            ExtracurricularProvider>(
          create: (context) => ExtracurricularProvider(
            Provider.of<ExtracurricularApi>(context, listen: false),
          ),
          update: (_, extraApi, previous) =>
              previous ?? ExtracurricularProvider(extraApi),
        ),
        ChangeNotifierProxyProvider<ClassroomApi, ClassroomProvider>(
          create: (context) => ClassroomProvider(
            Provider.of<ClassroomApi>(context, listen: false),
          ),
          update: (_, classroomApi, previous) =>
              previous ?? ClassroomProvider(classroomApi),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'School Hub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: routes,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
