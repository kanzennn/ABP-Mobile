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
      context.read<PermissionProvider>().fetchAll();
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
      final provider = context.read<PermissionProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final success = await provider.deleteGroup(group.id);
      messenger.showSnackBar(SnackBar(
        content: Text(success
            ? 'Group berhasil dihapus'
            : 'Gagal menghapus group'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
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
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                      itemCount: provider.groups.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final group = provider.groups[i];
                        // Hitung jumlah label (bukan individual permission)
                        final totalLabels = provider.labels
                            .where((l) => l.permissionGroupId == group.id)
                            .length;
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE67C13)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.folder_special,
                                      color: Color(0xFFE67C13), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(group.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE67C13)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '$totalLabels permission',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFFE67C13),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _AksiButton(
                                  icon: Icons.edit_outlined,
                                  color: Colors.orange,
                                  tooltip: 'Edit',
                                  onTap: () => _showGroupDialog(group: group),
                                ),
                                _AksiButton(
                                  icon: Icons.delete_outline,
                                  color: Colors.red,
                                  tooltip: 'Hapus',
                                  onTap: () => _deleteGroup(group),
                                ),
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

class _AksiButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _AksiButton(
      {required this.icon,
      required this.color,
      required this.tooltip,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
