import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_drawer.dart';
import 'dashboard/dashboard_screen.dart';
import 'users/user_list_screen.dart';
import 'roles/role_list_screen.dart';
import 'permissions/permission_list_screen.dart';
import 'permission_groups/permission_group_list_screen.dart';
import 'profile/profile_screen.dart';

class MenuEntry {
  final String title;
  final IconData icon;
  final Widget screen;
  final String? requiredPermission;

  const MenuEntry({
    required this.title,
    required this.icon,
    required this.screen,
    this.requiredPermission,
  });
}

const allMenuEntries = [
  MenuEntry(
    title: 'Dashboard',
    icon: Icons.dashboard,
    screen: DashboardScreen(),
  ),
  MenuEntry(
    title: 'Users',
    icon: Icons.people,
    screen: UserListScreen(),
    requiredPermission: 'user-view',
  ),
  MenuEntry(
    title: 'Hak Akses',
    icon: Icons.admin_panel_settings,
    screen: RoleListScreen(),
    requiredPermission: 'role-view',
  ),
  MenuEntry(
    title: 'Permissions',
    icon: Icons.security,
    screen: PermissionListScreen(),
    requiredPermission: 'permission-view',
  ),
  MenuEntry(
    title: 'Permission Groups',
    icon: Icons.folder_special,
    screen: PermissionGroupListScreen(),
    requiredPermission: 'permissiongroup-view',
  ),
  MenuEntry(
    title: 'Profil Saya',
    icon: Icons.person_outline,
    screen: ProfileScreen(),
  ),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleProvider>().fetchRoles();
    });
  }

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final visibleEntries = allMenuEntries.where((m) {
      if (m.requiredPermission == null) return true;
      return auth.hasPermission(m.requiredPermission!);
    }).toList();

    // Clamp selectedIndex kalau menu berubah
    final safeIndex =
        _selectedIndex.clamp(0, visibleEntries.length - 1).toInt();
    if (safeIndex != _selectedIndex) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => _selectedIndex = safeIndex));
    }

    final currentEntry = visibleEntries[safeIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentEntry.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ),
        ],
      ),
      drawer: AppDrawer(
        entries: visibleEntries,
        selectedIndex: safeIndex,
        onItemSelected: _onItemSelected,
      ),
      body: IndexedStack(
        index: safeIndex,
        children: visibleEntries.map((e) => e.screen).toList(),
      ),
    );
  }
}
