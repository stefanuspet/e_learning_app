import 'package:flutter/foundation.dart';
import '../api/notification_api.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationApi _notificationApi;

  bool _isLoading = false;
  String? _error;
  List<dynamic> _notifications = [];
  int _unreadCount = 0;
  Map<String, dynamic> _pagination = {};
  Map<String, dynamic> _filters = {
    'filter_type': 'all',
    'filter_read': 'all',
  };
  Map<String, dynamic> _counts = {};

  NotificationProvider(this._notificationApi);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  Map<String, dynamic> get pagination => _pagination;
  Map<String, dynamic> get filters => _filters;
  Map<String, dynamic> get counts => _counts;

  // Get notifications with filters and pagination
  Future<void> getNotifications({
    String filterType = 'all',
    String filterRead = 'all',
    int page = 1,
    int perPage = 15,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        _isLoading = true;
        _error = null;
        notifyListeners();
      }

      final result = await _notificationApi.getNotifications(
        filterType: filterType,
        filterRead: filterRead,
        page: page,
        perPage: perPage,
      );

      if (loadMore && page > 1) {
        // Append new notifications for pagination
        _notifications.addAll(result['notifications'] ?? []);
      } else {
        // Replace notifications for new filter or refresh
        _notifications = result['notifications'] ?? [];
      }

      _pagination = result['pagination'] ?? {};
      _filters = result['filters'] ?? {};
      _counts = result['counts'] ?? {};

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get unread count only
  Future<void> getUnreadCount() async {
    try {
      _unreadCount = await _notificationApi.getUnreadCount();
      notifyListeners();
    } catch (e) {
      // Don't set error for unread count failure, just log it
      if (kDebugMode) {
        print('Error getting unread count: $e');
      }
    }
  }

  // Get recent notifications for dashboard
  Future<List<dynamic>> getRecentNotifications() async {
    try {
      return await _notificationApi.getRecentNotifications();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Show specific notification
  Future<Map<String, dynamic>?> showNotification(int notificationId) async {
    try {
      final notification = await _notificationApi.showNotification(notificationId);

      // Update local notification if it exists
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index] = notification;

        // Update unread count if notification was marked as read
        if (notification['is_read'] == true) {
          await getUnreadCount();
        }

        notifyListeners();
      }

      return notification;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Mark specific notifications as read
  Future<void> markAsRead(List<int> notificationIds) async {
    try {
      await _notificationApi.markAsRead(notificationIds: notificationIds);

      // Update local state
      for (int id in notificationIds) {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          final notification = _notifications[index];
          if (notification['is_read'] == false) {
            notification['is_read'] = true;
            _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          }
        }
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mark single notification as read
  Future<void> markSingleAsRead(int notificationId) async {
    await markAsRead([notificationId]);
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationApi.markAsRead(markAll: true);

      // Update local state
      for (var notification in _notifications) {
        notification['is_read'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _notificationApi.deleteNotification(notificationId);

      // Remove from local state
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        if (notification['is_read'] == false) {
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        }
        _notifications.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete multiple notifications
  Future<void> deleteMultipleNotifications(List<int> notificationIds) async {
    try {
      final result = await _notificationApi.deleteMultipleNotifications(notificationIds);

      // Remove from local state
      for (int id in notificationIds) {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          final notification = _notifications[index];
          if (notification['is_read'] == false) {
            _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          }
          _notifications.removeAt(index);
        }
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Refresh notifications (pull to refresh)
  Future<void> refreshNotifications() async {
    await getNotifications(
      filterType: _filters['filter_type'] ?? 'all',
      filterRead: _filters['filter_read'] ?? 'all',
    );
  }

  // Load more notifications for pagination
  Future<void> loadMoreNotifications() async {
    if (_pagination['has_more_pages'] == true && !_isLoading) {
      final nextPage = (_pagination['current_page'] ?? 1) + 1;
      await getNotifications(
        filterType: _filters['filter_type'] ?? 'all',
        filterRead: _filters['filter_read'] ?? 'all',
        page: nextPage,
        loadMore: true,
      );
    }
  }

  // Apply filters
  Future<void> applyFilters({String? filterType, String? filterRead}) async {
    await getNotifications(
      filterType: filterType ?? _filters['filter_type'] ?? 'all',
      filterRead: filterRead ?? _filters['filter_read'] ?? 'all',
    );
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _notifications = [];
    _unreadCount = 0;
    _pagination = {};
    _counts = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}