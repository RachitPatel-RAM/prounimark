import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SessionSettingsWidget extends StatefulWidget {
  final bool autoGenerateCode;
  final bool allowLateEntry;
  final bool enableNotifications;
  final Function(bool) onAutoGenerateChanged;
  final Function(bool) onLateEntryChanged;
  final Function(bool) onNotificationsChanged;

  const SessionSettingsWidget({
    Key? key,
    required this.autoGenerateCode,
    required this.allowLateEntry,
    required this.enableNotifications,
    required this.onAutoGenerateChanged,
    required this.onLateEntryChanged,
    required this.onNotificationsChanged,
  }) : super(key: key);

  @override
  State<SessionSettingsWidget> createState() => _SessionSettingsWidgetState();
}

class _SessionSettingsWidgetState extends State<SessionSettingsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'settings',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Session Settings",
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "Configure attendance session options",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded
                        ? 'keyboard_arrow_up'
                        : 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Settings Content
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.dividerColor,
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Auto Generate Code Setting
                  _buildSettingTile(
                    icon: 'code',
                    title: "Auto-Generate Session Code",
                    subtitle:
                        "Automatically create a 3-digit code for students",
                    value: widget.autoGenerateCode,
                    onChanged: widget.onAutoGenerateChanged,
                  ),

                  SizedBox(height: 2.h),

                  // Allow Late Entry Setting
                  _buildSettingTile(
                    icon: 'access_time',
                    title: "Allow Late Entry",
                    subtitle: "Students can join after session starts",
                    value: widget.allowLateEntry,
                    onChanged: widget.onLateEntryChanged,
                  ),

                  SizedBox(height: 2.h),

                  // Enable Notifications Setting
                  _buildSettingTile(
                    icon: 'notifications',
                    title: "Send Notifications",
                    subtitle: "Notify students when session starts",
                    value: widget.enableNotifications,
                    onChanged: widget.onNotificationsChanged,
                  ),

                  SizedBox(height: 3.h),

                  // Session Code Preview
                  if (widget.autoGenerateCode) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'qr_code',
                                color: AppTheme.lightTheme.primaryColor,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "Session Code Preview",
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.primaryColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                "ABC", // Preview code
                                style: AppTheme
                                    .lightTheme.textTheme.headlineMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Text(
                              "Code will be generated when session starts",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],

                  // Settings Summary
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: AppTheme.lightTheme.dividerColor,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Session Configuration Summary",
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        _buildSummaryItem(
                          "Session Code",
                          widget.autoGenerateCode
                              ? "Auto-generated"
                              : "Manual entry",
                          widget.autoGenerateCode,
                        ),
                        _buildSummaryItem(
                          "Late Entry",
                          widget.allowLateEntry ? "Allowed" : "Not allowed",
                          widget.allowLateEntry,
                        ),
                        _buildSummaryItem(
                          "Notifications",
                          widget.enableNotifications ? "Enabled" : "Disabled",
                          widget.enableNotifications,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: value
            ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: value
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2)
              : AppTheme.lightTheme.dividerColor,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: value
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.lightTheme.primaryColor,
            activeTrackColor:
                AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
            inactiveThumbColor:
                AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            inactiveTrackColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, bool isEnabled) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppTheme.getSuccessColor(true)
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
