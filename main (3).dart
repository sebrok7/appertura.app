// admin/lib/utils/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/admin_login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/devices/devices_screen.dart';
import '../screens/logs/logs_screen.dart';
import '../screens/parkings/parkings_screen.dart';

final adminRouterProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/login',
  redirect: (ctx, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isAuth = state.uri.path == '/login';
    if (user == null && !isAuth) return '/login';
    if (user != null && isAuth) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const AdminLoginScreen()),

    ShellRoute(
      builder: (_, __, child) => AdminShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/users',     builder: (_, __) => const UsersScreen()),
        GoRoute(path: '/devices',   builder: (_, __) => const DevicesScreen()),
        GoRoute(path: '/logs',      builder: (_, __) => const LogsScreen()),
        GoRoute(path: '/parkings',  builder: (_, __) => const ParkingsScreen()),
      ],
    ),
  ],
));

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return _DesktopLayout(child: child);
    return _MobileLayout(child: child);
  }
}

class _DesktopLayout extends StatelessWidget {
  final Widget child;
  const _DesktopLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        const _Sidebar(),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(child: child),
      ]),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(child: _Sidebar()),
      body: child,
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  static const _items = [
    (icon: Icons.dashboard_rounded,     label: 'Dashboard',    path: '/dashboard'),
    (icon: Icons.people_alt_rounded,    label: 'Usuarios',     path: '/users'),
    (icon: Icons.bluetooth_rounded,     label: 'Dispositivos', path: '/devices'),
    (icon: Icons.local_parking_rounded, label: 'Parkings',     path: '/parkings'),
    (icon: Icons.receipt_long_rounded,  label: 'Historial',    path: '/logs'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    return Container(
      width: 220,
      color: const Color(0xFF0E1225),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF57F56), Color(0xFFFF2562)]),
              borderRadius: BorderRadius.circular(7),
            ), child: const Icon(Icons.local_parking_rounded, color: Colors.white, size: 15)),
            const SizedBox(width: 8),
            const Text('Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: Colors.white, fontFamily: 'SpaceGrotesk')),
          ]),
        ),
        const SizedBox(height: 32),
        ...(_items.map((item) {
          final selected = loc.startsWith(item.path);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: ListTile(
              onTap: () => context.go(item.path),
              selected: selected,
              selectedTileColor: const Color(0xFFF57F56).withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: Icon(item.icon, size: 20,
                  color: selected ? const Color(0xFFF57F56) : const Color(0xFFA5ACC7)),
              title: Text(item.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  fontFamily: 'SpaceGrotesk',
                  color: selected ? const Color(0xFFF57F56) : const Color(0xFFA5ACC7))),
            ),
          );
        })),
        const Spacer(),
        const Divider(color: Color(0xFF1E2540)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ListTile(
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
            title: const Text('Salir', style: TextStyle(fontSize: 13, color: Color(0xFFEF4444), fontFamily: 'SpaceGrotesk')),
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}
