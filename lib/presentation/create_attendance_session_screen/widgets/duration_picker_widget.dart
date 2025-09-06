import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class DurationPickerWidget extends StatefulWidget {
  final int durationMinutes;
  final Function(int) onDurationChanged;

  const DurationPickerWidget({
    Key? key,
    required this.durationMinutes,
    required this.onDurationChanged,
  }) : super(key: key);

  @override
  State<DurationPickerWidget> createState() => _DurationPickerWidgetState();
}

class _DurationPickerWidgetState extends State<DurationPickerWidget> {
  late TextEditingController _textController;
  bool _isSliderMode = true;

  // Predefined duration options
  final List<int> _quickDurations = [5, 10, 15, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.durationMinutes.toString());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateDuration(int minutes) {
    if (minutes >= 1 && minutes <= 60) {
      widget.onDurationChanged(minutes);
      _textController.text = minutes.toString();
    }
  }

  void _showIOSStylePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Container(
          height: 40.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              SizedBox(height: 2.h),

              // Title
              Text(
                "Select Duration",
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),

              // Duration options
              Expanded(
                child: ListView.builder(
                  itemCount: 60,
                  itemBuilder: (context, index) {
                    final minutes = index + 1;
                    final isSelected = minutes == widget.durationMinutes;

                    return InkWell(
                      onTap: () {
                        _updateDuration(minutes);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$minutes minute${minutes > 1 ? 's' : ''}",
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppTheme.lightTheme.primaryColor
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            if (isSelected)
                              CustomIconWidget(
                                iconName: 'check_circle',
                                color: AppTheme.lightTheme.primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
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
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Session Duration",
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "${widget.durationMinutes} minute${widget.durationMinutes > 1 ? 's' : ''}",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // Mode toggle
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSliderMode = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: _isSliderMode
                            ? AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: CustomIconWidget(
                        iconName: 'tune',
                        color: _isSliderMode
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSliderMode = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: !_isSliderMode
                            ? AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: CustomIconWidget(
                        iconName: 'edit',
                        color: !_isSliderMode
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Quick duration buttons
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _quickDurations.map((minutes) {
              final isSelected = minutes == widget.durationMinutes;
              return InkWell(
                onTap: () => _updateDuration(minutes),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    "${minutes}m",
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 3.h),

          // Duration input/slider
          if (_isSliderMode) ...[
            // Slider mode
            Row(
              children: [
                Text(
                  "1m",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: widget.durationMinutes.toDouble(),
                    min: 1.0,
                    max: 60.0,
                    divisions: 59,
                    activeColor: AppTheme.lightTheme.primaryColor,
                    inactiveColor: AppTheme.lightTheme.dividerColor,
                    onChanged: (value) {
                      _updateDuration(value.round());
                    },
                  ),
                ),
                Text(
                  "60m",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Text input mode
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Duration (minutes)",
                      suffixText: "min",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 1.5.h),
                    ),
                    onChanged: (value) {
                      final minutes = int.tryParse(value);
                      if (minutes != null) {
                        _updateDuration(minutes);
                      }
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                if (Platform.isIOS)
                  ElevatedButton(
                    onPressed: _showIOSStylePicker,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(3.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'access_time',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ],

          SizedBox(height: 2.h),

          // Duration info
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    "Session will automatically close after ${widget.durationMinutes} minute${widget.durationMinutes > 1 ? 's' : ''}. Students can mark attendance until then.",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
