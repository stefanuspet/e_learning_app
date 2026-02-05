import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/material_provider.dart';
import '../../api/api_client.dart';
import '../../utils/theme.dart';

class MaterialDetailScreen extends StatefulWidget {
  final int materialId;

  const MaterialDetailScreen({
    Key? key,
    required this.materialId,
  }) : super(key: key);

  @override
  State<MaterialDetailScreen> createState() =>
      _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider =
        Provider.of<MaterialProvider>(context, listen: false);

    try {
      await provider.fetchMaterialDetail(widget.materialId);
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
    final provider = Provider.of<MaterialProvider>(context);
    final data = provider.materialDetail;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Material Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : data == null
                  ? _buildEmptyState()
                  : _buildContent(data),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load material detail',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadDetail,
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
        child: Text('Material detail is not available'),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final material = data['material'] as Map<String, dynamic>?;
    final related =
        data['related'] is List ? data['related'] as List : <dynamic>[];

    if (material == null) {
      return _buildEmptyState();
    }

    final title = material['title']?.toString() ?? 'Material';
    final content =
        material['content']?.toString() ?? 'No description available.';
    final subjectName = material['subject_name']?.toString();
    final teacherName = material['teacher_name']?.toString();
    final createdAt = material['created_at']?.toString();
    final filePath = material['file_path']?.toString();
    final fileName = material['file_name']?.toString();
    final fileType = material['file_type']?.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.insert_drive_file_outlined,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (subjectName != null || teacherName != null)
                        Row(
                          children: [
                            if (subjectName != null) ...[
                              const Icon(Icons.book_outlined, size: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  subjectName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (subjectName != null && teacherName != null)
                              const SizedBox(width: 8),
                            if (teacherName != null) ...[
                              const Icon(Icons.person_outline, size: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  teacherName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (createdAt != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              createdAt,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Content',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                if (filePath != null && filePath.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openFile(filePath),
                      icon: Icon(
                        fileType == 'video'
                            ? Icons.play_circle_fill
                            : Icons.download,
                      ),
                      label: Text(
                        fileName?.isNotEmpty == true
                            ? 'Open ${fileName!}'
                            : 'Open file',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (related.isNotEmpty) ...[
            const Text(
              'Related materials',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: related.map((item) {
                if (item is! Map) return const SizedBox.shrink();
                final id = int.tryParse(item['id']?.toString() ?? '');
                final rTitle = item['title']?.toString() ?? 'Material';
                final rType = item['file_type']?.toString();
                final rCreated = item['created_at']?.toString();

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    onTap: id == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MaterialDetailScreen(
                                  materialId: id,
                                ),
                              ),
                            );
                          },
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppTheme.primaryColor.withOpacity(0.08),
                      child: Icon(
                        rType == 'video'
                            ? Icons.play_circle_fill
                            : Icons.insert_drive_file_outlined,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      rTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: rCreated != null
                        ? Text(
                            rCreated,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openFile(String filePath) async {
    // baseUrl: http://10.0.2.2:8000/api -> backend root: http://10.0.2.2:8000
    final apiBase = ApiClient.baseUrl;
    final root = apiBase.endsWith('/api')
        ? apiBase.substring(0, apiBase.length - 4)
        : apiBase;
    final url = Uri.parse('$root/storage/$filePath');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open file.'),
        ),
      );
    }
  }
}
