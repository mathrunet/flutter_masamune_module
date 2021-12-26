import 'dart:ui';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masamune_module/masamune_module.dart';

part 'sns_login.m.dart';

@module
@immutable
class SnsLoginModule extends PageModule {
  const SnsLoginModule({
    this.layoutType = LoginLayoutType.fixed,
    this.snsTypes = const [
      SnsLoginType.apple,
      SnsLoginType.google,
    ],
    bool enabled = true,
    String? title,
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
    this.featureImageRadius,
    this.featureImageSize,
    this.roleKey = Const.role,
    this.formImageSize,
    this.featureImageFit = BoxFit.cover,
    this.titleTextStyle,
    this.titleAlignment = Alignment.bottomLeft,
    this.guestLogin,
    this.titlePadding =
        const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    this.padding = const EdgeInsets.all(36),
    this.redirectTo = "/",
    this.registerVariables = const [],
    this.showOnlyRequiredVariable = true,
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
  }) : super(
          enabled: enabled,
          title: title,
          permission: permission,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig> get routeSettings {
    if (!enabled) {
      return const {};
    }

    final route = {
      "/landing": RouteConfig((_) => SnsLoginModuleLanding(this)),
      "/register": RouteConfig((_) => SnsLoginModuleRegister(this)),
    };
    return route;
  }

  /// レイアウトタイプ。
  final LoginLayoutType layoutType;

  /// SNSログインタイプ。
  final List<SnsLoginType> snsTypes;

  /// 前景色。
  final Color? color;

  /// ユーザーコレクションのパス。
  final String userPath;

  /// ロールのキー。
  final String roleKey;

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

  /// ゲストログイン用の設定。
  final LoginConfig? guestLogin;

  /// ログイン後のパス。
  final String redirectTo;

  /// 登録時の値データ。
  final List<VariableConfig> registerVariables;

  /// `true` if you want to show only necessary values at registration.
  final bool showOnlyRequiredVariable;

  @override
  SnsLoginModule? fromMap(DynamicMap map) => _$SnsLoginModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$SnsLoginModuleToMap(this);
}

class SnsLoginModuleLanding extends PageScopedWidget {
  const SnsLoginModuleLanding(this.config);
  final SnsLoginModule config;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animation = ref.useAutoPlayAnimationScenario(
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
                                  for (final type in config.snsTypes)
                                    _snsButton(context, type),
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
                                                    "/register");
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

  Widget _snsButton(BuildContext context, SnsLoginType type) {
    final buttonColor = config.buttonColor ?? config.color ?? Colors.white;
    final buttonBackgroundColor =
        config.buttonBackgroundColor ?? Colors.transparent;
    switch (type) {
      case SnsLoginType.apple:
        if (!Config.isIOS) {
          return const Empty();
        }
        return FormItemSubmit(
          "Apple SignIn".localize(),
          borderRadius: 35,
          height: 70,
          width: 1.6,
          color: buttonColor,
          borderColor: buttonColor,
          backgroundColor: buttonBackgroundColor,
          icon: FontAwesomeIcons.apple,
          onPressed: () {
            try {
              if (_hasRegistrationData(context)) {
                context.navigator.pushReplacementNamed("/register");
              } else {
                context.navigator.pushReplacementNamed(config.redirectTo);
              }
            } catch (e) {
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "Could not login. Please check your information."
                    .localize(),
              );
            }
          },
        );
      case SnsLoginType.google:
        return FormItemSubmit(
          "Google SignIn".localize(),
          borderRadius: 35,
          height: 70,
          width: 1.6,
          color: buttonColor,
          borderColor: buttonColor,
          backgroundColor: buttonBackgroundColor,
          icon: FontAwesomeIcons.google,
          onPressed: () {
            try {
              if (_hasRegistrationData(context)) {
                context.navigator.pushReplacementNamed("/register");
              } else {
                context.navigator.pushReplacementNamed(config.redirectTo);
              }
            } catch (e) {
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "Could not login. Please check your information."
                    .localize(),
              );
            }
          },
        );
      case SnsLoginType.facebook:
        return FormItemSubmit(
          "Facebook SignIn".localize(),
          borderRadius: 35,
          height: 70,
          width: 1.6,
          color: buttonColor,
          borderColor: buttonColor,
          backgroundColor: buttonBackgroundColor,
          icon: FontAwesomeIcons.facebook,
          onPressed: () {
            try {
              if (_hasRegistrationData(context)) {
                context.navigator.pushReplacementNamed("/register");
              } else {
                context.navigator.pushReplacementNamed(config.redirectTo);
              }
            } catch (e) {
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "Could not login. Please check your information."
                    .localize(),
              );
            }
          },
        );
      case SnsLoginType.twitter:
        return FormItemSubmit(
          "Twitter SignIn".localize(),
          borderRadius: 35,
          height: 70,
          width: 1.6,
          color: buttonColor,
          borderColor: buttonColor,
          backgroundColor: buttonBackgroundColor,
          icon: FontAwesomeIcons.twitter,
          onPressed: () {
            try {
              if (_hasRegistrationData(context)) {
                context.navigator.pushReplacementNamed("/register");
              } else {
                context.navigator.pushReplacementNamed(config.redirectTo);
              }
            } catch (e) {
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "Could not login. Please check your information."
                    .localize(),
              );
            }
          },
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

class _LoginModuleBackgroundImage extends StatelessWidget {
  const _LoginModuleBackgroundImage(
    this.config, {
    this.opacity = 0.75,
  });
  final SnsLoginModule config;
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

class SnsLoginModuleRegister extends PageScopedWidget {
  const SnsLoginModuleRegister(this.config);
  final SnsLoginModule config;

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
