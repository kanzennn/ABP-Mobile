import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/permission_label_model.dart';
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
            ? 'Role berhasil ${isEditing ? 'diperbarui' : 'dibuat'}'
            : 'Gagal menyimpan role'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permProvider = context.watch<PermissionProvider>();

    // Group labels by permission group
    final Map<String, List<PermissionLabelModel>> grouped = {};
    for (final label in permProvider.labels) {
      final groupName = label.permissionGroup?.name ?? 'Lainnya';
      grouped.putIfAbsent(groupName, () => []).add(label);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Role' : 'Tambah Role'),
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
                      labelText: 'Nama Role',
                      prefixIcon:
                          const Icon(Icons.admin_panel_settings_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Nama role wajib diisi' : null,
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
                                  margin: const EdgeInsets.only(
                                      top: 8, bottom: 4),
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
                                ...entry.value.expand((label) {
                                  return [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, top: 4),
                                      child: Text(label.name,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    ...label.permissions.map((perm) =>
                                        CheckboxListTile(
                                          title: Text(perm.name,
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                          value: _selectedPermissionIds
                                              .contains(perm.id),
                                          onChanged: (v) {
                                            setState(() {
                                              if (v == true) {
                                                _selectedPermissionIds
                                                    .add(perm.id);
                                              } else {
                                                _selectedPermissionIds
                                                    .remove(perm.id);
                                              }
                                            });
                                          },
                                          activeColor:
                                              const Color(0xFF1565C0),
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.only(
                                                  left: 24),
                                        )),
                                  ];
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
                      : Text(isEditing ? 'Simpan Perubahan' : 'Buat Role'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
