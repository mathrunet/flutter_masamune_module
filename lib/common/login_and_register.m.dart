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
      roles: map
          .get<List>("roles", const [
            RoleConfig(
                id: "register",
                label: "Registration",
                icon: FontAwesomeIcons.userAlt)
          ])
          .cast<DynamicMap>()
          .map((e) => e.toRoleConfig())
          .removeEmpty(),
      loginType: LoginType.values.firstWhere((e) =>
          e.index ==
          map.get<int>("loginType", LoginType.emailAndPassword.index)),
      layoutType: LoginLayoutType.values.firstWhere((e) =>
          e.index == map.get<int>("layoutType", LoginLayoutType.fixed.index)),
      backgroundColor:
          map.get<DynamicMap>("backgroundColor", <String, dynamic>{}).toColor(),
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
      titlePadding:
          map.get<DynamicMap>("titlePadding", <String, dynamic>{}).toEdgeInsets() ??
              const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      padding: map.get<DynamicMap>("padding", <String, dynamic>{}).toEdgeInsets() ??
          const EdgeInsets.all(36),
      redirectTo: map.get<String>("redirectTo", "/"),
      registerForm: map.get<List>("registerForm", const []).cast<DynamicMap>().map((e) => e.toFormConfig()).removeEmpty(),
      designType: DesignType.values.firstWhere((e) => e.index == map.get<int>("designType", DesignType.modern.index)));
}

DynamicMap _$LoginModuleToMap(LoginModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.roles.isNotEmpty) "roles": ref.roles.map((e) => e.toMap()),
    "loginType": ref.loginType.index,
    "layoutType": ref.layoutType.index,
    if (ref.backgroundColor != null)
      "backgroundColor": ref.backgroundColor?.toMap(),
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
    "featureImageFit": ref.featureImageFit.index,
    if (ref.titleTextStyle != null)
      "titleTextStyle": ref.titleTextStyle?.toMap(),
    "titleAlignment": ref.titleAlignment.toMap(),
    "login": ref.login.toMap(),
    if (ref.guestLogin != null) "guestLogin": ref.guestLogin?.toMap(),
    "titlePadding": ref.titlePadding.toMap(),
    "padding": ref.padding.toMap(),
    if (ref.redirectTo.isNotEmpty) "redirectTo": ref.redirectTo,
    if (ref.registerForm.isNotEmpty)
      "registerForm": ref.registerForm.map((e) => e.toMap()),
    "designType": ref.designType.index
  };
}
