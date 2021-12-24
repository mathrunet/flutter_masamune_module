import 'dart:ui';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masamune_module/masamune_module.dart';

part 'login_and_register.m.dart';

@module
@immutable
class LoginModule extends PageModule {
  const LoginModule({
    bool enabled = true,
    String title = "",
    this.layoutType = LoginLayoutType.fixed,
    this.color,
    this.userPath = Const.user,
    this.backgroundColor,
    this.backgroundGradient,
    this.appBarColorOnSliverList,
    this.appBarHeightOnSliverList,
    this.buttonColor,
    this.buttonBackgroundColor,
    this.backgroundImage,
    this.backgroundImageBlur = 5.0,
    this.featureImage,
    this.featureImageSize,
    this.featureImageRadius,
    this.roleKey = Const.role,
    this.formImageSize,
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
    this.padding = const EdgeInsets.all(36),
    this.redirectTo = "/",
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
    this.registerVariables = const [],
    this.showOnlyRequiredVariable = true,
  }) : super(
          enabled: enabled,
          title: title,
          permission: permission,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/landing": RouteConfig((_) => LoginModuleLanding(this)),
      "/login": RouteConfig((_) => LoginModuleLogin(this)),
      "/reset": RouteConfig((_) => LoginModulePasswordReset(this)),
      "/register": RouteConfig((_) => LoginModuleRegister(this)),
      "/register/anonymous":
          RouteConfig((_) => LoginModuleRegisterAnonymous(this)),
      "/register/{role_id}": RouteConfig((_) => LoginModuleRegister(this)),
    };
    return route;
  }

  /// レイアウトタイプ。
  final LoginLayoutType layoutType;

  /// 前景色。
  final Color? color;

  /// ロールのキー。
  final String roleKey;

  /// ユーザーコレクションのパス。
  final String userPath;

  /// 背景色。
  final Color? backgroundColor;

  /// 背景グラデーション。
  final Gradient? backgroundGradient;

  /// AppBarの背景色。Sliver時のみ。
  final Color? appBarColorOnSliverList;

  /// AppBarの高さ。Sliver時のみ。
  final double? appBarHeightOnSliverList;

  /// フィーチャー画像。
  final String? featureImage;

  /// フィーチャー画像の丸み。
  final BorderRadius? featureImageRadius;

  /// フィーチャー画像の配置。
  final BoxFit featureImageFit;

  /// フィーチャー画像のサイズ。
  final Size? featureImageSize;

  /// フォーム画像のサイズ。
  final Size? formImageSize;

  /// 背景画像。
  final String? backgroundImage;

  /// 背景のブラーを設定する度合い。
  final double? backgroundImageBlur;

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

  /// 登録時の値データ。
  final List<VariableConfig> registerVariables;

  /// `true` if you want to show only necessary values at registration.
  final bool showOnlyRequiredVariable;

  @override
  LoginModule? fromMap(DynamicMap map) => _$LoginModuleFromMap(map, this);
  @override
  DynamicMap toMap() => _$LoginModuleToMap(this);
}

class LoginModuleLanding extends PageScopedWidget {
  const LoginModuleLanding(this.config);
  final LoginModule config;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animation = ref.useAutoAnimationScenario(
      "main",
      [
        AnimationUnit(
          tween: DoubleTween(begin: 0, end: 1),
          from: const Duration(milliseconds: 500),
          to: const Duration(milliseconds: 1500),
          tag: "opacity",
        ),
      ],
    );

    final color = config.color ?? Colors.white;
    final buttonColor = config.buttonColor ?? config.color ?? Colors.white;
    final buttonBackgroundColor =
        config.buttonBackgroundColor ?? Colors.transparent;

