import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class BatchSelectionWidget extends StatefulWidget {
  final List<String> selectedBatches;
  final Function(List<String>) onBatchesChanged;

  const BatchSelectionWidget({
    Key? key,
    required this.selectedBatches,
    required this.onBatchesChanged,
  }) : super(key: key);

  @override
  State<BatchSelectionWidget> createState() => _BatchSelectionWidgetState();
}

class _BatchSelectionWidgetState extends State<BatchSelectionWidget> {
  bool _isExpanded = false;

  // Mock batch data
  final List<Map<String, dynamic>> _batches = [
    {
      "id": "CS-A-2024",
      "name": "Computer Science - Batch A",
      "year": "2024",
      "strength": 45,
      "branch": "Computer Science",
      "section": "A"
    },
    {
      "id": "CS-B-2024",
      "name": "Computer Science - Batch B",
      "year": "2024",
      "strength": 42,
      "branch": "Computer Science",
      "section": "B"
    },
    {
      "id": "CS-C-2024",
      "name": "Computer Science - Batch C",
      "year": "2024",
      "strength": 38,
      "branch": "Computer Science",
      "section": "C"
    },
    {
      "id": "IT-A-2024",
      "name": "Information Technology - Batch A",
      "year": "2024",
      "strength": 40,
      "branch": "Information Technology",
      "section": "A"
    },
    {
      "id": "IT-B-2024",
      "name": "Information Technology - Batch B",
      "year": "2024",
      "strength": 35,
      "branch": "Information Technology",
      "section": "B"
    }
  ];

  void _toggleBatch(String batchId) {
    List<String> updatedBatches = List.from(widget.selectedBatches);

    if (updatedBatches.contains(batchId)) {
      updatedBatches.remove(batchId);
    } else {
      updatedBatches.add(batchId);
    }

    widget.onBatchesChanged(updatedBatches);
  }

  int _getTotalStudents() {
    return _batches
        .where((batch) => widget.selectedBatches.contains(batch["id"]))
        .fold(0, (sum, batch) => sum + (batch["strength"] as int));
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
          // Batch Selection Header
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
                    iconName: 'groups',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Batches",
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          widget.selectedBatches.isEmpty
                              ? "No batches selected"
                              : "${widget.selectedBatches.length} batch${widget.selectedBatches.length > 1 ? 'es' : ''} selected",
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: widget.selectedBatches.isNotEmpty
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.selectedBatches.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        "${widget.selectedBatches.length}",
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

          // Selected Batches Summary
          if (widget.selectedBatches.isNotEmpty && !_isExpanded) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.dividerColor,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'people',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    "Total Students: ${_getTotalStudents()}",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Batch List
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.dividerColor,
            ),

            Container(
              constraints: BoxConstraints(maxHeight: 35.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _batches.length,
                itemBuilder: (context, index) {
                  final batch = _batches[index];
                  final isSelected =
                      widget.selectedBatches.contains(batch["id"]);

                  return InkWell(
                    onTap: () => _toggleBatch(batch["id"] as String),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          // Checkbox
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.lightTheme.primaryColor
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.lightTheme.primaryColor
                                    : AppTheme.lightTheme.dividerColor,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: isSelected
                                ? CustomIconWidget(
                                    iconName: 'check',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onPrimary,
                                    size: 16,
                                  )
                                : null,
                          ),
                          SizedBox(width: 3.w),

                          // Batch Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${batch["branch"]} - Section ${batch["section"]}",
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'people',
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                      size: 14,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      "${batch["strength"]} students",
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    CustomIconWidget(
                                      iconName: 'calendar_today',
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                      size: 14,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      "Batch ${batch["year"]}",
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Total Summary
            if (widget.selectedBatches.isNotEmpty) ...[
              Divider(
                height: 1,
                color: AppTheme.lightTheme.dividerColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Selected:",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "${widget.selectedBatches.length} batches • ${_getTotalStudents()} students",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
