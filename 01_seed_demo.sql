// admin/lib/widgets/admin_widgets.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

// ── Gradient button ───────────────────────────────────────────
class AdminGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const AdminGradientButton({super.key, required this.label, this.onPressed,
      this.loading = false, this.icon});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed != null ? AC.grad
            : const LinearGradient(colors: [Color(0xFF1C2340), Color(0xFF1C2340)]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: onPressed != null
            ? [BoxShadow(color: AC.glow1, blurRadius: 12, offset: const Offset(0, 3))]
            : [],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          foregroundColor: Colors.white, minimumSize: const Size(120, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: loading
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
      ),
    ),
  );
}

// ── Card ──────────────────────────────────────────────────────
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const AdminCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AC.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AC.border),
    ),
    padding: padding ?? const EdgeInsets.all(16),
    child: child,
  );
}

// ── Stat card ─────────────────────────────────────────────────
class AdminStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const AdminStatCard({super.key, required this.value, required this.label,
      required this.icon, this.color = AC.brand1});

  @override
  Widget build(BuildContext context) => AdminCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
        Container(width: 7, height: 7, decoration: BoxDecoration(
          shape: BoxShape.circle, color: color)),
      ]),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
          color: AC.text1, height: 1, fontFamily: 'SpaceGrotesk')),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 12, color: AC.text3, fontFamily: 'SpaceGrotesk')),
    ]),
  );
}

// ── Status chip ───────────────────────────────────────────────
class AStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const AStatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 10,
        fontWeight: FontWeight.w700, letterSpacing: 0.5, fontFamily: 'SpaceGrotesk')),
  );
}

// ── Field ─────────────────────────────────────────────────────
class AdminField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? hint;
  final IconData? prefixIcon;
  final int? maxLines;

  const AdminField({super.key, required this.label, required this.controller,
      this.obscure = false, this.keyboardType = TextInputType.text,
      this.hint, this.prefixIcon, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: const TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk', fontSize: 14),
    decoration: InputDecoration(
      labelText: label, hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: AC.text2) : null,
    ),
  );
}

// ── Page header ───────────────────────────────────────────────
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const PageHeader({super.key, required this.title, this.subtitle, this.actions});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
            color: AC.text1, fontFamily: 'SpaceGrotesk')),
        if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 13, color: AC.text2)),
      ])),
      if (actions != null) ...actions!,
    ]),
  );
}

// ── Empty ─────────────────────────────────────────────────────
class AdminEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const AdminEmpty({super.key, required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(
          color: AC.surface2, borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: AC.text3, size: 28)),
      const SizedBox(height: 16),
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
          color: AC.text1, fontFamily: 'SpaceGrotesk')),
      if (subtitle != null) ...[
        const SizedBox(height: 6),
        Text(subtitle!, style: const TextStyle(fontSize: 13, color: AC.text2), textAlign: TextAlign.center),
      ],
      if (action != null) ...[const SizedBox(height: 16), action!],
    ]),
  );
}

// ── Dialog helper ─────────────────────────────────────────────
Future<void> showAdminDialog(BuildContext context, {
  required String title,
  required List<Widget> fields,
  required String confirmLabel,
  required Future<void> Function() onConfirm,
}) async {
  bool loading = false;
  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      backgroundColor: AC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(color: AC.text1, fontFamily: 'SpaceGrotesk')),
      content: SizedBox(
        width: 400,
        child: Column(mainAxisSize: MainAxisSize.min, children: fields.map((f) =>
            Padding(padding: const EdgeInsets.only(bottom: 12), child: f)).toList()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AC.text2))),
        AdminGradientButton(
          label: confirmLabel, loading: loading,
          onPressed: loading ? null : () async {
            setState(() => loading = true);
            try {
              await onConfirm();
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) {
              setState(() => loading = false);
              if (ctx.mounted) ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          },
        ),
      ],
    )),
  );
}
