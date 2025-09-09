import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../../core/app_export.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class UserManagementWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const UserManagementWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  State<UserManagementWidget> createState() => _UserManagementWidgetState();
}

class _UserManagementWidgetState extends State<UserManagementWidget> {
  final AuthService _authService = AuthService();
  
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
      // Load both students and faculty
      final students = await _authService.getAllStudentUsers();
      final faculty = await _authService.getAllFacultyUsers();
      
      setState(() {
        _users = [...students, ...faculty];
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
        // Header with Create Faculty Button
        Container(
          padding: EdgeInsets.all(4.w),
          color: AppTheme.surfaceLight,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'User Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _createFacultyUser,
                icon: const Icon(Icons.person_add),
                label: const Text('Create Faculty'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
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
      selectedColor: Color.fromRGBO((AppTheme.primaryLight.r * 255.0).round() & 0xff, (AppTheme.primaryLight.g * 255.0).round() & 0xff, (AppTheme.primaryLight.b * 255.0).round() & 0xff, 0.2),
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
                  backgroundColor: Color.fromRGBO((_getRoleColor(user.role).r * 255.0).round() & 0xff, (_getRoleColor(user.role).g * 255.0).round() & 0xff, (_getRoleColor(user.role).b * 255.0).round() & 0xff, 0.2),
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
                    color: Color.fromRGBO((_getRoleColor(user.role).r * 255.0).round() & 0xff, (_getRoleColor(user.role).g * 255.0).round() & 0xff, (_getRoleColor(user.role).b * 255.0).round() & 0xff, 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color.fromRGBO((_getRoleColor(user.role).r * 255.0).round() & 0xff, (_getRoleColor(user.role).g * 255.0).round() & 0xff, (_getRoleColor(user.role).b * 255.0).round() & 0xff, 0.3),
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
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 2.h),
              DropdownButtonFormField<UserRole>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(_getRoleText(role)),
                  );
                }).toList(),
                onChanged: (UserRole? newRole) {
                  if (newRole != null) {
                    selectedRole = newRole;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                // Note: Update user functionality needs to be implemented in AuthService
                // For now, we'll just show a message
                navigator.pop();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Update functionality needs to be implemented in AuthService'),
                      backgroundColor: AppTheme.warningLight,
                    ),
                  );
                }
              } catch (e) {
                navigator.pop();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error updating user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
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
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              try {
                // Note: In a real app, you'd need to implement deleteUser in AuthService
                // For now, we'll just show a message
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Delete functionality needs to be implemented in AuthService'),
                      backgroundColor: AppTheme.warningLight,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete user: $e'),
                      backgroundColor: AppTheme.errorLight,
                    ),
                  );
                }
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

  void _createFacultyUser() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final branchController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Faculty User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (@darshan.ac.in) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: branchController,
                decoration: const InputDecoration(
                  labelText: 'Branch *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final branch = branchController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isEmpty || email.isEmpty || branch.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (!email.endsWith('@darshan.ac.in')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email must be from @darshan.ac.in domain'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                final result = await _authService.createFacultyUser(
                  email: email,
                  name: name,
                  branchId: branch,
                  phone: phone.isNotEmpty ? phone : null,
                );

                navigator.pop();
                
                if (result.isSuccess) {
                  _loadUsers();
                  widget.onRefresh();
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Faculty user "$name" created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(result.error ?? 'Failed to create faculty user'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                navigator.pop();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error creating faculty user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
