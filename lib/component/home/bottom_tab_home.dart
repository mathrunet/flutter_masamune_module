import 'package:masamune_module/masamune_module.dart';

@immutable
class BottomTabHomeModule extends PageModule
    with VerifyAppReroutePageModuleMixin {
  const BottomTabHomeModule({
    bool enabled = true,
    String? title = "",
    this.initialPath,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = true,
    this.disableOnTapWhenInitialIndex = true,
    this.floatingButtonOnCenter = false,
    required this.menu,
    this.dividerColor = Colors.transparent,
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const BottomTabHomeModuleHome(),
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
      "/": RouteConfig((_) => homePage),
    };
    return route;
  }

  // ホームのパス。
  final String? initialPath;

  final List<MenuConfig> menu;

  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;
  final bool disableOnTapWhenInitialIndex;
  final bool floatingButtonOnCenter;

  final Color? dividerColor;

  // ページの設定。
  final PageModuleWidget<BottomTabHomeModule> homePage;
}

class BottomTabHomeModuleHome extends PageModuleWidget<BottomTabHomeModule> {
  const BottomTabHomeModuleHome();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    BottomTabHomeModule module,
  ) {
    final initialId = module.initialPath ??
        module.menu.firstWhereOrNull((e) => e.path.isNotEmpty)?.path ??
        "";
    final controller = ref.useNavigatorController(initialId);
    final floatingButtonOnCenter =
        module.menu.length.isOdd && module.floatingButtonOnCenter;
    final center = floatingButtonOnCenter
        ? module.menu[(module.menu.length / 2).floor()]
        : null;

    return Scaffold(
      body: InlinePageBuilder(
        controller: controller,
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: floatingButtonOnCenter
          ? FloatingActionButtonLocation.centerDocked
          : null,
      floatingActionButton:
          floatingButtonOnCenter && center != null && center.path.isNotEmpty
              ? FloatingActionButton(
                  elevation: 2.0,
                  backgroundColor:
                      module.selectedItemColor ?? context.theme.primaryColor,
                  onPressed: () {
                    context.rootNavigator.pushNamed(
                      center.path!,
                      arguments: RouteQuery.fullscreenOrModal,
                    );
                  },
                  child: center.name.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(center.icon),
                            const Space.height(2.0),
                            Text(
                              center.name,
                              style: TextStyle(
                                color: context.theme.textColorOnPrimary,
                                fontSize: 10,
                              ),
                            )
                          ],
                        )
                      : Icon(center.icon),
                )
              : null,
      bottomNavigationBar: ColoredBox(
        color: context.theme.backgroundColor,
        child: UIBottomNavigationBar(
          elevation: 0,
          controller: controller,
          backgroundColor: module.backgroundColor,
          selectedItemColor:
              module.selectedItemColor ?? context.theme.primaryColor,
          unselectedItemColor:
              module.unselectedItemColor ?? context.theme.disabledColor,
          showSelectedLabels: module.showSelectedLabels,
          showUnselectedLabels: module.showUnselectedLabels,
          disableOnTapWhenInitialIndex: module.disableOnTapWhenInitialIndex,
          dividerColor: module.dividerColor,
          dividerSize: 0,
          indexID: initialId,
          items: [
            ...module.menu.mapAndRemoveEmpty((e) {
              if (e.path.isEmpty) {
                return null;
              }
              if (e == center) {
                return UIBottomNavigationBarItem(
                  id: e.path ?? "",
                  icon: const Empty(),
                  onRouteChange: (settings) => settings?.name == e.path,
                );
              }
              return UIBottomNavigationBarItem(
                id: e.path ?? "",
                icon: Icon(e.icon),
                label: e.name.isEmpty ? null : e.name,
                onRouteChange: (settings) => settings?.name == e.path,
                onTap: () {
                  controller.navigator.pushNamed(e.path!);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
