import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api/api_client.dart';
import 'api/auth_api.dart';
import 'api/attendance_api.dart';
import 'api/grade_api.dart';
import 'api/notification_api.dart';
import 'api/dashboard_api.dart';
import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/grade_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/dashboard_provider.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
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
      ],
      child: MaterialApp(
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
