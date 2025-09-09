import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../models/user_model.dart';
// import '../../models/hierarchy_model.dart';
import '../../services/firebase_service.dart';
import 'widgets/admin_stats_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/recent_activities_widget.dart';
import 'widgets/user_management_widget.dart';
import 'widgets/hierarchy_management_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserModel currentUser;

  const AdminDashboardScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Statistics
  int _totalStudents = 0;
  int _totalFaculty = 0;
  int _totalBranches = 0;
  int _totalClasses = 0;
  int _totalBatches = 0;
  final int _activeSessions = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load all users
      final users = await _firebaseService.getAllUsers();
      final students = users.where((u) => u.role == UserRole.student).length;
      final faculty = users.where((u) => u.role == UserRole.faculty).length;

      // Load hierarchy data
      final branches = await _firebaseService.getBranches();
      int totalClasses = 0;
      int totalBatches = 0;

      for (final branch in branches) {
        final classes = await _firebaseService.getClassesByBranch(branch.id);
        totalClasses += classes.length;
        
        for (final classModel in classes) {
          final batches = await _firebaseService.getBatchesByClass(classModel.id);
          totalBatches += batches.length;
        }
      }

      setState(() {
        _totalStudents = students;
        _totalFaculty = faculty;
        _totalBranches = branches.length;
        _totalClasses = totalClasses;
        _totalBatches = totalBatches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard data: $e';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> get _stats {
    return {
      'students': _totalStudents,
      'faculty': _totalFaculty,
      'branches': _totalBranches,
      'classes': _totalClasses,
      'batches': _totalBatches,
      'sessions': _activeSessions,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.backgroundLight,
        foregroundColor: AppTheme.textPrimaryLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  _showLogoutDialog();
                  break;
                case 'settings':
                  // Navigate to settings
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryLight,
          unselectedLabelColor: AppTheme.textSecondaryLight,
          indicatorColor: AppTheme.primaryLight,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Hierarchy', icon: Icon(Icons.account_tree)),
            Tab(text: 'Activities', icon: Icon(Icons.history)),
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
                        onPressed: _loadDashboardData,
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
                          AdminStatsWidget(stats: _stats),
                          SizedBox(height: 4.h),
                          QuickActionsWidget(
                            onManageUsers: () => _tabController.animateTo(1),
                            onManageHierarchy: () => _tabController.animateTo(2),
                            onViewActivities: () => _tabController.animateTo(3),
                          ),
                          SizedBox(height: 4.h),
                          RecentActivitiesWidget(),
                        ],
                      ),
                    ),
                    
                    // Users Tab
                    UserManagementWidget(
                      onRefresh: _loadDashboardData,
                    ),
                    
                    // Hierarchy Tab
                    HierarchyManagementWidget(
                      onRefresh: _loadDashboardData,
                    ),
                    
                    // Activities Tab
                    RecentActivitiesWidget(),
                  ],
                ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await _firebaseService.signOut();
              navigator.pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
