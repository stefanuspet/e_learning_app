import 'package:dio/dio.dart';
import '../models/assignment_model.dart';
import 'api_client.dart';

class AssignmentApi {
  final ApiClient _apiClient;

  AssignmentApi(this._apiClient);

  // GET /assignments - daftar tugas untuk siswa
  Future<List<dynamic>> getAssignmentsRaw() async {
    try {
      final response = await _apiClient.dio.get('/assignments');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('assignments')) {
          return data['assignments'] as List<dynamic>;
        }
        return <dynamic>[];
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get assignments');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Failed to get assignments');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Versi typed: mapping ke model Assignment jika struktur datanya cocok
  Future<List<Assignment>> getAssignments() async {
    final raw = await getAssignmentsRaw();
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => Assignment.fromJson(e))
        .toList();
  }

  // GET /assignments/{assignment} - detail tugas (raw data)
  Future<Map<String, dynamic>> getAssignmentDetailRaw(int assignmentId) async {
    try {
      final response =
          await _apiClient.dio.get('/assignments/$assignmentId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(response.data['message'] ??
            'Failed to get assignment detail');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to get assignment detail');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // POST /assignments/{assignment}/submit - submit / resubmit tugas
  // Mengirim multipart/form-data dengan field:
  // - submission_text (opsional)
  // - submission_file (opsional, file)
  Future<Map<String, dynamic>> submitAssignment(
    int assignmentId, {
    String? submissionText,
    String? filePath,
  }) async {
    try {
      final formData = FormData();

      if (submissionText != null && submissionText.trim().isNotEmpty) {
        formData.fields.add(MapEntry('submission_text', submissionText.trim()));
      }

      if (filePath != null && filePath.isNotEmpty) {
        // Ambil nama file dari path (mendukung / dan \)
        final segments = filePath.split(RegExp(r'[\\/]'));
        final fileName = segments.isNotEmpty ? segments.last : 'file';
        formData.files.add(
          MapEntry(
            'submission_file',
            await MultipartFile.fromFile(
              filePath,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _apiClient.dio.post(
        '/assignments/$assignmentId/submit',
        data: formData,
      );

      if (response.statusCode == 200 &&
          response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return <String, dynamic>{};
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to submit assignment');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Failed to submit assignment');
      } else {
        throw Exception(
            'Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}
