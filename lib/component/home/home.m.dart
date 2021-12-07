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
      featureIcon: map.get<String?>("featureIcon", null),
      featureImage: map.get<String?>("featureImage", null),
      featureImageFit: BoxFit.values.firstWhere((e) =>
          e.index == map.get<int>("featureImageFit", BoxFit.cover.index)),
      featureImageAlignment:
          map.get<DynamicMap>("featureImageAlignment", <String, dynamic>{}).toAlignment() ??
              Alignment.center,
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
      subMenu: map.get<List>("subMenu", const []).cast<DynamicMap>().map((e) => e.toMenuConfig()).removeEmpty(),
      profileRoutePath: map.get<String>("profileRoutePath", "user"),
      permission: map.get<DynamicMap>("permission", <String, dynamic>{}).toPermission() ?? const Permission(),
      rerouteConfig: map.get<DynamicMap>("rerouteConfig", <String, dynamic>{}).toRerouteConfig());
}

DynamicMap _$HomeModuleToMap(HomeModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.color != null) "color": ref.color?.toMap(),
    if (ref.textColor != null) "textColor": ref.textColor?.toMap(),
    "homeType": ref.homeType.index,
    if (ref.featureIcon.isNotEmpty) "featureIcon": ref.featureIcon,
    if (ref.featureImage.isNotEmpty) "featureImage": ref.featureImage,
    "featureImageFit": ref.featureImageFit.index,
    "featureImageAlignment": ref.featureImageAlignment.toMap(),
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
    if (ref.profileRoutePath.isNotEmpty)
      "profileRoutePath": ref.profileRoutePath,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfig != null) "rerouteConfig": ref.rerouteConfig?.toMap()
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
      routePath: map.get<String>("routePath", "info"),
      queryPath: map.get<String>("queryPath", "info"),
      icon: map.get<DynamicMap>("icon", <String, dynamic>{}).toIconData() ??
          Icons.info_rounded,
      nameKey: map.get<String>("nameKey", Const.name),
      createdTimeKey: map.get<String>("createdTimeKey", Const.createdTime),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      limit: map.get<int>("limit", 10));
}

DynamicMap _$HomeInformationModuleToMap(HomeInformationModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    "icon": ref.icon.toMap(),
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.createdTimeKey.isNotEmpty) "createdTimeKey": ref.createdTimeKey,
    "permission": ref.permission.toMap(),
    "limit": ref.limit
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
      routePath: map.get<String>("routePath", "calendar"),
      queryPath: map.get<String>("queryPath", "event"),
      startTimeKey: map.get<String>("startTimeKey", Const.startTime),
      endTimeKey: map.get<String>("endTimeKey", Const.endTime),
      allDayKey: map.get<String>("allDayKey", "allDay"),
      icon: map.get<DynamicMap>("icon", <String, dynamic>{}).toIconData() ??
          Icons.calendar_today);
}

DynamicMap _$HomeCalendarModuleToMap(HomeCalendarModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.startTimeKey.isNotEmpty) "startTimeKey": ref.startTimeKey,
    if (ref.endTimeKey.isNotEmpty) "endTimeKey": ref.endTimeKey,
    if (ref.allDayKey.isNotEmpty) "allDayKey": ref.allDayKey,
    "icon": ref.icon.toMap()
  };
}
