import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masamune/masamune.dart';
import 'package:masamune_module/masamune_module.dart';

part 'login_and_register.m.dart';

@module
@immutable
class LoginModule extends PageModule {
  const LoginModule({
    bool enabled = true,
    String title = "",
    this.roles = const [
      RoleConfig(
        id: "register",
        label: "Registration",
        icon: FontAwesomeIcons.userAlt,
      ),
    ],
    this.loginType = LoginType.emailAndPassword,
    this.layoutType = LoginLayoutType.sliverList,
    this.backgroundColor,
    this.appBarColorOnSliverList,
    this.appBarHeightOnSliverList,
    this.buttonColor,
    this.buttonBackgroundColor,
    this.featureImage,
    this.featureImageSize,
    this.featureImageFit = BoxFit.cover,
    this.titleTextStyle,
    this.titleAlignment = Alignment.bottomLeft,
    this.login = const LoginConfig(
      label: "Login",
      icon: FontAwesomeIcons.signInAlt,
    ),
    this.guestLogin,
    this.titlePadding =
        const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    this.padding = const EdgeInsets.all(24),
    this.redirectTo = "/",
    this.formColor,
    this.formBackgroundColor,
    this.registerForm = const [],
  }) : super(enabled: enabled, title: title);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/landing": RouteConfig((_) => Landing(this)),
      "/login": RouteConfig((_) => Login(this)),
      "/reset": RouteConfig((_) => PasswordReset(this)),
    };
    if (roles.length == 1) {
      route["/register"] = RouteConfig((_) => Register(this, roles.first));
    } else if (roles.isNotEmpty) {
      for (final role in roles) {
        route["/register/${role.id}"] =
            RouteConfig((_) => Register(this, role));
      }
    }
    return route;
  }

  /// 権限。
  final List<RoleConfig> roles;

  /// ログインタイプ。
  final LoginType loginType;

  /// レイアウトタイプ。
  final LoginLayoutType layoutType;

  /// 背景色。
  final Color? backgroundColor;

  /// AppBarの背景色。Sliver時のみ。
  final Color? appBarColorOnSliverList;

  /// AppBarの高さ。Sliver時のみ。
  final double? appBarHeightOnSliverList;

  /// フィーチャー画像。
  final String? featureImage;

  /// フィーチャー画像の配置。
  final BoxFit featureImageFit;

  /// フィーチャー画像のサイズ。
  final Size? featureImageSize;

  /// ボタンの前景色。
  final Color? buttonColor;

  /// ボタンの背景色。
  final Color? buttonBackgroundColor;

  /// タイトルのテキストスタイル。
  final TextStyle? titleTextStyle;

  /// タイトルの位置。
  final Alignment titleAlignment;

  /// タイトルのパディング。
  final EdgeInsetsGeometry titlePadding;

  /// コンテンツのパディング。
  final EdgeInsetsGeometry padding;

  /// ログイン用の設定。
  final LoginConfig login;

  /// ゲストログイン用の設定。
  final LoginConfig? guestLogin;

  /// ログイン後のパス。
  final String redirectTo;

  /// フォームの色。
  final Color? formColor;

  /// フォームの背景色。
  final Color? formBackgroundColor;

  /// 登録時のフォームデータ。
  final List<FormConfig> registerForm;

  @override
  LoginModule? fromMap(DynamicMap map) => _$LoginModuleFromMap(map, this);
  @override
  DynamicMap toMap() => _$LoginModuleToMap(this);
}

@immutable
class LoginConfig {
  const LoginConfig({
    this.label,
    this.color,
    this.icon,
  });
  final String? label;
  final IconData? icon;
  final Color? color;

  static LoginConfig? _fromMap(DynamicMap map) {
    if (map.isEmpty) {
      return null;
    }
    return LoginConfig(
      label: map.get<String?>("name", null),
      color: map.getAsMap("color").toColor(),
      icon: map.getAsMap("icon").toIconData(),
    );
  }

  DynamicMap toMap() {
    return <String, dynamic>{
      if (label.isNotEmpty) "name": label,
      if (color != null) "color": color.toMap(),
      if (icon != null) "icon": icon.toMap(),
    };
  }
}

