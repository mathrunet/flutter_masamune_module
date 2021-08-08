// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

CalendarModule? _$CalendarModuleFromMap(DynamicMap map, CalendarModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return CalendarModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", "") ?? "",
      routePath: map.get<String>("routePath", "calendar"),
      eventPath: map.get<String>("eventPath", "event"),
      userPath: map.get<String>("userPath", "user"),
      nameKey: map.get<String>("nameKey", Const.name),
      textKey: map.get<String>("textKey", Const.text),
      roleKey: map.get<String>("roleKey", Const.role),
      typeKey: map.get<String>("typeKey", Const.type),
      createdTimeKey: map.get<String>("createdTimeKey", Const.createdTime),
      modifiedTimeKey: map.get<String>("modifiedTimeKey", Const.modifiedTime),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      designType: DesignType.values.firstWhere((e) =>
          e.index == map.get<int>("designType", DesignType.modern.index)));
}

DynamicMap _$CalendarModuleToMap(CalendarModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.eventPath.isNotEmpty) "eventPath": ref.eventPath,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.typeKey.isNotEmpty) "typeKey": ref.typeKey,
    if (ref.createdTimeKey.isNotEmpty) "createdTimeKey": ref.createdTimeKey,
    if (ref.modifiedTimeKey.isNotEmpty) "modifiedTimeKey": ref.modifiedTimeKey,
    "permission": ref.permission.toMap(),
    "designType": ref.designType.index
  };
}
