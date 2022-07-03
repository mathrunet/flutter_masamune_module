import 'dart:ui';

import 'package:masamune_module/masamune_module.dart';

@immutable
class SnsLoginModule extends PageModule {
  const SnsLoginModule({
    this.layoutType = LoginLayoutType.fixed,
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
    this.featureImageRadius = BorderRadius.zero,
    this.featureImageSize = const Size(256, 256),
    this.formImageSize,
    this.featureImageFit = BoxFit.cover,
    this.titleTextStyle,
    this.titleTextAlignment = TextAlign.start,
    this.titleAlignment = Alignment.bottomLeft,
    this.titlePadding =
        const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    this.padding = const EdgeInsets.all(36),
    this.redirectTo = "/",
    this.registerVariables = const [],
    this.showOnlyRequiredVariable = true,
    this.anonymousSignInConfig,
    this.runAfterFinishBootHooksOnRidirect = true,
    List<RerouteConfig> rerouteConfigs = const [],
    this.landingPage = const SnsLoginModuleLanding(),
    this.registerPage = const SnsLoginModuleRegister(),
  }) : super(
          enabled: enabled,
          title: title,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig> get routeSettings {
    if (!enabled) {
      return const {};
    }

    final route = {
      "/landing": RouteConfig((_) => landingPage),
    };
    return route;
  }

  /// Widget.
  final PageModuleWidget<SnsLoginModule> landingPage;
  final PageModuleWidget<SnsLoginModule> registerPage;

  /// レイアウトタイプ。
  final LoginLayoutType layoutType;

  /// 前景色。
  final Color? color;

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

  /// タイトルのテキストの位置。
  final TextAlign titleTextAlignment;

  /// タイトルの位置。
  final Alignment titleAlignment;

  /// タイトルのパディング。
  final EdgeInsetsGeometry titlePadding;

  /// コンテンツのパディング。
  final EdgeInsetsGeometry padding;

  /// ログイン後のパス。
  final String redirectTo;

  /// 登録時の値データ。
  final List<VariableConfig> registerVariables;

  /// `true` if you want to show only necessary values at registration.
  final bool showOnlyRequiredVariable;

  /// 匿名ログイン用のテキストやアイコン。
  final MenuConfig? anonymousSignInConfig;

  /// True if [AfterFinishBoot] hook is executed on redirect.
  final bool runAfterFinishBootHooksOnRidirect;
}

class SnsLoginModuleLanding extends PageModuleWidget<SnsLoginModule> {
  const SnsLoginModuleLanding();

