// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

GalleryModule? _$GalleryModuleFromMap(DynamicMap map, GalleryModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return GalleryModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String>("title", ""),
      galleryType: GalleryType.values.firstWhere((e) =>
          e.index == map.get<int>("galleryType", GalleryType.tile.index)),
      routePath: map.get<String>("routePath", "gallery"),
      queryPath: map.get<String>("queryPath", "gallery"),
      userPath: map.get<String>("userPath", "user"),
      mediaKey: map.get<String>("mediaKey", Const.media),
      nameKey: map.get<String>("nameKey", Const.name),
      textKey: map.get<String>("textKey", Const.text),
      roleKey: map.get<String>("roleKey", Const.role),
      categoryKey: map.get<String>("categoryKey", Const.category),
      createdTimeKey: map.get<String>("createdTimeKey", Const.createdTime),
      maxCrossAxisExtentForMobile:
          map.get<double>("maxCrossAxisExtentForMobile", 200),
      maxCrossAxisExtentForDesktop:
          map.get<double>("maxCrossAxisExtentForDesktop", 200),
      childAspectRatioForMobile:
          map.get<double>("childAspectRatioForMobile", 0.5625),
      childAspectRatioForDesktop:
          map.get<double>("childAspectRatioForDesktop", 1),
      heightOnDetailView: map.get<double>("heightOnDetailView", 200),
      tileSpacing: map.get<double>("tileSpacing", 1),
      categoryConfig: map
          .get<List>("categoryConfig", const [])
          .cast<DynamicMap>()
          .map((e) => e.toGroupConfig())
          .removeEmpty(),
      mediaType: PlatformMediaType.values.firstWhere((e) =>
          e.index == map.get<int>("mediaType", PlatformMediaType.all.index)),
      skipDetailPage: map.get<bool>("skipDetailPage", false),
      sliverLayoutWhenModernDesignOnHome:
          map.get<bool>("sliverLayoutWhenModernDesignOnHome", true),
      automaticallyImplyLeadingOnHome:
          map.get<bool>("automaticallyImplyLeadingOnHome", true),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty(),
      contentQuery: map
          .get<DynamicMap>("contentQuery", <String, dynamic>{}).toModelQuery(),
      categoryQuery: map.get<DynamicMap>(
          "categoryQuery", <String, dynamic>{}).toModelQuery());
}

DynamicMap _$GalleryModuleToMap(GalleryModule ref) {
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
    "maxCrossAxisExtentForMobile": ref.maxCrossAxisExtentForMobile,
    "maxCrossAxisExtentForDesktop": ref.maxCrossAxisExtentForDesktop,
    "childAspectRatioForMobile": ref.childAspectRatioForMobile,
    "childAspectRatioForDesktop": ref.childAspectRatioForDesktop,
    "heightOnDetailView": ref.heightOnDetailView,
    "tileSpacing": ref.tileSpacing,
    if (ref.categoryConfig.isNotEmpty)
      "categoryConfig": ref.categoryConfig.map((e) => e.toMap()),
    "mediaType": ref.mediaType.index,
    "skipDetailPage": ref.skipDetailPage,
    "sliverLayoutWhenModernDesignOnHome":
        ref.sliverLayoutWhenModernDesignOnHome,
    "automaticallyImplyLeadingOnHome": ref.automaticallyImplyLeadingOnHome,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap()),
    if (ref.contentQuery != null) "contentQuery": ref.contentQuery?.toMap(),
    if (ref.categoryQuery != null) "categoryQuery": ref.categoryQuery?.toMap()
  };
}
