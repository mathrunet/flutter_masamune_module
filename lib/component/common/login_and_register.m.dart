// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_and_register.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

LoginModule? _$LoginModuleFromMap(DynamicMap map, LoginModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return LoginModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String>("title", ""),
      layoutType: LoginLayoutType.values.firstWhere((e) =>
          e.index == map.get<int>("layoutType", LoginLayoutType.fixed.index)),
      color: map.get<DynamicMap>("color", <String, dynamic>{}).toColor(),
      userPath: map.get<String>("userPath", Const.user),
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
      login: map.get<DynamicMap>("login", <String, dynamic>{}).toLoginConfig() ??
          const LoginConfig(label: "Login", icon: FontAwesomeIcons.signInAlt),
      guestLogin: map
          .get<DynamicMap>("guestLogin", <String, dynamic>{}).toLoginConfig(),
      titlePadding: map.get<DynamicMap>("titlePadding", <String, dynamic>{}).toEdgeInsets() ??
          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      padding: map.get<DynamicMap>("padding", <String, dynamic>{}).toEdgeInsets() ?? const EdgeInsets.all(36),
      redirectTo: map.get<String>("redirectTo", "/"),
      permission: map.get<DynamicMap>("permission", <String, dynamic>{}).toPermission() ?? const Permission(),
      rerouteConfigs: map.get<List>("rerouteConfigs", const []).cast<DynamicMap>().map((e) => e.toRerouteConfig()).removeEmpty(),
      registerVariables: map.get<List>("registerVariables", const []).cast<DynamicMap>().map((e) => e.toVariableConfig()).removeEmpty(),
      showOnlyRequiredVariable: map.get<bool>("showOnlyRequiredVariable", true));
}

DynamicMap _$LoginModuleToMap(LoginModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    "layoutType": ref.layoutType.index,
    if (ref.color != null) "color": ref.color?.toMap(),
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
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
    "login": ref.login.toMap(),
    if (ref.guestLogin != null) "guestLogin": ref.guestLogin?.toMap(),
    "titlePadding": ref.titlePadding.toMap(),
    "padding": ref.padding.toMap(),
    if (ref.redirectTo.isNotEmpty) "redirectTo": ref.redirectTo,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap()),
    if (ref.registerVariables.isNotEmpty)
      "registerVariables": ref.registerVariables.map((e) => e.toMap()),
    "showOnlyRequiredVariable": ref.showOnlyRequiredVariable
  };
}