  @override
  Widget build(BuildContext context, WidgetRef ref, SnsLoginModule module) {
    final animation = ref.useAutoPlayAnimationScenario(
      "main",
      [
        AnimationUnit(
          tween: DoubleTween(begin: 0.0, end: 1.0),
          from: const Duration(milliseconds: 500),
          to: const Duration(milliseconds: 1500),
          tag: "opacity",
        ),
      ],
    );

    final color = module.color ?? context.theme.textColor;

    switch (module.layoutType) {
      case LoginLayoutType.fixed:
        return UIScaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              _LoginModuleBackgroundImage(module, opacity: 0.75),
              AnimationScope(
                animation: animation,
                builder: (context, child, animation) {
                  return Opacity(
                    opacity: animation.get("opacity", 0.0),
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
                                if (module.featureImage.isNotEmpty)
                                  SizedBox(
                                    width: module.featureImageSize?.width,
                                    height: module.featureImageSize?.height,
                                    child: ClipRRect(
                                      borderRadius: module.featureImageRadius ??
                                          BorderRadius.zero,
                                      child: Image(
                                        image: NetworkOrAsset.image(
                                          module.featureImage!,
                                          ImageSize.medium,
                                        ),
                                        fit: module.featureImageFit,
                                      ),
                                    ),
                                  ),
                                if (module.title.isNotEmpty)
                                  Align(
                                    alignment: module.titleAlignment,
                                    child: Padding(
                                      padding: module.titlePadding,
                                      child: DefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: 56,
                                          fontFamily: "Mplus",
                                          fontWeight: FontWeight.w700,
                                          color: color,
                                        ),
                                        child: Text(
                                          module.title ?? "",
                                          textAlign: module.titleTextAlignment,
                                          style: module.titleTextStyle,
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
                              padding: module.padding,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  if (context.plugin != null)
                                    for (final adapter
                                        in context.plugin!.signIns)
                                      if (adapter.visible)
                                        _snsButton(
                                          context,
                                          ref,
                                          adapter,
                                          module,
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

  Widget _snsButton(
    BuildContext context,
    WidgetRef ref,
    SignInAdapter adapter,
    SnsLoginModule module,
  ) {
    final buttonColor =
        module.buttonColor ?? module.color ?? context.theme.textColorOnPrimary;
    final buttonBackgroundColor = module.buttonBackgroundColor;
    switch (adapter.provider) {
      case "mock":
        return FormItemSubmit(
          "SignIn".localize(),
          borderRadius: 35,
          height: 70,
          width: 1.6,
          color: buttonColor,
          borderColor: buttonColor,
          backgroundColor: buttonBackgroundColor,
          icon: FontAwesomeIcons.rightToBracket,
          onPressed: () async {
            try {
              await adapter.signIn().showIndicator(context);
              context.navigator.pushReplacementNamed(module.redirectTo);
              if (module.runAfterFinishBootHooksOnRidirect) {
                Future.wait(
                  Module.registeredHooks.map(
                    (e) => e.onAfterFinishBoot(context.navigator.context),
                  ),
                );
              }
            } catch (e) {
              print(e.toString());
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "Could not login. Please check your information."
                    .localize(),
              );
            }
          },
        );
      case "apple":
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
          onPressed: () async {
            try {
              await adapter.signIn().showIndicator(context);
              context.navigator.pushReplacementNamed(module.redirectTo);
              if (module.runAfterFinishBootHooksOnRidirect) {
                Future.wait(
                  Module.registeredHooks.map(
                    (e) => e.onAfterFinishBoot(context.navigator.context),
                  ),
                );
              }
            } catch (e) {
              print(e.toString());
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "Could not login. Please check your information."
                    .localize(),
              );
            }
          },
        );
      case "google":
        return FormItemSubmit(
          "Google SignIn".localize(),
          borderRadius: 35,
          height: 70,
          width: 1.6,
          color: buttonColor,
          borderColor: buttonColor,
          backgroundColor: buttonBackgroundColor,
          icon: FontAwesomeIcons.google,
          onPressed: () async {
            try {
              await adapter.signIn().showIndicator(context);
              context.navigator.pushReplacementNamed(module.redirectTo);
              if (module.runAfterFinishBootHooksOnRidirect) {
                Future.wait(
                  Module.registeredHooks.map(
                    (e) => e.onAfterFinishBoot(context.navigator.context),
                  ),
                );
              }
            } catch (e) {
              print(e.toString());
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "Could not login. Please check your information."
                    .localize(),
              );
            }
          },
        );
      case "facebook":
        return FormItemSubmit(
          "Facebook SignIn".localize(),
          borderRadius: 35,
          height: 70,
          width: 1.6,
          color: buttonColor,
          borderColor: buttonColor,
          backgroundColor: buttonBackgroundColor,
          icon: FontAwesomeIcons.facebook,
          onPressed: () async {
            try {
              await adapter.signIn().showIndicator(context);
              context.navigator.pushReplacementNamed(module.redirectTo);
              if (module.runAfterFinishBootHooksOnRidirect) {
                Future.wait(
                  Module.registeredHooks.map(
                    (e) => e.onAfterFinishBoot(context.navigator.context),
                  ),
                );
              }
            } catch (e) {
              print(e.toString());
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "Could not login. Please check your information."
                    .localize(),
              );
            }
          },
        );
      case "twitter":
        return FormItemSubmit(
          "Twitter SignIn".localize(),
          borderRadius: 35,
          height: 70,
          width: 1.6,
          color: buttonColor,
          borderColor: buttonColor,
          backgroundColor: buttonBackgroundColor,
          icon: FontAwesomeIcons.twitter,
          onPressed: () async {
            try {
              await adapter.signIn().showIndicator(context);
              context.navigator.pushReplacementNamed(module.redirectTo);
              if (module.runAfterFinishBootHooksOnRidirect) {
                Future.wait(
                  Module.registeredHooks.map(
                    (e) => e.onAfterFinishBoot(context.navigator.context),
                  ),
                );
              }
            } catch (e) {
              print(e.toString());
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "Could not login. Please check your information."
                    .localize(),
              );
            }
          },
        );
      case "anonymous":
        return FormItemSubmit(
          module.anonymousSignInConfig?.name.localize() ??
              "Anonymous SingIn".localize(),
          borderRadius: 35,
          height: 70,
          width: 1.6,
          color: buttonColor,
          borderColor: buttonColor,
          backgroundColor: buttonBackgroundColor,
          icon: module.anonymousSignInConfig?.icon ?? FontAwesomeIcons.user,
          onPressed: () async {
            try {
              await adapter.signIn().showIndicator(context);
              context.navigator.pushReplacementNamed(module.redirectTo);
              if (module.runAfterFinishBootHooksOnRidirect) {
                Future.wait(
                  Module.registeredHooks.map(
                    (e) => e.onAfterFinishBoot(context.navigator.context),
                  ),
                );
              }
            } catch (e) {
              print(e.toString());
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
    return const Empty();
  }
}

class _LoginModuleBackgroundImage extends StatelessWidget {
  const _LoginModuleBackgroundImage(
    this.module, {
    this.opacity = 0.75,
  });
  final SnsLoginModule module;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (module.backgroundImage.isNotEmpty) ...[
          Image(
            image: NetworkOrAsset.image(module.backgroundImage!),
            fit: BoxFit.cover,
          ),
          if (module.backgroundImageBlur != null)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: module.backgroundImageBlur!,
                sigmaY: module.backgroundImageBlur!,
              ),
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
    if (module.backgroundGradient != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: module.backgroundGradient,
        ),
      );
    } else if (opacity < 1.0) {
      return ColoredBox(
        color: (module.backgroundColor ?? context.theme.backgroundColor)
            .withOpacity(opacity),
      );
    } else {
      return ColoredBox(
        color: module.backgroundColor ?? context.theme.backgroundColor,
      );
    }
  }
}

class SnsLoginModuleRegister extends PageModuleWidget<SnsLoginModule> {
  const SnsLoginModuleRegister();

  @override
  Widget build(BuildContext context, WidgetRef ref, SnsLoginModule module) {
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
                context: context,
                ref: ref,
                onlyRequired: module.showOnlyRequiredVariable,
              ) ??
              [],
          ...module.registerVariables.buildForm(
            context: context,
            ref: ref,
            onlyRequired: module.showOnlyRequiredVariable,
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
            final collection = ref.readCollectionModel(module.userPath);
            final doc = context.model?.createDocument(collection, userId);
            if (doc == null) {
              throw Exception("User document has not created.");
            }
            context.app?.userVariables.setValue(
              target: doc,
              context: context,
              ref: ref,
              updated: false,
            );
            await context.model?.saveDocument(doc).showIndicator(context);
            context.navigator.pushReplacementNamed(module.redirectTo);
            if (module.runAfterFinishBootHooksOnRidirect) {
              Future.wait(
                Module.registeredHooks
                    .map((e) => e.onAfterFinishBoot(context.navigator.context)),
              );
            }
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
