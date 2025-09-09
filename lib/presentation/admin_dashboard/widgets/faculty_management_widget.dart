import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_model.dart';
import 'create_faculty_dialog.dart';
import 'edit_faculty_dialog.dart';
import 'faculty_list_widget.dart';

class FacultyManagementWidget extends StatefulWidget {
  final List<UserModel> facultyList;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final VoidCallback onFacultyCreated;

  const FacultyManagementWidget({
    super.key,
    required this.facultyList,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onFacultyCreated,
  });

  @override
  State<FacultyManagementWidget> createState() => _FacultyManagementWidgetState();
}

class _FacultyManagementWidgetState extends State<FacultyManagementWidget> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredFacultyList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _filteredFacultyList = widget.facultyList;
  }

  @override
  void didUpdateWidget(FacultyManagementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.facultyList != widget.facultyList) {
      _filteredFacultyList = widget.facultyList;
      _applySearchFilter();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applySearchFilter();
    });
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredFacultyList = widget.facultyList;
    } else {
      _filteredFacultyList = widget.facultyList.where((faculty) {
        return faculty.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               faculty.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<void> _showCreateFacultyDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateFacultyDialog(),
    );

    if (result == true) {
      widget.onFacultyCreated();
    }
  }

  Future<void> _showEditFacultyDialog(UserModel faculty) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditFacultyDialog(faculty: faculty),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }

  Future<void> _showDeleteConfirmationDialog(UserModel faculty) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Delete Faculty',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this faculty member?',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faculty Details:',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Name: ${faculty.name}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Email: ${faculty.email}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'This action cannot be undone. The faculty member will be permanently removed from the system.',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteFaculty(faculty);
    }
  }

  Future<void> _deleteFaculty(UserModel faculty) async {
    try {
      final result = await _authService.deleteFacultyUser(faculty.id);
      
      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Faculty member deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          widget.onRefresh();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Failed to delete faculty member'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete faculty member: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _resetFacultyPassword(UserModel faculty) async {
    try {
      final result = await _authService.adminResetFacultyPassword(faculty.id);
      
      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Failed to reset password'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Faculty Management',
                      style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Manage faculty accounts and permissions',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateFacultyDialog,
                icon: Icon(Icons.person_add),
                label: Text('Add Faculty'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 3.h),
          
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search faculty by name or email...',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: Icon(
                          Icons.clear,
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.lightTheme.colorScheme.surface,
              ),
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Faculty List
          Expanded(
            child: FacultyListWidget(
              facultyList: _filteredFacultyList,
              isLoading: widget.isLoading,
              error: widget.error,
              onRefresh: widget.onRefresh,
              onEdit: _showEditFacultyDialog,
              onDelete: _showDeleteConfirmationDialog,
              onResetPassword: _resetFacultyPassword,
            ),
          ),
        ],
      ),
    );
  }
}
