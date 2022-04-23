import 'package:masamune_module/masamune_module.dart';

@immutable
class SliverHomeModule extends PageModule {
  const SliverHomeModule({
    bool enabled = true,
    String? title,
    this.routePath = "home",
    this.backgroundImage,
    this.automaticallyImplyLeadingOnHome = true,
    this.backgroundColor,
    this.foregroundColor,
    this.headerHeight = 210,
    this.components = const [],
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const SliverHomeModuleHome(),
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
      "/$routePath": RouteConfig((_) => homePage),
    };
    return route;
  }

  // Widget.
  final PageModuleWidget<SliverHomeModule> homePage;

  final List<ModuleWidget<SliverHomeModule>> components;

  /// ヘッダーのカラー。
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// ヘッダーの画像。
  final String? backgroundImage;

  /// ヘッダーの高さ。
  final double headerHeight;

  /// Route path.
  final String routePath;

  /// True if you want to automatically display the back button when you are at home.
  final bool automaticallyImplyLeadingOnHome;
}

class SliverHomeModuleHome extends PageModuleWidget<SliverHomeModule> {
  const SliverHomeModuleHome();

  @override
  Widget build(BuildContext context, WidgetRef ref, SliverHomeModule module) {
    // Please describe reference.

    // Please describe the Widget.
    return UIScaffold(
      appBar: UIAppBar(
        title: Text(module.title ?? context.app?.title ?? "",
            style: TextStyle(
              color: module.foregroundColor ?? context.theme.textColorOnPrimary,
            )),
        expandedHeight: module.headerHeight,
        automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
        backgroundColor: module.backgroundColor ?? context.theme.primaryColor,
        foregroundColor:
            module.foregroundColor ?? context.theme.textColorOnPrimary,
        background: module.backgroundImage.isEmpty
            ? null
            : Image(
                image: NetworkOrAsset.image(module.backgroundImage!),
                fit: BoxFit.cover,
              ),
      ),
      body: UIListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: module.components.expandAndRemoveEmpty(
          (element) => [
            element,
            const Space.height(16),
          ],
        ),
      ),
    );
  }
}

class SliverHomeModuleListComponent extends ModuleWidget<SliverHomeModule> {
  const SliverHomeModuleListComponent({
    required this.query,
    required this.title,
    this.child = const SliverHomeModuleListTileComponent(),
    this.icon,
    this.filterQuery,
  });

  final ModelQuery query;
  final ModuleValueWidget<SliverHomeModule, DynamicMap> child;
  final String title;
  final IconData? icon;
  final FilterQuery? filterQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref, SliverHomeModule module) {
    final data = ref.watchCollectionModel(query.value);
    final filtered = filterQuery?.build(data, context, ref) ?? data;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DividHeadline(
          title,
          icon: icon,
        ),
        ...filtered.mapAndRemoveEmpty((item) {
          return ModuleValueProvider(value: item, child: child);
        }),
        const Space.height(16),
      ],
    );
  }
}

class SliverHomeModuleListTileComponent
    extends ModuleValueWidget<SliverHomeModule, DynamicMap> {
  const SliverHomeModuleListTileComponent();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    SliverHomeModule module,
    DynamicMap value,
  ) {
    final image = value.get("image", "");
    final title = value.get("name", "");
    return ListTile(
      leading: image.isEmpty
          ? null
          : CircleAvatar(
              backgroundImage: NetworkOrAsset.image(image),
            ),
      title: Text(title),
    );
  }
}

class SliverHomeModuleMenuComponent extends ModuleWidget<SliverHomeModule> {
  const SliverHomeModuleMenuComponent(this.menu);

  final List<MenuModuleItem> menu;

  @override
  Widget build(BuildContext context, WidgetRef ref, SliverHomeModule module) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: menu.expandAndRemoveEmpty(
        (item) {
          return [
            if (item.name.isNotEmpty)
              Headline(
                item.name!,
                icon: item.icon,
              )
            else ...[
              Container(
                height: 40,
                color: context.theme.dividerColor.withOpacity(0.5),
              ),
              const Divid(),
            ],
            ...item.menus.expandAndRemoveEmpty((menu) {
              return [
                ListItem(
                  leading: menu.icon != null
                      ? Icon(
                          menu.icon!,
                          color: menu.color,
                        )
                      : null,
                  title: Text(menu.name),
                  onTap: menu.path.isEmpty
                      ? null
                      : () {
                          if (menu.path!.startsWith("http")) {
                            ref.open(menu.path!);
                          } else {
                            context.rootNavigator.pushNamed(
                              ref.applyModuleTag(menu.path!),
                              arguments: RouteQuery.fullscreenOrModal,
                            );
                          }
                        },
                ),
                const Divid(),
              ];
            })
          ];
        },
      ),
    );
  }
}
