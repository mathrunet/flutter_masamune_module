// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sns_login.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

SnsLoginModule? _$SnsLoginModuleFromMap(DynamicMap map, SnsLoginModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return SnsLoginModule(
      layoutType: LoginLayoutType.values.firstWhere((e) =>
          e.index == map.get<int>("layoutType", LoginLayoutType.fixed.index)),
      snsTypes: map
          .get<List>(
              "snsTypes", const [SnsLoginType.apple, SnsLoginType.google])
          .cast<int>()
          .map((e) => SnsLoginType.values.firstWhere((n) => n.index == e))
          .removeEmpty(),
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", null),
      color: map.get<DynamicMap>("color", <String, dynamic>{}).toColor(),
      backgroundColor:
          map.get<DynamicMap>("backgroundColor", <String, dynamic>{}).toColor(),
      backgroundGradient: map.get<DynamicMap>(
          "backgroundGradient", <String, dynamic>{}).toGradient(),
      appBarColorOnSliverList: map.get<DynamicMap>(
          "appBarColorOnSliverList", <String, dynamic>{}).toColor(),
      appBarHeightOnSliverList:
          map.get<double?>("appBarHeightOnSliverList", null),
      buttonColor:
          map.get<DynamicMap>("buttonColor", <String, dynamic>{}).toColor(),
      buttonBackgroundColor: map.get<DynamicMap>(
          "buttonBackgroundColor", <String, dynamic>{}).toColor(),
      backgroundImage: map.get<String?>("backgroundImage", null),
      backgroundImageBlur: map.get<double?>("backgroundImageBlur", 5.0) ?? 5.0,
      featureImage: map.get<String?>("featureImage", null),
      featureImageSize:
          map.get<DynamicMap>("featureImageSize", <String, dynamic>{}).toSize(),
      roleKey: map.get<String>("roleKey", Const.role),
      formImageSize:
          map.get<DynamicMap>("formImageSize", <String, dynamic>{}).toSize(),
      featureImageFit: BoxFit.values.firstWhere((e) =>
          e.index == map.get<int>("featureImageFit", BoxFit.cover.index)),
      titleTextStyle: map
          .get<DynamicMap>("titleTextStyle", <String, dynamic>{}).toTextStyle(),
      titleAlignment:
          map.get<DynamicMap>("titleAlignment", <String, dynamic>{}).toAlignment() ??
              Alignment.bottomLeft,
      guestLogin: map
          .get<DynamicMap>("guestLogin", <String, dynamic>{}).toLoginConfig(),
      titlePadding: map.get<DynamicMap>("titlePadding", <String, dynamic>{}).toEdgeInsets() ??
          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      padding: map.get<DynamicMap>("padding", <String, dynamic>{}).toEdgeInsets() ??
          const EdgeInsets.all(36),
      redirectTo: map.get<String>("redirectTo", "/"),
      registerForm: map.get<List>("registerForm", const []).cast<DynamicMap>().map((e) => e.toFormConfig()).removeEmpty(),
      permission: map.get<DynamicMap>("permission", <String, dynamic>{}).toPermission() ?? const Permission(),
      rerouteConfig: map.get<DynamicMap>("rerouteConfig", <String, dynamic>{}).toRerouteConfig());
}

DynamicMap _$SnsLoginModuleToMap(SnsLoginModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "layoutType": ref.layoutType.index,
    if (ref.snsTypes.isNotEmpty) "snsTypes": ref.snsTypes.map((e) => e.index),
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.color != null) "color": ref.color?.toMap(),
    if (ref.backgroundColor != null)
      "backgroundColor": ref.backgroundColor?.toMap(),
    if (ref.backgroundGradient != null)
      "backgroundGradient": ref.backgroundGradient?.toMap(),
    if (ref.appBarColorOnSliverList != null)
      "appBarColorOnSliverList": ref.appBarColorOnSliverList?.toMap(),
    if (ref.appBarHeightOnSliverList != null)
      "appBarHeightOnSliverList": ref.appBarHeightOnSliverList,
    if (ref.buttonColor != null) "buttonColor": ref.buttonColor?.toMap(),
    if (ref.buttonBackgroundColor != null)
      "buttonBackgroundColor": ref.buttonBackgroundColor?.toMap(),
    if (ref.backgroundImage.isNotEmpty) "backgroundImage": ref.backgroundImage,
    if (ref.backgroundImageBlur != null)
      "backgroundImageBlur": ref.backgroundImageBlur,
    if (ref.featureImage.isNotEmpty) "featureImage": ref.featureImage,
    if (ref.featureImageSize != null)
      "featureImageSize": ref.featureImageSize?.toMap(),
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.formImageSize != null) "formImageSize": ref.formImageSize?.toMap(),
    "featureImageFit": ref.featureImageFit.index,
    if (ref.titleTextStyle != null)
      "titleTextStyle": ref.titleTextStyle?.toMap(),
    "titleAlignment": ref.titleAlignment.toMap(),
    if (ref.guestLogin != null) "guestLogin": ref.guestLogin?.toMap(),
    "titlePadding": ref.titlePadding.toMap(),
    "padding": ref.padding.toMap(),
    if (ref.redirectTo.isNotEmpty) "redirectTo": ref.redirectTo,
    if (ref.registerForm.isNotEmpty)
      "registerForm": ref.registerForm.map((e) => e.toMap()),
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfig != null) "rerouteConfig": ref.rerouteConfig?.toMap()
  };
}
