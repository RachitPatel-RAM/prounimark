import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../../core/app_export.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_service.dart';

class UserManagementWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const UserManagementWidget({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<UserManagementWidget> createState() => _UserManagementWidgetState();
}

class _UserManagementWidgetState extends State<UserManagementWidget> {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _errorMessage = '';
  UserRole? _filterRole;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final users = await _firebaseService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  List<UserModel> get _filteredUsers {
    List<UserModel> filtered = _users;

    if (_filterRole != null) {
      filtered = filtered.where((user) => user.role == _filterRole).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) =>
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (user.enrollmentNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: EdgeInsets.all(4.w),
          color: AppTheme.surfaceLight,
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              SizedBox(height: 2.h),
              
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', null),
                    SizedBox(width: 2.w),
                    _buildFilterChip('Students', UserRole.student),
                    SizedBox(width: 2.w),
                    _buildFilterChip('Faculty', UserRole.faculty),
                    SizedBox(width: 2.w),
                    _buildFilterChip('Admins', UserRole.admin),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Users List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
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
                            onPressed: _loadUsers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64.sp,
                                color: AppTheme.textSecondaryLight,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No users found',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(4.w),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(context, user);
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, UserRole? role) {
    final isSelected = _filterRole == role;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterRole = selected ? role : null;
        });
      },
      selectedColor: AppTheme.primaryLight.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryLight,
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondaryLight,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and role
            Row(
              children: [
                CircleAvatar(
                  radius: 20.sp,
                  backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                  child: Icon(
                    _getRoleIcon(user.role),
                    color: _getRoleColor(user.role),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getRoleColor(user.role).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getRoleText(user.role),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // User Details
            if (user.enrollmentNumber != null) ...[
              _buildDetailRow(
                context,
                'Enrollment',
                user.enrollmentNumber!,
                Icons.badge,
              ),
              SizedBox(height: 1.h),
            ],
            
            if (user.branch != null) ...[
              _buildDetailRow(
                context,
                'Branch',
                user.branch!,
                Icons.account_tree,
              ),
              SizedBox(height: 1.h),
            ],
            
            if (user.className != null) ...[
              _buildDetailRow(
                context,
                'Class',
                user.className!,
                Icons.class_,
              ),
              SizedBox(height: 1.h),
            ],
            
            if (user.batch != null) ...[
              _buildDetailRow(
                context,
                'Batch',
                user.batch!,
                Icons.group,
              ),
              SizedBox(height: 1.h),
            ],
            
            _buildDetailRow(
              context,
              'Created',
              DateFormat('MMM dd, yyyy').format(user.createdAt),
              Icons.calendar_today,
            ),
            
            SizedBox(height: 2.h),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editUser(user),
                    icon: Icon(Icons.edit, size: 16.sp),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryLight,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteUser(user),
                    icon: Icon(Icons.delete, size: 16.sp),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorLight,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.textSecondaryLight,
          size: 16.sp,
        ),
        SizedBox(width: 2.w),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.errorLight;
      case UserRole.faculty:
        return AppTheme.warningLight;
      case UserRole.student:
        return AppTheme.successLight;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.faculty:
        return Icons.person;
      case UserRole.student:
        return Icons.school;
    }
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.student:
        return 'Student';
    }
  }

  void _editUser(UserModel user) {
    // TODO: Implement edit user functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit user functionality will be implemented soon'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _firebaseService.deleteUser(user.id);
                _loadUsers();
                widget.onRefresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.name} deleted successfully'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete user: $e'),
                    backgroundColor: AppTheme.errorLight,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
