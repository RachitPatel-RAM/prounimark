import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import 'widgets/profile_header_widget.dart';
import 'widgets/profile_info_widget.dart';
import 'widgets/account_actions_widget.dart';
import 'widgets/security_settings_widget.dart';

class ProfileManagementScreen extends StatefulWidget {
  final UserModel? currentUser;

  const ProfileManagementScreen({
    Key? key,
    this.currentUser,
  }) : super(key: key);

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late UserModel _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser ?? _getDefaultUser();
    _isLoading = false;
  }

  UserModel _getDefaultUser() {
    return UserModel(
      id: 'temp_user',
      name: 'Current User',
      email: 'user@unimark.com',
      role: UserRole.student,
      enrollmentNumber: 'STU001',
      branch: 'Computer Science',
      className: 'CS-A',
      batch: '2024',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _updateProfile(UserModel updatedUser) async {
    setState(() => _isLoading = true);
    try {
      await _firebaseService.updateUser(updatedUser);
      setState(() {
        _currentUser = updatedUser;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword(String oldPassword, String newPassword) async {
    setState(() => _isLoading = true);
    try {
      await _firebaseService.changePassword(oldPassword, newPassword);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to change password: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _firebaseService.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login-screen',
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to logout: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Profile Management'),
        backgroundColor: AppTheme.backgroundLight,
        foregroundColor: AppTheme.textPrimaryLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
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
                        onPressed: () => setState(() => _errorMessage = ''),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      // Profile Header
                      ProfileHeaderWidget(
                        user: _currentUser,
                        onEditProfile: () => _showEditProfileDialog(),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Profile Information
                      ProfileInfoWidget(user: _currentUser),
                      
                      SizedBox(height: 4.h),
                      
                      // Security Settings
                      SecuritySettingsWidget(
                        onChangePassword: _changePassword,
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Account Actions
                      AccountActionsWidget(
                        onLogout: _logout,
                        onDeleteAccount: () => _showDeleteAccountDialog(),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(
        currentUser: _currentUser,
        onUpdate: _updateProfile,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final UserModel currentUser;
  final Function(UserModel) onUpdate;

  const _EditProfileDialog({
    required this.currentUser,
    required this.onUpdate,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _enrollmentController;
  late TextEditingController _branchController;
  late TextEditingController _classNameController;
  late TextEditingController _batchController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _emailController = TextEditingController(text: widget.currentUser.email);
    _enrollmentController = TextEditingController(text: widget.currentUser.enrollmentNumber ?? '');
    _branchController = TextEditingController(text: widget.currentUser.branch ?? '');
    _classNameController = TextEditingController(text: widget.currentUser.className ?? '');
    _batchController = TextEditingController(text: widget.currentUser.batch ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _enrollmentController.dispose();
    _branchController.dispose();
    _classNameController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _enrollmentController,
              decoration: const InputDecoration(
                labelText: 'Enrollment Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _branchController,
              decoration: const InputDecoration(
                labelText: 'Branch',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'Class',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _batchController,
              decoration: const InputDecoration(
                labelText: 'Batch',
                border: OutlineInputBorder(),
              ),
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
          onPressed: () {
            final updatedUser = widget.currentUser.copyWith(
              name: _nameController.text,
              email: _emailController.text,
              enrollmentNumber: _enrollmentController.text,
              branch: _branchController.text,
              className: _classNameController.text,
              batch: _batchController.text,
              updatedAt: DateTime.now(),
            );
            widget.onUpdate(updatedUser);
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
