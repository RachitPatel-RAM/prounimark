import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/user_model.dart';
import '../../../models/session_model.dart';
import '../../../services/attendance_service.dart';

class AttendanceReportsWidget extends StatefulWidget {
  final UserModel facultyUser;

  const AttendanceReportsWidget({
    super.key,
    required this.facultyUser,
  });

  @override
  State<AttendanceReportsWidget> createState() => _AttendanceReportsWidgetState();
}

class _AttendanceReportsWidgetState extends State<AttendanceReportsWidget> {
  final AttendanceService _attendanceService = AttendanceService();
  
  List<SessionModel> _sessions = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedCourse;
  String? _selectedClass;
  String? _selectedBatch;

  // Mock data - in real app, this would come from Firestore
  final List<String> _courses = [
    'All Courses',
    'Data Structures',
    'Algorithms',
    'Database Systems',
    'Software Engineering',
    'Computer Networks',
  ];

  final List<String> _classes = [
    'All Classes',
    'CE-1',
    'CE-2',
    'CE-3',
    'IT-1',
    'IT-2',
  ];

  final List<String> _batches = [
    'All Batches',
    'A',
    'B',
    'C',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCourse = _courses.first;
    _selectedClass = _classes.first;
    _selectedBatch = _batches.first;
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = await _attendanceService.getFacultySessions(widget.facultyUser.id);
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load sessions: $e';
        _isLoading = false;
      });
    }
  }

  List<SessionModel> get _filteredSessions {
    return _sessions.where((session) {
      if (_selectedCourse != null && _selectedCourse != 'All Courses' && session.course != _selectedCourse) {
        return false;
      }
      if (_selectedClass != null && _selectedClass != 'All Classes' && session.className != _selectedClass) {
        return false;
      }
      if (_selectedBatch != null && _selectedBatch != 'All Batches' && session.batchName != _selectedBatch) {
        return false;
      }
      return true;
    }).toList();
  }

  Map<String, dynamic> _getSessionStats() {
    final completedSessions = _filteredSessions.where((s) => s.endTime != null).toList();
    final totalStudents = completedSessions.fold<int>(0, (sum, session) => sum + session.studentsPresent.length);
    final totalSessions = completedSessions.length;
    final averageAttendance = totalSessions > 0 ? (totalStudents / totalSessions).round() : 0;

    return {
      'totalSessions': totalSessions,
      'totalStudents': totalStudents,
      'averageAttendance': averageAttendance,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 15.w,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            SizedBox(height: 2.h),
            Text(
              _error!,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _loadSessions,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = _getSessionStats();
    final filteredSessions = _filteredSessions;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Attendance Reports',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Filters
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCourse,
                        decoration: InputDecoration(
                          labelText: 'Course',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _courses.map((course) {
                          return DropdownMenuItem(
                            value: course,
                            child: Text(course),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCourse = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedClass,
                        decoration: InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _classes.map((classItem) {
                          return DropdownMenuItem(
                            value: classItem,
                            child: Text(classItem),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBatch,
                        decoration: InputDecoration(
                          labelText: 'Batch',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _batches.map((batch) {
                          return DropdownMenuItem(
                            value: batch,
                            child: Text(batch),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBatch = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event,
                  label: 'Total Sessions',
                  value: stats['totalSessions'].toString(),
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  label: 'Total Students',
                  value: stats['totalStudents'].toString(),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 2.h),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  label: 'Avg Attendance',
                  value: stats['averageAttendance'].toString(),
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.analytics,
                  label: 'Completion Rate',
                  value: '${((stats['totalSessions'] / _sessions.length) * 100).round()}%',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 4.h),
          
          // Sessions List
          Text(
            'Session History',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          
          if (filteredSessions.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 15.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No Sessions Found',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'No completed sessions match your current filters.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: filteredSessions.map((session) => _buildSessionReportCard(session)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 8.w,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionReportCard(SessionModel session) {
    final isCompleted = session.endTime != null;
    final duration = isCompleted 
        ? session.endTime!.difference(session.startTime)
        : DateTime.now().difference(session.startTime);
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted 
              ? Colors.green.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.schedule,
                color: isCompleted ? Colors.green : AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  session.course,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'In Progress',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isCompleted ? Colors.green.shade700 : AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildReportInfo(
                  icon: Icons.class_,
                  label: 'Class',
                  value: session.className,
                ),
              ),
              Expanded(
                child: _buildReportInfo(
                  icon: Icons.group,
                  label: 'Batch',
                  value: session.batchName ?? 'All',
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildReportInfo(
                  icon: Icons.access_time,
                  label: 'Duration',
                  value: '${duration.inMinutes}m ${duration.inSeconds % 60}s',
                ),
              ),
              Expanded(
                child: _buildReportInfo(
                  icon: Icons.people,
                  label: 'Present',
                  value: '${session.studentsPresent.length}',
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildReportInfo(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: _formatDate(session.startTime),
                ),
              ),
              if (session.sessionCode != null)
                Expanded(
                  child: _buildReportInfo(
                    icon: Icons.qr_code,
                    label: 'Code',
                    value: session.sessionCode!,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 4.w,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
}
