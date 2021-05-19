part of masamune_module;

enum HomeType {
  tileMenu,
}

@immutable
class HomeModule extends ModuleConfig {
  const HomeModule({
    bool enabled = true,
    String title = "",
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
    this.calendar = const HomeCalendarModule(enabled: false),
    this.info = const HomeInformationModule(enabled: false),
    this.roleKey = "role",
    this.nameKey = "name",
    this.menu = const [],
    this.subMenu = const [],
    this.roleMenu = const {},
    PermissionConfig permission = const PermissionConfig(),
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/": RouteConfig((_) => Home(this)),
    };
    route.addAll(info.routeSettings ?? {});
    route.addAll(calendar.routeSettings ?? {});
    return route;
  }

  @override
  String? get initialRoute => "/";

  /// お知らせの設定。
  final HomeInformationModule info;

  /// カレンダーの設定。
  final HomeCalendarModule calendar;

  /// デフォルトのメニュー。
  final List<MenuConfig> menu;

  /// 権限ごとのメニュー。
  final Map<String, List<MenuConfig>> roleMenu;

  /// サブメニュー。
  final List<MenuConfig> subMenu;

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

  /// 名前のキー。
  final String nameKey;

  /// 権限のキー。
  final String roleKey;

  List<MenuConfig> menuByRole(RoleConfig? role) {
    if (role == null || !roleMenu.containsKey(role.id)) {
      return menu;
    }
    return roleMenu[role.id] ?? [];
  }
}

@immutable
class HomeInformationModule extends PostModule {
  const HomeInformationModule({
    bool enabled = true,
    String? title,
    String postPath = "info",
    this.icon = Icons.info_rounded,
    PermissionConfig permission = const PermissionConfig(),
  }) : super(
          enabled: enabled,
          title: title,
          postPath: postPath,
          routePath: "info",
          editingType: PostEditingType.planeText,
          permission: permission,
        );

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/info/{post_id}": RouteConfig((_) => _PostView(this)),
      // "/info/{post_id}/edit": RouteConfig((_) => _PostEdit(this)),
    };
    return route;
  }

  /// アイコン。
  final IconData icon;
}

@immutable
class HomeCalendarModule extends ModuleConfig {
  const HomeCalendarModule(
      {bool enabled = true,
      String? title,
      this.path = "event",
      this.icon = Icons.calendar_today})
      : super(enabled: enabled, title: title);

  /// お知らせのデータパス。
  final String path;

  /// アイコン。
  final IconData icon;
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
