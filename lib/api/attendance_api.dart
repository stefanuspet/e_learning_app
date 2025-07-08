import 'package:dio/dio.dart';
import '../models/attendance.dart';
import '../models/statistics.dart';
import '../models/semester.dart';
import 'api_client.dart';

class AttendanceApi {
  final ApiClient _apiClient;

  AttendanceApi(this._apiClient);

  Future<void> submitAttendance(String pin) async {
    try {
      final response = await _apiClient.dio.post(
        '/attendance/submit',
        data: {'pin': pin},
      );
      _processResponse(response);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<AttendanceHistoryResponse> getAttendanceHistory() async {
    try {
      final response = await _apiClient.dio.get('/attendance/history');
      final data = _processResponse(response);

      return _parseHistoryResponse(data);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<AttendanceHistoryResponse> getAttendanceHistoryBySemester(int semesterId) async {
    try {
      final response =
      await _apiClient.dio.get('/attendance/history/$semesterId');
      final data = _processResponse(response);

      return _parseHistoryResponse(data);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Semester>> getSemesters() async {
    try {
      final response = await _apiClient.dio.get('/semesters');
      final data = _processResponse(response);

      final semestersData = data['semesters'] as List<dynamic>;
      return semestersData
          .map((e) => Semester.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  dynamic _processResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Unexpected API error.');
      }
    } else {
      throw Exception(response.data['message'] ?? 'Unexpected API error.');
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        return e.response?.data['message'] ??
            'Server error. Please try again.';
      } else {
        return 'Connection error. Please check your internet connection.';
      }
    }
    return 'An unexpected error occurred.';
  }

  AttendanceHistoryResponse _parseHistoryResponse(dynamic data) {
    List<Attendance> attendances = [];
    Statistics? statistics;
    Semester? semester;

    if (data is List) {
      attendances = data
          .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map) {
      if (data.containsKey('attendances')) {
        attendances = (data['attendances'] as List<dynamic>)
            .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data.containsKey('statistics')) {
        statistics =
            Statistics.fromJson(data['statistics'] as Map<String, dynamic>);
      }
      if (data.containsKey('semester')) {
        semester =
            Semester.fromJson(data['semester'] as Map<String, dynamic>);
      }
    }

    return AttendanceHistoryResponse(
      attendances: attendances,
      statistics: statistics,
      semester: semester,
    );
  }

}

class AttendanceHistoryResponse {
  final List<Attendance> attendances;
  final Statistics? statistics;
  final Semester? semester;

  AttendanceHistoryResponse({
    required this.attendances,
    this.statistics,
    this.semester,
  });
}
