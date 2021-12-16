import 'dart:ui';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masamune/masamune.dart';
import 'package:masamune/ui/ui.dart';
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
    this.registerForm = const [],
    Permission permission = const Permission(),
    RerouteConfig? rerouteConfig,
  }) : super(
          enabled: enabled,
          title: title,
          permission: permission,
          rerouteConfig: rerouteConfig,
        );

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }

    final route = {
      "/landing": RouteConfig((_) => SnsLoginModuleLanding(this)),
    };
    return route;
  }

  /// レイアウトタイプ。
  final LoginLayoutType layoutType;

  /// SNSログインタイプ。
  final List<SnsLoginType> snsTypes;

  /// 前景色。
  final Color? color;

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

  /// 登録時のフォームデータ。
  final List<FormConfig> registerForm;

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
                                    child: Image(
                                      image: NetworkOrAsset.image(
                                          config.featureImage!),
                                      fit: config.featureImageFit,
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
                                          context.navigator
                                              .pushNamed(config.redirectTo);
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
              context.navigator.pushNamed(config.redirectTo);
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
              context.navigator.pushNamed(config.redirectTo);
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
              context.navigator.pushNamed(config.redirectTo);
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
              context.navigator.pushNamed(config.redirectTo);
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