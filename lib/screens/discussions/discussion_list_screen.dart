import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discussion_provider.dart';
import '../../utils/theme.dart';
import 'discussion_thread_screen.dart';

class DiscussionListScreen extends StatefulWidget {
  final int subjectId;

  const DiscussionListScreen({
    Key? key,
    required this.subjectId,
  }) : super(key: key);

  @override
  State<DiscussionListScreen> createState() => _DiscussionListScreenState();
}

class _DiscussionListScreenState extends State<DiscussionListScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider =
        Provider.of<DiscussionProvider>(context, listen: false);

    try {
      await provider.loadSubjectAndDiscussions(widget.subjectId);
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiscussionProvider>(context);
    final subject = provider.subjectDetail;
    final discussions = provider.discussions;

    final String subjectName = subject != null
        ? (subject['name']?.toString() ?? 'Subject Discussions')
        : 'Subject Discussions';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          subjectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : discussions.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: discussions.length,
                        itemBuilder: (context, index) {
                          final item = discussions[index];
                          return _buildDiscussionCard(item);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
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
              _error ?? 'Failed to load discussions',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadData,
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
        child: Text('No discussions yet. Be the first to start one!'),
      ),
    );
  }

  Widget _buildDiscussionCard(dynamic item) {
    if (item is! Map) {
      return const SizedBox.shrink();
    }

    final title = item['title']?.toString() ?? 'Discussion';
    final author = item['creator']?.toString();
    final replies =
        int.tryParse(item['replies_count']?.toString() ?? '0') ?? 0;
    final id = int.tryParse(item['id']?.toString() ?? '');
    final createdAt = item['created_at']?.toString();
    final excerpt = item['excerpt']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: id == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiscussionThreadScreen(
                      subjectId: widget.subjectId,
                      threadId: id,
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.forum_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (excerpt != null && excerpt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                    if (author != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'By $author',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$replies replies',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        if (createdAt != null)
                          Text(
                            createdAt,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Discussion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Content',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim();

                if (title.isEmpty || content.isEmpty) return;

                final provider = Provider.of<DiscussionProvider>(
                  context,
                  listen: false,
                );

                try {
                  await provider.createDiscussion(widget.subjectId, {
                    'title': title,
                    'body': content,
                  });
                  if (mounted) Navigator.pop(context);
                } catch (_) {}
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
