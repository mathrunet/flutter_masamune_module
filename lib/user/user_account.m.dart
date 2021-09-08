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
      userPath: map.get<String>("userPath", "user"),
      blockPath: map.get<String>("blockPath", "block"),
      nameKey: map.get<String>("nameKey", Const.name),
      allowRoles: map.get<List>("allowRoles", const []).cast<String>(),
      allowUserDeleting: map.get<bool>("allowUserDeleting", false),
      allowEditingBlockList: map.get<bool>("allowEditingBlockList", true),
      designType: DesignType.values.firstWhere((e) =>
          e.index == map.get<int>("designType", DesignType.modern.index)),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission());
}

DynamicMap _$UserAccountModuleToMap(UserAccountModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    if (ref.blockPath.isNotEmpty) "blockPath": ref.blockPath,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.allowRoles.isNotEmpty) "allowRoles": ref.allowRoles.map((e) => e),
    "allowUserDeleting": ref.allowUserDeleting,
    "allowEditingBlockList": ref.allowEditingBlockList,
    "designType": ref.designType.index,
    "permission": ref.permission.toMap()
  };
}
