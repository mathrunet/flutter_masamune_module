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
      galleryPath: map.get<String>("galleryPath", "gallery"),
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
      tabConfig: map
          .get<List>("tabConfig", const [])
          .cast<DynamicMap>()
          .map((e) => e.toTabConfig())
          .removeEmpty(),
      mediaType: PlatformMediaType.values.firstWhere((e) =>
          e.index == map.get<int>("mediaType", PlatformMediaType.all.index)),
      skipDetailPage: map.get<bool>("skipDetailPage", false),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      designType: DesignType.values.firstWhere((e) =>
          e.index == map.get<int>("designType", DesignType.modern.index)),
      galleryQuery: map.get<DynamicMap>(
          "galleryQuery", <String, dynamic>{}).toCollectionQuery());
}

DynamicMap _$GalleryModuleToMap(GalleryModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    "galleryType": ref.galleryType.index,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.galleryPath.isNotEmpty) "galleryPath": ref.galleryPath,
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
    if (ref.tabConfig.isNotEmpty)
      "tabConfig": ref.tabConfig.map((e) => e.toMap()),
    "mediaType": ref.mediaType.index,
    "skipDetailPage": ref.skipDetailPage,
    "permission": ref.permission.toMap(),
    "designType": ref.designType.index,
    if (ref.galleryQuery != null) "galleryQuery": ref.galleryQuery?.toMap()
  };
}
