import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/permission_label_model.dart';
import '../../../data/models/permission_model.dart';
import '../../providers/role_provider.dart';
import '../../providers/permission_provider.dart';

class RoleFormScreen extends StatefulWidget {
  final RoleModel? role;
  const RoleFormScreen({super.key, this.role});

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  List<int> _selectedPermissionIds = [];
  bool _isLoading = false;

  bool get isEditing => widget.role != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameCtrl.text = widget.role!.name;
      _selectedPermissionIds =
          widget.role!.permissions.map((p) => p.id).toList();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  PermissionModel? _findAction(List<PermissionModel> perms, String action) {
    try {
      return perms.firstWhere(
          (p) => p.name.toLowerCase().split('-').last == action.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'permissions': _selectedPermissionIds,
    };

    bool success;
    if (isEditing) {
      success = await context
          .read<RoleProvider>()
          .updateRole(widget.role!.id, data);
    } else {
      success = await context.read<RoleProvider>().createRole(data);
    }

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Hak akses berhasil ${isEditing ? 'diperbarui' : 'dibuat'}'
            : 'Gagal menyimpan hak akses'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) Navigator.pop(context);
    }
  }

  Widget _buildCheckbox(PermissionModel? perm) {
    if (perm == null) {
      return const SizedBox(width: 36, height: 36);
    }
    final selected = _selectedPermissionIds.contains(perm.id);
    return SizedBox(
      width: 36,
      height: 36,
      child: Checkbox(
        value: selected,
        onChanged: (v) {
          setState(() {
            if (v == true) {
              _selectedPermissionIds.add(perm.id);
            } else {
              _selectedPermissionIds.remove(perm.id);
            }
          });
        },
        activeColor: const Color(0xFF1565C0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permProvider = context.watch<PermissionProvider>();

    final Map<String, List<PermissionLabelModel>> grouped = {};
    for (final label in permProvider.labels) {
      final groupName = label.permissionGroup?.name ?? 'Lainnya';
      grouped.putIfAbsent(groupName, () => []).add(label);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Hak Akses' : 'Tambah Hak Akses'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Hak Akses',
                      prefixIcon:
                          const Icon(Icons.admin_panel_settings_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Nama hak akses wajib diisi' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Permissions',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${_selectedPermissionIds.length} dipilih',
                              style: const TextStyle(
                                  color: Color(0xFF1565C0), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (permProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (grouped.isEmpty)
                        const Text('Tidak ada permission tersedia')
                      else
                        ...grouped.entries.map((entry) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 12, bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF1565C0)),
                                  ),
                                ),
                                // Header row
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                          flex: 3, child: SizedBox()),
                                      _HeaderCell('Semua'),
                                      _HeaderCell('Create'),
                                      _HeaderCell('Delete'),
                                      _HeaderCell('Edit'),
                                      _HeaderCell('View'),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                ...entry.value.map((label) {
                                  final ids = label.permissions
                                      .map((p) => p.id)
                                      .toList();
                                  final allSelected = ids.isNotEmpty &&
                                      ids.every((id) =>
                                          _selectedPermissionIds.contains(id));
                                  final someSelected = !allSelected &&
                                      ids.any((id) =>
                                          _selectedPermissionIds.contains(id));

                                  final createPerm =
                                      _findAction(label.permissions, 'create');
                                  final deletePerm =
                                      _findAction(label.permissions, 'delete');
                                  final editPerm =
                                      _findAction(label.permissions, 'update');
                                  final viewPerm =
                                      _findAction(label.permissions, 'view');

                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                label.name,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 36,
                                              height: 36,
                                              child: Checkbox(
                                                tristate: true,
                                                value: allSelected
                                                    ? true
                                                    : someSelected
                                                        ? null
                                                        : false,
                                                onChanged: (_) {
                                                  setState(() {
                                                    if (allSelected) {
                                                      _selectedPermissionIds
                                                          .removeWhere((id) =>
                                                              ids.contains(id));
                                                    } else {
                                                      for (final id in ids) {
                                                        if (!_selectedPermissionIds
                                                            .contains(id)) {
                                                          _selectedPermissionIds
                                                              .add(id);
                                                        }
                                                      }
                                                    }
                                                  });
                                                },
                                                activeColor:
                                                    const Color(0xFF1565C0),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                            _buildCheckbox(createPerm),
                                            _buildCheckbox(deletePerm),
                                            _buildCheckbox(editPerm),
                                            _buildCheckbox(viewPerm),
                                          ],
                                        ),
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                                }),
                              ],
                            )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? 'Simpan Perubahan' : 'Buat Hak Akses'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600),
      ),
    );
  }
}
