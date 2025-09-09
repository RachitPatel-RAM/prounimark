import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/active_session_card.dart';
import './widgets/attendance_summary_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/quick_filter_widget.dart';
import './widgets/upcoming_class_card.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  // bool _isRefreshing = false;

  // Mock data for faculty dashboard
  final Map<String, dynamic> facultyData = {
    "name": "Dr. Sarah Johnson",
    "department": "Computer Science",
    "employeeId": "FAC001",
    "profileImage":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmVzc29yfGVufDB8fDB8fHww",
  };

  final Map<String, dynamic> summaryData = {
    "todaySessions": 3,
    "totalStudents": 145,
    "averageAttendance": 78.5,
    "activeSessions": 1,
  };

  final List<Map<String, dynamic>> activeSessions = [
    {
      "id": "session_001",
      "sessionCode": "A7K",
      "subjectName": "Data Structures & Algorithms",
      "className": "CSE-3A",
      "batchName": "Batch 1",
      "presentCount": 28,
      "totalCount": 45,
      "timeRemaining": "23 min",
      "locationRadius": 500,
      "isActive": true,
      "startTime": "10:00 AM",
      "endTime": "11:00 AM",
      "createdAt": DateTime.now().subtract(const Duration(minutes: 37)),
    },
    {
      "id": "session_002",
      "sessionCode": "M3P",
      "subjectName": "Database Management Systems",
      "className": "CSE-3B",
      "batchName": "Batch 2",
      "presentCount": 35,
      "totalCount": 42,
      "timeRemaining": "12 min",
      "locationRadius": 300,
      "isActive": true,
      "startTime": "11:15 AM",
      "endTime": "12:15 PM",
      "createdAt": DateTime.now().subtract(const Duration(minutes: 48)),
    },
  ];

  final List<Map<String, dynamic>> upcomingClasses = [
    {
      "id": "class_001",
      "subjectName": "Software Engineering",
      "className": "CSE-4A",
      "batchName": "Batch 1",
      "startTime": "2:00 PM",
      "endTime": "3:00 PM",
      "room": "Lab 301",
      "studentCount": 38,
    },
    {
      "id": "class_002",
      "subjectName": "Machine Learning",
      "className": "CSE-4B",
      "batchName": "Batch 2",
      "startTime": "3:15 PM",
      "endTime": "4:15 PM",
      "room": "Room 205",
      "studentCount": 42,
    },
  ];

  final List<String> subjects = [
    "Data Structures & Algorithms",
    "Database Management Systems",
    "Software Engineering",
    "Machine Learning",
    "Computer Networks",
  ];

  final List<String> batches = [
    "Batch 1",
    "Batch 2",
    "Batch 3",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildSessionsTab(),
                  _buildReportsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: facultyData['profileImage'],
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  facultyData['name'],
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${facultyData['department']} • ${summaryData['todaySessions']} sessions today',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showProfileMenu(context),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Dashboard'),
          Tab(text: 'Sessions'),
          Tab(text: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            AttendanceSummaryWidget(summaryData: summaryData),
            SizedBox(height: 2.h),
            _buildSectionHeader('Active Sessions', activeSessions.length),
            if (activeSessions.isNotEmpty) ...[
              ...activeSessions.map((session) => ActiveSessionCard(
                    sessionData: session,
                    onEndSession: () => _handleEndSession(session['id']),
                    onEditSession: () => _handleEditSession(session['id']),
                    onViewDetails: () => _handleViewDetails(session['id']),
                    onDuplicateSession: () =>
                        _handleDuplicateSession(session['id']),
                    onExportAttendance: () =>
                        _handleExportAttendance(session['id']),
                    onSendNotifications: () =>
                        _handleSendNotifications(session['id']),
                  )),
            ] else ...[
              EmptyStateWidget(onCreateSession: _handleCreateSession),
            ],
            SizedBox(height: 2.h),
            _buildSectionHeader('Upcoming Classes', upcomingClasses.length),
            ...upcomingClasses.map((classData) => UpcomingClassCard(
                  classData: classData,
                  onCreateSession: () =>
                      _handleCreateSessionForClass(classData['id']),
                )),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsTab() {
    return Column(
      children: [
        SizedBox(height: 2.h),
        QuickFilterWidget(
          selectedFilter: _selectedFilter,
          onFilterChanged: _handleFilterChanged,
          subjects: subjects,
          batches: batches,
        ),
        SizedBox(height: 2.h),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: _buildFilteredSessionsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              Text(
                'Attendance Reports',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              _buildReportCard(
                title: 'Daily Report',
                subtitle: 'Today\'s attendance summary',
                icon: 'today',
                onTap: () => _handleGenerateReport('daily'),
              ),
              _buildReportCard(
                title: 'Weekly Report',
                subtitle: 'Last 7 days attendance',
                icon: 'date_range',
                onTap: () => _handleGenerateReport('weekly'),
              ),
              _buildReportCard(
                title: 'Monthly Report',
                subtitle: 'Current month overview',
                icon: 'calendar_month',
                onTap: () => _handleGenerateReport('monthly'),
              ),
              _buildReportCard(
                title: 'Custom Range',
                subtitle: 'Select date range',
                icon: 'tune',
                onTap: () => _handleGenerateReport('custom'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredSessionsList() {
    List<Map<String, dynamic>> filteredSessions = _getFilteredSessions();

    if (filteredSessions.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: EmptyStateWidget(onCreateSession: _handleCreateSession),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredSessions.length,
      itemBuilder: (context, index) {
        final session = filteredSessions[index];
        return ActiveSessionCard(
          sessionData: session,
          onEndSession: () => _handleEndSession(session['id']),
          onEditSession: () => _handleEditSession(session['id']),
          onViewDetails: () => _handleViewDetails(session['id']),
          onDuplicateSession: () => _handleDuplicateSession(session['id']),
          onExportAttendance: () => _handleExportAttendance(session['id']),
          onSendNotifications: () => _handleSendNotifications(session['id']),
        );
      },
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(4.w),
          leading: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _handleCreateSession,
      icon: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 24,
      ),
      label: Text(
        'Create Session',
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
    );
  }

  List<Map<String, dynamic>> _getFilteredSessions() {
    if (_selectedFilter == 'all') {
      return activeSessions;
    } else if (_selectedFilter == 'active') {
      return activeSessions
          .where((session) => session['isActive'] == true)
          .toList();
    } else if (_selectedFilter == 'completed') {
      return activeSessions
          .where((session) => session['isActive'] == false)
          .toList();
    } else if (_selectedFilter.startsWith('subject:')) {
      final subject = _selectedFilter.substring(8);
      return activeSessions
          .where((session) => session['subjectName'] == subject)
          .toList();
    } else if (_selectedFilter.startsWith('batch:')) {
      final batch = _selectedFilter.substring(6);
      return activeSessions
          .where((session) => session['batchName'] == batch)
          .toList();
    }
    return activeSessions;
  }

  Future<void> _handleRefresh() async {
    setState(() {
        // _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
        // _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dashboard refreshed successfully',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.getSuccessColor(true),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _handleCreateSession() {
    Navigator.pushNamed(context, '/create-attendance-session-screen');
  }

  void _handleCreateSessionForClass(String classId) {
    Navigator.pushNamed(context, '/create-attendance-session-screen');
  }

  void _handleEndSession(String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'End Session',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to end this attendance session? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Session ended successfully',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.getSuccessColor(true),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getErrorColor(true),
            ),
            child: Text(
              'End Session',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEditSession(String sessionId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit session functionality coming soon',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleViewDetails(String sessionId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'View session details functionality coming soon',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleDuplicateSession(String sessionId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Session duplicated successfully',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _handleExportAttendance(String sessionId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Attendance exported successfully',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _handleSendNotifications(String sessionId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notifications sent to students',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _handleGenerateReport(String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating $reportType report...',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Profile Settings',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'logout',
                color: AppTheme.getErrorColor(true),
                size: 24,
              ),
              title: Text(
                'Logout',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.getErrorColor(true),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                  (route) => false,
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
