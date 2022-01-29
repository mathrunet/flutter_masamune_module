import 'package:masamune_module/component/calendar/calendar.dart';
import 'package:masamune_module/masamune_module.dart';

part 'tile_menu_home.dart';

enum HomeType {
  tileMenu,
}

@immutable
class HomeModule extends PageModule with VerifyAppReroutePageModuleMixin {
  const HomeModule({
    bool enabled = true,
    String? title = "",
    this.color,
    this.textColor,
    this.homeType = HomeType.tileMenu,
    this.featureIcon,
    this.featureImage,
    this.featureImageFit = BoxFit.cover,
    this.featureImageAlignment = Alignment.center,
    this.titleTextStyle,
    this.titleAlignment = Alignment.center,
    this.titlePadding = const EdgeInsets.all(12),
    this.contentPadding = const EdgeInsets.all(8),
    this.headerHeight = 90,
    this.userPath = "user",
    this.calendar = const HomeCalendarModule(enabled: false),
    this.info = const HomeInformationModule(enabled: false),
    this.roleKey = Const.role,
    this.nameKey = Const.name,
    this.menu = const [],
    this.subMenu = const [],
    this.profileRoutePath = "user",
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
    this.header,
    this.footer,
    this.homePage = const HomeModuleHome(),
    this.tileMenuHomeWidget = const HomeModuleTileMenuHome(),
    this.tileMenuHomeInformationWidget =
        const HomeModuleTileMenuHomeInformation(),
    this.tileMenuHomeCalendarWidget = const HomeModuleTileMenuHomeCalendar(),
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
      "/": RouteConfig((_) => homePage),
    };
    route.addAll(info.routeSettings);
    route.addAll(calendar.routeSettings);
    return route;
  }

  // ページの設定。
  final PageModuleWidget<HomeModule> homePage;
  final ModuleWidget<HomeModule> tileMenuHomeWidget;
  final ModuleWidget<HomeModule> tileMenuHomeInformationWidget;
  final ModuleWidget<HomeModule> tileMenuHomeCalendarWidget;

  // ホームのパーツ。
  final ModuleWidget<HomeModule>? header;
  final ModuleWidget<HomeModule>? footer;

  /// お知らせの設定。
  final HomeInformationModule info;

  /// カレンダーの設定。
  final HomeCalendarModule calendar;

  /// デフォルトのメニュー。
  final List<MenuConfig> menu;

  /// サブメニュー。
  final List<MenuConfig> subMenu;

  /// ホームのデザインタイプ。
  final HomeType homeType;

  /// テキストカラー。
  final Color? textColor;

  /// メインカラー。
  final Color? color;

  /// フィーチャーアイコン。
  final String? featureIcon;

  /// フィーチャー画像。
  final String? featureImage;

  /// フィーチャー画像のサイズ。
  final BoxFit featureImageFit;

  /// フィーチャー画像の配置。
  final Alignment featureImageAlignment;

  /// タイトルのテキストスタイル。
  final TextStyle? titleTextStyle;

  /// タイトルの位置。
  final Alignment titleAlignment;

  /// タイトルのパディング。
  final EdgeInsetsGeometry titlePadding;

  /// コンテンツのパディング。
  final EdgeInsetsGeometry contentPadding;

  /// ヘッダーの高さ。
  final double headerHeight;

  /// ユーザーのデータパス。
  final String userPath;

  /// プロフィールページへのパス。
  final String profileRoutePath;

  /// 名前のキー。
  final String nameKey;

  /// 権限のキー。
  final String roleKey;
}

@immutable
class HomeInformationModule extends PostModule {
  const HomeInformationModule({
    bool enabled = true,
    String? title,
    String routePath = "info",
    String queryPath = "info",
    this.icon = Icons.info_rounded,
    String nameKey = Const.name,
    String createdTimeKey = Const.createdTime,
    Permission permission = const Permission(),
    PageModuleWidget<PostModule> viewPage = const PostModuleView(),
    PageModuleWidget<PostModule> editPage = const PostModuleEdit(),
    this.widget,
    this.limit = 10,
  }) : super(
          enabled: enabled,
          title: title,
          queryPath: queryPath,
          routePath: routePath,
          editingType: PostEditingType.planeText,
          permission: permission,
          viewPage: viewPage,
          editPage: editPage,
          nameKey: nameKey,
          createdTimeKey: createdTimeKey,
        );

  @override
  Map<String, RouteConfig> get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath/{post_id}": RouteConfig((_) => viewPage),
      "/$routePath/{post_id}/edit": RouteConfig((_) => editPage),
    };
    return route;
  }

  /// 表示数。
  final int limit;

  /// アイコン。
  final IconData icon;

  /// ウィジェット。
  final Widget? widget;
}

@immutable
class HomeCalendarModule extends CalendarModule {
  const HomeCalendarModule({
    bool enabled = true,
    String? title,
    String routePath = "calendar",
    String queryPath = "event",
    String startTimeKey = Const.startTime,
    String endTimeKey = Const.endTime,
    String allDayKey = "allDay",
    this.icon = Icons.calendar_today,
    PageModuleWidget<CalendarModule> detailPage = const CalendarModuleDetail(),
    this.widget,
  }) : super(
          enabled: enabled,
          title: title,
          routePath: routePath,
          queryPath: queryPath,
          detailPage: detailPage,
          startTimeKey: startTimeKey,
          endTimeKey: endTimeKey,
          allDayKey: allDayKey,
        );

  @override
  Map<String, RouteConfig> get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath/{event_id}/detail": RouteConfig((_) => detailPage),
    };
    return route;
  }

  /// アイコン。
  final IconData icon;

  /// ウィジェット。
  final Widget? widget;
}

class HomeModuleHome extends PageModuleWidget<HomeModule> {
  const HomeModuleHome();

  @override
  Widget build(BuildContext context, WidgetRef ref, HomeModule module) {
    switch (module.homeType) {
      case HomeType.tileMenu:
        return module.tileMenuHomeWidget;
    }
  }
}
