// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

EditModule? _$EditModuleFromMap(DynamicMap map, EditModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return EditModule(
      enabled: map.get<bool>("enabled", true),
      variables: map
          .get<List>("variables", const [])
          .cast<DynamicMap>()
          .map((e) => e.toVariableConfig())
          .removeEmpty(),
      title: map.get<String?>("title", null),
      routePath: map.get<String>("routePath", "edit"),
      queryPath: map.get<String>("queryPath", "edit"),
      queryKey: map.get<String>("queryKey", "edit_id"),
      enableDelete: map.get<bool>("enableDelete", true),
      automaticallyImplyLeadingOnHome:
          map.get<bool>("automaticallyImplyLeadingOnHome", true),
      sliverLayoutWhenModernDesignOnHome:
          map.get<bool>("sliverLayoutWhenModernDesignOnHome", false),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty());
}

DynamicMap _$EditModuleToMap(EditModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.variables.isNotEmpty)
      "variables": ref.variables.map((e) => e.toMap()),
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.queryKey.isNotEmpty) "queryKey": ref.queryKey,
    "enableDelete": ref.enableDelete,
    "automaticallyImplyLeadingOnHome": ref.automaticallyImplyLeadingOnHome,
    "sliverLayoutWhenModernDesignOnHome":
        ref.sliverLayoutWhenModernDesignOnHome,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap())
  };
}
