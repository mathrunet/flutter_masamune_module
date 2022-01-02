// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

ChatModule? _$ChatModuleFromMap(DynamicMap map, ChatModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return ChatModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", "") ?? "",
      routePath: map.get<String>("routePath", "chat"),
      queryPath: map.get<String>("queryPath", "chat"),
      userPath: map.get<String>("userPath", "user"),
      availableMemberPath:
          map.get<String?>("availableMemberPath", "user") ?? "user",
      mediaType: PlatformMediaType.values.firstWhere((e) =>
          e.index == map.get<int>("mediaType", PlatformMediaType.all.index)),
      nameKey: map.get<String>("nameKey", Const.name),
      textKey: map.get<String>("textKey", Const.text),
      roleKey: map.get<String>("roleKey", Const.role),
      typeKey: map.get<String>("typeKey", Const.type),
      memberKey: map.get<String>("memberKey", Const.member),
      mediaKey: map.get<String>("mediaKey", Const.media),
      createdTimeKey: map.get<String>("createdTimeKey", Const.createdTime),
      modifiedTimeKey: map.get<String>("modifiedTimeKey", Const.modifiedTime),
      chatRoomQuery: map
          .get<DynamicMap>("chatRoomQuery", <String, dynamic>{}).toModelQuery(),
      sliverLayoutWhenModernDesignOnHome:
          map.get<bool>("sliverLayoutWhenModernDesignOnHome", true),
      automaticallyImplyLeadingOnHome:
          map.get<bool>("automaticallyImplyLeadingOnHome", true),
      availableMemberQuery: map.get<DynamicMap>(
          "availableMemberQuery", <String, dynamic>{}).toModelQuery(),
      allowEditRoomName: map.get<bool>("allowEditRoomName", true),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty());
}

DynamicMap _$ChatModuleToMap(ChatModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    if (ref.availableMemberPath.isNotEmpty)
      "availableMemberPath": ref.availableMemberPath,
    "mediaType": ref.mediaType.index,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.typeKey.isNotEmpty) "typeKey": ref.typeKey,
    if (ref.memberKey.isNotEmpty) "memberKey": ref.memberKey,
    if (ref.mediaKey.isNotEmpty) "mediaKey": ref.mediaKey,
    if (ref.createdTimeKey.isNotEmpty) "createdTimeKey": ref.createdTimeKey,
    if (ref.modifiedTimeKey.isNotEmpty) "modifiedTimeKey": ref.modifiedTimeKey,
    if (ref.chatRoomQuery != null) "chatRoomQuery": ref.chatRoomQuery?.toMap(),
    "sliverLayoutWhenModernDesignOnHome":
        ref.sliverLayoutWhenModernDesignOnHome,
    "automaticallyImplyLeadingOnHome": ref.automaticallyImplyLeadingOnHome,
    if (ref.availableMemberQuery != null)
      "availableMemberQuery": ref.availableMemberQuery?.toMap(),
    "allowEditRoomName": ref.allowEditRoomName,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap())
  };
}
