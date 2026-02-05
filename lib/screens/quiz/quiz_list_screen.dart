import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/theme.dart';
import 'quiz_detail_screen.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({Key? key}) : super(key: key);

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider = Provider.of<QuizProvider>(context, listen: false);

    try {
      await provider.fetchQuizzes();
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
    final provider = Provider.of<QuizProvider>(context);
    final quizzes = provider.quizzes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quizzes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : quizzes.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadQuizzes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          final item = quizzes[index];
                          return _buildQuizCard(item);
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
              _error ?? 'Failed to load quizzes',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadQuizzes,
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
        child: Text('No quizzes available'),
      ),
    );
  }

  Widget _buildQuizCard(dynamic item) {
    final title = item is Map && item['title'] != null
        ? item['title'].toString()
        : 'Quiz';
    final subject = item is Map && item['subject_name'] != null
        ? item['subject_name'].toString()
        : null;
    final status = item is Map && item['status'] != null
        ? item['status'].toString()
        : null;
    final id = item is Map && item['id'] != null
        ? int.tryParse(item['id'].toString())
        : null;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'completed':
        statusColor = AppTheme.successColor;
        statusLabel = 'Completed';
        break;
      case 'ongoing':
        statusColor = AppTheme.primaryColor;
        statusLabel = 'Ongoing';
        break;
      case 'upcoming':
        statusColor = AppTheme.warningColor;
        statusLabel = 'Upcoming';
        break;
      default:
        statusColor = AppTheme.textSecondaryColor;
        statusLabel = status ?? 'Quiz';
        break;
    }

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
                    builder: (_) => QuizDetailScreen(quizId: id),
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
                  Icons.quiz_outlined,
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
                    ),
                    if (subject != null)
                      Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

