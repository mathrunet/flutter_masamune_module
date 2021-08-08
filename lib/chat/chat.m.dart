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
      chatPath: map.get<String>("chatPath", "chat"),
      userPath: map.get<String>("userPath", "user"),
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
      chatQuery: map.get<DynamicMap>(
          "chatQuery", <String, dynamic>{}).toCollectionQuery(),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      designType: DesignType.values.firstWhere((e) =>
          e.index == map.get<int>("designType", DesignType.modern.index)));
}

DynamicMap _$ChatModuleToMap(ChatModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.chatPath.isNotEmpty) "chatPath": ref.chatPath,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    "mediaType": ref.mediaType.index,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.typeKey.isNotEmpty) "typeKey": ref.typeKey,
    if (ref.memberKey.isNotEmpty) "memberKey": ref.memberKey,
    if (ref.mediaKey.isNotEmpty) "mediaKey": ref.mediaKey,
    if (ref.createdTimeKey.isNotEmpty) "createdTimeKey": ref.createdTimeKey,
    if (ref.modifiedTimeKey.isNotEmpty) "modifiedTimeKey": ref.modifiedTimeKey,
    if (ref.chatQuery != null) "chatQuery": ref.chatQuery?.toMap(),
    "permission": ref.permission.toMap(),
    "designType": ref.designType.index
  };
}
