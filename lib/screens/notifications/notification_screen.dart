import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../utils/theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  String _currentFilterType = 'all';
  String _currentFilterRead = 'all';
  List<int> _selectedNotifications = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      if (!provider.isLoading) {
        provider.loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications() async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    await provider.getNotifications(
      filterType: _currentFilterType,
      filterRead: _currentFilterRead,
    );
  }

  Future<void> _onRefresh() async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    await provider.refreshNotifications();
  }

  void _onFilterChanged(String filterType) {
    setState(() {
      _currentFilterType = filterType;
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });

    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.applyFilters(filterType: filterType, filterRead: _currentFilterRead);
  }

  void _onReadFilterChanged(String filterRead) {
    setState(() {
      _currentFilterRead = filterRead;
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });

    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.applyFilters(filterType: _currentFilterType, filterRead: filterRead);
  }

  void _toggleSelection(int notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }

      if (_selectedNotifications.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _enterSelectionMode(int notificationId) {
    setState(() {
      _isSelectionMode = true;
      _selectedNotifications = [notificationId];
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNotifications.clear();
    });
  }

  Future<void> _markSelectedAsRead() async {
    if (_selectedNotifications.isEmpty) return;

    final provider = Provider.of<NotificationProvider>(context, listen: false);
    await provider.markAsRead(_selectedNotifications);

    _exitSelectionMode();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications marked as read')),
    );
  }

  Future<void> _deleteSelected() async {
    if (_selectedNotifications.isEmpty) return;

    final confirmed = await _showDeleteConfirmation(_selectedNotifications.length);
    if (!confirmed) return;

    final provider = Provider.of<NotificationProvider>(context, listen: false);
    await provider.deleteMultipleNotifications(_selectedNotifications);

    _exitSelectionMode();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedNotifications.length} notifications deleted')),
    );
  }

  Future<bool> _showDeleteConfirmation(int count) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notifications'),
        content: Text('Are you sure you want to delete $count notification${count > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: _buildAppBar(provider),
          body: Column(
            children: [
              _buildFilterTabs(provider),
              if (_isSelectionMode) _buildSelectionToolbar(),
              Expanded(child: _buildNotificationList(provider)),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(NotificationProvider provider) {
    if (_isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
        title: Text('${_selectedNotifications.length} selected'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markSelectedAsRead,
            tooltip: 'Mark as read',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelected,
            tooltip: 'Delete',
          ),
        ],
      );
    }

    return AppBar(
      title: const Text('Notifications'),
      elevation: 0,
      actions: [
        if (provider.unreadCount > 0)
          TextButton.icon(
            onPressed: () async {
              await provider.markAllAsRead();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              }
            },
            icon: const Icon(Icons.done_all),
            label: const Text('Mark all as read'),
          ),
        PopupMenuButton<String>(
          onSelected: _onReadFilterChanged,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'all', child: Text('All')),
            const PopupMenuItem(value: 'unread', child: Text('Unread only')),
            const PopupMenuItem(value: 'read', child: Text('Read only')),
          ],
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.filter_list),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(NotificationProvider provider) {
    final counts = provider.counts;

    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        onTap: (index) {
          final filters = ['all', 'assignment', 'material', 'grade', 'system'];
          _onFilterChanged(filters[index]);
        },
        tabs: [
          Tab(text: 'All (${counts['all'] ?? 0})'),
          Tab(text: 'Assignment (${counts['assignment'] ?? 0})'),
          Tab(text: 'Material (${counts['material'] ?? 0})'),
          Tab(text: 'Grade (${counts['grade'] ?? 0})'),
          Tab(text: 'System (${counts['system'] ?? 0})'),
        ],
      ),
    );
  }

  Widget _buildSelectionToolbar() {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_selectedNotifications.length} notification${_selectedNotifications.length > 1 ? 's' : ''} selected',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<NotificationProvider>(context, listen: false);
              final unselectedIds = provider.notifications
                  .where((n) => !_selectedNotifications.contains(n['id']))
                  .map<int>((n) => n['id'] as int)
                  .toList();

              setState(() {
                _selectedNotifications = provider.notifications
                    .map<int>((n) => n['id'] as int)
                    .toList();
              });
            },
            child: const Text('Select All'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(NotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadNotifications,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              color: Colors.grey.shade400,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.notifications.length + (provider.pagination['has_more_pages'] == true ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final notification = provider.notifications[index];
          return _buildNotificationItem(context, notification, provider);
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notification, NotificationProvider provider) {
    final bool isRead = notification['is_read'] as bool;
    final bool isSelected = _selectedNotifications.contains(notification['id']);
    final IconData icon = _getIconForType(notification['type'] as String);
    final Color color = _getColorForType(notification['type'] as String);

    return Dismissible(
      key: Key('notification_${notification['id']}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(1);
      },
      onDismissed: (direction) async {
        await provider.deleteNotification(notification['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification deleted')),
          );
        }
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        color: isSelected
            ? Colors.blue.shade50
            : isRead
            ? Colors.white
            : Colors.blue.shade50,
        child: InkWell(
          onTap: () async {
            if (_isSelectionMode) {
              _toggleSelection(notification['id']);
            } else {
              // Mark as read and show detail
              if (!isRead) {
                await provider.markSingleAsRead(notification['id']);
              }

              // // Navigate to detail or related content based on redirect_url
              // final redirectUrl = notification['redirect_url'];
              // if (redirectUrl != null) {
              //   // Handle navigation based on URL
              //   _handleNotificationNavigation(redirectUrl);
              // }
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              _enterSelectionMode(notification['id']);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleSelection(notification['id']),
                    ),
                  ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] as String,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['content'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['created_at_human'] ?? _formatTimeAgo(notification['created_at']),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead && !_isSelectionMode)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationNavigation(String redirectUrl) {
    // Handle navigation based on redirect URL from API
    if (redirectUrl.contains('/assignments/submissions/')) {
      // Navigate to submission detail
      final submissionId = redirectUrl.split('/').last;
      Navigator.pushNamed(context, '/submissions/$submissionId');
    } else if (redirectUrl.contains('/assignments/')) {
      // Navigate to assignment detail
      final assignmentId = redirectUrl.split('/').last;
      Navigator.pushNamed(context, '/assignments/$assignmentId');
    } else if (redirectUrl.contains('/materials/')) {
      // Navigate to material detail
      final materialId = redirectUrl.split('/').last;
      Navigator.pushNamed(context, '/materials/$materialId');
    } else if (redirectUrl.contains('/grades')) {
      // Navigate to grades page
      Navigator.pushNamed(context, '/grades');
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'assignment':
        return Icons.assignment;
      case 'grade':
        return Icons.grading;
      case 'material':
        return Icons.book;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'assignment':
        return Colors.blue;
      case 'grade':
        return Colors.green;
      case 'material':
        return Colors.purple;
      case 'system':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(dynamic dateTime) {
    DateTime parsedDate;

    if (dateTime is String) {
      parsedDate = DateTime.parse(dateTime);
    } else if (dateTime is DateTime) {
      parsedDate = dateTime;
    } else {
      return 'Unknown time';
    }

    final Duration difference = DateTime.now().difference(parsedDate);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(parsedDate);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}