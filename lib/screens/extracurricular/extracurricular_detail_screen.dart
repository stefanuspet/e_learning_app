import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/extracurricular_provider.dart';
import '../../utils/theme.dart';

class ExtracurricularDetailScreen extends StatefulWidget {
  final int id;

  const ExtracurricularDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<ExtracurricularDetailScreen> createState() =>
      _ExtracurricularDetailScreenState();
}

class _ExtracurricularDetailScreenState
    extends State<ExtracurricularDetailScreen> {
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
        Provider.of<ExtracurricularProvider>(context, listen: false);

    try {
      await provider.fetchDetail(widget.id);
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
    final data = provider.detail;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Extracurricular Detail',
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
            const Icon(Icons.error_outline,
                color: AppTheme.errorColor, size: 40),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load extracurricular detail',
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
        child: Text('Extracurricular detail is not available'),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final name = data['name']?.toString() ?? 'Extracurricular';
    final description =
        data['description']?.toString() ?? 'No description available.';
    final mentor = data['mentor_name']?.toString();
    final schedule = data['schedule']?.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          if (mentor != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Mentor: $mentor',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
          if (schedule != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Text(
                  schedule,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

