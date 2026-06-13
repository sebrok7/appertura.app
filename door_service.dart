// admin/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/theme.dart';
import 'utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://YOUR_REF.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'YOUR_ANON_KEY'),
    debug: false,
  );

  runApp(const ProviderScope(child: ApperturaAdminApp()));
}

class ApperturaAdminApp extends ConsumerWidget {
  const ApperturaAdminApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Appertura Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.dark,
      routerConfig: ref.watch(adminRouterProvider),
    );
  }
}
