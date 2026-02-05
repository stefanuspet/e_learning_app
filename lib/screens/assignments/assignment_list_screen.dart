import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/assignment_provider.dart';
import '../../models/assignment_model.dart';
import 'assignment_detail_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({Key? key}) : super(key: key);

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider =
        Provider.of<AssignmentProvider>(context, listen: false);

    try {
      await provider.fetchAssignments();
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
    final assignments = provider.assignments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : assignments.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadAssignments,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: assignments.length,
                        itemBuilder: (context, index) {
                          final assignment = assignments[index];
                          return _buildAssignmentCard(assignment);
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
              _error ?? 'Failed to load assignments',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadAssignments,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.assignment_outlined,
                color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text(
              'No assignments yet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Your assignments will appear here when available.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final deadlineText = dateFormat.format(assignment.deadline);

    String statusText;
    Color statusColor;

    if (assignment.submittedAt != null) {
      statusText = 'Submitted';
      statusColor = Colors.green;
    } else if (assignment.isLate) {
      statusText = 'Overdue';
      statusColor = Colors.red;
    } else {
      statusText = 'Pending';
      statusColor = Colors.orange;
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AssignmentDetailScreen(assignmentId: assignment.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                assignment.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Deadline: $deadlineText',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (assignment.grade != null)
                    Row(
                      children: [
                        const Icon(Icons.grade, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Grade: ${assignment.grade}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
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
}

