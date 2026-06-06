import 'package:flutter/material.dart';
import '../../data/models/permission_group_model.dart';
import '../../data/models/permission_label_model.dart';
import '../../data/repositories/permission_group_repository.dart';
import '../../data/repositories/permission_repository.dart';

class PermissionProvider extends ChangeNotifier {
  final PermissionRepository _permRepo;
  final PermissionGroupRepository _groupRepo;

  List<PermissionLabelModel> _labels = [];
  List<PermissionGroupModel> _groups = [];
  bool _isLoading = false;
  String? _error;

  PermissionProvider(this._permRepo, this._groupRepo);

  List<PermissionLabelModel> get labels => _labels;
  List<PermissionGroupModel> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final results = await Future.wait([
      _permRepo.getAll(),
      _groupRepo.getAll(),
    ]);

    final labelRes = results[0] as dynamic;
    final groupRes = results[1] as dynamic;

    if (labelRes.success && labelRes.data != null) {
      final List<PermissionLabelModel> rawLabels = labelRes.data;
      final enriched = await Future.wait(
        rawLabels.map((label) async {
          final detail = await _permRepo.getById(label.id);
          return (detail.success && detail.data != null)
              ? detail.data!
              : label;
        }),
      );
      _labels = enriched;
    } else {
      _error = labelRes.message;
    }

    if (groupRes.success) _groups = groupRes.data ?? [];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchGroups() async {
    final res = await _groupRepo.getAll();
    if (res.success && res.data != null) {
      _groups = res.data!;
      notifyListeners();
    }
  }

  Future<bool> createLabel(Map<String, dynamic> data) async {
    final res = await _permRepo.create(data);
    if (res.success) await fetchAll();
    return res.success;
  }

  Future<bool> updateLabel(int id, Map<String, dynamic> data) async {
    final res = await _permRepo.update(id, data);
    if (res.success) await fetchAll();
    return res.success;
  }

  Future<bool> deleteLabel(int id) async {
    final res = await _permRepo.delete(id);
    if (res.success) _labels.removeWhere((l) => l.id == id);
    notifyListeners();
    return res.success;
  }

  Future<bool> createGroup(String name) async {
    final res = await _groupRepo.create(name);
    if (res.success) await fetchGroups();
    return res.success;
  }

  Future<bool> updateGroup(int id, String name) async {
    final res = await _groupRepo.update(id, name);
    if (res.success) await fetchGroups();
    return res.success;
  }

  Future<bool> deleteGroup(int id) async {
    final res = await _groupRepo.delete(id);
    if (res.success) _groups.removeWhere((g) => g.id == id);
    notifyListeners();
    return res.success;
  }
}
