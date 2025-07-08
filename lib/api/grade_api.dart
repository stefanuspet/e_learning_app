import 'package:dio/dio.dart';
import 'api_client.dart';

class GradeApi {
  final ApiClient _apiClient;

  GradeApi(this._apiClient);

  // Get all grades
  Future<Map<String, dynamic>> getGrades() async {
    try {
      final response = await _apiClient.dio.get('/grades');

      if (response.statusCode == 200 && response.data['success']) {
        // Map API response to expected format
        final apiData = response.data['data'];

        // Create the stats object with expected fields
        final Map<String, dynamic> statsMap = {
          'total_assignments': apiData['overall_stats']['total_assignments'],
          'average_grade': apiData['overall_stats']['average_grade'],
          'highest_grade': apiData['overall_stats']['highest_grade'],
          'lowest_grade': apiData['overall_stats']['lowest_grade'],
          // Add default values for missing fields
          'graded': apiData['overall_stats']['total_assignments'] ?? 0,
          'submitted_not_graded': 0,
          'not_submitted': 0,
        };

        // Process subjects data
        final List<dynamic> subjects = apiData['subjects'] ?? [];

        // Return data in the format expected by the app
        return {
          'stats': statsMap,
          'subjects': subjects,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get grades');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get grades');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get grades by subject
  Future<Map<String, dynamic>> getGradesBySubject(int subjectId) async {
    try {
      final response = await _apiClient.dio.get('/grades/subjects/$subjectId');

      if (response.statusCode == 200 && response.data['success']) {
        // The response is already in the format we expect, so return it directly
        // Just add some validation to make sure it has the required structure
        final apiData = response.data['data'];

        if (apiData == null) {
          throw Exception('No data returned from API');
        }

        if (!apiData.containsKey('subject') || !apiData.containsKey('stats') || !apiData.containsKey('assignments')) {
          throw Exception('Invalid data format received from API');
        }

        // Ensure assignments is a Map with the right structure
        if (!(apiData['assignments'] is Map)) {
          // If assignments is a List instead of a Map, convert it to the expected structure
          if (apiData['assignments'] is List) {
            final List<dynamic> allAssignments = apiData['assignments'] as List;
            apiData['assignments'] = {
              'graded': allAssignments.where((a) => a['grade'] != null).toList(),
              'submitted_not_graded': allAssignments.where((a) => a['grade'] == null && a['submitted_at'] != null).toList(),
              'not_submitted': allAssignments.where((a) => a['submitted_at'] == null).toList(),
            };
          } else {
            throw Exception('Invalid assignments format received from API');
          }
        }

        // Handle 'is_overdue' field in not_submitted assignments
        if (apiData['assignments']['not_submitted'] is List) {
          for (var assignment in apiData['assignments']['not_submitted']) {
            if (assignment.containsKey('is_overdue') && !assignment.containsKey('is_late')) {
              assignment['is_late'] = assignment['is_overdue'];
            }
          }
        }

        return apiData;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get subject grades');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get subject grades');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get assignment detail
  Future<Map<String, dynamic>> getAssignmentDetail(int assignmentId) async {
    try {
      final response = await _apiClient.dio.get('/grades/assignments/$assignmentId');

      if (response.statusCode == 200 && response.data['success']) {
        // Map API response to expected format if needed
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get assignment detail');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get assignment detail');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Get class performance for an assignment
  Future<Map<String, dynamic>> getClassPerformance(int assignmentId) async {
    try {
      final response = await _apiClient.dio.get('/grades/assignments/$assignmentId/performance');

      if (response.statusCode == 200 && response.data['success']) {
        // If API returns the needed data, return it directly
        return response.data['data'];
      } else if (response.statusCode == 200) {
        // If API doesn't have a specific endpoint for performance,
        // we'll return a placeholder that matches the expected format
        return {
          'class_average': 'N/A',
          'class_highest': 'N/A',
          'class_lowest': 'N/A',
          'your_rank': 'N/A',
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get class performance');
      }
    } on DioException catch (e) {
      // If the endpoint doesn't exist, return a placeholder
      if (e.response?.statusCode == 404) {
        return {
          'class_average': 'N/A',
          'class_highest': 'N/A',
          'class_lowest': 'N/A',
          'your_rank': 'N/A',
        };
      }

      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get class performance');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Get subjects list for filtering
  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final response = await _apiClient.dio.get('/subjects');

      if (response.statusCode == 200 && response.data['success']) {
        // Ensure the data is a list
        final data = response.data['data'];
        List<dynamic> subjectsData;

        if (data is List) {
          subjectsData = data;
        } else if (data is Map) {
          // If data is a map, try to extract a list from it
          if (data.containsKey('subjects') && data['subjects'] is List) {
            subjectsData = data['subjects'];
          } else {
            // Convert the map entries to a list of maps
            subjectsData = data.entries.map((entry) => {
              'id': int.tryParse(entry.key.toString()) ?? 0,
              'name': entry.value.toString(),
            }).toList();
          }
        } else {
          throw Exception('Invalid subjects data format');
        }

        return subjectsData.map((item) {
          // Ensure item is a Map
          if (item is! Map) {
            return {'id': 0, 'name': item.toString()};
          }

          // Handle different field names
          int id = 0;
          String name = 'Unknown Subject';

          if (item.containsKey('id') && item['id'] != null) {
            id = item['id'] is int ? item['id'] : int.tryParse(item['id'].toString()) ?? 0;
          } else if (item.containsKey('subject_id') && item['subject_id'] != null) {
            id = item['subject_id'] is int ? item['subject_id'] : int.tryParse(item['subject_id'].toString()) ?? 0;
          }

          if (item.containsKey('name') && item['name'] != null) {
            name = item['name'].toString();
          } else if (item.containsKey('subject_name') && item['subject_name'] != null) {
            name = item['subject_name'].toString();
          }

          return {'id': id, 'name': name};
        }).toList();
      } else {
        // If specific endpoint doesn't exist, try to get from grades
        try {
          final gradesResponse = await getGrades();
          if (gradesResponse.containsKey('subjects') && gradesResponse['subjects'] is List) {
            final subjects = gradesResponse['subjects'] as List<dynamic>;
            return subjects.map((subject) {
              int id = 0;
              String name = 'Unknown Subject';

              if (subject is Map) {
                if (subject.containsKey('subject_id') && subject['subject_id'] != null) {
                  id = subject['subject_id'] is int ? subject['subject_id'] : int.tryParse(subject['subject_id'].toString()) ?? 0;
                } else if (subject.containsKey('id') && subject['id'] != null) {
                  id = subject['id'] is int ? subject['id'] : int.tryParse(subject['id'].toString()) ?? 0;
                }

                if (subject.containsKey('subject_name') && subject['subject_name'] != null) {
                  name = subject['subject_name'].toString();
                } else if (subject.containsKey('name') && subject['name'] != null) {
                  name = subject['name'].toString();
                }
              } else {
                name = subject.toString();
              }

              return {'id': id, 'name': name};
            }).toList();
          }
        } catch (e) {
          print('Error getting subjects from grades: $e');
        }

        throw Exception(response.data['message'] ?? 'Failed to get subjects');
      }
    } on DioException catch (e) {
      // If subjects endpoint doesn't exist, try to get from grades
      if (e.response?.statusCode == 404) {
        try {
          final gradesResponse = await getGrades();
          if (gradesResponse.containsKey('subjects') && gradesResponse['subjects'] is List) {
            final subjects = gradesResponse['subjects'] as List<dynamic>;
            return subjects.map((subject) {
              int id = 0;
              String name = 'Unknown Subject';

              if (subject is Map) {
                if (subject.containsKey('subject_id') && subject['subject_id'] != null) {
                  id = subject['subject_id'] is int ? subject['subject_id'] : int.tryParse(subject['subject_id'].toString()) ?? 0;
                } else if (subject.containsKey('id') && subject['id'] != null) {
                  id = subject['id'] is int ? subject['id'] : int.tryParse(subject['id'].toString()) ?? 0;
                }

                if (subject.containsKey('subject_name') && subject['subject_name'] != null) {
                  name = subject['subject_name'].toString();
                } else if (subject.containsKey('name') && subject['name'] != null) {
                  name = subject['name'].toString();
                }
              } else {
                name = subject.toString();
              }

              return {'id': id, 'name': name};
            }).toList();
          }
        } catch (e) {
          print('Error getting subjects from grades: $e');
        }
      }

      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get subjects');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}