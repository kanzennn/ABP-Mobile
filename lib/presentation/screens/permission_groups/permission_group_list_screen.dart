import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/permission_group_model.dart';
import '../../providers/permission_provider.dart';

class PermissionGroupListScreen extends StatefulWidget {
  const PermissionGroupListScreen({super.key});

  @override
  State<PermissionGroupListScreen> createState() =>
      _PermissionGroupListScreenState();
}

class _PermissionGroupListScreenState
    extends State<PermissionGroupListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionProvider>().fetchGroups();
    });
  }

  Future<void> _showGroupDialog({PermissionGroupModel? group}) async {
    final ctrl = TextEditingController(text: group?.name ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(group == null ? 'Tambah Group' : 'Edit Group'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Nama Group',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v?.isEmpty == true ? 'Nama group wajib diisi' : null,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);

              bool success;
              if (group == null) {
                success = await context
                    .read<PermissionProvider>()
                    .createGroup(ctrl.text.trim());
              } else {
                success = await context
                    .read<PermissionProvider>()
                    .updateGroup(group.id, ctrl.text.trim());
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? 'Group berhasil ${group == null ? 'dibuat' : 'diperbarui'}'
                      : 'Gagal menyimpan group'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGroup(PermissionGroupModel group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Group'),
        content: Text('Yakin ingin menghapus group "${group.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final success =
          await context.read<PermissionProvider>().deleteGroup(group.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'Group berhasil dihapus'
              : 'Gagal menghapus group'),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PermissionProvider>();

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<PermissionProvider>().fetchGroups(),
              child: provider.groups.isEmpty
                  ? const Center(child: Text('Belum ada permission group'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.groups.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final group = provider.groups[i];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE67C13)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.folder_special,
                                  color: Color(0xFFE67C13)),
                            ),
                            title: Text(group.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'edit') {
                                  _showGroupDialog(group: group);
                                }
                                if (v == 'delete') _deleteGroup(group);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Hapus',
                                        style:
                                            TextStyle(color: Colors.red))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGroupDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Group'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }
}
