import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HierarchicalDropdownWidget extends StatefulWidget {
  final String? selectedBranch;
  final String? selectedClass;
  final String? selectedBatch;
  final Function(String?) onBranchChanged;
  final Function(String?) onClassChanged;
  final Function(String?) onBatchChanged;
  final bool isLocked;

  const HierarchicalDropdownWidget({
    Key? key,
    this.selectedBranch,
    this.selectedClass,
    this.selectedBatch,
    required this.onBranchChanged,
    required this.onClassChanged,
    required this.onBatchChanged,
    this.isLocked = false,
  }) : super(key: key);

  @override
  State<HierarchicalDropdownWidget> createState() =>
      _HierarchicalDropdownWidgetState();
}

class _HierarchicalDropdownWidgetState
    extends State<HierarchicalDropdownWidget> {
  bool _isLoadingBranches = false;
  bool _isLoadingClasses = false;
  bool _isLoadingBatches = false;

  // Mock data - In real app, this would come from Firebase Firestore
  final List<Map<String, dynamic>> _branchData = [
    {
      "id": "CE",
      "name": "Computer Engineering",
      "classes": [
        {
          "id": "CE_SEM1",
          "name": "Semester 1",
          "batches": [
            {"id": "CE_SEM1_A", "name": "Batch A"},
            {"id": "CE_SEM1_B", "name": "Batch B"},
            {"id": "CE_SEM1_C", "name": "Batch C"},
          ]
        },
        {
          "id": "CE_SEM2",
          "name": "Semester 2",
          "batches": [
            {"id": "CE_SEM2_A", "name": "Batch A"},
            {"id": "CE_SEM2_B", "name": "Batch B"},
          ]
        },
        {
          "id": "CE_SEM3",
          "name": "Semester 3",
          "batches": [
            {"id": "CE_SEM3_A", "name": "Batch A"},
            {"id": "CE_SEM3_B", "name": "Batch B"},
            {"id": "CE_SEM3_C", "name": "Batch C"},
          ]
        },
      ]
    },
    {
      "id": "IT",
      "name": "Information Technology",
      "classes": [
        {
          "id": "IT_SEM1",
          "name": "Semester 1",
          "batches": [
            {"id": "IT_SEM1_A", "name": "Batch A"},
            {"id": "IT_SEM1_B", "name": "Batch B"},
          ]
        },
        {
          "id": "IT_SEM2",
          "name": "Semester 2",
          "batches": [
            {"id": "IT_SEM2_A", "name": "Batch A"},
            {"id": "IT_SEM2_B", "name": "Batch B"},
            {"id": "IT_SEM2_C", "name": "Batch C"},
          ]
        },
      ]
    },
    {
      "id": "EC",
      "name": "Electronics & Communication",
      "classes": [
        {
          "id": "EC_SEM1",
          "name": "Semester 1",
          "batches": [
            {"id": "EC_SEM1_A", "name": "Batch A"},
            {"id": "EC_SEM1_B", "name": "Batch B"},
          ]
        },
        {
          "id": "EC_SEM3",
          "name": "Semester 3",
          "batches": [
            {"id": "EC_SEM3_A", "name": "Batch A"},
            {"id": "EC_SEM3_B", "name": "Batch B"},
            {"id": "EC_SEM3_C", "name": "Batch C"},
          ]
        },
      ]
    },
    {
      "id": "ME",
      "name": "Mechanical Engineering",
      "classes": [
        {
          "id": "ME_SEM1",
          "name": "Semester 1",
          "batches": [
            {"id": "ME_SEM1_A", "name": "Batch A"},
            {"id": "ME_SEM1_B", "name": "Batch B"},
          ]
        },
        {
          "id": "ME_SEM2",
          "name": "Semester 2",
          "batches": [
            {"id": "ME_SEM2_A", "name": "Batch A"},
            {"id": "ME_SEM2_B", "name": "Batch B"},
            {"id": "ME_SEM2_C", "name": "Batch C"},
          ]
        },
      ]
    },
  ];

  List<Map<String, dynamic>> get _availableBranches => _branchData;

  List<Map<String, dynamic>> get _availableClasses {
    if (widget.selectedBranch == null) return [];
    final branch = _branchData.firstWhere(
      (b) => (b["id"] as String) == widget.selectedBranch,
      orElse: () => <String, dynamic>{},
    );
    return (branch["classes"] as List<Map<String, dynamic>>?) ?? [];
  }

  List<Map<String, dynamic>> get _availableBatches {
    if (widget.selectedClass == null) return [];
    final classes = _availableClasses;
    final selectedClass = classes.firstWhere(
      (c) => (c["id"] as String) == widget.selectedClass,
      orElse: () => <String, dynamic>{},
    );
    return (selectedClass["batches"] as List<Map<String, dynamic>>?) ?? [];
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoadingBranches = true);
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoadingBranches = false);
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoadingClasses = true);
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isLoadingClasses = false);
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoadingBatches = true);
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isLoadingBatches = false);
  }

  void _showBranchPicker() async {
    if (widget.isLocked) return;

    await _loadBranches();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerBottomSheet(
        title: 'Select Branch',
        items: _availableBranches,
        selectedValue: widget.selectedBranch,
        onSelected: (value) {
          widget.onBranchChanged(value);
          // Reset dependent selections
          widget.onClassChanged(null);
          widget.onBatchChanged(null);
        },
      ),
    );
  }

  void _showClassPicker() async {
    if (widget.isLocked || widget.selectedBranch == null) return;

    await _loadClasses();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerBottomSheet(
        title: 'Select Class',
        items: _availableClasses,
        selectedValue: widget.selectedClass,
        onSelected: (value) {
          widget.onClassChanged(value);
          // Reset dependent selection
          widget.onBatchChanged(null);
        },
      ),
    );
  }

  void _showBatchPicker() async {
    if (widget.isLocked || widget.selectedClass == null) return;

    await _loadBatches();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerBottomSheet(
        title: 'Select Batch',
        items: _availableBatches,
        selectedValue: widget.selectedBatch,
        onSelected: widget.onBatchChanged,
      ),
    );
  }

  Widget _buildPickerBottomSheet({
    required String title,
    required List<Map<String, dynamic>> items,
    required String? selectedValue,
    required Function(String?) onSelected,
  }) {
    return Container(
      height: 60.h,
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

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
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

          // Items list
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedValue == item["id"];

                return ListTile(
                  title: Text(
                    item["name"] as String,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check',
                          size: 5.w,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    onSelected(item["id"] as String);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required VoidCallback onTap,
    required bool isEnabled,
    required bool isLoading,
  }) {
    final displayText = value != null ? _getDisplayName(value, label) : hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: isEnabled
                ? AppTheme.lightTheme.colorScheme.onSurface
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: isEnabled && !isLoading ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: isEnabled
                    ? AppTheme.lightTheme.colorScheme.outline
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(8),
              color: isEnabled
                  ? AppTheme.lightTheme.colorScheme.surface
                  : AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: value != null
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                else if (widget.isLocked)
                  CustomIconWidget(
                    iconName: 'lock',
                    size: 5.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                  )
                else
                  CustomIconWidget(
                    iconName: isEnabled
                        ? 'keyboard_arrow_down'
                        : 'keyboard_arrow_down',
                    size: 6.w,
                    color: isEnabled
                        ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayName(String id, String type) {
    switch (type) {
      case 'Branch':
        return _availableBranches.firstWhere(
          (b) => (b["id"] as String) == id,
          orElse: () => {"name": id},
        )["name"] as String;
      case 'Class':
        return _availableClasses.firstWhere(
          (c) => (c["id"] as String) == id,
          orElse: () => {"name": id},
        )["name"] as String;
      case 'Batch':
        return _availableBatches.firstWhere(
          (b) => (b["id"] as String) == id,
          orElse: () => {"name": id},
        )["name"] as String;
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Branch Dropdown
        _buildDropdownField(
          label: 'Branch',
          value: widget.selectedBranch,
          hint: 'Select your branch',
          onTap: _showBranchPicker,
          isEnabled: !widget.isLocked,
          isLoading: _isLoadingBranches,
        ),
        SizedBox(height: 3.h),

        // Class Dropdown
        _buildDropdownField(
          label: 'Class',
          value: widget.selectedClass,
          hint: widget.selectedBranch != null
              ? 'Select your class'
              : 'Select branch first',
          onTap: _showClassPicker,
          isEnabled: !widget.isLocked && widget.selectedBranch != null,
          isLoading: _isLoadingClasses,
        ),
        SizedBox(height: 3.h),

        // Batch Dropdown
        _buildDropdownField(
          label: 'Batch',
          value: widget.selectedBatch,
          hint: widget.selectedClass != null
              ? 'Select your batch'
              : 'Select class first',
          onTap: _showBatchPicker,
          isEnabled: !widget.isLocked && widget.selectedClass != null,
          isLoading: _isLoadingBatches,
        ),

        if (widget.isLocked) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.warningLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  size: 5.w,
                  color: AppTheme.warningLight,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Branch, Class, and Batch selections are locked after registration.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
