import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/storage/secure_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/role_repository.dart';
import 'data/repositories/permission_repository.dart';
import 'data/repositories/permission_group_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/role_provider.dart';
import 'presentation/providers/permission_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_screen.dart';

void main() {
  runApp(const MsmeApp());
}

class MsmeApp extends StatelessWidget {
  const MsmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureStorage();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(storage), storage),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(UserRepository(storage)),
        ),
        ChangeNotifierProvider(
          create: (_) => RoleProvider(RoleRepository(storage)),
        ),
        ChangeNotifierProvider(
          create: (_) => PermissionProvider(
            PermissionRepository(storage),
            PermissionGroupRepository(storage),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'MSME Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const _AuthWrapper(),
      ),
    );
  }
}

class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat...'),
                  ],
                ),
              ),
            );
          case AuthStatus.authenticated:
            return const MainScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}
