import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/permission_label_model.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/permission_provider.dart';
import '../../providers/role_provider.dart';
import '../../providers/user_provider.dart';
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
      context.read<RoleProvider>().fetchRoles();
      context.read<UserProvider>().fetchUsers();
    });
  }

  bool _hasAction(PermissionLabelModel label, String action) {
    return label.permissions
        .any((p) => p.name.toLowerCase().split('-').last == action);
  }

  int _totalUsers(PermissionLabelModel label, List<RoleModel> roles,
      List<UserModel> users) {
    final permIds = label.permissions.map((p) => p.id).toSet();
    final roleIds = roles
        .where((r) => r.permissions.any((p) => permIds.contains(p.id)))
        .map((r) => r.id)
        .toSet();
    return users.where((u) => u.roles.any((r) => roleIds.contains(r.id))).length;
  }

  String _formatDate(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
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
      final provider = context.read<PermissionProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final success = await provider.deleteLabel(label.id);
      messenger.showSnackBar(SnackBar(
        content: Text(success
            ? 'Permission berhasil dihapus'
            : 'Gagal menghapus permission'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  void _viewLabel(PermissionLabelModel label, int totalUsers) {
    final actions = [
      ('Create', _hasAction(label, 'create')),
      ('Delete', _hasAction(label, 'delete')),
      ('Edit', _hasAction(label, 'update')),
      ('View', _hasAction(label, 'view')),
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF1565C0), size: 20),
            const SizedBox(width: 8),
            Expanded(
                child:
                    Text(label.name, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogRow(
              icon: Icons.folder_outlined,
              label: 'Grup',
              value: label.permissionGroup?.name ?? '-',
            ),
            const SizedBox(height: 8),
            _DialogRow(
              icon: Icons.people_outline,
              label: 'Total Pengguna',
              value: '$totalUsers pengguna',
            ),
            const SizedBox(height: 8),
            _DialogRow(
              icon: Icons.calendar_today_outlined,
              label: 'Dibuat Pada',
              value: _formatDate(label.createdAt),
            ),
            const SizedBox(height: 8),
            _DialogRow(
              icon: Icons.update,
              label: 'Terakhir Diubah',
              value: _formatDate(label.updatedAt),
            ),
            const SizedBox(height: 12),
            const Text('Aksi Tersedia',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: actions
                  .where((a) => a.$2)
                  .map((a) => _ActionBadge(label: a.$1))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PermissionProvider>();
    final roles = context.watch<RoleProvider>().roles;
    final users = context.watch<UserProvider>().users;

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<PermissionProvider>().fetchAll(),
                  child: provider.labels.isEmpty
                      ? const Center(child: Text('Belum ada permission'))
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(12, 12, 12, 80),
                          itemCount: provider.labels.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final label = provider.labels[i];
                            final total =
                                _totalUsers(label, roles, users);
                            return _PermissionCard(
                              label: label,
                              totalUsers: total,
                              hasCreate: _hasAction(label, 'create'),
                              hasDelete: _hasAction(label, 'delete'),
                              hasEdit: _hasAction(label, 'update'),
                              hasView: _hasAction(label, 'view'),
                              createdAt: _formatDate(label.createdAt),
                              updatedAt: _formatDate(label.updatedAt),
                              onView: () => _viewLabel(label, total),
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        PermissionFormScreen(label: label)),
                              ),
                              onDelete: () => _deleteLabel(label),
                            );
                          },
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

class _PermissionCard extends StatelessWidget {
  final PermissionLabelModel label;
  final int totalUsers;
  final bool hasCreate;
  final bool hasDelete;
  final bool hasEdit;
  final bool hasView;
  final String createdAt;
  final String updatedAt;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PermissionCard({
    required this.label,
    required this.totalUsers,
    required this.hasCreate,
    required this.hasDelete,
    required this.hasEdit,
    required this.hasView,
    required this.createdAt,
    required this.updatedAt,
    required this.onView,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      if (label.permissionGroup != null)
                        Text(label.permissionGroup!.name,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                _AksiButton(
                    icon: Icons.visibility_outlined,
                    color: Colors.blue,
                    tooltip: 'Lihat',
                    onTap: onView),
                _AksiButton(
                    icon: Icons.edit_outlined,
                    color: Colors.orange,
                    tooltip: 'Edit',
                    onTap: onEdit),
                _AksiButton(
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    tooltip: 'Hapus',
                    onTap: onDelete),
              ],
            ),
            const SizedBox(height: 8),
            // Aksi badges
            Row(
              children: [
                Text('Aksi: ',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600)),
                if (hasCreate) ...[
                  const _ActionBadge(label: 'Create'),
                  const SizedBox(width: 4),
                ],
                if (hasDelete) ...[
                  const _ActionBadge(label: 'Delete'),
                  const SizedBox(width: 4),
                ],
                if (hasEdit) ...[
                  const _ActionBadge(label: 'Edit'),
                  const SizedBox(width: 4),
                ],
                if (hasView) const _ActionBadge(label: 'View'),
              ],
            ),
            const SizedBox(height: 6),
            // Info row
            Row(
              children: [
                const Icon(Icons.people_outline,
                    size: 13, color: Color(0xFF1565C0)),
                const SizedBox(width: 4),
                Text('$totalUsers pengguna',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today_outlined,
                    size: 11, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(createdAt,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(width: 12),
                Icon(Icons.update, size: 11, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(updatedAt,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final String label;
  const _ActionBadge({required this.label});

  static const _colors = {
    'Create': Color(0xFF2E7D32),
    'Delete': Color(0xFFC62828),
    'Edit': Color(0xFFE65100),
    'View': Color(0xFF1565C0),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[label] ?? const Color(0xFF1565C0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _DialogRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DialogRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        SizedBox(
          width: 110,
          child: Text(label,
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ],
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
