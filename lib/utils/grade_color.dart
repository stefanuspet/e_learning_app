import 'package:flutter/material.dart';

Color getGradeColor(num grade) {
  if (grade >= 90) return Colors.green;
  if (grade >= 80) return Colors.blue;
  if (grade >= 70) return Colors.orange;
  return Colors.red;
}
