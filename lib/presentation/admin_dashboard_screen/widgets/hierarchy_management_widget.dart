import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../../core/app_export.dart';
import '../../../models/hierarchy_model.dart';
import '../../../services/firebase_service.dart';

class HierarchyManagementWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const HierarchyManagementWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  State<HierarchyManagementWidget> createState() => _HierarchyManagementWidgetState();
}

class _HierarchyManagementWidgetState extends State<HierarchyManagementWidget>
    with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  
  late TabController _tabController;
  List<BranchModel> _branches = [];
  List<ClassModel> _classes = [];
  List<BatchModel> _batches = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHierarchyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHierarchyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final branches = await _firebaseService.getBranches();
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load hierarchy data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadClasses(String branchId) async {
    try {
      final classes = await _firebaseService.getClassesByBranch(branchId);
      setState(() {
        _classes = classes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load classes: $e';
      });
    }
  }

  Future<void> _loadBatches(String classId) async {
    try {
      final batches = await _firebaseService.getBatchesByClass(classId);
      setState(() {
        _batches = batches;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load batches: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: AppTheme.surfaceLight,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryLight,
            unselectedLabelColor: AppTheme.textSecondaryLight,
            indicatorColor: AppTheme.primaryLight,
            tabs: const [
              Tab(text: 'Branches', icon: Icon(Icons.account_tree)),
              Tab(text: 'Classes', icon: Icon(Icons.class_)),
              Tab(text: 'Batches', icon: Icon(Icons.group)),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBranchesTab(),
              _buildClassesTab(),
              _buildBatchesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBranchesTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: AppTheme.errorLight,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _errorMessage,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.errorLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: _loadHierarchyData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Add Branch Button
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddBranchDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Branch'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryLight,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Branches List
                  Expanded(
                    child: _branches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_tree_outlined,
                                  size: 64.sp,
                                  color: AppTheme.textSecondaryLight,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No branches found',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Add your first branch to get started',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            itemCount: _branches.length,
                            itemBuilder: (context, index) {
                              final branch = _branches[index];
                              return _buildBranchCard(context, branch);
                            },
                          ),
                  ),
                ],
              );
  }

  Widget _buildClassesTab() {
    return Column(
      children: [
        // Branch Selector
        Padding(
          padding: EdgeInsets.all(4.w),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Branch',
              border: OutlineInputBorder(),
            ),
            items: _branches.map((branch) {
              return DropdownMenuItem(
                value: branch.id,
                child: Text(branch.name),
              );
            }).toList(),
            onChanged: (branchId) {
              if (branchId != null) {
                _loadClasses(branchId);
              }
            },
          ),
        ),
        
        // Classes List
        Expanded(
          child: _classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.class_outlined,
                        size: 64.sp,
                        color: AppTheme.textSecondaryLight,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No classes found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Select a branch to view classes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final classModel = _classes[index];
                    return _buildClassCard(context, classModel);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBatchesTab() {
    return Column(
      children: [
        // Class Selector
        Padding(
          padding: EdgeInsets.all(4.w),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Class',
              border: OutlineInputBorder(),
            ),
            items: _classes.map((classModel) {
              return DropdownMenuItem(
                value: classModel.id,
                child: Text(classModel.name),
              );
            }).toList(),
            onChanged: (classId) {
              if (classId != null) {
                _loadBatches(classId);
              }
            },
          ),
        ),
        
        // Batches List
        Expanded(
          child: _batches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 64.sp,
                        color: AppTheme.textSecondaryLight,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No batches found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Select a class to view batches',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _batches.length,
                  itemBuilder: (context, index) {
                    final batch = _batches[index];
                    return _buildBatchCard(context, batch);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBranchCard(BuildContext context, BranchModel branch) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color.fromRGBO((AppTheme.primaryLight.r * 255.0).round() & 0xff, (AppTheme.primaryLight.g * 255.0).round() & 0xff, (AppTheme.primaryLight.b * 255.0).round() & 0xff, 0.2),
          child: Icon(
            Icons.account_tree,
            color: AppTheme.primaryLight,
          ),
        ),
        title: Text(
          branch.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Created: ${DateFormat('MMM dd, yyyy').format(branch.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editBranch(branch);
                break;
              case 'delete':
                _deleteBranch(branch);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classModel) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color.fromRGBO((AppTheme.successLight.r * 255.0).round() & 0xff, (AppTheme.successLight.g * 255.0).round() & 0xff, (AppTheme.successLight.b * 255.0).round() & 0xff, 0.2),
          child: Icon(
            Icons.class_,
            color: AppTheme.successLight,
          ),
        ),
        title: Text(
          classModel.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Created: ${DateFormat('MMM dd, yyyy').format(classModel.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editClass(classModel);
                break;
              case 'delete':
                _deleteClass(classModel);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchCard(BuildContext context, BatchModel batch) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color.fromRGBO((AppTheme.warningLight.r * 255.0).round() & 0xff, (AppTheme.warningLight.g * 255.0).round() & 0xff, (AppTheme.warningLight.b * 255.0).round() & 0xff, 0.2),
          child: Icon(
            Icons.group,
            color: AppTheme.warningLight,
          ),
        ),
        title: Text(
          batch.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Created: ${DateFormat('MMM dd, yyyy').format(batch.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editBatch(batch);
                break;
              case 'delete':
                _deleteBatch(batch);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBranchDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Branch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Branch Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final branchName = nameController.text;
                navigator.pop();
                try {
                  final branch = BranchModel(
                    id: '',
                    name: branchName,
                    description: descriptionController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await _firebaseService.createBranch(branch);
                  _loadHierarchyData();
                  widget.onRefresh();
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Branch "$branchName" created successfully'),
                        backgroundColor: AppTheme.successLight,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Failed to create branch: $e'),
                        backgroundColor: AppTheme.errorLight,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editBranch(BranchModel branch) {
    final nameController = TextEditingController(text: branch.name);
    final descriptionController = TextEditingController(text: branch.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Branch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Branch Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a branch name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final branchName = nameController.text.trim();
              final description = descriptionController.text.trim();

              try {
                final updatedBranch = BranchModel(
                  id: branch.id,
                  name: branchName,
                  description: description.isEmpty ? '' : description,
                  createdAt: branch.createdAt,
                  updatedAt: DateTime.now(),
                );
                await _firebaseService.updateBranch(updatedBranch);
                navigator.pop();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Branch "$branchName" updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _loadHierarchyData();
                widget.onRefresh();
              } catch (e) {
                navigator.pop();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error updating branch: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteBranch(BranchModel branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete "${branch.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final branchName = branch.name;
              navigator.pop();
              try {
                await _firebaseService.deleteBranch(branch.id);
                _loadHierarchyData();
                widget.onRefresh();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Branch "$branchName" deleted successfully'),
                      backgroundColor: AppTheme.successLight,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete branch: $e'),
                      backgroundColor: AppTheme.errorLight,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editClass(ClassModel classModel) {
    final nameController = TextEditingController(text: classModel.name);
    final descriptionController = TextEditingController(text: classModel.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Class Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a class name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final className = nameController.text.trim();
              final description = descriptionController.text.trim();

              try {
                final updatedClass = ClassModel(
                  id: classModel.id,
                  name: className,
                  description: description.isEmpty ? null : description,
                  branchId: classModel.branchId,
                  createdAt: classModel.createdAt,
                  updatedAt: DateTime.now(),
                );
                await _firebaseService.updateClass(updatedClass);
                navigator.pop();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Class "$className" updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _loadClasses(classModel.branchId);
                widget.onRefresh();
              } catch (e) {
                navigator.pop();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error updating class: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteClass(ClassModel classModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete "${classModel.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final className = classModel.name;
              navigator.pop();
              try {
                await _firebaseService.deleteClass(classModel.id);
                _loadClasses(classModel.branchId);
                widget.onRefresh();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Class "$className" deleted successfully'),
                      backgroundColor: AppTheme.successLight,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete class: $e'),
                      backgroundColor: AppTheme.errorLight,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editBatch(BatchModel batch) {
    final nameController = TextEditingController(text: batch.name);
    final descriptionController = TextEditingController(text: batch.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Batch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Batch Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a batch name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final batchName = nameController.text.trim();
              final description = descriptionController.text.trim();

              try {
                final updatedBatch = BatchModel(
                  id: batch.id,
                  name: batchName,
                  description: description.isEmpty ? null : description,
                  classId: batch.classId,
                  createdAt: batch.createdAt,
                  updatedAt: DateTime.now(),
                );
                await _firebaseService.updateBatch(updatedBatch);
                navigator.pop();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Batch "$batchName" updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _loadBatches(batch.classId);
                widget.onRefresh();
              } catch (e) {
                navigator.pop();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error updating batch: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteBatch(BatchModel batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text('Are you sure you want to delete "${batch.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final batchName = batch.name;
              navigator.pop();
              try {
                await _firebaseService.deleteBatch(batch.id);
                _loadBatches(batch.classId);
                widget.onRefresh();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Batch "$batchName" deleted successfully'),
                      backgroundColor: AppTheme.successLight,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete batch: $e'),
                      backgroundColor: AppTheme.errorLight,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
