// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

DetailModule? _$DetailModuleFromMap(DynamicMap map, DetailModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return DetailModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", null),
      routePath: map.get<String>("routePath", "detail"),
      queryPath: map.get<String>("queryPath", ""),
      commentQueryPath: map.get<String>("commentQueryPath", "comment"),
      nameKey: map.get<String>("nameKey", Const.name),
      textKey: map.get<String>("textKey", Const.text),
      imageKey: map.get<String>("imageKey", Const.image),
      iconKey: map.get<String>("iconKey", Const.icon),
      timeKey: map.get<String>("timeKey", Const.time),
      userKey: map.get<String>("userKey", Const.user),
      tagKey: map.get<String>("tagKey", Const.tag),
      searchPath: map.get<String>("searchPath", "search"),
      likeCountKey: map.get<String>("likeCountKey", "likeCount"),
      userPath: map.get<String>("userPath", Const.user),
      enableBookmark: map.get<bool>("enableBookmark", true),
      enableComment: map.get<bool>("enableComment", true),
      enableLike: map.get<bool>("enableLike", true),
      enableShare: map.get<bool>("enableShare", true),
      multipleImage: map.get<bool>("multipleImage", false),
      bookmarkPath: map.get<String>("bookmarkPath", "bookmark"),
      likePath: map.get<String>("likePath", "like"),
      automaticallyImplyLeadingOnHome:
          map.get<bool>("automaticallyImplyLeadingOnHome", true),
      expandedHeight: map.get<double>("expandedHeight", 240),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty());
}

DynamicMap _$DetailModuleToMap(DetailModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.commentQueryPath.isNotEmpty)
      "commentQueryPath": ref.commentQueryPath,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.imageKey.isNotEmpty) "imageKey": ref.imageKey,
    if (ref.iconKey.isNotEmpty) "iconKey": ref.iconKey,
    if (ref.timeKey.isNotEmpty) "timeKey": ref.timeKey,
    if (ref.userKey.isNotEmpty) "userKey": ref.userKey,
    if (ref.tagKey.isNotEmpty) "tagKey": ref.tagKey,
    if (ref.searchPath.isNotEmpty) "searchPath": ref.searchPath,
    if (ref.likeCountKey.isNotEmpty) "likeCountKey": ref.likeCountKey,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    "enableBookmark": ref.enableBookmark,
    "enableComment": ref.enableComment,
    "enableLike": ref.enableLike,
    "enableShare": ref.enableShare,
    "multipleImage": ref.multipleImage,
    if (ref.bookmarkPath.isNotEmpty) "bookmarkPath": ref.bookmarkPath,
    if (ref.likePath.isNotEmpty) "likePath": ref.likePath,
    "automaticallyImplyLeadingOnHome": ref.automaticallyImplyLeadingOnHome,
    "expandedHeight": ref.expandedHeight,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap())
  };
}
