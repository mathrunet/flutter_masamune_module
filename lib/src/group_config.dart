part of masamune_module;

class GroupConfig {
  const GroupConfig({
    required this.id,
    this.label = "",
    this.icon,
    this.value,
    this.query,
  });
  final String id;
  final String label;
  final IconData? icon;
  final ModelQuery? query;
  final Object? value;

  static GroupConfig? _fromMap(DynamicMap map) {
    if (map.isEmpty || !map.containsKey("id") || !map.containsKey("name")) {
      return null;
    }
    return GroupConfig(
      id: map.get("id", ""),
      label: map.get("name", ""),
      icon: map.getAsMap("icon").toIconData(),
      value: map.get("value", null),
      query: map.getAsMap("query").toModelQuery(),
    );
  }

  DynamicMap toMap() {
    return <String, dynamic>{
      "id": id,
      "name": label,
      if (icon != null) "icon": icon!.toMap(),
      if (value != null) "value": value,
      if (query != null) "query": query!.toMap(),
    };
  }

  @override
  String toString() {
    return label;
  }
}
