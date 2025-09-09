import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class AdvancedOptionsWidget extends StatefulWidget {
  final bool preventDuplicates;
  final bool enableOfflineSync;
  final String customInstructions;
  final Function(bool) onPreventDuplicatesChanged;
  final Function(bool) onOfflineSyncChanged;
  final Function(String) onInstructionsChanged;

  const AdvancedOptionsWidget({
    super.key,
    required this.preventDuplicates,
    required this.enableOfflineSync,
    required this.customInstructions,
    required this.onPreventDuplicatesChanged,
    required this.onOfflineSyncChanged,
    required this.onInstructionsChanged,
  });

  @override
  State<AdvancedOptionsWidget> createState() => _AdvancedOptionsWidgetState();
}

class _AdvancedOptionsWidgetState extends State<AdvancedOptionsWidget> {
  bool _isExpanded = false;
  late TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    _instructionsController =
        TextEditingController(text: widget.customInstructions);
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

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
                    iconName: 'tune',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Advanced Options",
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "Additional session configuration",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_hasActiveOptions())
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        "${_getActiveOptionsCount()}",
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(width: 2.w),
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

          // Advanced Options Content
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.dividerColor,
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Duplicate Prevention Setting
                  _buildAdvancedSettingTile(
                    icon: 'block',
                    title: "Prevent Duplicate Attendance",
                    subtitle:
                        "Block multiple attendance submissions from same student",
                    value: widget.preventDuplicates,
                    onChanged: widget.onPreventDuplicatesChanged,
                    warningText: widget.preventDuplicates
                        ? "Students can only mark attendance once per session"
                        : null,
                  ),

                  SizedBox(height: 3.h),

                  // Offline Sync Setting
                  _buildAdvancedSettingTile(
                    icon: 'sync',
                    title: "Enable Offline Sync",
                    subtitle:
                        "Allow attendance marking when internet is unavailable",
                    value: widget.enableOfflineSync,
                    onChanged: widget.onOfflineSyncChanged,
                    warningText: widget.enableOfflineSync
                        ? "Attendance will sync when connection is restored"
                        : null,
                  ),

                  SizedBox(height: 3.h),

                  // Custom Instructions Section
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
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'description',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              "Custom Instructions",
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "Additional instructions for students during attendance",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        TextField(
                          controller: _instructionsController,
                          maxLines: 4,
                          maxLength: 200,
                          decoration: InputDecoration(
                            hintText:
                                "Enter special instructions for students (optional)...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: EdgeInsets.all(3.w),
                          ),
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                          onChanged: widget.onInstructionsChanged,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Security Features Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'security',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              "Security Features",
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "• GPS location verification (500m radius)\n• Device binding prevents proxy attendance\n• Session code validation with time limits\n• Automatic duplicate detection",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Advanced Settings Summary
                  if (_hasActiveOptions()) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.getSuccessColor(true)
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: AppTheme.getSuccessColor(true)
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
                                iconName: 'check_circle',
                                color: AppTheme.getSuccessColor(true),
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "Active Advanced Options",
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  color: AppTheme.getSuccessColor(true),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          if (widget.preventDuplicates)
                            Text(
                              "✓ Duplicate prevention enabled",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (widget.enableOfflineSync)
                            Text(
                              "✓ Offline sync enabled",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (widget.customInstructions.isNotEmpty)
                            Text(
                              "✓ Custom instructions added",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingTile({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    String? warningText,
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
      child: Column(
        children: [
          Row(
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
                activeThumbColor: AppTheme.lightTheme.primaryColor,
                activeTrackColor:
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                inactiveThumbColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                inactiveTrackColor: AppTheme
                    .lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
              ),
            ],
          ),
          if (warningText != null && value) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.getWarningColor(true).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.getWarningColor(true),
                    size: 14,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      warningText,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getWarningColor(true),
                        fontWeight: FontWeight.w500,
                      ),
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

  bool _hasActiveOptions() {
    return widget.preventDuplicates ||
        widget.enableOfflineSync ||
        widget.customInstructions.isNotEmpty;
  }

  int _getActiveOptionsCount() {
    int count = 0;
    if (widget.preventDuplicates) count++;
    if (widget.enableOfflineSync) count++;
    if (widget.customInstructions.isNotEmpty) count++;
    return count;
  }
}
