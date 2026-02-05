import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/theme.dart';

class QuizDetailScreen extends StatefulWidget {
  final int quizId;

  const QuizDetailScreen({
    Key? key,
    required this.quizId,
  }) : super(key: key);

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;

  // questionId -> selected optionId (for multiple choice)
  final Map<int, int?> _selectedOptions = {};
  // questionId -> essay text
  final Map<int, String> _essayAnswers = {};

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

    final provider = Provider.of<QuizProvider>(context, listen: false);

    try {
      await provider.fetchQuizDetail(widget.quizId);
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
    final data = provider.quizDetail;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Detail',
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
    final message = _error ?? 'Failed to load quiz detail';
    final alreadyDone = message.contains('Quiz sudah dikerjakan');

    if (alreadyDone) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quiz sudah dikerjakan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nilai dan status kuis dapat kamu lihat di daftar kuis atau halaman nilai.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
              _error ?? 'Failed to load quiz detail',
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
        child: Text('Quiz detail is not available'),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    // Struktur baru: { "quiz": {...}, "questions": [...] }
    final quiz = (data['quiz'] ?? {}) as Map<String, dynamic>;
    final questions = (data['questions'] ?? []) as List<dynamic>;

    final title = quiz['title']?.toString() ?? 'Quiz';
    final duration = quiz['duration_minutes']?.toString();
    final totalQuestions = questions.length.toString();

    Color statusColor;
    String statusLabel = 'Quiz';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (totalQuestions.isNotEmpty) ...[
                          const Icon(Icons.list_alt, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$totalQuestions questions',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                        if (totalQuestions.isNotEmpty &&
                            duration != null) ...[
                          const SizedBox(width: 12),
                        ],
                        if (duration != null) ...[
                          const Icon(Icons.timer, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$duration minutes',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (questions.isEmpty)
            const Text(
              'No questions available for this quiz.',
              style: TextStyle(fontSize: 14),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(questions.length, (index) {
                final raw = questions[index] as Map<String, dynamic>;
                final questionId = raw['id'] as int? ?? 0;
                final type = raw['type']?.toString() ?? 'multiple_choice';
                final text = raw['question_text']?.toString() ?? '';
                final points = raw['points']?.toString();
                final options = (raw['options'] ?? []) as List<dynamic>;

                return _buildQuestionCard(
                  index: index,
                  questionId: questionId,
                  type: type,
                  text: text,
                  points: points,
                  options: options,
                );
              }),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () => _submitAnswers(questions),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Answers'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required int index,
    required int questionId,
    required String type,
    required String text,
    String? points,
    required List<dynamic> options,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (points != null) ...[
              const SizedBox(height: 4),
              Text(
                '$points pts',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (type == 'multiple_choice')
              Column(
                children: options.map((opt) {
                  final optMap = opt as Map<String, dynamic>;
                  final optionId = optMap['id'] as int? ?? 0;
                  final optionText =
                      optMap['option_text']?.toString() ?? '';

                  return RadioListTile<int>(
                    value: optionId,
                    groupValue: _selectedOptions[questionId],
                    onChanged: (value) {
                      setState(() {
                        _selectedOptions[questionId] = value;
                      });
                    },
                    title: Text(optionText),
                  );
                }).toList(),
              )
            else
              TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write your answer here',
                ),
                onChanged: (value) {
                  _essayAnswers[questionId] = value;
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAnswers(List<dynamic> questions) async {
    final provider = Provider.of<QuizProvider>(context, listen: false);

    final answers = questions.map((q) {
      final m = q as Map<String, dynamic>;
      final questionId = m['id'] as int? ?? 0;
      final type = m['type']?.toString() ?? 'multiple_choice';

      return {
        'question_id': questionId,
        'option_id':
            type == 'multiple_choice' ? _selectedOptions[questionId] : null,
        'essay_answer':
            type == 'multiple_choice' ? null : (_essayAnswers[questionId] ?? ''),
      };
    }).toList();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await provider.submitQuiz(widget.quizId, {
        'answers': answers,
      });

      if (!mounted) return;

      final score = result['score'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            score != null ? 'Quiz submitted. Score: $score' : 'Quiz submitted.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
