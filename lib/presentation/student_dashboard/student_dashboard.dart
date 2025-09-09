import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'widgets/active_session_card.dart';
import 'widgets/attendance_stats_card.dart';
import 'widgets/empty_sessions_widget.dart';
import 'widgets/student_header_widget.dart';
import 'widgets/today_schedule_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLocationEnabled = false;
  double? _locationAccuracy;
  // bool _isLoading = false;
  int _selectedIndex = 0;

  // Mock student data
  final Map<String, dynamic> studentData = {
    "name": "Arjun Patel",
    "enrollmentNumber": "21CE001",
    "email": "arjun.patel@darshan.ac.in",
    "branch": "Computer Engineering",
    "class": "CE-A",
    "batch": "A1",
    "attendancePercentage": 78.5,
    "presentDays": 47,
    "absentDays": 13,
    "totalDays": 60,
  };

  // Mock active sessions data
  final List<Map<String, dynamic>> activeSessions = [
    {
      "id": "session_001",
      "subject": "Data Structures and Algorithms",
      "faculty": "Dr. Priya Sharma",
      "code": "247",
      "timeRemaining": 420, // 7 minutes in seconds
      "location": {
        "latitude": 22.9734,
        "longitude": 72.5138,
        "radius": 500,
      },
      "room": "Lab-301",
      "startTime": "10:00 AM",
      "endTime": "11:00 AM",
    }
  ];

  // Mock today's schedule data
  final List<Map<String, dynamic>> todaySchedule = [
    { "subject": "Database Management Systems",
      "faculty": "Prof. Rajesh Kumar",
      "startTime": "09:00",
      "endTime": "10:00",
      "room": "Room-205",
      "isCompleted": true,
      "isActive": false,
    },
    { "subject": "Data Structures and Algorithms",
      "faculty": "Dr. Priya Sharma",
      "startTime": "10:00",
      "endTime": "11:00",
      "room": "Lab-301",
      "isCompleted": false,
      "isActive": true,
    },
    { "subject": "Computer Networks",
      "faculty": "Dr. Amit Singh",
      "startTime": "11:15",
      "endTime": "12:15",
      "room": "Room-102",
      "isCompleted": false,
      "isActive": false,
    },
    { "subject": "Software Engineering",
      "faculty": "Prof. Neha Joshi",
      "startTime": "14:00",
      "endTime": "15:00",
      "room": "Room-301",
      "isCompleted": false,
      "isActive": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        setState(() {
          _isLocationEnabled = true;
          _locationAccuracy = position.accuracy;
        });
      } else {
        setState(() {
          _isLocationEnabled = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLocationEnabled = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
        // _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    await _checkLocationPermission();

    setState(() {
        // _isLoading = false;
    });
  }

  void _markAttendance() {
    if (!_isLocationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location permission is required to mark attendance'),
          backgroundColor: AppTheme.getErrorColor(true),
          action: SnackBarAction(
            label: 'Enable',
            textColor: Colors.white,
            onPressed: () async {
              await openAppSettings();
            },
          ),
        ),
      );
      return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Attendance marked successfully!'),
        backgroundColor: AppTheme.getSuccessColor(true),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: _selectedIndex == 0 ? _buildDashboardTab() : _buildOtherTabs(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _selectedIndex == 0 && activeSessions.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: _markAttendance,
            backgroundColor: AppTheme.lightTheme.primaryColor,
            foregroundColor: Colors.white,
            icon: CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: Colors.white,
              size: 24,
            ),
            label: Text(
              'Quick Scan',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : null,
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.primaryColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: StudentHeaderWidget(
              studentName: studentData['name'] as String,
              enrollmentNumber: studentData['enrollmentNumber'] as String,
              attendancePercentage: studentData['attendancePercentage'] as double,
              onProfileTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 2.h),
          ),
          SliverToBoxAdapter(
            child: AttendanceStatsCard(
              attendancePercentage: studentData['attendancePercentage'] as double,
              presentDays: studentData['presentDays'] as int,
              absentDays: studentData['absentDays'] as int,
              totalDays: studentData['totalDays'] as int,
            ),
          ),
          if (activeSessions.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                child: Text(
                  'Active Sessions',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ActiveSessionCard(
                    session: activeSessions[index],
                    onMarkAttendance: _markAttendance,
                    isLocationEnabled: _isLocationEnabled,
                    locationAccuracy: _locationAccuracy,
                  );
                },
                childCount: activeSessions.length,
              ),
            ),
          ] else ...[
            const SliverToBoxAdapter(
              child: EmptySessionsWidget(),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
              child: Text(
                'Today\'s Schedule',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: TodayScheduleCard(
              scheduleItems: todaySchedule,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherTabs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: _selectedIndex == 1 ? 'history' : 'person',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            _selectedIndex == 1 ? 'Attendance History' : 'Profile',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Coming Soon',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'dashboard', 'Dashboard'),
              _buildNavItem(1, 'history', 'History'),
              _buildNavItem(2, 'person', 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconName, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isSelected 
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: isSelected 
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}