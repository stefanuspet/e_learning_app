import 'package:flutter/material.dart';
import '../../models/attendance.dart';

class AttendanceItem extends StatelessWidget {
  final Attendance attendance;

  const AttendanceItem({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(attendance.session.title),
        subtitle: Text(
          _formatDate(attendance.session.date),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Chip(
          label: Text(attendance.status),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