    switch (config.layoutType) {
      case LoginLayoutType.fixed:
        return UIScaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              _LoginModuleBackgroundImage(config, opacity: 0.75),
              AnimationScope(
                animation: animation,
                builder: (context, child, animation) {
                  return Opacity(
                    opacity: animation.get("opacity", 0),
                    child: Column(
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
                                    child: ClipRRect(
                                      borderRadius: config.featureImageRadius ??
                                          BorderRadius.zero,
                                      child: Image(
                                        image: NetworkOrAsset.image(
                                            config.featureImage!),
                                        fit: config.featureImageFit,
                                      ),
                                    ),
                                  ),
                                if (config.title.isNotEmpty)
                                  Align(
                                    alignment: config.titleAlignment,
                                    child: Padding(
                                      padding: config.titlePadding,
                                      child: DefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: 56,
                                          fontFamily: "Mplus",
                                          fontWeight: FontWeight.w700,
                                          color: color,
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
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: config.padding,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  for (final role in context.roles)
                                    FormItemSubmit(
                                      role.label.isNotEmpty
                                          ? ("%s registration"
                                              .localize()
                                              .format([role.label!.localize()]))
                                          : "Registration".localize(),
                                      borderRadius: 35,
                                      height: 70,
                                      width: 1.6,
                                      color: buttonColor,
                                      borderColor: buttonColor,
                                      backgroundColor: buttonBackgroundColor,
                                      icon: role.icon,
                                      onPressed: () {
                                        if (role.path.isNotEmpty) {
                                          context.navigator
                                              .pushNamed(role.path!);
                                        } else {
                                          if (context.roles.length <= 1) {
                                            context.navigator.pushNamed(
                                                "/register",
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
                                      borderRadius: 35,
                                      height: 70,
                                      width: 1.6,
                                      color: buttonColor,
                                      borderColor: buttonColor,
                                      backgroundColor: buttonBackgroundColor,
                                      icon: config.guestLogin!.icon,
                                      onPressed: () async {
                                        try {
                                          await context.model
                                              ?.signInAnonymously()
                                              .showIndicator(context);
                                          if (_hasRegistrationData(context)) {
                                            context.navigator
                                                .pushReplacementNamed(
                                                    "/register/anonymous");
                                          } else {
                                            context.navigator
                                                .pushReplacementNamed(
                                                    config.redirectTo);
                                          }
                                        } catch (e) {
                                          UIDialog.show(
                                            context,
                                            title: "Error".localize(),
                                            text:
                                                "Could not login. Please check your information."
                                                    .localize(),
                                          );
                                        }
                                      },
                                    ),
                                  FormItemSubmit(
                                    config.login.label?.localize() ??
                                        "Login".localize(),
                                    borderRadius: 35,
                                    height: 70,
                                    width: 1.6,
                                    color: buttonColor,
                                    borderColor: buttonColor,
                                    backgroundColor: buttonBackgroundColor,
                                    icon: config.login.icon,
                                    onPressed: () {
                                      context.navigator.pushNamed("/login",
                                          arguments: RouteQuery.fade);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
    }
  }

  bool _hasRegistrationData(BuildContext context) {
    return (context.app?.userVariables
                    .where(
                        (e) => !config.showOnlyRequiredVariable || e.required)
                    .length ??
                0) +
            config.registerVariables
                .where((e) => !config.showOnlyRequiredVariable || e.required)
                .length >
        0;
  }
}

class LoginModuleLogin extends PageScopedWidget {
  const LoginModuleLogin(this.config);
  final LoginModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.useForm();
    final emailFocus = ref.useFocusNode("email");
    final passFocus = ref.useFocusNode("pass");
    final showPassword = ref.state("showPassword", false);

    final color = config.color ?? Colors.white;
    final buttonColor = config.buttonColor ?? config.color ?? Colors.white;
    final buttonBackgroundColor =
        config.buttonBackgroundColor ?? Colors.transparent;
    final imageSize = _imageSize();

    return Scaffold(
      backgroundColor: config.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: color,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _LoginModuleBackgroundImage(config, opacity: 0.75),
          FormBuilder(
            type: FormBuilderType.center,
            key: form.key,
            padding: const EdgeInsets.all(0),
            children: [
              const Space.height(24),
              if (config.featureImage.isNotEmpty)
                Center(
                  child: SizedBox(
                    width: imageSize?.width,
                    height: imageSize?.height,
                    child: ClipRRect(
                      borderRadius: config.featureImageRadius,
                      child: Image(
                        image: NetworkOrAsset.image(config.featureImage!),
                        fit: config.featureImageFit,
                      ),
                    ),
                  ),
                )
              else
                Center(
                  child: Text(
                    config.login.label?.localize() ?? "Login".localize(),
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.headline5
                            ?.copyWith(color: config.color) ??
                        TextStyle(color: config.color),
                  ),
                ),
              const Space.height(36),
              DividHeadline("Email".localize(),
                  icon: Icons.email, color: color.withOpacity(0.75)),
              FormItemTextField(
                dense: true,
                focusNode: emailFocus,
                hintText: "Input %s".localize().format(["Email".localize()]),
                errorText:
                    "No input %s".localize().format(["Email".localize()]),
                keyboardType: TextInputType.emailAddress,
                color: color,
                cursorColor: color,
                subColor: color.withOpacity(0.5),
                maxLines: 1,
                minLength: 2,
                maxLength: 256,
                onSaved: (value) {
                  context["email"] = value;
                },
                onSubmitted: (value) {
                  passFocus.requestFocus();
                },
              ),
              DividHeadline("Password".localize(),
                  icon: Icons.lock, color: color.withOpacity(0.75)),
              FormItemTextField(
                dense: true,
                focusNode: passFocus,
                hintText: "Input %s".localize().format(["Password".localize()]),
                errorText:
                    "No input %s".localize().format(["Password".localize()]),
                keyboardType: TextInputType.visiblePassword,
                color: color,
                cursorColor: color,
                subColor: color.withOpacity(0.5),
                maxLines: 1,
                minLength: 8,
                maxLength: 36,
                obscureText: !showPassword.value,
                onSaved: (value) {
                  context["password"] = value;
                },
                suffixIcon: GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 18, 0),
                    child: Icon(
                      !showPassword.value
                          ? FontAwesomeIcons.solidEyeSlash
                          : FontAwesomeIcons.solidEye,
                      color: color.withOpacity(0.5),
                      size: 21,
                    ),
                  ),
                  onTap: () {
                    showPassword.value = !showPassword.value;
                  },
                ),
                suffixIconConstraints:
                    const BoxConstraints(minHeight: 0, minWidth: 0),
                onSubmitted: (value) => _onSubmitted(context, ref, form),
              ),
              Divid(color: color.withOpacity(0.75)),
              const Space.height(16),
              Indent(
                padding: EdgeInsets.symmetric(
                    horizontal: config.padding.horizontal / 2.0),
                children: [
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.navigator
                            .pushNamed("/reset", arguments: RouteQuery.fade);
                      },
                      child: Text(
                        "Click here if you forget your password".localize(),
                        style: TextStyle(
                          color: color,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const Space.height(16),
                  FormItemSubmit(
                    config.login.label?.localize() ?? "Login".localize(),
                    borderRadius: 35,
                    height: 70,
                    width: 1.6,
                    color: buttonColor,
                    backgroundColor: buttonBackgroundColor,
                    borderColor: buttonColor,
                    icon: Icons.check,
                    onPressed: () => _onSubmitted(context, ref, form),
                  )
                ],
              ),
              const Space.height(24),
            ],
          ),
        ],
      ),
    );
  }

  Size? _imageSize() {
    if (config.formImageSize != null) {
      return config.formImageSize;
    }
    if (config.featureImageSize != null) {
      return config.featureImageSize! / 2.0;
    }
    return null;
  }

  Future<void> _onSubmitted(
    BuildContext context,
    WidgetRef ref,
    FormContext form,
  ) async {
    if (!form.validate()) {
      return;
    }
    try {
      await context.model
          ?.signInEmailAndPassword(
            email: context.get("email", ""),
            password: context.get("password", ""),
            userPath: config.userPath,
          )
          .showIndicator(context);
      context.navigator.pushReplacementNamed(config.redirectTo);
    } catch (e) {
      UIDialog.show(
        context,
        title: "Error".localize(),
        text: "Could not login. Please check your email address and password."
            .localize(),
        submitText: "Close".localize(),
      );
    }
  }
}

class LoginModuleRegister extends PageScopedWidget {
  const LoginModuleRegister(this.config);
  final LoginModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.useForm();
    final emailFocus = ref.useFocusNode("email");
    final passFocus = ref.useFocusNode("pass");
    final passConfirmFocus = ref.useFocusNode("passConfirm");
    final showPassword = ref.state("showPassword", false);
    final showPasswordConfirm = ref.state("showPasswordConfirm", false);
    final role = context.roles.length <= 1
        ? context.roles.first
        : context.roles
            .firstWhere((element) => element.id == context.get("role_id", ""));

    final color = config.color ?? Colors.white;
    final buttonColor = config.buttonColor ?? config.color ?? Colors.white;
    final buttonBackgroundColor =
        config.buttonBackgroundColor ?? Colors.transparent;
    final imageSize = _imageSize();

    return Scaffold(
      backgroundColor: config.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: color,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _LoginModuleBackgroundImage(config, opacity: 0.75),
          FormBuilder(
            type: FormBuilderType.center,
            key: form.key,
            padding: const EdgeInsets.all(0),
            children: [
              const Space.height(24),
              if (config.featureImage.isNotEmpty)
                Center(
                  child: SizedBox(
                    width: imageSize?.width,
                    height: imageSize?.height,
                    child: ClipRRect(
                      borderRadius: config.featureImageRadius,
                      child: Image(
                        image: NetworkOrAsset.image(config.featureImage!),
                        fit: config.featureImageFit,
                      ),
                    ),
                  ),
                )
              else
                Center(
                  child: Text(
                    role.label.isNotEmpty
                        ? "%s registration"
                            .localize()
                            .format([role.label!.localize()])
                        : "Registration".localize(),
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.headline5
                            ?.copyWith(color: config.color) ??
                        TextStyle(color: config.color),
                  ),
                ),
              const Space.height(36),
              DividHeadline("Email".localize(),
                  icon: Icons.email, color: color.withOpacity(0.75)),
              FormItemTextField(
                dense: true,
                hintText: "Input %s".localize().format(["Email".localize()]),
                errorText:
                    "No input %s".localize().format(["Email".localize()]),
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                maxLength: 256,
                color: color,
                cursorColor: color,
                subColor: color.withOpacity(0.5),
                focusNode: emailFocus,
                onSaved: (value) {
                  context["email"] = value;
                },
                onSubmitted: (value) {
                  passFocus.requestFocus();
                },
              ),
              DividHeadline("Password".localize(),
                  icon: Icons.lock, color: color.withOpacity(0.75)),
              FormItemTextField(
                dense: true,
                hintText: "Input %s".localize().format(["Password".localize()]),
                errorText:
                    "No input %s".localize().format(["Password".localize()]),
                keyboardType: TextInputType.visiblePassword,
                maxLines: 1,
                minLength: 8,
                maxLength: 36,
                color: color,
                cursorColor: color,
                subColor: color.withOpacity(0.5),
                obscureText: !showPassword.value,
                onSaved: (value) {
                  context["password"] = value;
                },
                focusNode: passFocus,
                suffixIcon: GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 18, 0),
                    child: Icon(
                      !showPassword.value
                          ? FontAwesomeIcons.solidEyeSlash
                          : FontAwesomeIcons.solidEye,
                      color: color.withOpacity(0.5),
                      size: 21,
                    ),
                  ),
                  onTap: () {
                    showPassword.value = !showPassword.value;
                  },
                ),
                suffixIconConstraints:
                    const BoxConstraints(minHeight: 0, minWidth: 0),
                onSubmitted: (value) {
                  passConfirmFocus.requestFocus();
                },
              ),
              DividHeadline("ConfirmationPassword".localize(),
                  icon: Icons.lock, color: color.withOpacity(0.75)),
              FormItemTextField(
                dense: true,
                hintText: "Input %s".localize().format(["Password".localize()]),
                errorText:
                    "No input %s".localize().format(["Password".localize()]),
                keyboardType: TextInputType.visiblePassword,
                maxLines: 1,
                minLength: 8,
                maxLength: 36,
                color: color,
                cursorColor: color,
                subColor: color.withOpacity(0.5),
                focusNode: passConfirmFocus,
                obscureText: !showPasswordConfirm.value,
                onSaved: (value) {
                  context["passwordConfirm"] = value;
                },
                suffixIcon: GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 18, 0),
                    child: Icon(
                      !showPasswordConfirm.value
                          ? FontAwesomeIcons.solidEyeSlash
                          : FontAwesomeIcons.solidEye,
                      color: color.withOpacity(0.5),
                      size: 21,
                    ),
                  ),
                  onTap: () {
                    showPasswordConfirm.value = !showPasswordConfirm.value;
                  },
                ),
                suffixIconConstraints:
                    const BoxConstraints(minHeight: 0, minWidth: 0),
                onSubmitted: (value) {
                  _onSubmitted(context, ref, form, role);
                },
              ),
              ...context.app?.userVariables.buildForm(
                    context,
                    ref,
                    onlyRequired: config.showOnlyRequiredVariable,
                  ) ??
                  [],
              ...config.registerVariables.buildForm(
                context,
                ref,
                onlyRequired: config.showOnlyRequiredVariable,
              ),
              Divid(color: color.withOpacity(0.75)),
              if (context.app?.termsUrl != null)
                FormItemCheckbox(
                  dense: true,
                  needToCheck: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 4.5),
                  labelText: "Agree to the %s".localize().format([
                    "[${"Terms".localize()}](${context.app?.termsUrl})",
                  ]),
                  errorText: "Please agree to the %s"
                      .localize()
                      .format(["Terms".localize()]),
                  color: color,
                  checkColor: context.theme.primaryColor,
                  activeColor: color,
                  linkTextStyle: TextStyle(
                      color: color, decoration: TextDecoration.underline),
                  onSaved: (value) {
                    context["terms"] = value;
                  },
                ),
              Divid(color: color.withOpacity(0.75)),
              const Space.height(24),
              Indent(
                padding: EdgeInsets.symmetric(
                    horizontal: config.padding.horizontal / 2.0),
                children: [
                  FormItemSubmit(
                    role.label.isNotEmpty
                        ? "%s registration"
                            .localize()
                            .format([role.label!.localize()])
                        : "Registration".localize(),
                    borderRadius: 35,
                    height: 70,
                    width: 1.6,
                    color: buttonColor,
                    backgroundColor: buttonBackgroundColor,
                    borderColor: buttonColor,
                    icon: Icons.check,
                    onPressed: () => _onSubmitted(context, ref, form, role),
                  )
                ],
              ),
              const Space.height(24),
            ],
          ),
        ],
      ),
    );
  }

  Size? _imageSize() {
    if (config.formImageSize != null) {
      return config.formImageSize;
    }
    if (config.featureImageSize != null) {
      return config.featureImageSize! / 2.0;
    }
    return null;
  }

  Future<void> _onSubmitted(
    BuildContext context,
    WidgetRef ref,
    FormContext form,
    RoleConfig role,
  ) async {
    if (await context.model?.skipRegistration(data: {
          config.roleKey: role.id,
        }) ??
        false) {
      context.navigator.pushReplacementNamed(config.redirectTo);
      return;
    }
    if (!form.validate()) {
      return;
    }
    if (context.get("password", "") != context.get("passwordConfirm", "")) {
      UIDialog.show(
        context,
        title: "Error".localize(),
        text: "Passwords do not match.".localize(),
        submitText: "Close".localize(),
      );
      return;
    }
    if (context.app?.termsUrl != null && !context.get("terms", false)) {
      UIDialog.show(
        context,
        title: "Error".localize(),
        text: "Please agree to the %s".localize().format(["Terms".localize()]),
        submitText: "Close".localize(),
      );
      return;
    }
    try {
      await context.model?.registerInEmailAndPassword(
        email: context.get("email", ""),
        password: context.get("password", ""),
        userPath: config.userPath,
        data: {
          config.roleKey: role.id,
          ...context.app?.userVariables.buildMap(
                context,
                ref,
                onlyRequired: config.showOnlyRequiredVariable,
              ) ??
              {},
          ...config.registerVariables.buildMap(
            context,
            ref,
            onlyRequired: config.showOnlyRequiredVariable,
          ),
        },
      ).showIndicator(context);
      UIDialog.show(
        context,
        title: "Complete".localize(),
        text: "Registration has been completed.".localize(),
        submitText: "Forward".localize(),
        onSubmit: () {
          context.navigator.pushReplacementNamed(config.redirectTo);
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
  }
}

class LoginModulePasswordReset extends PageScopedWidget {
  const LoginModulePasswordReset(this.config);
  final LoginModule config;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.useForm();
    final emailFocus = ref.useFocusNode("main");

    final color = config.color ?? Colors.white;
    final buttonColor = config.buttonColor ?? config.color ?? Colors.white;
    final buttonBackgroundColor =
        config.buttonBackgroundColor ?? Colors.transparent;
    final imageSize = _imageSize();

    return Scaffold(
      backgroundColor: config.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: color,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _LoginModuleBackgroundImage(config, opacity: 0.75),
          FormBuilder(
            type: FormBuilderType.center,
            key: form.key,
            padding: const EdgeInsets.all(0),
            children: [
              const Space.height(24),
              if (config.featureImage.isNotEmpty)
                Center(
                  child: SizedBox(
                    width: imageSize?.width,
                    height: imageSize?.height,
                    child: ClipRRect(
                      borderRadius: config.featureImageRadius,
                      child: Image(
                        image: NetworkOrAsset.image(config.featureImage!),
                        fit: config.featureImageFit,
                      ),
                    ),
                  ),
                )
              else
                Center(
                  child: Text(
                    "Password reset".localize(),
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.headline5
                            ?.copyWith(color: config.color) ??
                        TextStyle(color: config.color),
                  ),
                ),
              const Space.height(24),
              MessageBox(
                "Email to reset your password will be sent to the email address you specified. Please reset your password from the link in the email you received."
                    .localize(),
                color: color,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              const Space.height(24),
              DividHeadline("Email".localize(),
                  icon: Icons.email, color: color.withOpacity(0.75)),
              FormItemTextField(
                dense: true,
                focusNode: emailFocus,
                hintText: "Input %s".localize().format(["Email".localize()]),
                errorText:
                    "No input %s".localize().format(["Email".localize()]),
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                maxLength: 256,
                color: color,
                cursorColor: color,
                subColor: color.withOpacity(0.5),
                onSaved: (value) {
                  context["email"] = value;
                },
                onSubmitted: (value) => _onSubmitted(context, ref, form),
              ),
              Divid(color: color.withOpacity(0.75)),
              const Space.height(24),
              Indent(
                padding: EdgeInsets.symmetric(
                    horizontal: config.padding.horizontal / 2.0),
                children: [
                  FormItemSubmit(
                    "Send mail".localize(),
                    borderRadius: 35,
                    height: 70,
                    width: 1.6,
                    color: buttonColor,
                    backgroundColor: buttonBackgroundColor,
                    borderColor: buttonColor,
                    icon: Icons.send,
                    onPressed: () => _onSubmitted(context, ref, form),
                  ),
                ],
              ),
              const Space.height(24),
            ],
          ),
        ],
      ),
    );
  }

  Size? _imageSize() {
    if (config.formImageSize != null) {
      return config.formImageSize;
    }
    if (config.featureImageSize != null) {
      return config.featureImageSize! / 2.0;
    }
    return null;
  }

  Future<void> _onSubmitted(
    BuildContext context,
    WidgetRef ref,
    FormContext form,
  ) async {
    if (!form.validate()) {
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
  }
}

class _LoginModuleBackgroundImage extends StatelessWidget {
  const _LoginModuleBackgroundImage(
    this.config, {
    this.opacity = 0.75,
  });
  final LoginModule config;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (config.backgroundImage.isNotEmpty) ...[
          Image(
            image: NetworkOrAsset.image(config.backgroundImage!),
            fit: BoxFit.cover,
          ),
          if (config.backgroundImageBlur != null)
            BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: config.backgroundImageBlur!,
                  sigmaY: config.backgroundImageBlur!),
              child: _backgroundColor(context, opacity),
            )
          else
            _backgroundColor(context, opacity),
        ] else ...[
          _backgroundColor(context),
        ],
      ],
    );
  }

  Widget _backgroundColor(BuildContext context, [double opacity = 1.0]) {
    if (config.backgroundGradient != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: config.backgroundGradient,
        ),
      );
    } else if (opacity < 1.0) {
      return ColoredBox(
        color: (config.backgroundColor ?? context.theme.backgroundColor)
            .withOpacity(opacity),
      );
    } else {
      return ColoredBox(
          color: config.backgroundColor ?? context.theme.backgroundColor);
    }
  }
}

