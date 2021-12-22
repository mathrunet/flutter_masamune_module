// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

PostModule? _$PostModuleFromMap(DynamicMap map, PostModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return PostModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", "") ?? "",
      routePath: map.get<String>("routePath", "post"),
      queryPath: map.get<String>("queryPath", "post"),
      userPath: map.get<String>("userPath", "user"),
      nameKey: map.get<String>("nameKey", Const.name),
      textKey: map.get<String>("textKey", Const.text),
      roleKey: map.get<String>("roleKey", Const.role),
      createdTimeKey: map.get<String>("createdTimeKey", Const.createdTime),
      editingType: PostEditingType.values.firstWhere((e) =>
          e.index ==
          map.get<int>("editingType", PostEditingType.planeText.index)),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty(),
      postQuery:
          map.get<DynamicMap>("postQuery", <String, dynamic>{}).toModelQuery());
}

DynamicMap _$PostModuleToMap(PostModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.createdTimeKey.isNotEmpty) "createdTimeKey": ref.createdTimeKey,
    "editingType": ref.editingType.index,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap()),
    if (ref.postQuery != null) "postQuery": ref.postQuery?.toMap()
  };
}
