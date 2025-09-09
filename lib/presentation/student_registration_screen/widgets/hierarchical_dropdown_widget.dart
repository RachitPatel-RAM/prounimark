import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/hierarchy_model.dart';

class HierarchicalDropdownWidget extends StatefulWidget {
  final List<BranchModel> branches;
  final List<ClassModel> classes;
  final List<BatchModel> batches;
  final String? selectedBranchId;
  final String? selectedClassId;
  final String? selectedBatchId;
  final Function(String?) onBranchChanged;
  final Function(String?) onClassChanged;
  final Function(String?) onBatchChanged;
  final bool isLocked;

  const HierarchicalDropdownWidget({
    super.key,
    required this.branches,
    required this.classes,
    required this.batches,
    this.selectedBranchId,
    this.selectedClassId,
    this.selectedBatchId,
    required this.onBranchChanged,
    required this.onClassChanged,
    required this.onBatchChanged,
    this.isLocked = false,
  });

  @override
  State<HierarchicalDropdownWidget> createState() =>
      _HierarchicalDropdownWidgetState();
}

class _HierarchicalDropdownWidgetState
    extends State<HierarchicalDropdownWidget> {
  bool _isLoadingBranches = false;
  bool _isLoadingClasses = false;
  bool _isLoadingBatches = false;

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
      builder: (context) => _buildBranchPickerBottomSheet(),
    );
  }

  void _showClassPicker() async {
    if (widget.isLocked || widget.selectedBranchId == null) return;

    await _loadClasses();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildClassPickerBottomSheet(),
    );
  }

  void _showBatchPicker() async {
    if (widget.isLocked || widget.selectedClassId == null) return;

    await _loadBatches();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBatchPickerBottomSheet(),
    );
  }

  Widget _buildBranchPickerBottomSheet() {
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
                  'Select Branch',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
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
              itemCount: widget.branches.length,
              itemBuilder: (context, index) {
                final branch = widget.branches[index];
                final isSelected = widget.selectedBranchId == branch.id;

                return ListTile(
                  title: Text(
                    branch.name,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          size: 5.w,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    widget.onBranchChanged(branch.id);
                    widget.onClassChanged(null);
                    widget.onBatchChanged(null);
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

  Widget _buildClassPickerBottomSheet() {
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
                  'Select Class',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
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
              itemCount: widget.classes.length,
              itemBuilder: (context, index) {
                final classModel = widget.classes[index];
                final isSelected = widget.selectedClassId == classModel.id;

                return ListTile(
                  title: Text(
                    classModel.name,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          size: 5.w,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    widget.onClassChanged(classModel.id);
                    widget.onBatchChanged(null);
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

  Widget _buildBatchPickerBottomSheet() {
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
                  'Select Batch',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
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
              itemCount: widget.batches.length,
              itemBuilder: (context, index) {
                final batch = widget.batches[index];
                final isSelected = widget.selectedBatchId == batch.id;

                return ListTile(
                  title: Text(
                    batch.name,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          size: 5.w,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    widget.onBatchChanged(batch.id);
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
          borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(12),
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
                  Icon(
                    Icons.lock,
                    size: 5.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down,
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
        final branch = widget.branches.firstWhere(
          (b) => b.id == id,
          orElse: () => BranchModel(
            id: id,
            name: id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        return branch.name;
      case 'Class':
        final classModel = widget.classes.firstWhere(
          (c) => c.id == id,
          orElse: () => ClassModel(
            id: id,
            branchId: '',
            name: id,
            createdAt: DateTime.now(),
          ),
        );
        return classModel.name;
      case 'Batch':
        final batch = widget.batches.firstWhere(
          (b) => b.id == id,
          orElse: () => BatchModel(
            id: id,
            classId: '',
            name: id,
            createdAt: DateTime.now(),
          ),
        );
        return batch.name;
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.school,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Academic Details',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          'Select your branch, class, and batch. These selections will be locked after registration and can only be changed by an administrator.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 3.h),

        // Branch Dropdown
        _buildDropdownField(
          label: 'Branch',
          value: widget.selectedBranchId,
          hint: 'Select your branch',
          onTap: _showBranchPicker,
          isEnabled: !widget.isLocked,
          isLoading: _isLoadingBranches,
        ),
        SizedBox(height: 3.h),

        // Class Dropdown
        _buildDropdownField(
          label: 'Class',
          value: widget.selectedClassId,
          hint: widget.selectedBranchId != null
              ? 'Select your class'
              : 'Select branch first',
          onTap: _showClassPicker,
          isEnabled: !widget.isLocked && widget.selectedBranchId != null,
          isLoading: _isLoadingClasses,
        ),
        SizedBox(height: 3.h),

        // Batch Dropdown
        _buildDropdownField(
          label: 'Batch',
          value: widget.selectedBatchId,
          hint: widget.selectedClassId != null
              ? 'Select your batch'
              : 'Select class first',
          onTap: _showBatchPicker,
          isEnabled: !widget.isLocked && widget.selectedClassId != null,
          isLoading: _isLoadingBatches,
        ),

        if (widget.isLocked) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
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
