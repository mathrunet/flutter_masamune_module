
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

  static LoginConfig? _fromMap(DynamicMap map) {
    if (map.isEmpty) {
      return null;
    }
    return LoginConfig(
      label: map.get<String?>("name", null),
      color: map.getAsMap("color").toColor(),
      icon: map.getAsMap("icon").toIconData(),
    );
  }

  DynamicMap toMap() {
    return <String, dynamic>{
      if (label.isNotEmpty) "name": label,
      if (color != null) "color": color.toMap(),
      if (icon != null) "icon": icon.toMap(),
    };
  }
}