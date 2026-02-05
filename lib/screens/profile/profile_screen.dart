import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/grade_provider.dart';
import '../../utils/theme.dart';
import '../login_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pastikan statistik dashboard & nilai ter-load saat membuka profil
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });

      try {
        final dashboardProvider =
            Provider.of<DashboardProvider>(context, listen: false);
        final gradeProvider =
            Provider.of<GradeProvider>(context, listen: false);

        if (dashboardProvider.stats.isEmpty) {
          await dashboardProvider.getDashboardData();
        }

        final stats = gradeProvider.grades['stats'];
        final hasAverage = stats is Map &&
            stats['average_grade'] != null &&
            (stats['total_assignments'] ?? 0) != 0;
        if (!hasAverage) {
          await gradeProvider.getGrades();
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final student = authProvider.student;
    final user = authProvider.user;
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final gradeProvider = Provider.of<GradeProvider>(context);

    final attendanceRate =
        dashboardProvider.stats['attendance_rate']?.toString() ?? '--';

    double? avgGradeValue;
    final gradesStats = gradeProvider.grades['stats'];
    if (gradesStats is Map && gradesStats['average_grade'] != null) {
      final raw = gradesStats['average_grade'];
      avgGradeValue = raw is num
          ? raw.toDouble()
          : double.tryParse(raw.toString());
    }
    final averageGradeText =
        avgGradeValue != null ? avgGradeValue.toStringAsFixed(1) : '--';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Column(
                children: [
                  // Profile Card (compact, full width)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile content
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    AppTheme.primaryColor.withOpacity(0.1),
                                child: Text(
                                  (student?.name?.isNotEmpty == true
                                          ? student!.name[0]
                                          : (user?.email.isNotEmpty == true
                                              ? user!.email[0]
                                              : '?'))
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Student info
                              Text(
                                student?.name ?? "Student Name",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NISN: ${student?.nisn ?? "-"}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? "email@example.com",
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),

                              const SizedBox(height: 12),
                              Column(
                                children: [
                                  Text(
                                    'Class',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    student?.className ?? 'Not Assigned',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Section (Attendance & Grades)
                  _buildStatsSection(
                    attendanceRate: attendanceRate,
                    averageGrade: averageGradeText,
                  ),

                  const SizedBox(height: 16),

                  // Change Password section
                  _buildSettingsSection('Account', [
                    _buildSettingItem(
                      Icons.lock_outline,
                      'Change Password',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // Logout Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        _showLogoutConfirmation(context, authProvider);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Version info
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Tampilkan dialog konfirmasi logout
  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _performLogout(context, authProvider);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk melakukan logout
  Future<void> _performLogout(BuildContext context, AuthProvider authProvider) async {
    setState(() {
      _isLoading = true;
    });

    await authProvider.logout();

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }


  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.blue.shade600,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Statistik (absensi & nilai) di profil
  Widget _buildStatsSection({
    required String attendanceRate,
    required String averageGrade,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Statistics',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_today,
                  title: 'Attendance',
                  value: attendanceRate,
                  subtitle: 'Kehadiran',
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.grade_outlined,
                  title: 'Grades',
                  value: averageGrade,
                  subtitle: 'Rata-rata nilai',
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
