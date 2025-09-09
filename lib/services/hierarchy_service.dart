import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hierarchy_model.dart';

class HierarchyService {
  static final HierarchyService _instance = HierarchyService._internal();
  factory HierarchyService() => _instance;
  HierarchyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all active branches
  Future<List<BranchModel>> getBranches() async {
    try {
      final querySnapshot = await _firestore
          .collection('branches')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => BranchModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all active classes for a specific branch
  Future<List<ClassModel>> getClassesByBranch(String branchId) async {
    try {
      final querySnapshot = await _firestore
          .collection('classes')
          .where('branchId', isEqualTo: branchId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => ClassModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all active batches for a specific class
  Future<List<BatchModel>> getBatchesByClass(String classId) async {
    try {
      final querySnapshot = await _firestore
          .collection('batches')
          .where('classId', isEqualTo: classId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => BatchModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get branch by ID
  Future<BranchModel?> getBranchById(String branchId) async {
    try {
      final doc = await _firestore.collection('branches').doc(branchId).get();
      if (doc.exists) {
        return BranchModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get class by ID
  Future<ClassModel?> getClassById(String classId) async {
    try {
      final doc = await _firestore.collection('classes').doc(classId).get();
      if (doc.exists) {
        return ClassModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get batch by ID
  Future<BatchModel?> getBatchById(String batchId) async {
    try {
      final doc = await _firestore.collection('batches').doc(batchId).get();
      if (doc.exists) {
        return BatchModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create a new branch (admin only)
  Future<bool> createBranch({
    required String name,
    String? description,
  }) async {
    try {
      final branch = BranchModel(
        id: '',
        name: name,
        description: description ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('branches').add(branch.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create a new class (admin only)
  Future<bool> createClass({
    required String branchId,
    required String name,
    String? description,
  }) async {
    try {
      final classModel = ClassModel(
        id: '',
        branchId: branchId,
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('classes').add(classModel.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create a new batch (admin only)
  Future<bool> createBatch({
    required String classId,
    required String name,
    String? description,
  }) async {
    try {
      final batch = BatchModel(
        id: '',
        classId: classId,
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('batches').add(batch.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update branch (admin only)
  Future<bool> updateBranch(String branchId, {
    String? name,
    String? description,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (isActive != null) updateData['isActive'] = isActive;

      await _firestore.collection('branches').doc(branchId).update(updateData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update class (admin only)
  Future<bool> updateClass(String classId, {
    String? name,
    String? description,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (isActive != null) updateData['isActive'] = isActive;

      await _firestore.collection('classes').doc(classId).update(updateData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update batch (admin only)
  Future<bool> updateBatch(String batchId, {
    String? name,
    String? description,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (isActive != null) updateData['isActive'] = isActive;

      await _firestore.collection('batches').doc(batchId).update(updateData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete branch (admin only) - soft delete
  Future<bool> deleteBranch(String branchId) async {
    try {
      await _firestore.collection('branches').doc(branchId).update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete class (admin only) - soft delete
  Future<bool> deleteClass(String classId) async {
    try {
      await _firestore.collection('classes').doc(classId).update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete batch (admin only) - soft delete
  Future<bool> deleteBatch(String batchId) async {
    try {
      await _firestore.collection('batches').doc(batchId).update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
