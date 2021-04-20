part of masamune_module;

enum HomeType {
  tileMenu,
}

@immutable
class HomeModule extends ModuleConfig {
  const HomeModule({
    bool enabled = true,
    String title = "",
    this.roles = const [
      RoleConfig(
        id: "register",
        label: "Registration",
        icon: FontAwesomeIcons.userAlt,
      ),
    ],
    this.color,
    this.textColor,
    this.homeType = HomeType.tileMenu,
    this.featureImage,
    this.featureImageFit = BoxFit.cover,
    this.titleTextStyle,
    this.titleAlignment = Alignment.center,
    this.titlePadding = const EdgeInsets.all(12),
    this.contentPadding = const EdgeInsets.all(8),
    this.headerHeight,
    this.userPath = "user",
    this.infoPath = "info",
    this.roleKey = "role",
    this.nameKey = "name",
  }) : super(enabled: enabled, title: title);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/": RouteConfig((_) => Home(this)),
    };
    return route;
  }

  @override
  String? get initialRoute => "/";

  /// 権限。
  final List<RoleConfig> roles;

  /// ホームのデザインタイプ。
  final HomeType homeType;

  /// テキストカラー。
  final Color? textColor;

  /// メインカラー。
  final Color? color;

  /// フィーチャー画像。
  final ImageProvider? featureImage;

  /// フィーチャー画像の配置。
  final BoxFit featureImageFit;

  /// タイトルのテキストスタイル。
  final TextStyle? titleTextStyle;

  /// タイトルの位置。
  final Alignment titleAlignment;

  /// タイトルのパディング。
  final EdgeInsetsGeometry titlePadding;

  /// コンテンツのパディング。
  final EdgeInsetsGeometry contentPadding;

  /// ヘッダーの高さ。
  final double? headerHeight;

  /// ユーザーのデータパス。
  final String userPath;

  /// お知らせのデータパス。
  final String infoPath;

  /// 名前のキー。
  final String nameKey;

  /// 権限のキー。
  final String roleKey;
}

class Home extends PageHookWidget {
  const Home(this.config);
  final HomeModule config;
  @override
  Widget build(BuildContext context) {
    switch (config.homeType) {
      case HomeType.tileMenu:
        return TileMenuHome(config);
    }
  }
}
