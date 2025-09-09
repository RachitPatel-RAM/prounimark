import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/user_model.dart';
import '../../../models/session_model.dart';
import '../../../services/attendance_service.dart';

class LiveSessionWidget extends StatefulWidget {
  final SessionModel session;
  final UserModel facultyUser;
  final VoidCallback onSessionEnded;

  const LiveSessionWidget({
    super.key,
    required this.session,
    required this.facultyUser,
    required this.onSessionEnded,
  });

  @override
  State<LiveSessionWidget> createState() => _LiveSessionWidgetState();
}

class _LiveSessionWidgetState extends State<LiveSessionWidget> {
  final AttendanceService _attendanceService = AttendanceService();
  
  SessionModel? _currentSession;
  List<String> _studentsPresent = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _loadSessionData();
    _startSessionMonitoring();
  }

  Future<void> _loadSessionData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final session = await _attendanceService.getSession(widget.session.id);
      if (session != null) {
        setState(() {
          _currentSession = session;
          _studentsPresent = session.studentsPresent;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Session not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load session data: $e';
        _isLoading = false;
      });
    }
  }

  void _startSessionMonitoring() {
    // In a real app, you would use Firestore real-time listeners
    // For now, we'll simulate with a timer
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadSessionData();
        _startSessionMonitoring();
      }
    });
  }

  Future<void> _endSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End Session'),
        content: Text('Are you sure you want to end this attendance session? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text('End Session'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _attendanceService.endSession(widget.session.id);
        if (mounted) {
          Navigator.pop(context);
          widget.onSessionEnded();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to end session: $e'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  String _getSessionDuration() {
    if (_sessionStartTime == null) return '00:00';
    
    final duration = DateTime.now().difference(_sessionStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Live Session',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 3.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  'LIVE',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _endSession,
            icon: Icon(
              Icons.stop,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            tooltip: 'End Session',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            )
          : _error != null
              ? Center(
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
                        onPressed: _loadSessionData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Session Info Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.lightTheme.colorScheme.primary,
                              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.play_circle,
                                  color: Colors.white,
                                  size: 6.w,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    _currentSession?.course ?? widget.session.course,
                                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSessionInfo(
                                    icon: Icons.class_,
                                    label: 'Class',
                                    value: _currentSession?.className ?? widget.session.className,
                                  ),
                                ),
                                Expanded(
                                  child: _buildSessionInfo(
                                    icon: Icons.group,
                                    label: 'Batch',
                                    value: _currentSession?.batchName ?? widget.session.batchName ?? 'All',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSessionInfo(
                                    icon: Icons.qr_code,
                                    label: 'Session Code',
                                    value: _currentSession?.sessionCode ?? widget.session.sessionCode ?? 'N/A',
                                  ),
                                ),
                                Expanded(
                                  child: _buildSessionInfo(
                                    icon: Icons.access_time,
                                    label: 'Duration',
                                    value: _getSessionDuration(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Attendance Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle,
                              label: 'Present',
                              value: _studentsPresent.length.toString(),
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.cancel,
                              label: 'Absent',
                              value: '0', // This would be calculated from total students
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Students Present List
                      Text(
                        'Students Present',
                        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      
                      if (_studentsPresent.isEmpty)
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
                                Icons.people_outline,
                                size: 15.w,
                                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No Students Yet',
                                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Students can mark attendance using the session code.',
                                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: _studentsPresent.asMap().entries.map((entry) {
                              final index = entry.key;
                              final studentId = entry.value;
                              return _buildStudentCard(studentId, index + 1);
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSessionInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 4.w,
          color: Colors.white.withValues(alpha: 0.8),
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(String studentId, int index) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student $studentId', // In real app, this would be the actual student name
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Enrollment: $studentId',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 5.w,
          ),
        ],
      ),
    );
  }
}
