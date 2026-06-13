// admin/lib/screens/logs/logs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../utils/theme.dart';
import '../../widgets/admin_widgets.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});
  @override ConsumerState<LogsScreen> createState() => _S();
}

class _S extends ConsumerState<LogsScreen> {
  String _q = '';
  String _resultFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(logsProvider);

    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(title: const Text('Historial global'), backgroundColor: AC.bg, elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.refresh_rounded, color: AC.text2),
                onPressed: () => ref.invalidate(logsProvider)),
            const SizedBox(width: 16),
          ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(children: [
            Expanded(child: TextField(
              onChanged: (v) => setState(() => _q = v.toLowerCase()),
              style: const TextStyle(color: AC.text1, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Buscar usuario o ubicación...',
                prefixIcon: Icon(Icons.search_rounded, size: 18, color: AC.text2),
              ),
            )),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _resultFilter, dropdownColor: AC.surface2,
              style: const TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk', fontSize: 13),
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'all',     child: Text('Todos')),
                DropdownMenuItem(value: 'success', child: Text('Éxito')),
                DropdownMenuItem(value: 'denied',  child: Text('Denegado')),
                DropdownMenuItem(value: 'error',   child: Text('Error')),
              ],
              onChanged: (v) => setState(() => _resultFilter = v!),
            ),
          ]),
        ),
        Expanded(child: logs.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AC.brand1)),
          error: (e, _) => AdminEmpty(icon: Icons.error_outline, title: 'Error', subtitle: '$e'),
          data: (list) {
            final filtered = list.where((l) {
              final match = _q.isEmpty ||
                  (l['user_name'] ?? '').toString().toLowerCase().contains(_q) ||
                  (l['user_email'] ?? '').toString().toLowerCase().contains(_q) ||
                  (l['space_number'] ?? '').toString().toLowerCase().contains(_q) ||
                  (l['parking_name'] ?? '').toString().toLowerCase().contains(_q);
              final res = _resultFilter == 'all' || l['result'] == _resultFilter;
              return match && res;
            }).toList();

            if (filtered.isEmpty) return const AdminEmpty(
                icon: Icons.receipt_long_outlined, title: 'Sin registros');

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final l  = filtered[i];
                final ok = l['result'] == 'success';
                final ts = l['created_at'] != null
                    ? DateFormat('d MMM yyyy · HH:mm', 'es')
                        .format(DateTime.parse(l['created_at']).toLocal())
                    : '—';
                final location = l['space_label'] ?? (l['space_number'] != null
                    ? 'Plaza ${l['space_number']}' : l['parking_name'] ?? '—');

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AC.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AC.border),
                  ),
                  child: Row(children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ok ? AC.success : l['result'] == 'denied' ? AC.warning : AC.error)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l['user_name'] ?? l['user_email'] ?? '—',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                              color: AC.text1, fontFamily: 'SpaceGrotesk')),
                      Row(children: [
                        Text(location, style: const TextStyle(fontSize: 11, color: AC.text3, fontFamily: 'SpaceGrotesk')),
                        if (l['ble_rssi'] != null) ...[
                          const Text('  ·  ', style: TextStyle(color: AC.text3)),
                          Text('${l['ble_rssi']} dBm',
                              style: const TextStyle(fontSize: 11, color: AC.text3, fontFamily: 'SpaceGrotesk')),
                        ],
                      ]),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(ts, style: const TextStyle(fontSize: 11, color: AC.text2, fontFamily: 'SpaceGrotesk')),
                      const SizedBox(height: 2),
                      AStatusChip(
                        label: ok ? 'OK' : l['result'] == 'denied' ? 'Denegado' : 'Error',
                        color: ok ? AC.success : l['result'] == 'denied' ? AC.warning : AC.error,
                      ),
                    ]),
                  ]),
                );
              },
            );
          },
        )),
      ]),
    );
  }
}
