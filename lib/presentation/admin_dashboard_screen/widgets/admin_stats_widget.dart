import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class AdminStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const AdminStatsWidget({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        
        SizedBox(height: 3.h),
        
        // Main Stats Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 3.h,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              'Students',
              stats['students'].toString(),
              Icons.school,
              AppTheme.primaryLight,
            ),
            _buildStatCard(
              context,
              'Faculty',
              stats['faculty'].toString(),
              Icons.person,
              AppTheme.successLight,
            ),
            _buildStatCard(
              context,
              'Branches',
              stats['branches'].toString(),
              Icons.account_tree,
              AppTheme.warningLight,
            ),
            _buildStatCard(
              context,
              'Classes',
              stats['classes'].toString(),
              Icons.class_,
              AppTheme.errorLight,
            ),
            _buildStatCard(
              context,
              'Batches',
              stats['batches'].toString(),
              Icons.group,
              AppTheme.primaryLight,
            ),
            _buildStatCard(
              context,
              'Active Sessions',
              stats['sessions'].toString(),
              Icons.play_circle,
              AppTheme.successLight,
            ),
          ],
        ),
        
        SizedBox(height: 4.h),
        
        // System Health Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      color: AppTheme.successLight,
                      size: 24.sp,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'System Health',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 3.h),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildHealthIndicator(
                        context,
                        'Database',
                        'Connected',
                        AppTheme.successLight,
                        Icons.cloud_done,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildHealthIndicator(
                        context,
                        'Authentication',
                        'Active',
                        AppTheme.successLight,
                        Icons.security,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildHealthIndicator(
                        context,
                        'Location Services',
                        'Available',
                        AppTheme.successLight,
                        Icons.location_on,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildHealthIndicator(
                        context,
                        'Notifications',
                        'Enabled',
                        AppTheme.successLight,
                        Icons.notifications,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24.sp,
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(
    BuildContext context,
    String title,
    String status,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
