import 'package:flutter/material.dart';

class GradeUtils {
  static Color getGradeColor(num grade) {
    if (grade >= 90) {
      return Colors.green;
    } else if (grade >= 80) {
      return Colors.blue;
    } else if (grade >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static bool isAssignmentOverdue(DateTime deadline) {
    final now = DateTime.now();
    return deadline.isBefore(now);
  }
}