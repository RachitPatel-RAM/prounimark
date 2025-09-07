import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/user_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditProfile;

  const ProfileHeaderWidget({
    Key? key,
    required this.user,
    required this.onEditProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryLight,
              AppTheme.primaryLight.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 8.h,
              backgroundColor: Colors.white,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 6.h,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
            
            SizedBox(height: 2.h),
            
            // User Name
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 0.5.h),
            
            // User Role
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.toString().split('.').last.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            SizedBox(height: 2.h),
            
            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: onEditProfile,
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
