import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/classroom_provider.dart';
import '../../utils/theme.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({Key? key}) : super(key: key);

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentClass();
  }

  Future<void> _loadCurrentClass() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider =
        Provider.of<ClassroomProvider>(context, listen: false);

    try {
      await provider.fetchCurrentClass();
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
    final provider = Provider.of<ClassroomProvider>(context);
    final currentClass = provider.currentClass;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Class',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : currentClass == null
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadCurrentClass,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildClassCard(),
                        ],
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
              _error ?? 'Failed to load class information',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadCurrentClass,
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
        child: Text('Class information is not available'),
      ),
    );
  }

  Widget _buildClassCard() {
    final provider = Provider.of<ClassroomProvider>(context, listen: false);
    final currentClass = provider.currentClass!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.class_,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentClass.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Class ID: ${currentClass.id}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              currentClass.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

