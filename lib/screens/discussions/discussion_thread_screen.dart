import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discussion_provider.dart';
import '../../utils/theme.dart';

class DiscussionThreadScreen extends StatefulWidget {
  final int subjectId;
  final int threadId;

  const DiscussionThreadScreen({
    Key? key,
    required this.subjectId,
    required this.threadId,
  }) : super(key: key);

  @override
  State<DiscussionThreadScreen> createState() =>
      _DiscussionThreadScreenState();
}

class _DiscussionThreadScreenState extends State<DiscussionThreadScreen> {
  bool _isLoading = true;
  String? _error;
  final TextEditingController _replyController = TextEditingController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadThread();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshThreadSilently(),
    );
  }

  Future<void> _loadThread() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider =
        Provider.of<DiscussionProvider>(context, listen: false);

    try {
      await provider.loadThread(widget.subjectId, widget.threadId);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshThreadSilently() async {
    final provider =
        Provider.of<DiscussionProvider>(context, listen: false);
    try {
      await provider.loadThread(widget.subjectId, widget.threadId);
    } catch (_) {
      // ignore auto-refresh errors
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiscussionProvider>(context);
    final data = provider.threadDetail;
    final thread =
        data != null ? data['thread'] as Map<String, dynamic>? : null;
    final replies =
        data != null && data['replies'] is List ? data['replies'] as List : <dynamic>[];
    final currentUserId = data != null ? data['current_user_id'] : null;

    final String title = thread != null
        ? (thread['title']?.toString() ?? 'Discussion')
        : 'Discussion';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : thread == null
                        ? _buildEmptyState()
                        : _buildContent(thread, replies, currentUserId),
          ),
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppTheme.errorColor, size: 40),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load discussion',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadThread,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Discussion is not available'),
      ),
    );
  }

  Widget _buildContent(
    Map<String, dynamic> thread,
    List<dynamic> replies,
    dynamic currentUserId,
  ) {
    final creator = thread['creator'] is Map
        ? (thread['creator']['name']?.toString() ?? 'User')
        : thread['creator']?.toString();
    final body =
        thread['body']?.toString() ?? 'No content available.';

    return RefreshIndicator(
      onRefresh: _loadThread,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread['title']?.toString() ?? 'Discussion',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  if (creator != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'By $creator',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Replies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          if (replies.isEmpty)
            const Text(
              'No replies yet. Be the first to reply!',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryColor,
              ),
            )
          else
            ...replies.map(
              (reply) => _buildReplyCard(reply, currentUserId),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(dynamic reply, dynamic currentUserId) {
    if (reply is! Map) return const SizedBox.shrink();

    final user = reply['user'];
    final userName = user is Map
        ? (user['name']?.toString() ?? 'User')
        : reply['user_name']?.toString() ?? 'User';
    final body = reply['body']?.toString() ?? '';
    final isMine =
        currentUserId != null && user is Map && user['id'] == currentUserId;

    final bubbleColor =
        isMine ? AppTheme.primaryColor : Colors.grey.shade100;
    final textColor = isMine ? Colors.white : AppTheme.textPrimaryColor;
    final metaColor =
        isMine ? Colors.white70 : AppTheme.textSecondaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (!isMine) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMine
                      ? const Radius.circular(12)
                      : const Radius.circular(2),
                  bottomRight: isMine
                      ? const Radius.circular(2)
                      : const Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMine ? 'You' : userName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: metaColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMine) const SizedBox(width: 8),
          if (isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write a reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppTheme.primaryColor),
              onPressed: _submitReply,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final provider =
        Provider.of<DiscussionProvider>(context, listen: false);

    try {
      await provider.replyDiscussion(widget.subjectId, widget.threadId, {
        'body': text,
      });
      _replyController.clear();
    } catch (_) {}
  }
}
