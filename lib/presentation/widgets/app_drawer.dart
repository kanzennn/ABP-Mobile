import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/main_screen.dart';

class AppDrawer extends StatelessWidget {
  final List<MenuEntry> entries;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    required this.entries,
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...entries
                    .where((e) => e.title != 'Profil Saya')
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) => _DrawerItem(
                          icon: entry.value.icon,
                          title: entry.value.title,
                          isSelected: selectedIndex == entry.key,
                          onTap: () => onItemSelected(entry.key),
                        )),
                const Divider(),
                Builder(builder: (ctx) {
                  final profileIdx =
                      entries.indexWhere((e) => e.title == 'Profil Saya');
                  return _DrawerItem(
                    icon: Icons.person_outline,
                    title: 'Profil Saya',
                    isSelected: profileIdx != -1 && selectedIndex == profileIdx,
                    onTap: () =>
                        profileIdx != -1 ? onItemSelected(profileIdx) : null,
                  );
                }),
              ],
            ),
          ),
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
  final VoidCallback? onTap;
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
