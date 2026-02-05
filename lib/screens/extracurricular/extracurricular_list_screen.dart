import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/extracurricular_provider.dart';
import '../../utils/theme.dart';
import 'extracurricular_detail_screen.dart';

class ExtracurricularListScreen extends StatefulWidget {
  const ExtracurricularListScreen({Key? key}) : super(key: key);

  @override
  State<ExtracurricularListScreen> createState() =>
      _ExtracurricularListScreenState();
}

class _ExtracurricularListScreenState
    extends State<ExtracurricularListScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExtracurriculars();
  }

  Future<void> _loadExtracurriculars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider =
        Provider.of<ExtracurricularProvider>(context, listen: false);

    try {
      await provider.fetchExtracurriculars();
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
    final provider = Provider.of<ExtracurricularProvider>(context);
    final items = provider.extracurriculars;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Extracurriculars',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : items.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadExtracurriculars,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildCard(item);
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
            const Icon(Icons.error_outline,
                color: AppTheme.errorColor, size: 40),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load extracurriculars',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadExtracurriculars,
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
        child: Text('No extracurriculars available'),
      ),
    );
  }

  Widget _buildCard(dynamic item) {
    final name = item is Map && item['name'] != null
        ? item['name'].toString()
        : 'Extracurricular';
    final description = item is Map && item['description'] != null
        ? item['description'].toString()
        : null;
    final mentor = item is Map && item['mentor_name'] != null
        ? item['mentor_name'].toString()
        : null;
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
                        ExtracurricularDetailScreen(id: id),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              if (mentor != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Mentor: $mentor',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

