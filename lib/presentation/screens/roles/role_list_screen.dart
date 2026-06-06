import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/role_model.dart';
import '../../providers/role_provider.dart';
import '../../providers/user_provider.dart';
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
      context.read<UserProvider>().fetchUsers();
    });
  }

  Future<void> _deleteRole(RoleModel role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Hak Akses'),
        content: Text('Yakin ingin menghapus "${role.name}"?'),
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
      final provider = context.read<RoleProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final success = await provider.deleteRole(role.id);
      messenger.showSnackBar(SnackBar(
        content: Text(success
            ? 'Hak akses berhasil dihapus'
            : 'Gagal menghapus hak akses'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoleProvider>();
    final users = context.watch<UserProvider>().users;

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : RefreshIndicator(
                  onRefresh: () => context.read<RoleProvider>().fetchRoles(),
                  child: provider.roles.isEmpty
                      ? const Center(child: Text('Belum ada hak akses'))
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(12, 12, 12, 80),
                          itemCount: provider.roles.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final role = provider.roles[i];
                            final memberCount = users
                                .where((u) =>
                                    u.roles.any((r) => r.id == role.id))
                                .length;
                            return _RoleCard(
                              role: role,
                              memberCount: memberCount,
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        RoleFormScreen(role: role)),
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
        label: const Text('Tambah Hak Akses'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final RoleModel role;
  final int memberCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoleCard({
    required this.role,
    required this.memberCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings,
                  color: Color(0xFF43A047), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Badge(
                        label: '${role.permissions.length} permission',
                        color: const Color(0xFF43A047),
                      ),
                      const SizedBox(width: 6),
                      _Badge(
                        label: '$memberCount anggota',
                        color: const Color(0xFF1E88E5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionBtn(
                    icon: Icons.edit_outlined,
                    color: Colors.orange,
                    tooltip: 'Edit',
                    onTap: onEdit),
                _ActionBtn(
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    tooltip: 'Hapus',
                    onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn(
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
