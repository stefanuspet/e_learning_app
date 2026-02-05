import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/material_provider.dart';
import 'material_detail_screen.dart';

class MaterialListScreen extends StatefulWidget {
  const MaterialListScreen({Key? key}) : super(key: key);

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider =
        Provider.of<MaterialProvider>(context, listen: false);

    try {
      await provider.fetchMaterials();
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
    final materials = provider.materials;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : materials.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadMaterials,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: materials.length,
                        itemBuilder: (context, index) {
                          final item = materials[index];
                          return _buildMaterialCard(item);
                        },
                      ),
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
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load materials',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadMaterials,
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
        child: Text('No materials available'),
      ),
    );
  }

  Widget _buildMaterialCard(dynamic item) {
    final title = item is Map && item['title'] != null
        ? item['title'].toString()
        : 'Material';
    final subject = item is Map && item['subject_name'] != null
        ? item['subject_name'].toString()
        : null;
    final uploadedAtRaw =
        item is Map ? item['uploaded_at'] : null;
    DateTime? uploadedAt;
    if (uploadedAtRaw != null) {
      uploadedAt = uploadedAtRaw is DateTime
          ? uploadedAtRaw
          : DateTime.tryParse(uploadedAtRaw.toString());
    }
    final dateFormat = DateFormat('dd MMM yyyy');

    final id = item is Map && item['id'] != null
        ? int.tryParse(item['id'].toString())
        : null;

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
                    builder: (_) =>
                        MaterialDetailScreen(materialId: id),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subject != null) ...[
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              if (uploadedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(uploadedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

