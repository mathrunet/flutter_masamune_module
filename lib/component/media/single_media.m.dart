// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_media.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

SingleMediaModule? _$SingleMediaModuleFromMap(
    DynamicMap map, SingleMediaModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return SingleMediaModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String>("title", ""),
      galleryType: GalleryType.values.firstWhere((e) =>
          e.index == map.get<int>("galleryType", GalleryType.tile.index)),
      routePath: map.get<String>("routePath", "media"),
      queryPath: map.get<String>("queryPath", "app/media"),
      userPath: map.get<String>("userPath", "user"),
      mediaKey: map.get<String>("mediaKey", Const.media),
      nameKey: map.get<String>("nameKey", Const.name),
      textKey: map.get<String>("textKey", Const.text),
      roleKey: map.get<String>("roleKey", Const.role),
      categoryKey: map.get<String>("categoryKey", Const.category),
      createdTimeKey: map.get<String>("createdTimeKey", Const.createdTime),
      mediaType: PlatformMediaType.values.firstWhere((e) =>
          e.index == map.get<int>("mediaType", PlatformMediaType.all.index)),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      sliverLayoutWhenModernDesignOnHome:
          map.get<bool>("sliverLayoutWhenModernDesignOnHome", true),
      automaticallyImplyLeadingOnHome:
          map.get<bool>("automaticallyImplyLeadingOnHome", true),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty());
}

DynamicMap _$SingleMediaModuleToMap(SingleMediaModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    "galleryType": ref.galleryType.index,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    if (ref.mediaKey.isNotEmpty) "mediaKey": ref.mediaKey,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.categoryKey.isNotEmpty) "categoryKey": ref.categoryKey,
    if (ref.createdTimeKey.isNotEmpty) "createdTimeKey": ref.createdTimeKey,
    "mediaType": ref.mediaType.index,
    "permission": ref.permission.toMap(),
    "sliverLayoutWhenModernDesignOnHome":
        ref.sliverLayoutWhenModernDesignOnHome,
    "automaticallyImplyLeadingOnHome": ref.automaticallyImplyLeadingOnHome,
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap())
  };
}
