import 'package:dio/dio.dart';
import 'api_client.dart';

class NotificationApi {
  final ApiClient _apiClient;

  NotificationApi(this._apiClient);

  // Get notifications with filters and pagination
  Future<Map<String, dynamic>> getNotifications({
    String filterType = 'all',
    String filterRead = 'all',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = {
        'filter_type': filterType,
        'filter_read': filterRead,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final response = await _apiClient.dio.get(
        '/notifications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get notifications');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get notifications');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get('/notifications/unread-count');

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data']['unread_count'] ?? 0;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get unread count');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get unread count');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Get recent notifications
  Future<List<dynamic>> getRecentNotifications() async {
    try {
      final response = await _apiClient.dio.get('/notifications/recent');

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get recent notifications');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get recent notifications');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Show specific notification
  Future<Map<String, dynamic>> showNotification(int notificationId) async {
    try {
      final response = await _apiClient.dio.get('/notifications/$notificationId');

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get notification');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get notification');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Mark notifications as read
  Future<Map<String, dynamic>> markAsRead({
    List<int>? notificationIds,
    bool markAll = false,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (markAll) {
        data['mark_all'] = true;
      } else if (notificationIds != null && notificationIds.isNotEmpty) {
        data['notification_ids'] = notificationIds;
      } else {
        throw Exception('Either provide notification IDs or set markAll to true');
      }

      final response = await _apiClient.dio.post('/notifications/mark-as-read', data: data);

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'] ?? {};
      } else {
        throw Exception(response.data['message'] ?? 'Failed to mark notifications as read');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to mark notifications as read');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await _apiClient.dio.delete('/notifications/$notificationId');

      if (response.statusCode != 200 || !response.data['success']) {
        throw Exception(response.data['message'] ?? 'Failed to delete notification');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete notification');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // Delete multiple notifications
  Future<Map<String, dynamic>> deleteMultipleNotifications(List<int> notificationIds) async {
    try {
      final response = await _apiClient.dio.delete(
        '/notifications',
        data: {'notification_ids': notificationIds},
      );

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'] ?? {};
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete notifications');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete notifications');
      } else {
        throw Exception('Connection error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}