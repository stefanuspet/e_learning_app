import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/theme.dart';
import '../attendance/attendance_qr_scanner_screen.dart';
import '../dashboard_screen.dart';
import '../subjects/subject_list_screen.dart';
import '../profile/profile_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider =
        Provider.of<ScheduleProvider>(context, listen: false);

    try {
      await provider.fetchSchedules(includeExtracurricular: true);
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
    final provider = Provider.of<ScheduleProvider>(context);
    final schedules = provider.schedules;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : schedules.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadSchedules,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: _buildGroupedSchedule(schedules),
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
            const Icon(Icons.error_outline,
                color: AppTheme.errorColor, size: 40),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load schedules',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadSchedules,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom navigation bar sama seperti Dashboard & Subjects
  Widget _buildBottomNavigationBar(BuildContext context) {
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.menu_book_outlined,
                    label: 'Subjects',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubjectListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 48),
                  _buildNavItem(
                    context: context,
                    icon: Icons.schedule_outlined,
                    label: 'Schedule',
                    onTap: () {
                      // Already on schedule screen.
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

      LocationPermission permission = await Geolocator.checkPermission();
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.schedule_outlined,
                color: AppTheme.textSecondaryColor, size: 40),
            SizedBox(height: 8),
            Text(
              'No schedule available',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Your class schedule will appear here when available.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Group jadwal per hari berdasarkan raw_day
  List<Widget> _buildGroupedSchedule(List<dynamic> rawItems) {
    final List<Map<String, dynamic>> items =
        rawItems.whereType<Map<String, dynamic>>().toList();

    final Map<String, List<Map<String, dynamic>>> byDay = {};
    for (final item in items) {
      final rawDay = item['raw_day']?.toString() ?? 'other';
      byDay.putIfAbsent(rawDay, () => []).add(item);
    }

    const orderedDays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    String _labelForDay(String rawDay) {
      switch (rawDay) {
        case 'monday':
          return 'Senin';
        case 'tuesday':
          return 'Selasa';
        case 'wednesday':
          return 'Rabu';
        case 'thursday':
          return 'Kamis';
        case 'friday':
          return 'Jumat';
        case 'saturday':
          return 'Sabtu';
        case 'sunday':
          return 'Minggu';
        default:
          return rawDay;
      }
    }

    final widgets = <Widget>[];

    for (final rawDay in orderedDays) {
      final dayItems = byDay[rawDay];
      if (dayItems == null || dayItems.isEmpty) continue;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _labelForDay(rawDay),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ),
      );

      for (final item in dayItems) {
        widgets.add(_buildScheduleCard(item));
      }

      widgets.add(const SizedBox(height: 12));
    }

    if (widgets.isEmpty) {
      widgets.add(_buildEmptyState());
    }

    return widgets;
  }

  Widget _buildScheduleCard(dynamic item) {
    if (item is! Map) {
      return const SizedBox.shrink();
    }

    final subject = item['subject_name']?.toString() ?? 'Subject';
    final teacher = item['teacher_name']?.toString();
    final day = item['day']?.toString();
    final startTime = item['start_time']?.toString();
    final endTime = item['end_time']?.toString();
    final room = item['room']?.toString();
    final type = item['type']?.toString() ?? 'subject';

    String? time;
    if (startTime != null && endTime != null) {
      time =
          '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}';
    } else if (startTime != null) {
      time = startTime.substring(0, 5);
    }

    final bool isExtracurricular = type == 'extracurricular';
    final Color accentColor =
        isExtracurricular ? AppTheme.warningColor : AppTheme.primaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isExtracurricular
                        ? Icons.group_outlined
                        : Icons.book_outlined,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      if (teacher != null)
                        Text(
                          isExtracurricular
                              ? '$teacher • Ekstrakurikuler'
                              : teacher,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (day != null) ...[
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
                if (day != null && time != null)
                  const SizedBox(width: 12),
                if (time != null) ...[
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
                if (room != null) ...[
                  const Spacer(),
                  const Icon(Icons.meeting_room, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    room,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
