part of masamune_module;

enum LoginLayoutType {
  fixed,
}

enum SnsLoginType {
  google,
  apple,
  facebook,
  twitter,
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
