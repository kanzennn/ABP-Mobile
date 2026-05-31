import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/permission_label_model.dart';
import '../../providers/permission_provider.dart';

class _PermEntry {
  int? id;
  final TextEditingController ctrl;
  _PermEntry({this.id}) : ctrl = TextEditingController();
}

class PermissionFormScreen extends StatefulWidget {
  final PermissionLabelModel? label;
  const PermissionFormScreen({super.key, this.label});

  @override
  State<PermissionFormScreen> createState() => _PermissionFormScreenState();
}

class _PermissionFormScreenState extends State<PermissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelNameCtrl = TextEditingController();
  int? _selectedGroupId;
  List<_PermEntry> _entries = [_PermEntry()];
  bool _isLoading = false;

  bool get isEditing => widget.label != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _labelNameCtrl.text = widget.label!.name;
      _selectedGroupId = widget.label!.permissionGroupId;
      _entries = widget.label!.permissions
          .map((p) => _PermEntry(id: p.id)..ctrl.text = p.name)
          .toList();
      if (_entries.isEmpty) _entries = [_PermEntry()];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionProvider>().fetchGroups();
    });
  }

  @override
  void dispose() {
    _labelNameCtrl.dispose();
    for (final e in _entries) {
      e.ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih permission group terlebih dahulu')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final perms = _entries
        .where((e) => e.ctrl.text.trim().isNotEmpty)
        .map((e) {
          final m = <String, dynamic>{'name': e.ctrl.text.trim()};
          if (e.id != null) m['id'] = e.id;
          return m;
        })
        .toList();

    final data = {
      'label_name': _labelNameCtrl.text.trim(),
      'permission_group_id': _selectedGroupId,
      'permission': perms,
    };

    bool success;
    if (isEditing) {
      success = await context
          .read<PermissionProvider>()
          .updateLabel(widget.label!.id, data);
    } else {
      success =
          await context.read<PermissionProvider>().createLabel(data);
    }

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Permission berhasil ${isEditing ? 'diperbarui' : 'dibuat'}'
            : 'Gagal menyimpan permission'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<PermissionProvider>().groups;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Permission' : 'Tambah Permission'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Label Permission',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _labelNameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nama Label',
                          prefixIcon: const Icon(Icons.label_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v?.isEmpty == true
                            ? 'Nama label wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedGroupId,
                        decoration: InputDecoration(
                          labelText: 'Permission Group',
                          prefixIcon: const Icon(Icons.folder_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: groups
                            .map((g) => DropdownMenuItem(
                                  value: g.id,
                                  child: Text(g.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedGroupId = v),
                        validator: (v) =>
                            v == null ? 'Pilih group' : null,
                      ),
                    ],
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
                          const Text('Daftar Permission',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          TextButton.icon(
                            onPressed: () => setState(
                                () => _entries.add(_PermEntry())),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Tambah'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._entries.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final perm = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: perm.ctrl,
                                  decoration: InputDecoration(
                                    labelText: 'Nama permission ${idx + 1}',
                                    hintText: 'contoh: user-create',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ),
                              if (_entries.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () => setState(
                                      () => _entries.removeAt(idx)),
                                ),
                            ],
                          ),
                        );
                      }),
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
                      : Text(isEditing
                          ? 'Simpan Perubahan'
                          : 'Buat Permission'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
