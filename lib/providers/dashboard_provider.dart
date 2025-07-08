import 'package:flutter/foundation.dart';
import '../api/dashboard_api.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardApi _dashboardApi;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _dashboardData = {};
  Map<String, dynamic> _studentData = {};
  Map<String, dynamic> _stats = {};
  List<dynamic> _subjects = [];
  List<dynamic> _upcomingAssignments = [];
  List<dynamic> _recentMaterials = [];
  int _unreadNotifications = 0;

  DashboardProvider(this._dashboardApi);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboardData => _dashboardData;
  Map<String, dynamic> get studentData => _studentData;
  Map<String, dynamic> get stats => _stats;
  List<dynamic> get subjects => _subjects;
  List<dynamic> get upcomingAssignments => _upcomingAssignments;
  List<dynamic> get recentMaterials => _recentMaterials;
  int get unreadNotifications => _unreadNotifications;

  // Get dashboard data
  Future<void> getDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _dashboardApi.getDashboardData();
      _dashboardData = result;

      if (result.containsKey('student')) {
        _studentData = result['student'];
      }

      if (result.containsKey('stats')) {
        _stats = result['stats'];
      }

      if (result.containsKey('subjects')) {
        _subjects = result['subjects'];
      }

      if (result.containsKey('upcoming_assignments')) {
        _upcomingAssignments = result['upcoming_assignments'];
      }

      if (result.containsKey('recent_materials')) {
        _recentMaterials = result['recent_materials'];
      }

      if (result.containsKey('unread_notifications')) {
        _unreadNotifications = result['unread_notifications'];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get subjects
  Future<void> getSubjects() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _dashboardApi.getSubjects();
      _subjects = result;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get upcoming assignments
  Future<void> getUpcomingAssignments({int limit = 5}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _dashboardApi.getUpcomingAssignments(limit);
      _upcomingAssignments = result;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get recent materials
  Future<void> getRecentMaterials({int limit = 5}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _dashboardApi.getRecentMaterials(limit);
      _recentMaterials = result;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load all dashboard data at once
  Future<void> loadAllDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get all dashboard data in one call
      await getDashboardData();

      // If for some reason the dashboard API doesn't provide all data,
      // we can fetch the missing data separately
      if (_subjects.isEmpty) {
        await getSubjects();
      }

      if (_upcomingAssignments.isEmpty) {
        await getUpcomingAssignments();
      }

      if (_recentMaterials.isEmpty) {
        await getRecentMaterials();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}