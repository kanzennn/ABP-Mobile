import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/role_model.dart';
import '../../providers/role_provider.dart';
import 'role_form_screen.dart';

class RoleListScreen extends StatefulWidget {
  const RoleListScreen({super.key});

  @override
  State<RoleListScreen> createState() => _RoleListScreenState();
}

class _RoleListScreenState extends State<RoleListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleProvider>().fetchRoles();
    });
  }

  Future<void> _deleteRole(RoleModel role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Role'),
        content: Text('Yakin ingin menghapus role "${role.name}"?'),
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
          await context.read<RoleProvider>().deleteRole(role.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              success ? 'Role berhasil dihapus' : 'Gagal menghapus role'),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoleProvider>();

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<RoleProvider>().fetchRoles(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.roles.length,
                    separatorBuilder: (_, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final role = provider.roles[i];
                      return _RoleCard(
                        role: role,
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RoleFormScreen(role: role)),
                        ),
                        onDelete: () => _deleteRole(role),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RoleFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Role'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final RoleModel role;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoleCard(
      {required this.role, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.admin_panel_settings,
                      color: Color(0xFF43A047)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                          '${role.permissions.length} permission',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            if (role.permissions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: role.permissions
                    .take(5)
                    .map((p) => Chip(
                          label:
                              Text(p.name, style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          backgroundColor:
                              const Color(0xFF43A047).withValues(alpha: 0.1),
                        ))
                    .toList(),
              ),
              if (role.permissions.length > 5)
                Text('+${role.permissions.length - 5} lainnya',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}
