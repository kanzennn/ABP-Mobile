import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'dashboard/dashboard_screen.dart';
import 'users/user_list_screen.dart';
import 'roles/role_list_screen.dart';
import 'permissions/permission_list_screen.dart';
import 'permission_groups/permission_group_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const _titles = [
    'Dashboard',
    'Users',
    'Roles',
    'Permissions',
    'Permission Groups',
  ];

  static const _screens = [
    DashboardScreen(),
    UserListScreen(),
    RoleListScreen(),
    PermissionListScreen(),
    PermissionGroupListScreen(),
  ];

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // tutup drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
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
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}
