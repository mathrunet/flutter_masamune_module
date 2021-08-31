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
      commentPath: map.get<String>("commentPath", "comment"),
      commentTemplatePath:
          map.get<String>("commentTemplatePath", "commentTemplate"),
      nameKey: map.get<String>("nameKey", Const.name),
      userKey: map.get<String>("userKey", Const.user),
      textKey: map.get<String>("textKey", Const.text),
      roleKey: map.get<String>("roleKey", Const.role),
      typeKey: map.get<String>("typeKey", Const.type),
      iamgeKey: map.get<String>("iamgeKey", Const.media),
      createdTimeKey: map.get<String>("createdTimeKey", Const.createdTime),
      modifiedTimeKey: map.get<String>("modifiedTimeKey", Const.modifiedTime),
      startTimeKey: map.get<String>("startTimeKey", Const.startTime),
      endTimeKey: map.get<String>("endTimeKey", Const.endTime),
      allDayKey: map.get<String>("allDayKey", "allDay"),
      detailLabel: map.get<String>("detailLabel", "Detail"),
      commentLabel: map.get<String>("commentLabel", "Comment"),
      editingType: CalendarEditingType.values.firstWhere((e) =>
          e.index ==
          map.get<int>("editingType", CalendarEditingType.planeText.index)),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      initialCommentTemplate:
          map.get<List>("initialCommentTemplate", const []).cast<String>(),
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
    if (ref.commentPath.isNotEmpty) "commentPath": ref.commentPath,
    if (ref.commentTemplatePath.isNotEmpty)
      "commentTemplatePath": ref.commentTemplatePath,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.userKey.isNotEmpty) "userKey": ref.userKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.typeKey.isNotEmpty) "typeKey": ref.typeKey,
    if (ref.iamgeKey.isNotEmpty) "iamgeKey": ref.iamgeKey,
    if (ref.createdTimeKey.isNotEmpty) "createdTimeKey": ref.createdTimeKey,
    if (ref.modifiedTimeKey.isNotEmpty) "modifiedTimeKey": ref.modifiedTimeKey,
    if (ref.startTimeKey.isNotEmpty) "startTimeKey": ref.startTimeKey,
    if (ref.endTimeKey.isNotEmpty) "endTimeKey": ref.endTimeKey,
    if (ref.allDayKey.isNotEmpty) "allDayKey": ref.allDayKey,
    if (ref.detailLabel.isNotEmpty) "detailLabel": ref.detailLabel,
    if (ref.commentLabel.isNotEmpty) "commentLabel": ref.commentLabel,
    "editingType": ref.editingType.index,
    "permission": ref.permission.toMap(),
    if (ref.initialCommentTemplate.isNotEmpty)
      "initialCommentTemplate": ref.initialCommentTemplate.map((e) => e),
    "designType": ref.designType.index
  };
}
