part of masamune_module;

@immutable
class RoleConfig {
  const RoleConfig({
    required this.id,
    this.label,
    this.color,
    this.icon,
    this.onTap,
  });
  final String id;
  final String? label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
}
