import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/assignment_provider.dart';
import '../../models/assignment_model.dart';
import '../../utils/theme.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final int assignmentId;

  const AssignmentDetailScreen({
    Key? key,
    required this.assignmentId,
  }) : super(key: key);

  @override
  State<AssignmentDetailScreen> createState() =>
      _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
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
        Provider.of<AssignmentProvider>(context, listen: false);

    try {
      await provider.fetchAssignmentDetail(widget.assignmentId);
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
    final provider = Provider.of<AssignmentProvider>(context);
    final data = provider.assignmentDetail;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assignment Detail',
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
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load assignment detail',
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
        child: Text('Assignment detail is not available'),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    // Struktur API baru:
    // {
    //   "assignment": { ... },
    //   "submission": { ... } | null,
    //   "can_submit": true/false
    // }
    final assignmentJson =
        data['assignment'] as Map<String, dynamic>?;
    final submissionJson =
        data['submission'] as Map<String, dynamic>?;
    final bool canSubmit = data['can_submit'] == true;

    if (assignmentJson == null) {
      return _buildEmptyState();
    }

    // Coba map ke model Assignment untuk mendapatkan deadline, dll.
    Assignment? assignment;
    try {
      assignment = Assignment.fromJson(assignmentJson);
    } catch (_) {
      assignment = null;
    }

    final deadline = assignment?.deadline ??
        (assignmentJson['deadline'] != null
            ? DateTime.tryParse(
                assignmentJson['deadline'].toString(),
              )
            : null);

    final formattedDeadline =
        assignmentJson['formatted_deadline']?.toString();
    final daysRemaining = assignmentJson['days_remaining'];
    final isOverdue = assignmentJson['is_overdue'] == true;
    final subjectName = assignmentJson['subject_name']?.toString();
    final teacherName = assignmentJson['teacher_name']?.toString();
    final filePath =
        assignment?.filePath ?? assignmentJson['file_path']?.toString();
    final fileName = assignmentJson['file_name']?.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(
            title: assignment?.title ??
                (assignmentJson['title']?.toString() ?? 'Assignment'),
            subjectName: subjectName,
            teacherName: teacherName,
            deadline: deadline,
            formattedDeadline: formattedDeadline,
            daysRemaining: daysRemaining,
            isOverdue: isOverdue,
          ),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            description: assignment?.description ??
                (assignmentJson['description']?.toString() ??
                    'No description provided.'),
            fileName: fileName,
            filePath: filePath,
          ),
          const SizedBox(height: 16),
          if (submissionJson != null &&
              (submissionJson['grade'] != null ||
                  submissionJson['message_eval'] != null))
            _buildGradeCard(submissionJson),
          if (submissionJson != null &&
              (submissionJson['grade'] != null ||
                  submissionJson['message_eval'] != null))
            const SizedBox(height: 12),
          _buildSubmissionCard(submissionJson, canSubmit),
        ],
      ),
    );
  }

  Widget _buildHeaderCard({
    required String title,
    String? subjectName,
    String? teacherName,
    DateTime? deadline,
    String? formattedDeadline,
    dynamic daysRemaining,
    required bool isOverdue,
  }) {
    String? deadlineText;
    if (formattedDeadline != null) {
      deadlineText = formattedDeadline;
    } else if (deadline != null) {
      deadlineText =
          DateFormat('dd MMM yyyy, HH:mm').format(deadline);
    }

    String? chipText;
    Color chipColor = AppTheme.warningColor;
    if (daysRemaining != null && daysRemaining is num) {
      if (isOverdue) {
        chipText = 'Overdue';
        chipColor = AppTheme.errorColor;
      } else {
        chipText =
            'Due in ${daysRemaining.toInt()} day${daysRemaining == 1 ? '' : 's'}';
      }
    }

    return Container(
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
              Icons.assignment_outlined,
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
                if (deadlineText != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        deadlineText,
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
          if (chipText != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                chipText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: chipColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard({
    required String description,
    String? fileName,
    String? filePath,
  }) {
    return Container(
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
            'Description',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          if (filePath != null || fileName != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.attach_file, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    fileName ?? filePath ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradeCard(Map<String, dynamic> submission) {
    final gradeValue = submission['grade'];
    final messageEval = submission['message_eval']?.toString();

    return Container(
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
            'Grade',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppTheme.primaryColor.withOpacity(0.08),
                child: Text(
                  gradeValue.toString(),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (messageEval != null && messageEval.isNotEmpty)
                Expanded(
                  child: Text(
                    messageEval,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(
      Map<String, dynamic>? submission, bool canSubmit) {
    DateTime? submittedAt;
    bool isLate = false;
    String? fileName;
    bool canResubmit = false;

    if (submission != null) {
      if (submission['submitted_at'] != null) {
        submittedAt =
            DateTime.tryParse(submission['submitted_at'].toString());
      }
      isLate = submission['is_late'] == true;
      fileName = submission['file_name']?.toString();
      canResubmit = submission['can_resubmit'] == true;
    }

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
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
            'Submission',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          if (submittedAt != null)
            Row(
              children: [
                const Icon(Icons.check_circle,
                    size: 16, color: AppTheme.successColor),
                const SizedBox(width: 4),
                Text(
                  'Submitted at ${dateFormat.format(submittedAt)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            )
          else
            Row(
              children: const [
                Icon(Icons.info_outline,
                    size: 16, color: AppTheme.warningColor),
                SizedBox(width: 4),
                Text(
                  'Not submitted yet',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          if (fileName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_file, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (isLate) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: AppTheme.errorColor),
                SizedBox(width: 4),
                Text(
                  'Submitted late',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSubmit
                  ? () => _showSubmitBottomSheet(submission)
                  : null,
              child: Text(
                submittedAt != null
                    ? (canResubmit
                        ? 'Resubmit Assignment'
                        : 'Submission Locked')
                    : 'Submit Assignment',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitBottomSheet(Map<String, dynamic>? submission) {
    final textController = TextEditingController(
      text: submission?['submission_text']?.toString() ?? '',
    );
    String? selectedFilePath;
    String? selectedFileName;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickFile() async {
              final result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
              );
              if (result != null && result.files.isNotEmpty) {
                final file = result.files.single;
                if (file.path != null) {
                  setModalState(() {
                    selectedFilePath = file.path;
                    selectedFileName = file.name;
                  });
                }
              }
            }

            Future<void> submit() async {
              if (isSubmitting) return;
              setModalState(() {
                isSubmitting = true;
              });

              final provider = Provider.of<AssignmentProvider>(
                context,
                listen: false,
              );

              try {
                final text = textController.text.trim();
                await provider.submitAssignment(
                  widget.assignmentId,
                  submissionText: text.isEmpty ? null : text,
                  filePath: selectedFilePath,
                );

                if (!mounted) return;
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment submitted successfully.'),
                  ),
                );
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
                  setModalState(() {
                    isSubmitting = false;
                  });
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Submit Assignment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Submission text',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      selectedFileName ?? 'Attach file (optional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : submit,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
