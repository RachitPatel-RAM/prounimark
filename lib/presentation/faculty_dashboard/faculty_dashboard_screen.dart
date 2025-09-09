import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/location_validation_service.dart';
import '../../services/location_monitoring_service.dart';
import '../../models/user_model.dart';
import '../../widgets/location_warning_widget.dart';
import 'widgets/faculty_header_widget.dart';
import 'widgets/attendance_session_widget.dart';
import 'widgets/attendance_reports_widget.dart';
import '../faculty_password_reset_screen/faculty_password_reset_screen.dart';

class FacultyDashboardScreen extends StatefulWidget {
  const FacultyDashboardScreen({super.key});

  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final LocationValidationService _locationService = LocationValidationService();
  final LocationMonitoringService _locationMonitoringService = LocationMonitoringService();
  
  late TabController _tabController;
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _error;
  bool _isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _checkLocationStatus();
    _startLocationMonitoring();
  }

  void _startLocationMonitoring() {
    _locationMonitoringService.addLocationListener(_onLocationStatusChanged);
    _locationMonitoringService.startMonitoring();
  }

  void _onLocationStatusChanged() {
    setState(() {
      _isLocationEnabled = _locationMonitoringService.isLocationEnabled;
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _authService.getCurrentUserModel();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationStatus() async {
    try {
      final result = await _locationService.validateLocationAccess();
      setState(() {
        _isLocationEnabled = result.isSuccess;
      });
    } catch (e) {
      setState(() {
        _isLocationEnabled = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
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
          'Location must be enabled to use UniMark. Please turn on location services to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkLocationStatus();
            },
            child: Text('Check Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, you might want to open device settings
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacultyPasswordResetScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationMonitoringService.removeLocationListener(_onLocationStatusChanged);
    _locationMonitoringService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

    if (_error != null || _currentUser == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
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
                _error ?? 'Failed to load user data',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: _loadUserData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return LocationWarningWidget(
      showWarning: true,
      onLocationRequested: _checkLocationStatus,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
        title: Text(
          'Faculty Dashboard',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 1,
        actions: [
          // Location Status Indicator
          Container(
            margin: EdgeInsets.only(right: 2.w),
            child: IconButton(
              onPressed: _checkLocationStatus,
              icon: Icon(
                _isLocationEnabled ? Icons.location_on : Icons.location_off,
                color: _isLocationEnabled 
                    ? Colors.green 
                    : AppTheme.lightTheme.colorScheme.error,
              ),
              tooltip: _isLocationEnabled ? 'Location Enabled' : 'Location Disabled',
            ),
          ),
          // Password Reset
          IconButton(
            onPressed: _showPasswordResetDialog,
            icon: Icon(
              Icons.lock_reset,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            tooltip: 'Change Password',
          ),
          // Sign Out
          IconButton(
            onPressed: _handleSignOut,
            icon: Icon(
              Icons.logout,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            tooltip: 'Sign Out',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.lightTheme.colorScheme.primary,
          unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          indicatorColor: AppTheme.lightTheme.colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.play_circle),
              text: 'Sessions',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Reports',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FacultyHeaderWidget(user: _currentUser!),
                SizedBox(height: 4.h),
                
                // Location Status Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: _isLocationEnabled 
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.errorContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isLocationEnabled 
                          ? Colors.green.withValues(alpha: 0.3)
                          : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isLocationEnabled ? Icons.location_on : Icons.location_off,
                        color: _isLocationEnabled ? Colors.green : AppTheme.lightTheme.colorScheme.error,
                        size: 8.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLocationEnabled ? 'Location Enabled' : 'Location Disabled',
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                color: _isLocationEnabled ? Colors.green : AppTheme.lightTheme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _isLocationEnabled 
                                  ? 'You can start attendance sessions'
                                  : 'Enable location to use attendance features',
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: _isLocationEnabled 
                                    ? Colors.green.shade700
                                    : AppTheme.lightTheme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isLocationEnabled)
                        ElevatedButton(
                          onPressed: _showLocationWarning,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightTheme.colorScheme.error,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Enable'),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: 4.h),
                
                // Quick Actions
                _buildQuickActionsCard(),
              ],
            ),
          ),
          
          // Attendance Sessions Tab
          AttendanceSessionWidget(
            facultyUser: _currentUser!,
            isLocationEnabled: _isLocationEnabled,
            onLocationCheck: _checkLocationStatus,
          ),
          
          // Attendance Reports Tab
          AttendanceReportsWidget(facultyUser: _currentUser!),
        ],
      ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.play_circle,
                  title: 'Start Session',
                  onTap: _isLocationEnabled ? () => _tabController.animateTo(1) : _showLocationWarning,
                  enabled: _isLocationEnabled,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.analytics,
                  title: 'View Reports',
                  onTap: () => _tabController.animateTo(2),
                  enabled: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.lock_reset,
                  title: 'Change Password',
                  onTap: _showPasswordResetDialog,
                  enabled: true,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: _handleSignOut,
                  enabled: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: enabled 
              ? AppTheme.lightTheme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled 
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2)
                : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: enabled 
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: enabled 
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
