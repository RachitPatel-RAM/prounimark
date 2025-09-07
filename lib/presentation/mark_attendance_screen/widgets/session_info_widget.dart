import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/session_model.dart';

class SessionInfoWidget extends StatelessWidget {
  final SessionModel session;

  const SessionInfoWidget({
    Key? key,
    required this.session,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    session.subject,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    session.status.toString().split('.').last.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            _buildInfoRow(
              context,
              Icons.access_time,
              'Session Time',
              '${_formatTime(session.startAt)} - ${_formatTime(session.expiresAt)}',
            ),
            
            SizedBox(height: 1.h),
            
            _buildInfoRow(
              context,
              Icons.location_on,
              'Location',
              'Lat: ${session.facultyLocation.lat.toStringAsFixed(4)}, Lng: ${session.facultyLocation.lng.toStringAsFixed(4)}',
            ),
            
            SizedBox(height: 1.h),
            
            _buildInfoRow(
              context,
              Icons.radio_button_checked,
              'GPS Radius',
              '${session.gpsRadiusM}m',
            ),
            
            SizedBox(height: 2.h),
            
            // Session Code (for faculty reference)
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Session Code: ${session.code.toString().padLeft(3, '0')}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}