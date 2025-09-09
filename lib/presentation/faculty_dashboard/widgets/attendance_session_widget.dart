import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/user_model.dart';
import '../../../models/session_model.dart';
import '../../../services/attendance_service.dart';
import 'create_session_dialog.dart';
import 'live_session_widget.dart';

class AttendanceSessionWidget extends StatefulWidget {
  final UserModel facultyUser;
  final bool isLocationEnabled;
  final VoidCallback onLocationCheck;

  const AttendanceSessionWidget({
    super.key,
    required this.facultyUser,
    required this.isLocationEnabled,
    required this.onLocationCheck,
  });

  @override
  State<AttendanceSessionWidget> createState() => _AttendanceSessionWidgetState();
}

class _AttendanceSessionWidgetState extends State<AttendanceSessionWidget> {
  final AttendanceService _attendanceService = AttendanceService();
  
  List<SessionModel> _sessions = [];
  bool _isLoading = true;
  String? _error;
  SessionModel? _activeSession;

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _checkActiveSession();
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

  Future<void> _checkActiveSession() async {
    try {
      final activeSession = await _attendanceService.getActiveSession(widget.facultyUser.id);
      setState(() {
        _activeSession = activeSession;
      });
    } catch (e) {
      // No active session or error
      setState(() {
        _activeSession = null;
      });
    }
  }

  Future<void> _createNewSession() async {
    if (!widget.isLocationEnabled) {
      _showLocationWarning();
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateSessionDialog(
        facultyUser: widget.facultyUser,
      ),
    );

    if (result == true) {
      _loadSessions();
      _checkActiveSession();
    }
  }

  void _showLocationWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: AppTheme.lightTheme.colorScheme.error),
            SizedBox(width: 2.w),
            Text('Location Required'),
          ],
        ),
        content: Text(
          'Location must be enabled to start an attendance session. Please enable location services and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLocationCheck();
            },
            child: Text('Check Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinActiveSession(SessionModel session) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveSessionWidget(
          session: session,
          facultyUser: widget.facultyUser,
          onSessionEnded: () {
            _loadSessions();
            _checkActiveSession();
          },
        ),
      ),
    );
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attendance Sessions',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _createNewSession,
                icon: Icon(Icons.add),
                label: Text('New Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 3.h),
          
          // Active Session Card
          if (_activeSession != null)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 3.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle,
                        color: Colors.green,
                        size: 6.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Active Session',
                          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'LIVE',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildSessionInfo(_activeSession!),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _joinActiveSession(_activeSession!),
                      icon: Icon(Icons.visibility),
                      label: Text('View Live Session'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Sessions List
          if (_sessions.isEmpty)
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
                    Icons.event_note,
                    size: 15.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No Sessions Yet',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Start your first attendance session to begin tracking student attendance.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    onPressed: _createNewSession,
                    icon: Icon(Icons.add),
                    label: Text('Create First Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _sessions.map((session) => _buildSessionCard(session)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    final isActive = _activeSession?.id == session.id;
    final isCompleted = session.endTime != null;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive 
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
                isActive ? Icons.play_circle : isCompleted ? Icons.check_circle : Icons.schedule,
                color: isActive ? Colors.green : isCompleted ? Colors.blue : AppTheme.lightTheme.colorScheme.primary,
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
                  color: isActive 
                      ? Colors.green.withValues(alpha: 0.1)
                      : isCompleted 
                          ? Colors.blue.withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active' : isCompleted ? 'Completed' : 'Scheduled',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isActive 
                        ? Colors.green.shade700
                        : isCompleted 
                            ? Colors.blue.shade700
                            : AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSessionInfo(session),
          if (isActive) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _joinActiveSession(session),
                icon: Icon(Icons.visibility),
                label: Text('View Live Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionInfo(SessionModel session) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.class_,
                label: 'Class',
                value: session.className,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
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
              child: _buildInfoItem(
                icon: Icons.access_time,
                label: 'Started',
                value: _formatTime(session.startTime),
              ),
            ),
            if (session.endTime != null)
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.stop,
                  label: 'Ended',
                  value: _formatTime(session.endTime!),
                ),
              ),
          ],
        ),
        if (session.sessionCode != null) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.qr_code,
                  label: 'Session Code',
                  value: session.sessionCode!,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem({
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
