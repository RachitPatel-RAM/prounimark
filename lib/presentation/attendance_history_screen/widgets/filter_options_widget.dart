import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/attendance_model.dart';

class FilterOptionsWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final AttendanceStatus? statusFilter;
  final Function(DateTime?, DateTime?, AttendanceStatus?) onApply;
  final VoidCallback onClear;

  const FilterOptionsWidget({
    Key? key,
    this.startDate,
    this.endDate,
    this.statusFilter,
    required this.onApply,
    required this.onClear,
  }) : super(key: key);

  @override
  State<FilterOptionsWidget> createState() => _FilterOptionsWidgetState();
}

class _FilterOptionsWidgetState extends State<FilterOptionsWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  AttendanceStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _statusFilter = widget.statusFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: AppTheme.primaryLight,
                  size: 24.sp,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Filter Attendance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            SizedBox(height: 4.h),
            
            // Date Range
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            
            SizedBox(height: 2.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Start Date',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildDateField(
                    'End Date',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 4.h),
            
            // Status Filter
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            
            SizedBox(height: 2.h),
            
            Wrap(
              spacing: 2.w,
              runSpacing: 2.h,
              children: [
                _buildStatusChip('All', null),
                _buildStatusChip('Present', AttendanceStatus.present),
                _buildStatusChip('Absent', AttendanceStatus.absent),
                _buildStatusChip('Late', AttendanceStatus.late),
              ],
            ),
            
            SizedBox(height: 4.h),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Clear'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_startDate, _endDate, _statusFilter);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.dividerLight),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.textSecondaryLight,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    date != null 
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: date != null 
                          ? AppTheme.textPrimaryLight 
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
                if (date != null)
                  IconButton(
                    onPressed: () => onChanged(null),
                    icon: Icon(
                      Icons.clear,
                      color: AppTheme.textSecondaryLight,
                      size: 16.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, AttendanceStatus? status) {
    final isSelected = _statusFilter == status;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? status : null;
        });
      },
      selectedColor: AppTheme.primaryLight.withOpacity(0.2),
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
}
