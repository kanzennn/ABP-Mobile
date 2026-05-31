import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              ),
            ),
            accountName: Text(user?.name ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.name.isNotEmpty == true)
                    ? user!.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          _DrawerItem(
            icon: Icons.people,
            title: 'Users',
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          _DrawerItem(
            icon: Icons.admin_panel_settings,
            title: 'Roles',
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
          _DrawerItem(
            icon: Icons.security,
            title: 'Permissions',
            isSelected: selectedIndex == 3,
            onTap: () => onItemSelected(3),
          ),
          _DrawerItem(
            icon: Icons.folder_special,
            title: 'Permission Groups',
            isSelected: selectedIndex == 4,
            onTap: () => onItemSelected(4),
          ),
          const Divider(),
          const Spacer(),
          _DrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            isSelected: false,
            iconColor: Colors.red,
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: isSelected
              ? const Color(0xFF1565C0)
              : (iconColor ?? Colors.grey.shade700)),
      title: Text(title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1565C0) : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          )),
      selected: isSelected,
      selectedTileColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