class LoginModuleRegisterAnonymous extends PageScopedWidget {
  const LoginModuleRegisterAnonymous(this.config);
  final LoginModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.useForm();

    return UIScaffold(
      designType: DesignType.material,
      appBar: UIAppBar(
        designType: DesignType.material,
        title: Text("Registration".localize()),
      ),
      body: FormBuilder(
        key: form.key,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ...context.app?.userVariables.buildForm(
                context,
                ref,
                onlyRequired: config.showOnlyRequiredVariable,
              ) ??
              [],
          ...config.registerVariables.buildForm(
            context,
            ref,
            onlyRequired: config.showOnlyRequiredVariable,
          ),
          const Divid(),
          const Space.height(120),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!form.validate()) {
            return;
          }
          try {
            final userId = context.model?.userId;
            if (userId.isEmpty) {
              throw Exception("User id is not found.");
            }
            final collection = ref.readCollectionModel(config.userPath);
            final doc = context.model?.createDocument(collection, userId);
            if (doc == null) {
              throw Exception("User document has not created.");
            }
            context.app?.userVariables.buildValue(doc, context, ref);
            await context.model?.saveDocument(doc).showIndicator(context);
            context.navigator.pushReplacementNamed(config.redirectTo);
          } catch (e) {
            UIDialog.show(
              context,
              title: "Error".localize(),
              text: "Invalid error.".localize(),
              submitText: "Close".localize(),
            );
          }
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
