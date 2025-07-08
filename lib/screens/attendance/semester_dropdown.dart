import 'package:flutter/material.dart';
import '../../models/semester.dart';

class SemesterDropdown extends StatelessWidget {
  final List<Semester> semesters;
  final int? selectedId;
  final void Function(int?) onChanged;

  const SemesterDropdown({
    super.key,
    required this.semesters,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<int>(
        value: selectedId,
        decoration: const InputDecoration(
          labelText: "Select Semester",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: semesters.map((semester) {
          return DropdownMenuItem<int>(
            value: semester.id,
            child: Text(semester.name),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
