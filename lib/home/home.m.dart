// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

HomeModule? _$HomeModuleFromMap(DynamicMap map, HomeModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return HomeModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", "") ?? "",
      color: map.get<DynamicMap>("color", <String, dynamic>{}).toColor(),
      textColor:
          map.get<DynamicMap>("textColor", <String, dynamic>{}).toColor(),
      homeType: HomeType.values.firstWhere(
          (e) => e.index == map.get<int>("homeType", HomeType.tileMenu.index)),
      featureImage: map.get<String?>("featureImage", null),
      featureImageFit: BoxFit.values.firstWhere((e) =>
          e.index == map.get<int>("featureImageFit", BoxFit.cover.index)),
      titleTextStyle: map
          .get<DynamicMap>("titleTextStyle", <String, dynamic>{}).toTextStyle(),
      titleAlignment: map.get<DynamicMap>("titleAlignment", <String, dynamic>{}).toAlignment() ??
          Alignment.center,
      titlePadding: map.get<DynamicMap>("titlePadding", <String, dynamic>{}).toEdgeInsets() ??
          const EdgeInsets.all(12),
      contentPadding:
          map.get<DynamicMap>("contentPadding", <String, dynamic>{}).toEdgeInsets() ??
              const EdgeInsets.all(8),
      headerHeight: map.get<double>("headerHeight", 90),
      userPath: map.get<String>("userPath", "user"),
      calendar: map.get<DynamicMap>("calendar", <String, dynamic>{}).toModule() ??
          const HomeCalendarModule(enabled: false),
      info: map.get<DynamicMap>("info", <String, dynamic>{}).toModule() ??
          const HomeInformationModule(enabled: false),
      roleKey: map.get<String>("roleKey", Const.role),
      nameKey: map.get<String>("nameKey", Const.name),
      menu: map
          .get<List>("menu", const [])
          .cast<DynamicMap>()
          .map((e) => e.toMenuConfig())
          .removeEmpty(),
      subMenu: map
          .get<List>("subMenu", const [])
          .cast<DynamicMap>()
          .map((e) => e.toMenuConfig())
          .removeEmpty(),
      roleMenu: map
          .get<Map>("roleMenu", const {})
          .cast<String, List>()
          .map((k, v) => MapEntry(k, v.cast<DynamicMap>().map((e) => e.toMenuConfig()).removeEmpty())),
      permission: map.get<DynamicMap>("permission", <String, dynamic>{}).toPermission() ?? const Permission(),
      designType: DesignType.values.firstWhere((e) => e.index == map.get<int>("designType", DesignType.modern.index)));
}

DynamicMap _$HomeModuleToMap(HomeModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.color != null) "color": ref.color?.toMap(),
    if (ref.textColor != null) "textColor": ref.textColor?.toMap(),
    "homeType": ref.homeType.index,
    if (ref.featureImage.isNotEmpty) "featureImage": ref.featureImage,
    "featureImageFit": ref.featureImageFit.index,
    if (ref.titleTextStyle != null)
      "titleTextStyle": ref.titleTextStyle?.toMap(),
    "titleAlignment": ref.titleAlignment.toMap(),
    "titlePadding": ref.titlePadding.toMap(),
    "contentPadding": ref.contentPadding.toMap(),
    "headerHeight": ref.headerHeight,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    "calendar": ref.calendar.toMap(),
    "info": ref.info.toMap(),
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.menu.isNotEmpty) "menu": ref.menu.map((e) => e.toMap()),
    if (ref.subMenu.isNotEmpty) "subMenu": ref.subMenu.map((e) => e.toMap()),
    if (ref.roleMenu.isNotEmpty)
      "roleMenu":
          ref.roleMenu.map((k, v) => MapEntry(k, v.map((e) => e.toMap()))),
    "permission": ref.permission.toMap(),
    "designType": ref.designType.index
  };
}

HomeInformationModule? _$HomeInformationModuleFromMap(
    DynamicMap map, HomeInformationModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return HomeInformationModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", null),
      postPath: map.get<String>("postPath", "info"),
      icon: map.get<DynamicMap>("icon", <String, dynamic>{}).toIconData() ??
          Icons.info_rounded,
      designType: DesignType.values.firstWhere((e) =>
          e.index == map.get<int>("designType", DesignType.modern.index)),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission());
}

DynamicMap _$HomeInformationModuleToMap(HomeInformationModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.postPath.isNotEmpty) "postPath": ref.postPath,
    "icon": ref.icon.toMap(),
    "designType": ref.designType.index,
    "permission": ref.permission.toMap()
  };
}

HomeCalendarModule? _$HomeCalendarModuleFromMap(
    DynamicMap map, HomeCalendarModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return HomeCalendarModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", null),
      path: map.get<String>("path", "event"),
      icon: map.get<DynamicMap>("icon", <String, dynamic>{}).toIconData() ??
          Icons.calendar_today);
}

DynamicMap _$HomeCalendarModuleToMap(HomeCalendarModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.path.isNotEmpty) "path": ref.path,
    "icon": ref.icon.toMap()
  };
}
