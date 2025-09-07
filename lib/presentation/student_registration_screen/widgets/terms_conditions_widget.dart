import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TermsConditionsWidget extends StatefulWidget {
  final bool isAccepted;
  final Function(bool) onChanged;

  const TermsConditionsWidget({
    Key? key,
    required this.isAccepted,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<TermsConditionsWidget> createState() => _TermsConditionsWidgetState();
}

class _TermsConditionsWidgetState extends State<TermsConditionsWidget> {
  void _showTermsAndConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 85.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      size: 6.w,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppTheme.lightTheme.dividerColor),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'UniMark Attendance Management System',
                      'Welcome to UniMark, the secure attendance management system for Darshan University. By registering and using this application, you agree to the following terms and conditions.',
                    ),
                    _buildSection(
                      '1. Account Registration',
                      '• You must use your official university email address (@darshan.ac.in) for registration.\n'
                          '• Provide accurate and complete information during registration.\n'
                          '• Your enrollment number must be valid and currently active.\n'
                          '• Each student account is limited to one device for security purposes.',
                    ),
                    _buildSection(
                      '2. Attendance Marking',
                      '• Attendance can only be marked when physically present within the designated location radius (500 meters).\n'
                          '• GPS location services must be enabled for attendance marking.\n'
                          '• Proxy attendance or false check-ins are strictly prohibited and may result in account suspension.\n'
                          '• Session codes are time-sensitive and expire after the designated period.',
                    ),
                    _buildSection(
                      '3. Data Privacy & Security',
                      '• Your location data is used solely for attendance verification purposes.\n'
                          '• Personal information is stored securely and not shared with third parties.\n'
                          '• Device binding ensures single-device access for enhanced security.\n'
                          '• All attendance records are maintained with audit trails.',
                    ),
                    _buildSection(
                      '4. User Responsibilities',
                      '• Maintain the confidentiality of your account credentials.\n'
                          '• Report any suspicious activity or security breaches immediately.\n'
                          '• Ensure your device has accurate location services enabled.\n'
                          '• Follow university attendance policies and guidelines.',
                    ),
                    _buildSection(
                      '5. System Usage',
                      '• The system is available during official university hours.\n'
                          '• Maintenance windows may temporarily restrict access.\n'
                          '• Misuse of the system may result in account suspension or disciplinary action.\n'
                          '• Students are responsible for marking attendance within the specified time windows.',
                    ),
                    _buildSection(
                      '6. Technical Requirements',
                      '• Compatible Android (7.0+) or iOS (12.0+) device required.\n'
                          '• Stable internet connection necessary for real-time synchronization.\n'
                          '• Location permissions must be granted for proper functionality.\n'
                          '• Regular app updates are recommended for optimal performance.',
                    ),
                    _buildSection(
                      '7. Limitation of Liability',
                      '• The university is not liable for technical issues affecting attendance marking.\n'
                          '• Students are responsible for ensuring their attendance is properly recorded.\n'
                          '• System downtime or connectivity issues do not excuse attendance requirements.\n'
                          '• Alternative attendance methods may be provided during system maintenance.',
                    ),
                    _buildSection(
                      '8. Modifications',
                      '• These terms may be updated periodically with prior notice.\n'
                          '• Continued use of the application constitutes acceptance of updated terms.\n'
                          '• Major changes will be communicated through official university channels.',
                    ),
                    _buildSection(
                      '9. Contact Information',
                      'For technical support or queries regarding these terms:\n'
                          '• Email: support@darshan.ac.in\n'
                          '• Phone: +91-2827-286702\n'
                          '• Office: IT Department, Darshan University',
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'By clicking "I Accept" below, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),

            // Accept button
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onChanged(true);
                      Navigator.pop(context);
                    },
                    child: Text('I Accept Terms & Conditions'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: widget.isAccepted,
                  onChanged: (bool? value) => widget.onChanged(value ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 0.5.h),
                    RichText(
                      text: TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' of UniMark.'),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    GestureDetector(
                      onTap: _showTermsAndConditions,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'article',
                              size: 4.w,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Read Full Terms',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}