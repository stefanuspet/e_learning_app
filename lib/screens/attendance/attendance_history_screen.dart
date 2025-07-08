import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/attendance_provider.dart';
import '../../models/attendance.dart';
import '../../models/statistics.dart';
import '../../models/semester.dart';
import 'attendance_stats_card.dart';
import 'attendance_item.dart';
import 'semester_dropdown.dart';
import 'empty_history_widget.dart';
import 'error_message_widget.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  Future<void>? _initialLoadFuture;

  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _initLoad();
  }

  Future<void> _initLoad() async {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    await provider.loadSemesters();

    final activeSemester = provider.activeSemester;
    if (activeSemester != null) {
      await provider.loadAttendanceHistory(semesterId: activeSemester.id);
    } else {
      await provider.loadAttendanceHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: FutureBuilder<void>(
        future: _initialLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorMessageWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _initialLoadFuture = _initLoad();
                });
              },
            );
          } else {
            return Consumer<AttendanceProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    AttendanceStatsCard(
                      stats: (provider.statistics ?? provider.computeAttendanceStats()).toMap(),
                    ),
                    SemesterDropdown(
                      semesters: provider.semesters,
                      selectedId: provider.selectedSemesterId,
                      onChanged: (value) {
                        provider.loadAttendanceHistory(semesterId: value);
                      },
                    ),
                    Expanded(
                      child: _buildHistory(provider),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildHistory(AttendanceProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return ErrorMessageWidget(
        message: provider.error!,
        onRetry: () {
          provider.loadAttendanceHistory(semesterId: provider.selectedSemesterId);
        },
      );
    }

    if (provider.attendanceHistory.isEmpty) {
      return const EmptyHistoryWidget();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.attendanceHistory.length,
      itemBuilder: (context, index) {
        final Attendance attendance = provider.attendanceHistory[index];
        return AttendanceItem(attendance: attendance);
      },
    );
  }
}
