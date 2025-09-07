import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../models/hierarchy_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class ManageHierarchyScreen extends StatefulWidget {
  final UserModel? currentUser;

  const ManageHierarchyScreen({
    Key? key,
    this.currentUser,
  }) : super(key: key);

  @override
  State<ManageHierarchyScreen> createState() => _ManageHierarchyScreenState();
}

class _ManageHierarchyScreenState extends State<ManageHierarchyScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late UserModel _currentUser;
  List<BranchModel> _hierarchyList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser ?? _getDefaultUser();
    _loadHierarchy();
  }

  UserModel _getDefaultUser() {
    return UserModel(
      id: 'admin_user',
      name: 'Admin User',
      email: 'admin@unimark.com',
      role: UserRole.admin,
      enrollmentNumber: 'ADMIN001',
      branch: 'Administration',
      className: 'Admin',
      batch: '2024',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _loadHierarchy() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final hierarchy = await _firebaseService.getHierarchy();
      setState(() {
        _hierarchyList = hierarchy;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load hierarchy: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addHierarchyLevel(BranchModel hierarchy) async {
    setState(() => _isLoading = true);
    try {
      await _firebaseService.addHierarchyLevel(hierarchy);
      await _loadHierarchy();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hierarchy level added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add hierarchy level: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateHierarchyLevel(BranchModel hierarchy) async {
    setState(() => _isLoading = true);
    try {
      await _firebaseService.updateHierarchyLevel(hierarchy);
      await _loadHierarchy();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hierarchy level updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update hierarchy level: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHierarchyLevel(String hierarchyId) async {
    setState(() => _isLoading = true);
    try {
      await _firebaseService.deleteHierarchyLevel(hierarchyId);
      await _loadHierarchy();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hierarchy level deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete hierarchy level: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Manage Hierarchy'),
        backgroundColor: AppTheme.backgroundLight,
        foregroundColor: AppTheme.textPrimaryLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHierarchyDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHierarchy,
          ),
        ],
      ),
      body: _isLoading
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
                        onPressed: _loadHierarchy,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _hierarchyList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_tree,
                            size: 64.sp,
                            color: AppTheme.textSecondaryLight,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No hierarchy levels found',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          ElevatedButton(
                            onPressed: () => _showAddHierarchyDialog(),
                            child: const Text('Add First Level'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(4.w),
                      itemCount: _hierarchyList.length,
                      itemBuilder: (context, index) {
                        final hierarchy = _hierarchyList[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 2.h),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryLight,
                              child: Text(
                                hierarchy.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              hierarchy.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hierarchy.description.isNotEmpty)
                                  Text(hierarchy.description),
                                Text('Created: ${_formatDate(hierarchy.createdAt)}'),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _showEditHierarchyDialog(hierarchy);
                                    break;
                                  case 'delete':
                                    _showDeleteConfirmationDialog(hierarchy.id);
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
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  void _showAddHierarchyDialog() {
    showDialog(
      context: context,
      builder: (context) => _HierarchyDialog(
        onSave: _addHierarchyLevel,
      ),
    );
  }

  void _showEditHierarchyDialog(BranchModel hierarchy) {
    showDialog(
      context: context,
      builder: (context) => _HierarchyDialog(
        hierarchy: hierarchy,
        onSave: _updateHierarchyLevel,
      ),
    );
  }

  void _showDeleteConfirmationDialog(String hierarchyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hierarchy Level'),
        content: const Text(
          'Are you sure you want to delete this hierarchy level? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteHierarchyLevel(hierarchyId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _HierarchyDialog extends StatefulWidget {
  final BranchModel? hierarchy;
  final Function(BranchModel) onSave;

  const _HierarchyDialog({
    this.hierarchy,
    required this.onSave,
  });

  @override
  State<_HierarchyDialog> createState() => _HierarchyDialogState();
}

class _HierarchyDialogState extends State<_HierarchyDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hierarchy?.name ?? '');
    _descriptionController = TextEditingController(text: widget.hierarchy?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.hierarchy == null ? 'Add Hierarchy Level' : 'Edit Hierarchy Level'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
            final hierarchy = widget.hierarchy?.copyWith(
              name: _nameController.text,
              description: _descriptionController.text,
              updatedAt: DateTime.now(),
            ) ?? BranchModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text,
              description: _descriptionController.text,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            widget.onSave(hierarchy);
            Navigator.of(context).pop();
          },
          child: Text(widget.hierarchy == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