extension _LoginConfigExtensions on DynamicMap? {
  LoginConfig? toLoginConfig() {
    if (this == null) {
      return null;
    }
    return LoginConfig._fromMap(this!);
  }
}

enum LoginType { emailAndPassword }

enum LoginLayoutType {
  sliverList,
  fixed,
}

class Landing extends PageHookWidget {
  const Landing(this.config);
  final LoginModule config;
  @override
  Widget build(BuildContext context) {
    switch (config.layoutType) {
      case LoginLayoutType.fixed:
        return Scaffold(
          backgroundColor: config.backgroundColor,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (config.featureImage.isNotEmpty)
                        SizedBox(
                          width: config.featureImageSize?.width,
                          height: config.featureImageSize?.height,
                          child: Image(
                            image: NetworkOrAsset.image(config.featureImage!),
                            fit: config.featureImageFit,
                          ),
                        ),
                      if (config.title.isNotEmpty)
                        Align(
                          alignment: config.titleAlignment,
                          child: Padding(
                            padding: config.titlePadding,
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                fontSize: 56,
                                fontFamily: "Mplus",
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              child: Text(
                                config.title ?? "",
                                style: config.titleTextStyle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: config.padding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      for (final role in config.roles)
                        FormItemSubmit(
                          role.label?.localize() ?? "Registration".localize(),
                          color: config.buttonColor,
                          backgroundColor: config.buttonBackgroundColor ??
                              role.color ??
                              context.theme.accentColor,
                          icon: role.icon,
                          onPressed: () {
                            if (role.path.isNotEmpty) {
                              context.navigator.pushNamed(role.path!);
                            } else {
                              if (config.roles.length <= 1) {
                                context.navigator.pushNamed("/register",
                                    arguments: RouteQuery.fade);
                              } else {
                                context.navigator.pushNamed(
                                    "/register/${role.id}",
                                    arguments: RouteQuery.fade);
                              }
                            }
                          },
                        ),
                      if (config.guestLogin != null)
                        FormItemSubmit(
                          config.guestLogin!.label?.localize() ??
                              "Guest login".localize(),
                          color: config.buttonColor,
                          backgroundColor: config.buttonBackgroundColor ??
                              config.guestLogin!.color ??
                              context.theme.primaryColor,
                          icon: config.guestLogin!.icon,
                          onPressed: () async {
                            await context.model
                                ?.signInAnonymously()
                                .showIndicator(context);
                            context.navigator.pushNamed(config.redirectTo);
                          },
                        ),
                      FormItemSubmit(
                        config.login.label?.localize() ?? "Login".localize(),
                        color: config.buttonColor,
                        backgroundColor: config.buttonBackgroundColor ??
                            config.login.color ??
                            context.theme.primaryColor,
                        icon: config.login.icon,
                        onPressed: () {
                          context.navigator
                              .pushNamed("/login", arguments: RouteQuery.fade);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        final height = context.mediaQuery.size.height;
        final appBarHeight = config.appBarHeightOnSliverList ?? (height / 2);
        final contentHeight = height - appBarHeight;
        return Scaffold(
          backgroundColor: config.backgroundColor,
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: config.appBarColorOnSliverList ??
                    context.theme.primaryColor,
                elevation: 0,
                expandedHeight: appBarHeight,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (config.featureImage.isNotEmpty)
                        SizedBox(
                          width: config.featureImageSize?.width,
                          height: config.featureImageSize?.height,
                          child: Image(
                            image: NetworkOrAsset.image(config.featureImage!),
                            fit: config.featureImageFit,
                          ),
                        ),
                      Align(
                        alignment: config.titleAlignment,
                        child: Padding(
                          padding: config.titlePadding,
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 56,
                              fontFamily: "Mplus",
                              fontWeight: FontWeight.w700,
                            ),
                            child: Text(
                              config.title ?? "",
                              style: config.titleTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  constraints: BoxConstraints(minHeight: contentHeight),
                  padding: config.padding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final role in config.roles)
                        FormItemSubmit(
                          role.label?.localize() ?? "Registration".localize(),
                          color: config.buttonColor,
                          backgroundColor: config.buttonBackgroundColor ??
                              role.color ??
                              context.theme.accentColor,
                          icon: role.icon,
                          onPressed: () {
                            if (role.path.isNotEmpty) {
                              context.navigator.pushNamed(role.path!);
                            } else {
                              if (config.roles.length <= 1) {
                                context.navigator.pushNamed("/register",
                                    arguments: RouteQuery.fade);
                              } else {
                                context.navigator.pushNamed(
                                    "/register/${role.id}",
                                    arguments: RouteQuery.fade);
                              }
                            }
                          },
                        ),
                      if (config.guestLogin != null)
                        FormItemSubmit(
                          config.guestLogin!.label?.localize() ??
                              "Guest login".localize(),
                          color: config.buttonColor,
                          backgroundColor: config.buttonBackgroundColor ??
                              config.guestLogin!.color ??
                              context.theme.primaryColor,
                          icon: config.guestLogin!.icon,
                          onPressed: () async {
                            await context.model
                                ?.signInAnonymously()
                                .showIndicator(context);
                            context.navigator.pushNamed(config.redirectTo);
                          },
                        ),
                      FormItemSubmit(
                        config.login.label?.localize() ?? "Login".localize(),
                        color: config.buttonColor,
                        backgroundColor: config.buttonBackgroundColor ??
                            config.login.color ??
                            context.theme.primaryColor,
                        icon: config.login.icon,
                        onPressed: () {
                          context.navigator
                              .pushNamed("/login", arguments: RouteQuery.fade);
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class Login extends PageHookWidget with UIPageFormMixin {
  Login(this.config);
  final LoginModule config;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: config.backgroundColor,
      appBar: AppBar(
        backgroundColor: config.login.color ?? context.theme.primaryColor,
        title: Text(config.login.label?.localize() ?? "Login".localize()),
      ),
      body: FormBuilder(
        type: FormBuilderType.center,
        key: formKey,
        padding: config.padding,
        children: [
          FormItemLabel("Email".localize(), color: config.formColor),
          FormItemTextField(
            hintText: "Please enter a email address".localize(),
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            minLength: 2,
            maxLength: 256,
            onSaved: (value) {
              context["email"] = value;
            },
            color: config.formColor,
            backgroundColor: config.formBackgroundColor,
          ),
          FormItemLabel("Password".localize(), color: config.formColor),
          FormItemTextField(
            hintText: "Please enter a password".localize(),
            keyboardType: TextInputType.visiblePassword,
            maxLines: 1,
            minLength: 8,
            maxLength: 36,
            obscureText: true,
            onSaved: (value) {
              context["password"] = value;
            },
            color: config.formColor,
            backgroundColor: config.formBackgroundColor,
          ),
          Center(
            child: TextButton(
              onPressed: () {
                context.navigator
                    .pushNamed("/reset", arguments: RouteQuery.fade);
              },
              child: Text(
                "Click here if you forget your password".localize(),
                style: TextStyle(
                  color: config.formColor ?? context.theme.textColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!validate(context)) {
            return;
          }
          try {
            await context.model
                ?.signInEmailAndPassword(
                  email: context.get("email", ""),
                  password: context.get("password", ""),
                )
                .showIndicator(context);
            context.navigator.pushNamed(config.redirectTo);
          } catch (e) {
            UIDialog.show(
              context,
              title: "Error".localize(),
              text:
                  "Could not login. Please check your email address and password."
                      .localize(),
              submitText: "Close".localize(),
            );
          }
        },
        icon: const Icon(Icons.check),
        label: Text(
          config.login.label?.localize() ?? "Login".localize(),
        ),
        backgroundColor: config.login.color ?? context.theme.primaryColor,
      ),
    );
  }
}

class Register extends PageHookWidget with UIPageFormMixin {
  Register(this.config, this.role);
  final LoginModule config;
  final RoleConfig role;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: config.backgroundColor,
      appBar: AppBar(
        backgroundColor: role.color ?? context.theme.accentColor,
        title: Text(role.label?.localize() ?? "Registration".localize()),
      ),
      body: FormBuilder(
        type: FormBuilderType.center,
        key: formKey,
        padding: config.padding,
        children: [
          FormItemLabel("Email".localize(), color: config.formColor),
          FormItemTextField(
            hintText: "Please enter a email address".localize(),
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            maxLength: 256,
            onSaved: (value) {
              context["email"] = value;
            },
            color: config.formColor,
            backgroundColor: config.formBackgroundColor,
          ),
          FormItemLabel("Password".localize(), color: config.formColor),
          FormItemTextField(
            hintText: "Please enter a password".localize(),
            keyboardType: TextInputType.visiblePassword,
            maxLines: 1,
            minLength: 8,
            maxLength: 36,
            obscureText: true,
            onSaved: (value) {
              context["password"] = value;
            },
            color: config.formColor,
            backgroundColor: config.formBackgroundColor,
          ),
          FormItemLabel("ConfirmationPassword".localize(),
              color: config.formColor),
          FormItemTextField(
            hintText: "Please enter a password".localize(),
            keyboardType: TextInputType.visiblePassword,
            maxLines: 1,
            minLength: 8,
            maxLength: 36,
            obscureText: true,
            onSaved: (value) {
              context["passwordConfirm"] = value;
            },
            color: config.formColor,
            backgroundColor: config.formBackgroundColor,
          ),
          ...config.registerForm.map((e) => e.build(context))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!validate(context)) {
            return;
          }
          if (context.get("password", "") !=
              context.get("passwordConfirm", "")) {
            UIDialog.show(
              context,
              title: "Error".localize(),
              text: "Passwords do not match.".localize(),
              submitText: "Close".localize(),
            );
          }
          try {
            await context.model
                ?.registerInEmailAndPassword(
                  email: context.get("email", ""),
                  password: context.get("password", ""),
                )
                .showIndicator(context);
            UIDialog.show(
              context,
              title: "Complete".localize(),
              text: "Registration has been completed.".localize(),
              submitText: "Forward".localize(),
              onSubmit: () {
                context.navigator.pushNamed(config.redirectTo);
              },
            );
          } catch (e) {
            UIDialog.show(
              context,
              title: "Error".localize(),
              text:
                  "Could not register. It may already be registered. Please check your email address and password again."
                      .localize(),
              submitText: "Close".localize(),
            );
          }
        },
        icon: const Icon(Icons.check),
        label: Text(
          "Registration".localize(),
        ),
        backgroundColor: role.color ?? context.theme.accentColor,
      ),
    );
  }
}

class PasswordReset extends PageHookWidget with UIPageFormMixin {
  PasswordReset(this.config);
  final LoginModule config;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: config.backgroundColor,
      appBar: AppBar(
        backgroundColor: config.login.color ?? context.theme.primaryColor,
        title: Text("Password reset".localize()),
      ),
      body: FormBuilder(
        type: FormBuilderType.center,
        key: formKey,
        padding: config.padding,
        children: [
          FormItemLabel("Email".localize(), color: config.formColor),
          FormItemTextField(
            hintText: "Please enter a email address".localize(),
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            maxLength: 256,
            onSaved: (value) {
              context["email"] = value;
            },
            color: config.formColor,
            backgroundColor: config.formBackgroundColor,
          ),
          MessageBox(
            "Email to reset your password will be sent to the email address you specified. Please reset your password from the link in the email you received."
                .localize(),
            color: config.formColor ?? context.theme.accentColor,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!validate(context)) {
            return;
          }
          try {
            await context.model
                ?.sendPasswordResetEmail(
                  email: context.get("email", ""),
                )
                .showIndicator(context);
            UIDialog.show(
              context,
              title: "Complete".localize(),
              text:
                  "Password reset email has been sent to the specified email address. Please login again after resetting the password."
                      .localize(),
              submitText: "Back".localize(),
              onSubmit: () {
                context.navigator.pop();
              },
            );
          } catch (e) {
            UIDialog.show(
              context,
              title: "Error".localize(),
              text:
                  "The specified email address did not exist. Please check your email address."
                      .localize(),
              submitText: "Close".localize(),
            );
          }
        },
        icon: const Icon(Icons.send),
        label: Text(
          "Send mail".localize(),
        ),
        backgroundColor: config.login.color ?? context.theme.primaryColor,
      ),
    );
  }
}
