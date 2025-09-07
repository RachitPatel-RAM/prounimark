import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../../core/app_export.dart';
import '../../../models/hierarchy_model.dart';
import '../../../services/firebase_service.dart';

class HierarchyManagementWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const HierarchyManagementWidget({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

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
          backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
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
          backgroundColor: AppTheme.successLight.withOpacity(0.2),
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
          backgroundColor: AppTheme.warningLight.withOpacity(0.2),
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
                Navigator.of(context).pop();
                try {
                  final branch = BranchModel(
                    id: '',
                    name: nameController.text,
                    description: descriptionController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await _firebaseService.createBranch(branch);
                  _loadHierarchyData();
                  widget.onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Branch "${nameController.text}" created successfully'),
                      backgroundColor: AppTheme.successLight,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create branch: $e'),
                      backgroundColor: AppTheme.errorLight,
                    ),
                  );
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
    // TODO: Implement edit branch functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit branch functionality will be implemented soon'),
        backgroundColor: AppTheme.primaryLight,
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
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete branch functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Delete branch functionality will be implemented soon'),
                  backgroundColor: AppTheme.primaryLight,
                ),
              );
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
    // TODO: Implement edit class functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit class functionality will be implemented soon'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _deleteClass(ClassModel classModel) {
    // TODO: Implement delete class functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delete class functionality will be implemented soon'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _editBatch(BatchModel batch) {
    // TODO: Implement edit batch functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit batch functionality will be implemented soon'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _deleteBatch(BatchModel batch) {
    // TODO: Implement delete batch functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delete batch functionality will be implemented soon'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }
}
