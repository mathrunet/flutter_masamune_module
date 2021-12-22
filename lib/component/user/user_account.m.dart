// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

UserAccountModule? _$UserAccountModuleFromMap(
    DynamicMap map, UserAccountModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return UserAccountModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", null),
      routePath: map.get<String>("routePath", "user"),
      queryPath: map.get<String>("queryPath", "user"),
      blockPath: map.get<String>("blockPath", "block"),
      nameKey: map.get<String>("nameKey", Const.name),
      allowRoles: map.get<List>("allowRoles", const []).cast<String>(),
      allowUserDeleting: map.get<bool>("allowUserDeleting", false),
      allowEditingBlockList: map.get<bool>("allowEditingBlockList", true),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty());
}

DynamicMap _$UserAccountModuleToMap(UserAccountModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.blockPath.isNotEmpty) "blockPath": ref.blockPath,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.allowRoles.isNotEmpty) "allowRoles": ref.allowRoles.map((e) => e),
    "allowUserDeleting": ref.allowUserDeleting,
    "allowEditingBlockList": ref.allowEditingBlockList,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap())
  };
}
