import 'package:flutter/foundation.dart';
import '../api/schedule_api.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleApi _scheduleApi;

  bool _isLoading = false;
  String? _error;
  List<dynamic> _schedules = [];

  ScheduleProvider(this._scheduleApi);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get schedules => _schedules;

  Future<void> fetchSchedules({
    bool includeExtracurricular = true,
    String? day,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _schedules = await _scheduleApi.getSchedules(
        includeExtracurricular: includeExtracurricular,
        day: day,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
