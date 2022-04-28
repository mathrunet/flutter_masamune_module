import 'package:masamune_module/masamune_module.dart';

@immutable
class ListModule extends PageModule {
  const ListModule({
    bool enabled = true,
    String? title,
    String routePath = "list",
    String queryPath = "list",
    ModelQuery? query,
    this.padding = const EdgeInsets.all(0),
    this.enableAdd = true,
    this.mergeConfig,
    this.automaticallyImplyLeadingOnHome = true,
    this.sliverLayoutWhenModernDesignOnHome = true,
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const ListModuleHome(),
    this.top = const [],
    this.bottom = const [],
    this.item = const ListModuleItem(),
  }) : super(
          enabled: enabled,
          title: title,
          routePath: routePath,
          queryPath: queryPath,
          query: query,
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

  /// Form padding.
  final EdgeInsetsGeometry padding;

  /// Item widget.
  final ModuleValueWidget<ListModule, DynamicMap> item;

  /// Top widget.
  final List<ModuleWidget<EditModule>> top;

  /// Bottom widget.
  final List<ModuleWidget<EditModule>> bottom;

  /// True if you want to enable additions.
  final bool enableAdd;

  /// Specify when merging separate collections.
  final MergeCollectionConfig? mergeConfig;

  /// Widget.
  final PageModuleWidget<ListModule> homePage;

  /// True if Home is a sliver layout.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// True if you want to automatically display the back button when you are at home.
  final bool automaticallyImplyLeadingOnHome;
}

class ListModuleHome extends PageModuleWidget<ListModule> {
  const ListModuleHome();

  @override
  Widget build(BuildContext context, WidgetRef ref, ListModule module) {
    // Please describe reference.
    final collection = ref.watchCollectionModel(
      module.query?.value ?? module.queryPath,
    );
    final mergedCollection = module.mergeConfig != null
        ? collection.mergeDetailInformation(
            ref,
            module.mergeConfig!.path,
            idKey: module.mergeConfig!.key,
            keyPrefix: module.mergeConfig!.prefix,
          )
        : null;

    // Please describe the Widget.
    return UIScaffold(
      loadingFutures: [
        collection.loading,
      ],
      appBar: UIAppBar(
        title: Text(module.title ?? "List".localize()),
      ),
      body: ListBuilder<DynamicMap>(
        source: mergedCollection ?? collection,
        top: module.top,
        bottom: module.bottom,
        builder: (context, item, index) {
          return [
            ModuleValueProvider(value: item, child: module.item),
          ];
        },
      ),
      floatingActionButton: module.enableAdd
          ? FloatingActionButton.extended(
              onPressed: () {
                context.rootNavigator.pushNamed(
                  "/${module.routePath}/edit",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              label: Text("Add".localize()),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class ListModuleItem extends ModuleValueWidget<ListModule, DynamicMap> {
  const ListModuleItem();
  @override
  Widget build(BuildContext context, WidgetRef ref, ListModule module,
      DynamicMap value) {
    return ListItem(
      title: Text(value.get(Const.name, "")),
    );
  }
}

class ListModuleProfile extends ModuleValueWidget<ListModule, DynamicMap> {
  const ListModuleProfile();
  @override
  Widget build(BuildContext context, WidgetRef ref, ListModule module,
      DynamicMap value) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            child: CircleAvatar(
              backgroundImage: NetworkOrAsset.image(value.get(Const.image, "")),
            ),
          ),
          const Space.width(16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value.get(Const.name, "")),
                const Space.height(8),
                Text(value.get(Const.text, "")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
