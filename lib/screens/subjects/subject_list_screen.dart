import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/attendance_provider.dart';
import '../attendance/attendance_qr_scanner_screen.dart';
import '../schedule/schedule_screen.dart';
import '../profile/profile_screen.dart';
import '../grades/grade_detail_screen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({Key? key}) : super(key: key);

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);

    try {
      await dashboardProvider.getSubjects();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final subjects = dashboardProvider.subjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subjects',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : subjects.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadSubjects,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject =
                              subjects[index] as Map<String, dynamic>;
                          return _buildSubjectCard(context, subject);
                        },
                      ),
                    ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load subjects',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadSubjects,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.book_outlined, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text(
              'No subjects available',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Your enrolled subjects will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
      BuildContext context, Map<String, dynamic> subject) {
    final name = subject['name']?.toString() ??
        subject['subject_name']?.toString() ??
        'Subject';
    final teacher = subject['teacher_name']?.toString();
    final materialsCount = subject['materials_count']?.toString();
    final assignmentsCount = subject['assignments_count']?.toString();

    // Ambil subject id (mendukung 'id' atau 'subject_id')
    int? subjectId;
    if (subject['id'] != null) {
      subjectId = int.tryParse(subject['id'].toString());
    } else if (subject['subject_id'] != null) {
      subjectId = int.tryParse(subject['subject_id'].toString());
    }

    return InkWell(
      onTap: subjectId == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GradeDetailScreen(subjectId: subjectId!),
                ),
              );
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (teacher != null && teacher.isNotEmpty)
                        Text(
                          teacher,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.article,
                        size: 14,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${materialsCount ?? '-'} Materials',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 14,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${assignmentsCount ?? '-'} Assignments',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    // Sama desain modern seperti di Dashboard, agar konsisten.
    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.home_outlined,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      );
                    },
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.menu_book,
                    label: 'Subjects',
                    onTap: () {
                      // Already on Subjects
                    },
                  ),
                  const SizedBox(width: 48),
                  _buildNavItem(
                    context: context,
                    icon: Icons.schedule_outlined,
                    label: 'Schedule',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScheduleScreen(),
                        ),
                      );
                    },
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            child: GestureDetector(
              onTap: _handleQrAttendance,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade600.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleQrAttendance() async {
    final qrToken = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceQrScannerScreen(),
      ),
    );

    if (!mounted || qrToken == null || qrToken.isEmpty) return;

    Position position;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }

      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);
      final success = await attendanceProvider.submitAttendance(
        qrToken,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absensi berhasil dicatat.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              attendanceProvider.error ?? 'Gagal mencatat absensi.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
