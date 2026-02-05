import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/grade_provider.dart';
import '../../models/grade_model.dart';
import '../../models/subject_model.dart';
import '../../models/assignment_model.dart';
import '../../utils/grade_utils.dart';
import '../materials/material_detail_screen.dart';
import '../quiz/quiz_detail_screen.dart';
import '../discussions/discussion_thread_screen.dart';
import '../assignments/assignment_detail_screen.dart';
import './widgets/empty_state_widget.dart';
import './widgets/error_state_widget.dart';

class GradeDetailScreen extends StatefulWidget {
  final int subjectId;

  const GradeDetailScreen({
    Key? key,
    required this.subjectId,
  }) : super(key: key);

  @override
  _GradeDetailScreenState createState() => _GradeDetailScreenState();
}

class _GradeDetailScreenState extends State<GradeDetailScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubjectGrades();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSubjectGrades() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
      await gradeProvider.getGradesBySubject(widget.subjectId);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_getSubjectName()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? ErrorStateWidget(
        message: _errorMessage!,
        onRetry: _loadSubjectGrades,
      )
          : _buildContent(),
    );
  }

  String _getSubjectName() {
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

    if (gradeProvider.subjectGrades != null &&
        gradeProvider.subjectGrades!['subject'] != null) {
      return gradeProvider.subjectGrades!['subject']['name'] as String? ?? 'Subject Details';
    }

    return 'Subject Details';
  }

  Widget _buildContent() {
    final gradeProvider = Provider.of<GradeProvider>(context);

    if (gradeProvider.subjectGrades == null) {
      return const Center(child: Text('No data available'));
    }

    final data = gradeProvider.subjectGrades!;

    // Jika backend sudah mengirimkan recent_activities (struktur baru),
    // gunakan itu sebagai sumber daftar aktivitas.
    if (data.containsKey('recent_activities')) {
      final activitiesData = data['recent_activities'];

      if (activitiesData is! List) {
        return const EmptyStateWidget(
          title: 'No activities yet',
          subtitle: 'Activities for this subject will appear here.',
          icon: Icons.inbox_outlined,
        );
      }

      final activities = activitiesData
          .whereType<Map<String, dynamic>>()
          .map((item) {
            final type = item['type']?.toString() ?? 'assignment';
            final id = int.tryParse(item['id'].toString()) ?? 0;
            final title = item['title']?.toString() ?? 'Activity';
            final dateStr = item['date']?.toString();
            DateTime? date =
                dateStr != null ? DateTime.tryParse(dateStr) : null;
            return _SubjectActivityItem(
              type: type,
              id: id,
              title: title,
              date: date,
            );
          })
          .toList();

      if (activities.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: EmptyStateWidget(
              title: 'No activities yet',
              subtitle: 'Activities for this subject will appear here.',
              icon: Icons.inbox_outlined,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return _buildActivityCard(
            context,
            activities[index],
            widget.subjectId,
          );
        },
      );
    }

    if (!gradeProvider.subjectGrades!.containsKey('subject') ||
        !gradeProvider.subjectGrades!.containsKey('stats') ||
        !gradeProvider.subjectGrades!.containsKey('assignments')) {
      return const EmptyStateWidget(
        title: 'Invalid data format',
        subtitle: 'The required data structure is not available',
        icon: Icons.error_outline,
      );
    }

    Subject subject;
    GradeStats stats;
    List<Assignment> gradedAssignments = [];
    List<Assignment> submittedAssignments = [];
    List<Assignment> pendingAssignments = [];

    try {
      subject = Subject.fromJson(gradeProvider.subjectGrades!['subject']);
      stats = GradeStats.fromJson(gradeProvider.subjectGrades!['stats']);

      /// ✅ get assignments map properly
      final assignmentsMap =
      gradeProvider.subjectGrades!['assignments'] as Map<String, dynamic>;

      /// graded
      if (assignmentsMap['graded'] != null) {
        gradedAssignments = (assignmentsMap['graded'] as List)
            .map((item) => Assignment.fromJson(item))
            .toList();
      }

      /// submitted_not_graded
      if (assignmentsMap['submitted_not_graded'] != null) {
        submittedAssignments =
            (assignmentsMap['submitted_not_graded'] as List)
                .map((item) => Assignment.fromJson(item))
                .toList();
      }

      /// not_submitted
      if (assignmentsMap['not_submitted'] != null) {
        pendingAssignments =
            (assignmentsMap['not_submitted'] as List)
                .map((item) => Assignment.fromJson(item))
                .toList();
      }
    } catch (e) {
      return EmptyStateWidget(
        title: 'Error parsing data',
        subtitle: 'Failed to process the data: ${e.toString()}',
        icon: Icons.error_outline,
      );
    }

    // Flatten all assignments into a single activity list
    final List<_SubjectActivityItem> activities = [
      ...gradedAssignments.map(
        (a) => _SubjectActivityItem(
          type: 'assignment',
          id: a.id,
          title: a.title,
          date: a.deadline,
        ),
      ),
      ...submittedAssignments.map(
        (a) => _SubjectActivityItem(
          type: 'assignment',
          id: a.id,
          title: a.title,
          date: a.deadline,
        ),
      ),
      ...pendingAssignments.map(
        (a) => _SubjectActivityItem(
          type: 'assignment',
          id: a.id,
          title: a.title,
          date: a.deadline,
        ),
      ),
    ];

    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: EmptyStateWidget(
            title: 'No activities yet',
            subtitle: 'Activities for this subject will appear here.',
            icon: Icons.inbox_outlined,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return _buildActivityCard(
          context,
          activities[index],
          widget.subjectId,
        );
      },
    );
  }


  Widget _buildSubjectInfoCard(Subject subject, GradeStats stats) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.book,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Teacher: ${subject.teacher?.name ?? 'Not Assigned'}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (subject.description != null && subject.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      subject.description!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGradedTab(List<Assignment> assignments) {
    return assignments.isEmpty
        ? const EmptyStateWidget(
      title: 'No graded assignments',
      subtitle: 'Your graded assignments will appear here',
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return _buildGradedAssignmentItem(assignments[index]);
      },
    );
  }

  Widget _buildSubmittedTab(List<Assignment> assignments) {
    return assignments.isEmpty
        ? const EmptyStateWidget(
      title: 'No submitted assignments',
      subtitle: 'Your submitted assignments will appear here',
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return _buildSubmittedAssignmentItem(assignments[index]);
      },
    );
  }

  Widget _buildPendingTab(List<Assignment> assignments) {
    return assignments.isEmpty
        ? const EmptyStateWidget(
      title: 'No pending assignments',
      subtitle: 'Your pending assignments will appear here',
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        final isOverdue = GradeUtils.isAssignmentOverdue(assignment.deadline);

        return _buildPendingAssignmentItem(assignment, isOverdue);
      },
    );
  }

  Widget _buildGradedAssignmentItem(Assignment assignment) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          _showAssignmentDetails(assignment);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (assignment.grade != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: GradeUtils.getGradeColor(assignment.grade!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${assignment.grade}',
                        style: TextStyle(
                          color: GradeUtils.getGradeColor(assignment.grade!),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                assignment.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${DateFormat('MMM d, yyyy').format(assignment.deadline)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (assignment.submittedAt != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Submitted: ${DateFormat('MMM d, yyyy').format(assignment.submittedAt!)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (assignment.isLate)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Submitted Late',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSubmittedAssignmentItem(Assignment assignment) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assignment.description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('MMM d, yyyy').format(assignment.deadline)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (assignment.submittedAt != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Submitted: ${DateFormat('MMM d, yyyy').format(assignment.submittedAt!)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (assignment.isLate)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Submitted Late',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingAssignmentItem(Assignment assignment, bool isOverdue) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isOverdue ? 'Overdue' : 'Pending',
                    style: TextStyle(
                      color: isOverdue ? Colors.red.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assignment.description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${DateFormat('MMM d, yyyy').format(assignment.deadline)}',
                  style: TextStyle(
                    color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignmentDetails(Assignment assignment) async {
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Fetch class performance data
      await gradeProvider.getClassPerformance(assignment.id);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      } else {
        return; // Context not available, bail out
      }

      // Get the performance data
      final classPerformance = gradeProvider.classPerformance ?? {
        'class_average': 'N/A',
        'class_highest': 'N/A',
        'class_lowest': 'N/A',
        'your_rank': 'N/A',
      };

      // Show the bottom sheet with assignment details
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _buildAssignmentDetailModal(assignment, classPerformance);
        },
      );
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      } else {
        return; // Context not available, bail out
      }

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load class performance: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Show the bottom sheet with assignment details but without class performance
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _buildAssignmentDetailModal(
            assignment,
            {
              'class_average': 'N/A',
              'class_highest': 'N/A',
              'class_lowest': 'N/A',
              'your_rank': 'N/A',
            },
          );
        },
      );
    }
  }

  Widget _buildAssignmentDetailModal(Assignment assignment, Map<String, dynamic> classPerformance) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                if (assignment.grade != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: GradeUtils.getGradeColor(assignment.grade!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${assignment.grade}',
                      style: TextStyle(
                        color: GradeUtils.getGradeColor(assignment.grade!),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dates
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Due Date',
                          DateFormat('MMMM d, yyyy').format(assignment.deadline),
                          Icons.calendar_today,
                        ),
                        if (assignment.submittedAt != null) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Submitted Date',
                            DateFormat('MMMM d, yyyy, h:mm a').format(assignment.submittedAt!),
                            Icons.check_circle,
                            textColor: assignment.isLate ? Colors.red.shade700 : Colors.green,
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Evaluation (if graded)
                  if (assignment.messageEval != null && assignment.messageEval!.isNotEmpty) ...[
                    Text(
                      'Teacher\'s Feedback',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        assignment.messageEval!,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Performance
                  Text(
                    'Class Performance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Class Average',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${classPerformance['class_average']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Class Highest',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${classPerformance['class_highest']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Class Lowest',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${classPerformance['class_lowest']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Rank',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${classPerformance['your_rank']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? textColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: textColor ?? Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor ?? Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}

class _SubjectActivityItem {
  final String type;
  final int id;
  final String title;
  final DateTime? date;

  _SubjectActivityItem({
    required this.type,
    required this.id,
    required this.title,
    required this.date,
  });
}

Widget _buildActivityCard(
  BuildContext context,
  _SubjectActivityItem activity,
  int subjectId,
) {
  Color statusColor;
  String statusLabel;
  IconData icon;

  switch (activity.type) {
    case 'material':
      statusColor = Colors.green.shade600;
      statusLabel = 'Material';
      icon = Icons.insert_drive_file_outlined;
      break;
    case 'quiz':
      statusColor = Colors.purple.shade600;
      statusLabel = 'Quiz';
      icon = Icons.timer_outlined;
      break;
    case 'discussion':
      statusColor = Colors.orange.shade700;
      statusLabel = 'Discussion';
      icon = Icons.forum_outlined;
      break;
    case 'assignment':
    default:
      statusColor = Colors.blue.shade600;
      statusLabel = 'Assignment';
      icon = Icons.assignment_outlined;
      break;
  }

  return InkWell(
    onTap: () {
      if (activity.type == 'assignment') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AssignmentDetailScreen(assignmentId: activity.id),
          ),
        );
      } else if (activity.type == 'discussion') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiscussionThreadScreen(
              subjectId: subjectId,
              threadId: activity.id,
            ),
          ),
        );
      } else if (activity.type == 'quiz') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizDetailScreen(quizId: activity.id),
          ),
        );
      } else if (activity.type == 'material') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MaterialDetailScreen(materialId: activity.id),
          ),
        );
      }
    },
    borderRadius: BorderRadius.circular(12),
    child: Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: statusColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 200,
                      child: Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      activity.date != null
                          ? DateFormat('MMM d, yyyy').format(activity.date!)
                          : '-',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
