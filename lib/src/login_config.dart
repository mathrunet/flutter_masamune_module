part of masamune_module;

enum LoginLayoutType {
  fixed,
}

@immutable
class LoginConfig {
  const LoginConfig({
    this.label,
    this.color,
    this.icon,
  });
  final String? label;
  final IconData? icon;
  final Color? color;
}
