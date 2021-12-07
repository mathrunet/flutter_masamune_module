// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

UserModule? _$UserModuleFromMap(DynamicMap map, UserModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return UserModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String>("title", ""),
      contents: map
          .get<List>("contents", const [])
          .cast<DynamicMap>()
          .map((e) => e.toModule<UserWidgetModule>())
          .removeEmpty(),
      routePath: map.get<String>("routePath", "user"),
      queryPath: map.get<String>("queryPath", "user"),
      reportPath: map.get<String>("reportPath", "report"),
      blockPath: map.get<String>("blockPath", "block"),
      nameKey: map.get<String>("nameKey", Const.name),
      textKey: map.get<String>("textKey", Const.text),
      imageKey: map.get<String>("imageKey", Const.image),
      iconKey: map.get<String>("iconKey", Const.icon),
      roleKey: map.get<String>("roleKey", Const.role),
      expandedHeight: map.get<double>("expandedHeight", 160),
      additionalInformation: map
          .get<Map>("additionalInformation", const {}).cast<String, String>(),
      allowImageEditing: map.get<bool>("allowImageEditing", false),
      allowFollow: map.get<bool>("allowFollow", false),
      allowBlock: map.get<bool>("allowBlock", true),
      allowReport: map.get<bool>("allowReport", true),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfig: map.get<DynamicMap>(
          "rerouteConfig", <String, dynamic>{}).toRerouteConfig());
}

DynamicMap _$UserModuleToMap(UserModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.contents.isNotEmpty) "contents": ref.contents.map((e) => e.toMap()),
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.reportPath.isNotEmpty) "reportPath": ref.reportPath,
    if (ref.blockPath.isNotEmpty) "blockPath": ref.blockPath,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.imageKey.isNotEmpty) "imageKey": ref.imageKey,
    if (ref.iconKey.isNotEmpty) "iconKey": ref.iconKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    "expandedHeight": ref.expandedHeight,
    if (ref.additionalInformation.isNotEmpty)
      "additionalInformation":
          ref.additionalInformation.map((k, v) => MapEntry(k, v)),
    "allowImageEditing": ref.allowImageEditing,
    "allowFollow": ref.allowFollow,
    "allowBlock": ref.allowBlock,
    "allowReport": ref.allowReport,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfig != null) "rerouteConfig": ref.rerouteConfig?.toMap()
  };
}
