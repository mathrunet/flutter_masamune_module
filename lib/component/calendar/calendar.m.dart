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
      queryPath: map.get<String>("queryPath", "event"),
      userPath: map.get<String>("userPath", "user"),
      commentPath: map.get<String>("commentPath", "comment"),
      commentTemplatePath:
          map.get<String>("commentTemplatePath", "commentTemplate"),
      nameKey: map.get<String>("nameKey", Const.name),
      userKey: map.get<String>("userKey", Const.user),
      textKey: map.get<String>("textKey", Const.text),
      roleKey: map.get<String>("roleKey", Const.role),
      typeKey: map.get<String>("typeKey", Const.type),
      imageKey: map.get<String>("imageKey", Const.media),
      createdTimeKey: map.get<String>("createdTimeKey", Const.createdTime),
      modifiedTimeKey: map.get<String>("modifiedTimeKey", Const.modifiedTime),
      startTimeKey: map.get<String>("startTimeKey", Const.startTime),
      endTimeKey: map.get<String>("endTimeKey", Const.endTime),
      allDayKey: map.get<String>("allDayKey", "allDay"),
      detailLabel: map.get<String>("detailLabel", "Detail"),
      noteLabel: map.get<String>("noteLabel", "Note"),
      commentLabel: map.get<String>("commentLabel", "Comment"),
      noteKey: map.get<String>("noteKey", "note"),
      enableNote: map.get<bool>("enableNote", false),
      editingType: CalendarEditingType.values.firstWhere((e) =>
          e.index ==
          map.get<int>("editingType", CalendarEditingType.planeText.index)),
      markerType: UICalendarMarkerType.values.firstWhere((e) =>
          e.index ==
          map.get<int>("markerType", UICalendarMarkerType.count.index)),
      showAddingButton: map.get<bool>("showAddingButton", true),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      initialCommentTemplate:
          map.get<List>("initialCommentTemplate", const []).cast<String>(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty());
}

DynamicMap _$CalendarModuleToMap(CalendarModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    if (ref.commentPath.isNotEmpty) "commentPath": ref.commentPath,
    if (ref.commentTemplatePath.isNotEmpty)
      "commentTemplatePath": ref.commentTemplatePath,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.userKey.isNotEmpty) "userKey": ref.userKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.typeKey.isNotEmpty) "typeKey": ref.typeKey,
    if (ref.imageKey.isNotEmpty) "imageKey": ref.imageKey,
    if (ref.createdTimeKey.isNotEmpty) "createdTimeKey": ref.createdTimeKey,
    if (ref.modifiedTimeKey.isNotEmpty) "modifiedTimeKey": ref.modifiedTimeKey,
    if (ref.startTimeKey.isNotEmpty) "startTimeKey": ref.startTimeKey,
    if (ref.endTimeKey.isNotEmpty) "endTimeKey": ref.endTimeKey,
    if (ref.allDayKey.isNotEmpty) "allDayKey": ref.allDayKey,
    if (ref.detailLabel.isNotEmpty) "detailLabel": ref.detailLabel,
    if (ref.noteLabel.isNotEmpty) "noteLabel": ref.noteLabel,
    if (ref.commentLabel.isNotEmpty) "commentLabel": ref.commentLabel,
    if (ref.noteKey.isNotEmpty) "noteKey": ref.noteKey,
    "enableNote": ref.enableNote,
    "editingType": ref.editingType.index,
    "markerType": ref.markerType.index,
    "showAddingButton": ref.showAddingButton,
    "permission": ref.permission.toMap(),
    if (ref.initialCommentTemplate.isNotEmpty)
      "initialCommentTemplate": ref.initialCommentTemplate.map((e) => e),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap())
  };
}
