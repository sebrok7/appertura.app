// admin/lib/screens/users/users_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../utils/theme.dart';
import '../../widgets/admin_widgets.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});
  @override ConsumerState<UsersScreen> createState() => _S();
}

class _S extends ConsumerState<UsersScreen> {
  String _q = '';
  String _roleFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);

    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(title: const Text('Usuarios'), backgroundColor: AC.bg, elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.refresh_rounded, color: AC.text2),
                onPressed: () => ref.invalidate(usersProvider)),
            const SizedBox(width: 8),
            AdminGradientButton(icon: Icons.person_add_rounded, label: 'Nuevo usuario',
                onPressed: () => _addUser(context)),
            const SizedBox(width: 16),
          ]),
      body: Column(children: [
        // Search + filter
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(children: [
            Expanded(child: TextField(
              onChanged: (v) => setState(() => _q = v.toLowerCase()),
              style: const TextStyle(color: AC.text1, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar usuario...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AC.text2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            )),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _roleFilter,
              dropdownColor: AC.surface2,
              style: const TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk', fontSize: 13),
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'all',       child: Text('Todos')),
                DropdownMenuItem(value: 'resident',  child: Text('Residentes')),
                DropdownMenuItem(value: 'admin',     child: Text('Admins')),
                DropdownMenuItem(value: 'guest',     child: Text('Invitados')),
              ],
              onChanged: (v) => setState(() => _roleFilter = v!),
            ),
          ]),
        ),

        // List
        Expanded(child: users.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AC.brand1)),
          error: (e, _) => AdminEmpty(icon: Icons.error_outline, title: 'Error', subtitle: '$e'),
          data: (list) {
            var filtered = list.where((u) {
              final match = _q.isEmpty ||
                  (u['full_name'] ?? '').toString().toLowerCase().contains(_q) ||
                  (u['email'] ?? '').toString().toLowerCase().contains(_q);
              final roleMatch = _roleFilter == 'all' || u['role'] == _roleFilter;
              return match && roleMatch;
            }).toList();

            if (filtered.isEmpty) return const AdminEmpty(icon: Icons.person_off_rounded, title: 'Sin resultados');

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final u = filtered[i];
                final role    = u['role'] ?? 'resident';
                final active  = u['is_active'] ?? true;
                final created = u['created_at'] != null
                    ? DateFormat('d MMM yyyy').format(DateTime.parse(u['created_at']))
                    : '—';

                return AdminCard(
                  child: Row(children: [
                    // Avatar
                    Container(width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: role == 'admin' || role == 'super_admin'
                            ? AC.grad : null,
                        color: role == 'admin' || role == 'super_admin' ? null : AC.surface2,
                        border: Border.all(color: AC.border),
                      ),
                      child: Center(child: Text(
                        _initials(u['full_name'], u['email']),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(u['full_name'] ?? u['email'] ?? '—',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                              color: AC.text1, fontFamily: 'SpaceGrotesk')),
                      Text(u['email'] ?? '',
                          style: const TextStyle(fontSize: 12, color: AC.text3, fontFamily: 'SpaceGrotesk')),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      AStatusChip(
                        label: active ? role : 'suspendido',
                        color: !active ? AC.error : role == 'admin' || role == 'super_admin'
                            ? AC.brand1 : AC.success,
                      ),
                      const SizedBox(height: 4),
                      Text(created, style: const TextStyle(fontSize: 10, color: AC.text3, fontFamily: 'SpaceGrotesk')),
                    ]),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      color: AC.surface2,
                      icon: const Icon(Icons.more_vert_rounded, color: AC.text3, size: 18),
                      onSelected: (a) => _handleAction(context, ref, a, u),
                      itemBuilder: (_) => [
                        if (active)
                          const PopupMenuItem(value: 'suspend',
                              child: Text('Suspender', style: TextStyle(color: AC.error, fontFamily: 'SpaceGrotesk')))
                        else
                          const PopupMenuItem(value: 'reactivate',
                              child: Text('Reactivar', style: TextStyle(color: AC.success, fontFamily: 'SpaceGrotesk'))),
                        PopupMenuItem(value: 'make_admin',
                            child: Text(role == 'admin' ? 'Quitar admin' : 'Hacer admin',
                                style: const TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk'))),
                      ],
                    ),
                  ]),
                );
              },
            );
          },
        )),
      ]),
    );
  }

  Future<void> _handleAction(BuildContext ctx, WidgetRef ref, String action, Map u) async {
    final svc = ref.read(adminServiceProvider);
    try {
      if (action == 'suspend') {
        await svc.suspendUser(u['id'], 'Suspendido por administrador');
      } else if (action == 'reactivate') {
        await svc.reactivateUser(u['id']);
      } else if (action == 'make_admin') {
        final newRole = u['role'] == 'admin' ? 'resident' : 'admin';
        await svc.updateUserRole(u['id'], newRole);
      }
      ref.invalidate(usersProvider);
    } catch (e) {
      if (ctx.mounted) ScaffoldMessenger.of(ctx)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _addUser(BuildContext ctx) async {
    final name  = TextEditingController();
    final email = TextEditingController();
    final pass  = TextEditingController();
    String role = 'resident';

    await showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Nuevo usuario', style: TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk')),
      content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
        AdminField(label: 'Nombre completo', controller: name, prefixIcon: Icons.person_outline),
        const SizedBox(height: 10),
        AdminField(label: 'Email', controller: email, prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 10),
        AdminField(label: 'Contraseña inicial', controller: pass, prefixIcon: Icons.lock_outline, obscure: true),
        const SizedBox(height: 10),
        StatefulBuilder(builder: (_, setState) => DropdownButtonFormField<String>(
          value: role, dropdownColor: AC.surface2,
          decoration: InputDecoration(
            labelText: 'Rol', filled: true, fillColor: AC.surface2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          style: const TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk'),
          items: const [
            DropdownMenuItem(value: 'resident', child: Text('Residente')),
            DropdownMenuItem(value: 'admin',    child: Text('Administrador')),
            DropdownMenuItem(value: 'guest',    child: Text('Invitado')),
          ],
          onChanged: (v) => setState(() => role = v!),
        )),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AC.text2))),
        AdminGradientButton(
          label: 'Crear',
          onPressed: () async {
            if (name.text.isEmpty || email.text.isEmpty || pass.text.isEmpty) return;
            await ref.read(adminServiceProvider).createUser(
                email.text.trim(), pass.text, name.text.trim(), role);
            ref.invalidate(usersProvider);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ],
    ));
  }

  String _initials(String? name, String? email) {
    if (name != null && name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return parts[0][0].toUpperCase();
    }
    return (email ?? 'U')[0].toUpperCase();
  }
}
