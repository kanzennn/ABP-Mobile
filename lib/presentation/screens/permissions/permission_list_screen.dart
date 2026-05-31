import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/permission_label_model.dart';
import '../../providers/permission_provider.dart';
import 'permission_form_screen.dart';

class PermissionListScreen extends StatefulWidget {
  const PermissionListScreen({super.key});

  @override
  State<PermissionListScreen> createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionProvider>().fetchAll();
    });
  }

  Future<void> _deleteLabel(PermissionLabelModel label) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Permission'),
        content: Text(
            'Yakin ingin menghapus "${label.name}"?\nSemua permission di dalamnya akan ikut terhapus.'),
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
          await context.read<PermissionProvider>().deleteLabel(label.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'Permission berhasil dihapus'
              : 'Gagal menghapus permission'),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PermissionProvider>();

    // Group labels by permission group name
    final Map<String, List<PermissionLabelModel>> grouped = {};
    for (final label in provider.labels) {
      final groupName = label.permissionGroup?.name ?? 'Lainnya';
      grouped.putIfAbsent(groupName, () => []).add(label);
    }

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<PermissionProvider>().fetchAll(),
                  child: grouped.isEmpty
                      ? const Center(child: Text('Belum ada permission'))
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: grouped.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, top: 16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.folder,
                                          color: Color(0xFFE67C13), size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFFE67C13)),
                                      ),
                                    ],
                                  ),
                                ),
                                ...entry.value.map((label) => Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.security,
                                                    color: Color(0xFFE53935),
                                                    size: 18),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(label.name,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: const Icon(
                                                      Icons.more_vert),
                                                  onSelected: (v) {
                                                    if (v == 'edit') {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                PermissionFormScreen(
                                                                    label:
                                                                        label)),
                                                      );
                                                    }
                                                    if (v == 'delete') {
                                                      _deleteLabel(label);
                                                    }
                                                  },
                                                  itemBuilder: (_) => [
                                                    const PopupMenuItem(
                                                        value: 'edit',
                                                        child: Text('Edit')),
                                                    const PopupMenuItem(
                                                        value: 'delete',
                                                        child: Text('Hapus',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red))),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (label.permissions.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 4,
                                                runSpacing: 2,
                                                children: label.permissions
                                                    .map((p) => Chip(
                                                          label: Text(p.name,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          10)),
                                                          padding:
                                                              EdgeInsets.zero,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          backgroundColor:
                                                              Colors.red.shade50,
                                                        ))
                                                    .toList(),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                            );
                          }).toList(),
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PermissionFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Permission'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }
}
