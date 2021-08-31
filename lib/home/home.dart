import 'package:masamune/masamune.dart';
import 'package:masamune_module/calendar/calendar.dart';
import 'package:masamune_module/masamune_module.dart';

import 'package:masamune_module/post/post.dart';

part 'tile_menu_home.dart';
part 'home.m.dart';

enum HomeType {
  tileMenu,
}

@module
@immutable
class HomeModule extends PageModule {
  const HomeModule({
    bool enabled = true,
    String? title = "",
    this.color,
    this.textColor,
    this.homeType = HomeType.tileMenu,
    this.featureImage,
    this.featureImageFit = BoxFit.cover,
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
    this.roleMenu = const {},
    Permission permission = const Permission(),
    this.home,
    this.tileMenuHome,
    this.tileMenuHomeInformation,
    this.tileMenuHomeCalendar,
    this.designType = DesignType.modern,
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/": RouteConfig((_) => home ?? HomeModuleHome(this)),
    };
    route.addAll(info.routeSettings ?? {});
    route.addAll(calendar.routeSettings ?? {});
    return route;
  }

  // ページの設定。
  final Widget? home;
  final Widget? tileMenuHome;
  final Widget? tileMenuHomeInformation;
  final Widget? tileMenuHomeCalendar;

  /// デザインタイプ。
  final DesignType designType;

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
  final String? featureImage;

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
  final double headerHeight;

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

  @override
  HomeModule? fromMap(DynamicMap map) => _$HomeModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$HomeModuleToMap(this);
}

@module
@immutable
class HomeInformationModule extends PostModule {
  const HomeInformationModule({
    bool enabled = true,
    String? title,
    String routePath = "info",
    String postPath = "info",
    this.icon = Icons.info_rounded,
    String nameKey = Const.name,
    String createdTimeKey = Const.createdTime,
    DesignType designType = DesignType.modern,
    Permission permission = const Permission(),
    Widget? view,
    this.widget,
  }) : super(
          enabled: enabled,
          title: title,
          postPath: postPath,
          routePath: routePath,
          editingType: PostEditingType.planeText,
          permission: permission,
          designType: designType,
          view: view,
          nameKey: nameKey,
          createdTimeKey: createdTimeKey,
        );

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath/{post_id}": RouteConfig((_) => view ?? PostModuleView(this)),
    };
    return route;
  }

  /// アイコン。
  final IconData icon;

  /// ウィジェット。
  final Widget? widget;

  @override
  HomeInformationModule? fromMap(DynamicMap map) =>
      _$HomeInformationModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$HomeInformationModuleToMap(this);
}

@module
@immutable
class HomeCalendarModule extends CalendarModule {
  const HomeCalendarModule({
    bool enabled = true,
    String? title,
    String routePath = "calendar",
    String eventPath = "event",
    String startTimeKey = Const.startTime,
    String endTimeKey = Const.endTime,
    String allDayKey = "allDay",
    this.icon = Icons.calendar_today,
    Widget? detail,
    this.widget,
  }) : super(
          enabled: enabled,
          title: title,
          routePath: routePath,
          eventPath: eventPath,
          detail: detail,
          startTimeKey: startTimeKey,
          endTimeKey: endTimeKey,
          allDayKey: allDayKey,
        );

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath/{event_id}/detail":
          RouteConfig((_) => detail ?? CalendarModuleDetail(this)),
    };
    return route;
  }

  /// アイコン。
  final IconData icon;

  /// ウィジェット。
  final Widget? widget;

  @override
  HomeCalendarModule? fromMap(DynamicMap map) =>
      _$HomeCalendarModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$HomeCalendarModuleToMap(this);
}

class HomeModuleHome extends PageHookWidget {
  const HomeModuleHome(this.config);
  final HomeModule config;
  @override
  Widget build(BuildContext context) {
    switch (config.homeType) {
      case HomeType.tileMenu:
        return config.tileMenuHome ?? HomeModuleTileMenuHome(config);
    }
  }
}
