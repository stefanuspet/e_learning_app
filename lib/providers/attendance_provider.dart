import 'package:flutter/foundation.dart';
import '../api/attendance_api.dart';
import '../models/attendance.dart';
import '../models/semester.dart';
import '../models/statistics.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceApi _attendanceApi;

  bool _isLoading = false;
  String? _error;

  List<Attendance> _attendanceHistory = [];
  List<Semester> _semesters = [];
  Statistics? _statistics;
  Semester? _selectedSemester;
  Semester? _activeSemester;

  int? _selectedSemesterId;

  AttendanceProvider(this._attendanceApi);

  // === GETTERS ===
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Attendance> get attendanceHistory => _attendanceHistory;
  List<Semester> get semesters => _semesters;
  Statistics? get statistics => _statistics;
  Semester? get selectedSemester => _selectedSemester;
  Semester? get activeSemester => _activeSemester;
  int? get selectedSemesterId => _selectedSemesterId;

  /// Load list of semesters from API
  Future<void> loadSemesters() async {
    _setLoading(true);
    try {
      final semesters = await _attendanceApi.getSemesters();
      _semesters = semesters;

      if (semesters.any((s) => s.isActive)) {
        _activeSemester = semesters.firstWhere((s) => s.isActive);
      } else {
        _activeSemester = semesters.isNotEmpty ? semesters.first : null;
      }

      notifyListeners();
    } catch (e, stack) {
      debugPrint("loadSemesters ERROR => $e\n$stack");
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load attendance history (all or by semester)
  Future<void> loadAttendanceHistory({int? semesterId}) async {
    _setLoading(true);

    try {
      final response = semesterId != null
          ? await _attendanceApi.getAttendanceHistoryBySemester(semesterId)
          : await _attendanceApi.getAttendanceHistory();

      _attendanceHistory = response.attendances;
      _statistics = response.statistics;
      _selectedSemester = response.semester;
      _selectedSemesterId = semesterId;

      notifyListeners();
    } catch (e, stack) {
      debugPrint("loadAttendanceHistory ERROR => $e\n$stack");
      _attendanceHistory = [];
      _statistics = null;
      _selectedSemester = null;
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Submit attendance with a PIN
  Future<bool> submitAttendance(String pin) async {
    _setLoading(true);
    try {
      await _attendanceApi.submitAttendance(pin);
      return true;
    } catch (e, stack) {
      debugPrint("submitAttendance ERROR => $e\n$stack");
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset history and statistics
  void resetAttendanceHistory() {
    _attendanceHistory = [];
    _statistics = null;
    _selectedSemester = null;
    _selectedSemesterId = null;
    notifyListeners();
  }

  /// Clear any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Compute local attendance stats if backend returns nothing
  Statistics computeAttendanceStats() {
    int present = 0;
    int sick = 0;
    int excused = 0;
    int absent = 0;

    for (var item in _attendanceHistory) {
      switch (item.status) {
        case 'hadir':
          present++;
          break;
        case 'sakit':
          sick++;
          break;
        case 'izin':
          excused++;
          break;
        case 'alpha':
          absent++;
          break;
      }
    }

    int total = present + sick + excused + absent;
    String rate = total > 0
        ? "${(present / total * 100).toStringAsFixed(2)}%"
        : "0%";

    return Statistics(
      totalSubjects: 0,
      pendingAssignments: 0,
      completedAssignments: 0,
      attendanceRate: rate,
      present: present,
      sick: sick,
      excused: excused,
      absent: absent,
    );
  }

  /// Internal helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(Object e) {
    debugPrint("AttendanceProvider error => $e");
    _error = e.toString();
    notifyListeners();
  }
}
