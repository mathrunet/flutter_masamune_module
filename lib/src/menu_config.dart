part of masamune_module;

class MenuConfig {
  const MenuConfig({required this.name, this.text, this.icon, this.path,});
  final IconData? icon;
  final String name;
  final String? text;
  final String? path;
}
