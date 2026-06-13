// admin/lib/screens/devices/devices_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../utils/theme.dart';
import '../../widgets/admin_widgets.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});
  @override ConsumerState<DevicesScreen> createState() => _S();
}

class _S extends ConsumerState<DevicesScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(title: const Text('Dispositivos'), backgroundColor: AC.bg, elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.refresh_rounded, color: AC.text2),
                onPressed: () => ref.invalidate(devicesProvider)),
            const SizedBox(width: 8),
            AdminGradientButton(icon: Icons.add_circle_rounded, label: 'Nuevo dispositivo',
                onPressed: () => _addDevice(context)),
            const SizedBox(width: 16),
          ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: TextField(
            onChanged: (v) => setState(() => _q = v.toLowerCase()),
            style: const TextStyle(color: AC.text1, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Buscar por Device ID o nombre BLE...',
              prefixIcon: Icon(Icons.search_rounded, size: 18, color: AC.text2),
            ),
          ),
        ),
        Expanded(child: devices.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AC.brand1)),
          error: (e, _) => AdminEmpty(icon: Icons.error_outline, title: 'Error', subtitle: '$e'),
          data: (list) {
            final filtered = _q.isEmpty ? list : list.where((d) =>
                (d['device_id'] ?? '').toString().toLowerCase().contains(_q) ||
                (d['ble_name'] ?? '').toString().toLowerCase().contains(_q)).toList();

            if (filtered.isEmpty) return const AdminEmpty(
                icon: Icons.device_hub_outlined, title: 'Sin dispositivos',
                subtitle: 'Añade el primer dispositivo Aparkao');

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d      = filtered[i];
                final active = d['is_active'] ?? true;
                final space  = d['parking_spaces'];
                final parking = space?['parkings'];
                final lastSeen = d['last_seen_at'] != null
                    ? DateFormat('d MMM HH:mm').format(DateTime.parse(d['last_seen_at']).toLocal())
                    : null;

                return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: active ? AC.brand1.withOpacity(0.12) : AC.surface2,
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.bluetooth_rounded, color: active ? AC.brand1 : AC.text3, size: 22)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d['ble_name'] ?? 'APARKAO_${d['device_id']}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                              color: AC.text1, fontFamily: 'SpaceGrotesk')),
                      Text('ID: ${d['device_id']}',
                          style: const TextStyle(fontSize: 12, color: AC.text3, fontFamily: 'SpaceGrotesk')),
                    ])),
                    AStatusChip(label: active ? 'Activo' : 'Baja',
                        color: active ? AC.success : AC.text3),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      color: AC.surface2,
                      icon: const Icon(Icons.more_vert_rounded, color: AC.text3, size: 18),
                      onSelected: (a) => _handleAction(context, a, d),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'perms',
                            child: Text('Gestionar permisos', style: TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk'))),
                        const PopupMenuItem(value: 'deactivate',
                            child: Text('Dar de baja', style: TextStyle(color: AC.error, fontFamily: 'SpaceGrotesk'))),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AC.border),
                  const SizedBox(height: 8),
                  Wrap(spacing: 16, children: [
                    if (space != null)
                      _Tag(Icons.local_parking_rounded, 'Plaza ${space['number'] ?? '—'}'),
                    if (parking != null)
                      _Tag(Icons.directions_car_rounded, parking['name'] ?? '—'),
                    _Tag(Icons.timer_rounded, '${d['relay_pulse_ms'] ?? 500} ms'),
                    if (lastSeen != null)
                      _Tag(Icons.access_time_rounded, lastSeen),
                  ]),
                ]));
              },
            );
          },
        )),
      ]),
    );
  }

  Future<void> _handleAction(BuildContext ctx, String action, Map d) async {
    final svc = ref.read(adminServiceProvider);
    if (action == 'deactivate') {
      await svc.deactivateDevice(d['id']);
      ref.invalidate(devicesProvider);
    } else if (action == 'perms') {
      await _managePerms(ctx, d);
    }
  }

  Future<void> _managePerms(BuildContext ctx, Map device) async {
    final perms = await ref.read(adminServiceProvider).getDevicePermissions(device['id']);
    final emailCtrl = TextEditingController();

    if (!ctx.mounted) return;
    await showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Permisos: ${device['ble_name'] ?? device['device_id']}',
          style: const TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk')),
      content: SizedBox(width: 480, child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (perms.isNotEmpty) ...[
          ...perms.map((p) {
            final profile = p['profiles'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AdminCard(child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile?['full_name'] ?? '—', style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: AC.text1)),
                  Text(profile?['email'] ?? '', style: const TextStyle(fontSize: 11, color: AC.text3)),
                ])),
                AStatusChip(label: p['permission_type'] ?? 'permanent', color: AC.success),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: AC.error, size: 18),
                  onPressed: () async {
                    await ref.read(adminServiceProvider)
                        .revokePermission(p['user_id'], device['id']);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ])),
            );
          }),
          const Divider(color: AC.border),
        ],
        AdminField(label: 'Email del usuario', controller: emailCtrl,
            prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 8),
        AdminGradientButton(
          label: 'Conceder acceso permanente',
          onPressed: () async {
            if (emailCtrl.text.isEmpty) return;
            final users = await Supabase.instance.client.from('profiles')
                .select('id, email').eq('email', emailCtrl.text.trim()).maybeSingle();
            if (users == null) {
              if (ctx.mounted) ScaffoldMessenger.of(ctx)
                  .showSnackBar(const SnackBar(content: Text('Usuario no encontrado')));
              return;
            }
            await ref.read(adminServiceProvider).grantPermission(
                userId: users['id'], deviceId: device['id']);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar', style: TextStyle(color: AC.text2))),
      ],
    ));
  }

  Future<void> _addDevice(BuildContext ctx) async {
    final deviceId  = TextEditingController();
    final bleName   = TextEditingController();
    final relayCtrl = TextEditingController(text: '500');

    await showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Nuevo dispositivo', style: TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk')),
      content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
        AdminField(label: 'Device ID *', controller: deviceId,
            prefixIcon: Icons.fingerprint_rounded, hint: 'ID grabado en el firmware'),
        const SizedBox(height: 10),
        AdminField(label: 'Nombre BLE', controller: bleName,
            prefixIcon: Icons.bluetooth_rounded, hint: 'APARKAO_XXXX (auto si vacío)'),
        const SizedBox(height: 10),
        AdminField(label: 'Pulso relé (ms)', controller: relayCtrl,
            prefixIcon: Icons.timer_rounded, keyboardType: TextInputType.number),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AC.text2))),
        AdminGradientButton(
          label: 'Añadir',
          onPressed: () async {
            if (deviceId.text.isEmpty) return;
            await ref.read(adminServiceProvider).createDevice(
              deviceId: deviceId.text.trim(),
              bleName: bleName.text.isNotEmpty ? bleName.text.trim() : null,
              relayMs: int.tryParse(relayCtrl.text) ?? 500,
            );
            ref.invalidate(devicesProvider);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ],
    ));
  }
}

class _Tag extends StatelessWidget {
  final IconData icon; final String text;
  const _Tag(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: AC.text3),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 11, color: AC.text3, fontFamily: 'SpaceGrotesk')),
  ]);
}

