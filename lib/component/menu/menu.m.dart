// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

MenuModule? _$MenuModuleFromMap(DynamicMap map, MenuModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return MenuModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", null),
      routePath: map.get<String>("routePath", "menu"),
      automaticallyImplyLeadingOnHome:
          map.get<bool>("automaticallyImplyLeadingOnHome", true),
      sliverLayoutWhenModernDesignOnHome:
          map.get<bool>("sliverLayoutWhenModernDesignOnHome", true),
      menu: map
          .get<List>("menu", const [])
          .cast<DynamicMap>()
          .map((e) => e.toMenuModuleItem())
          .removeEmpty(),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty());
}

DynamicMap _$MenuModuleToMap(MenuModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    "automaticallyImplyLeadingOnHome": ref.automaticallyImplyLeadingOnHome,
    "sliverLayoutWhenModernDesignOnHome":
        ref.sliverLayoutWhenModernDesignOnHome,
    if (ref.menu.isNotEmpty) "menu": ref.menu.map((e) => e.toMap()),
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap())
  };
}
