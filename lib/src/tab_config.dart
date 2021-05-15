part of masamune_module;

class TabConfig {
  const TabConfig({
    required this.id,
    required this.label,
    this.icon,
    this.value,
  });
  final String id;
  final String label;
  final IconData? icon;
  final Object? value;
}
