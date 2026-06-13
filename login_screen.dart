// admin/lib/screens/auth/admin_login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/admin_service.dart';
import '../../utils/theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});
  @override ConsumerState<AdminLoginScreen> createState() => _S();
}

class _S extends ConsumerState<AdminLoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false, _obscure = true;
  String? _error;

  @override void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final svc = ref.read(adminServiceProvider);
      await svc.signIn(_email.text.trim(), _pass.text);
      final ok = await svc.isAdmin();
      if (!ok) {
        await svc.signOut();
        throw Exception('No tienes permisos de administrador');
      }
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() {
        _error = e.toString().contains('Invalid') ? 'Email o contraseña incorrectos'
            : e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AC.bg,
    body: Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AC.surface, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AC.border),
          boxShadow: [BoxShadow(color: AC.glow1.withOpacity(0.15), blurRadius: 60, spreadRadius: 10)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(
              gradient: AC.grad, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.local_parking_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            const Text('Appertura Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: AC.text1, fontFamily: 'SpaceGrotesk')),
          ]),
          const SizedBox(height: 32),
          const Text('Acceso administrador', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
              color: AC.text1, fontFamily: 'SpaceGrotesk')),
          const SizedBox(height: 24),

          AdminField(label: 'Email', controller: _email,
              prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          TextField(
            controller: _pass, obscureText: _obscure,
            style: const TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk', fontSize: 14),
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AC.text2),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18, color: AC.text2),
                onPressed: () => setState(() => _obscure = !_obscure)),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AC.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8), border: Border.all(color: AC.error.withOpacity(0.35))),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AC.error, size: 15),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: AC.error, fontSize: 13))),
              ])),
          ],
          const SizedBox(height: 20),

          SizedBox(width: double.infinity,
              child: AdminGradientButton(label: 'Entrar', loading: _loading, onPressed: _login)),
        ]),
      ),
    ),
  );
}
