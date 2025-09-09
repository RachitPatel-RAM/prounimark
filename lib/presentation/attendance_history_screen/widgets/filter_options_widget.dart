import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/attendance_model.dart';

class FilterOptionsWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final AttendanceResult? statusFilter;
  final Function(DateTime?, DateTime?, AttendanceResult?) onApply;
  final VoidCallback onClear;

  const FilterOptionsWidget({
    super.key,
    this.startDate,
    this.endDate,
    this.statusFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterOptionsWidget> createState() => _FilterOptionsWidgetState();
}

class _FilterOptionsWidgetState extends State<FilterOptionsWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  AttendanceResult? _statusFilter;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _statusFilter = widget.statusFilter;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Options'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Start Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Start Date'),
              subtitle: Text(_startDate != null 
                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                  : 'Select start date'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                }
              },
            ),
            
            // End Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('End Date'),
              subtitle: Text(_endDate != null 
                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                  : 'Select end date'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                }
              },
            ),
            
            // Status Filter
            ListTile(
              leading: const Icon(Icons.filter_list),
              title: const Text('Status'),
              subtitle: Text(_statusFilter != null 
                  ? _statusFilter.toString().split('.').last.toUpperCase()
                  : 'All statuses'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Select Status',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        ListTile(
                          title: const Text('All Statuses'),
                          leading: const Icon(Icons.all_inclusive),
                          onTap: () {
                            setState(() {
                              _statusFilter = null;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Present'),
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          onTap: () {
                            setState(() {
                              _statusFilter = AttendanceResult.accepted;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Absent'),
                          leading: const Icon(Icons.cancel, color: Colors.red),
                          onTap: () {
                            setState(() {
                              _statusFilter = AttendanceResult.rejected;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 2.h),
            
            // Clear Filters Button
            if (_startDate != null || _endDate != null || _statusFilter != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                      _statusFilter = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All Filters'),
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
            widget.onApply(_startDate, _endDate, _statusFilter);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}