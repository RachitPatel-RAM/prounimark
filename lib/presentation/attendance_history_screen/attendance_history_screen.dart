import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// import 'package:fl_chart/fl_chart.dart';
import '../../core/app_export.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import 'widgets/attendance_stats_widget.dart';
import 'widgets/attendance_list_widget.dart';
import 'widgets/attendance_chart_widget.dart';
import 'widgets/filter_options_widget.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final UserModel currentUser;

  const AttendanceHistoryScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen>
    with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  
  late TabController _tabController;
  List<AttendanceModel> _attendanceHistory = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Filter options
  DateTime? _startDate;
  DateTime? _endDate;
  AttendanceStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAttendanceHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final history = await _firebaseService.getAttendanceHistory(widget.currentUser.id);
      setState(() {
        _attendanceHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load attendance history: $e';
        _isLoading = false;
      });
    }
  }

  List<AttendanceModel> get _filteredAttendance {
    List<AttendanceModel> filtered = _attendanceHistory;

    if (_startDate != null) {
      filtered = filtered.where((attendance) => 
          attendance.timestamp.isAfter(_startDate!) || 
          attendance.timestamp.isAtSameMomentAs(_startDate!)).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((attendance) => 
          attendance.timestamp.isBefore(_endDate!.add(const Duration(days: 1))) || 
          attendance.timestamp.isAtSameMomentAs(_endDate!)).toList();
    }

    if (_statusFilter != null) {
      filtered = filtered.where((attendance) => 
          attendance.status == _statusFilter).toList();
    }

    return filtered;
  }

  Map<String, dynamic> get _attendanceStats {
    final total = _attendanceHistory.length;
    final present = _attendanceHistory.where((a) => a.status == AttendanceStatus.present).length;
    final absent = _attendanceHistory.where((a) => a.status == AttendanceStatus.absent).length;
    final late = _attendanceHistory.where((a) => a.status == AttendanceStatus.late).length;
    
    return {
      'total': total,
      'present': present,
      'absent': absent,
      'late': late,
      'percentage': total > 0 ? (present / total * 100).round() : 0,
    };
  }

  void _applyFilters(DateTime? startDate, DateTime? endDate, AttendanceStatus? status) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
      _statusFilter = status;
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _statusFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: AppTheme.backgroundLight,
        foregroundColor: AppTheme.textPrimaryLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendanceHistory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryLight,
          unselectedLabelColor: AppTheme.textSecondaryLight,
          indicatorColor: AppTheme.primaryLight,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Chart', icon: Icon(Icons.bar_chart)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppTheme.errorLight,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _errorMessage,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.errorLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: _loadAttendanceHistory,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Overview Tab
                    SingleChildScrollView(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        children: [
                          AttendanceStatsWidget(
                            stats: _attendanceStats,
                            filteredStats: _getFilteredStats(),
                          ),
                          SizedBox(height: 4.h),
                          if (_filteredAttendance.isNotEmpty)
                            AttendanceListWidget(
                              attendanceList: _filteredAttendance.take(5).toList(),
                              showAll: false,
                            ),
                        ],
                      ),
                    ),
                    
                    // Chart Tab
                    SingleChildScrollView(
                      padding: EdgeInsets.all(4.w),
                      child: AttendanceChartWidget(
                        attendanceHistory: _attendanceHistory,
                        filteredAttendance: _filteredAttendance,
                      ),
                    ),
                    
                    // History Tab
                    AttendanceListWidget(
                      attendanceList: _filteredAttendance,
                      showAll: true,
                    ),
                  ],
                ),
    );
  }

  Map<String, dynamic> _getFilteredStats() {
    final filtered = _filteredAttendance;
    final total = filtered.length;
    final present = filtered.where((a) => a.status == AttendanceStatus.present).length;
    final absent = filtered.where((a) => a.status == AttendanceStatus.absent).length;
    final late = filtered.where((a) => a.status == AttendanceStatus.late).length;
    
    return {
      'total': total,
      'present': present,
      'absent': absent,
      'late': late,
      'percentage': total > 0 ? (present / total * 100).round() : 0,
    };
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterOptionsWidget(
        startDate: _startDate,
        endDate: _endDate,
        statusFilter: _statusFilter,
        onApply: _applyFilters,
        onClear: _clearFilters,
      ),
    );
  }
}
