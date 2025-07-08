import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/grade_provider.dart';
import '../../models/grade_model.dart';
import '../../models/assignment_model.dart';
import '../../utils/grade_utils.dart';
import './grade_detail_screen.dart';
import './widgets/error_state_widget.dart';
import './widgets/empty_state_widget.dart';

class GradeListScreen extends StatefulWidget {
  const GradeListScreen({Key? key}) : super(key: key);

  @override
  _GradeListScreenState createState() => _GradeListScreenState();
}

class _GradeListScreenState extends State<GradeListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedSubjectId;
  List<Map<String, dynamic>>? _subjects;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

      // Load subjects for dropdown
      try {
        await gradeProvider.getSubjects();
        _subjects = gradeProvider.subjects;
      } catch (e) {
        // Failed to load subjects, but we can still try to load grades
        print('Failed to load subjects: $e');
      }

      // Load grades based on selected subject
      if (_selectedSubjectId != null) {
        await gradeProvider.getGradesBySubject(_selectedSubjectId!);
      } else {
        await gradeProvider.getGrades();
      }
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
        title: const Text('My Grades'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? ErrorStateWidget(
        message: _errorMessage!,
        onRetry: _loadGrades,
      )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final gradeProvider = Provider.of<GradeProvider>(context);
    final grades = gradeProvider.grades;

    // Check if the required data is available
    if (!grades.containsKey('stats') || !grades.containsKey('subjects')) {
      return const EmptyStateWidget(
        title: 'No grade data available',
        subtitle: 'Your grades will appear here when available',
        icon: Icons.assessment_outlined,
      );
    }

    // If subjects list is empty
    final List subjects = grades['subjects'] as List;
    if (subjects.isEmpty) {
      return const EmptyStateWidget(
        title: 'No subjects available',
        subtitle: 'Your enrolled subjects will appear here',
        icon: Icons.school_outlined,
      );
    }

    // Extract data from provider - safely
    final stats = GradeStats.fromJson(grades['stats']);

    // Convert subjects list to SubjectGrade objects
    final List<SubjectGrade> subjectGrades = [];
    for (var subject in subjects) {
      try {
        subjectGrades.add(SubjectGrade.fromJson(subject));
      } catch (e) {
        print('Error parsing subject data: $e');
        // Skip this subject if parsing fails
      }
    }

    // If no grades after parsing
    if (subjectGrades.isEmpty) {
      return const EmptyStateWidget(
        title: 'No grades available',
        subtitle: 'Your grades will appear here when available',
        icon: Icons.assessment_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGrades,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Stats Card
              _buildStatsCard(stats),
              const SizedBox(height: 24),

              // Subject selector
              // if (_subjects != null && _subjects!.isNotEmpty)
              //   Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.grey.shade300),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: DropdownButtonHideUnderline(
              //       child: DropdownButton<int?>(
              //         isExpanded: true,
              //         hint: const Text('Filter by Subject'),
              //         value: _selectedSubjectId,
              //         items: _subjects!.map((subject) {
              //           return DropdownMenuItem<int?>(
              //             value: subject['id'] as int?,
              //             child: Text(subject['name'] as String),
              //           );
              //         }).toList(),
              //         onChanged: (value) {
              //           setState(() {
              //             _selectedSubjectId = value;
              //           });
              //           _loadGrades();
              //         },
              //       ),
              //     ),
              //   ),
              // const SizedBox(height: 24),

              // Grades by Subject
              ...subjectGrades.map((subject) => _buildSubjectGradeCard(subject)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(GradeStats stats) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grade Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBox(
                'Average',
                '${stats.averageGrade.toStringAsFixed(1)}',
                Colors.white,
              ),
              _buildStatBox(
                'Highest',
                '${stats.highestGrade}',
                Colors.green.shade300,
              ),
              _buildStatBox(
                'Lowest',
                '${stats.lowestGrade}',
                Colors.orange.shade300,
              ),
              _buildStatBox(
                'Total',
                '${stats.totalAssignments}',
                Colors.purple.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color valueColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectGradeCard(SubjectGrade subject) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
          // Subject header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
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
                        subject.subjectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subject.totalGraded} assignments graded',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: GradeUtils.getGradeColor(subject.averageGrade).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Avg: ${subject.averageGrade.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: GradeUtils.getGradeColor(subject.averageGrade),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subject assignments
          if (subject.assignments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No assignments available',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subject.assignments.length > 2 ? 2 : subject.assignments.length,
              itemBuilder: (context, index) {
                return _buildAssignmentItem(subject.assignments[index]);
              },
            ),

          // View all button
          if (subject.assignments.length > 2)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GradeDetailScreen(subjectId: subject.subjectId),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                // decoration: BoxDecoration(
                //   color: Colors.grey.shade50,
                  // borderRadius: const BorderRadius.only(
                  //   bottomLeft: Radius.circular(16),
                  //   bottomRight: Radius.circular(16),
                  // ),
                  // border: Border(
                  //   top: BorderSide(color: Colors.grey.shade200),
                  // ),
                // ),
                // child: Center(
                //   child: Text(
                //     'View All Assignments',
                //     style: TextStyle(
                //       color: Colors.blue.shade600,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentItem(Assignment assignment) {
    return InkWell(
        onTap: () {
          // Navigate to assignment detail
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
          Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              if (assignment.submittedAt != null)
                Text(
                  DateFormat('MMMM d, yyyy').format(assignment.submittedAt!),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              if (assignment.isLate)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Late',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 10,
                    ),
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
        fontSize: 16,
      ),
    ),
    ),
            ],
          ),
        ),
    );
  }
}