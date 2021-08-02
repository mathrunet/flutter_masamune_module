part of masamune_module;

class TabConfig {
  const TabConfig({
    required this.id,
    this.label = "",
    this.icon,
    this.value,
    this.query,
  });
  final String id;
  final String label;
  final IconData? icon;
  final CollectionQuery? query;
  final Object? value;

  static TabConfig? _fromMap(DynamicMap map) {
    if (map.isEmpty || !map.containsKey("id") || !map.containsKey("name")) {
      return null;
    }
    return TabConfig(
      id: map.get("id", ""),
      label: map.get("name", ""),
      icon: map.getAsMap("icon").toIconData(),
      value: map.get("value", null),
      query: map.getAsMap("query").toCollectionQuery(),
    );
  }

  DynamicMap toMap() {
    return <String, dynamic>{
      "id": id,
      "name": label,
      if (query != null) "query": query!.toMap(),
      if (icon != null) "icon": icon!.toMap(),
      if (value != null) "value": value,
    };
  }

  @override
  String toString() {
    return label;
  }
}
