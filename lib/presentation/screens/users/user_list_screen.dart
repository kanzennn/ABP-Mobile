import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/role_provider.dart';
import '../../../data/models/user_model.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int? _selectedRoleId;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
      context.read<RoleProvider>().fetchRoles();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<UserModel> _filtered(List<UserModel> users) {
    return users.where((u) {
      final matchQuery = _query.isEmpty ||
          u.name.toLowerCase().contains(_query.toLowerCase()) ||
          u.email.toLowerCase().contains(_query.toLowerCase());
      final matchRole = _selectedRoleId == null ||
          u.roles.any((r) => r.id == _selectedRoleId);
      final matchStatus = _selectedStatus == 'all' ||
          (_selectedStatus == 'active' && u.isActive) ||
          (_selectedStatus == 'inactive' && !u.isActive);
      return matchQuery && matchRole && matchStatus;
    }).toList();
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus "${user.name}"?'),
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
      final provider = context.read<UserProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final success = await provider.deleteUser(user.id);
      messenger.showSnackBar(SnackBar(
        content:
            Text(success ? 'User berhasil dihapus' : 'Gagal menghapus user'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  void _viewUser(UserModel user) {
    final isActive = user.isActive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1565C0),
              radius: 20,
              child: Text(user.name[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(user.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Email', value: user.email),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Status',
              value: isActive ? 'Aktif' : 'Tidak Aktif',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Role',
              value: user.roles.isNotEmpty
                  ? user.roles.map((r) => r.name).join(', ')
                  : 'Tidak ada role',
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
    final provider = context.watch<UserProvider>();
    final roles = context.watch<RoleProvider>().roles;
    final filtered = _filtered(provider.users);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            })
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _selectedRoleId,
                        decoration: InputDecoration(
                          labelText: 'Filter Role',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Semua Role')),
                          ...roles.map((r) => DropdownMenuItem(
                                value: r.id,
                                child: Text(r.name,
                                    overflow: TextOverflow.ellipsis),
                              )),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedRoleId = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('Semua')),
                          DropdownMenuItem(
                              value: 'active', child: Text('Aktif')),
                          DropdownMenuItem(
                              value: 'inactive',
                              child: Text('Tidak Aktif')),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedStatus = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 8),
                            Text(provider.error!),
                            TextButton(
                                onPressed: () =>
                                    context.read<UserProvider>().fetchUsers(),
                                child: const Text('Coba Lagi')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<UserProvider>().fetchUsers(),
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text('Tidak ada user ditemukan'))
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, i) {
                                  final user = filtered[i];
                                  final isActive = user.isActive;
                                  return _UserCard(
                                    user: user,
                                    isActive: isActive,
                                    onView: () => _viewUser(user),
                                    onEdit: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              UserFormScreen(user: user)),
                                    ),
                                    onDelete: () => _deleteUser(user),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah User'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isActive;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.isActive,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF1565C0),
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (user.roles.isNotEmpty)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.roles.map((r) => r.name).join(', '),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: isActive
                                  ? Colors.green.shade300
                                  : Colors.red.shade300),
                        ),
                        child: Text(
                          isActive ? 'Aktif' : 'Tidak Aktif',
                          style: TextStyle(
                              fontSize: 11,
                              color: isActive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionBtn(
                        icon: Icons.visibility_outlined,
                        color: Colors.blue,
                        tooltip: 'Lihat',
                        onTap: onView),
                    _ActionBtn(
                        icon: Icons.edit_outlined,
                        color: Colors.orange,
                        tooltip: 'Edit',
                        onTap: onEdit),
                  ],
                ),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ),
        const Text(': ', style: TextStyle(color: Colors.grey)),
        Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }
}
