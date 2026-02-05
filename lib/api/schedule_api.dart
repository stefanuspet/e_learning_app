import 'package:dio/dio.dart';
import 'api_client.dart';

class ScheduleApi {
  final ApiClient _apiClient;

  ScheduleApi(this._apiClient);

  // GET /schedules - jadwal pelajaran siswa
  // includeExtracurricular: jika true, jadwal pelajaran + ekskul
  // day: filter opsional (monday, tuesday, ...)
  Future<List<dynamic>> getSchedules({
    bool includeExtracurricular = true,
    String? day,
  }) async {
    try {
      final query = <String, dynamic>{
        'include_extracurricular': includeExtracurricular ? 1 : 0,
      };
      if (day != null && day.isNotEmpty) {
        query['day'] = day;
      }

      final response = await _apiClient.dio.get(
        '/schedules',
        queryParameters: query,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('schedules')) {
          return data['schedules'] as List<dynamic>;
        }
        return <dynamic>[];
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get schedules');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Failed to get schedules');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}
