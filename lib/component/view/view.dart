import 'package:masamune_module/masamune_module.dart';

@immutable
class ViewModule extends PageModule {
  const ViewModule({
    bool enabled = true,
    required this.variables,
    String? title,
    String routePath = "view",
    String queryPath = "view",
    ModelQuery? query,
    this.queryKey = "view_id",
    this.titleKey = Const.name,
    this.bottomSpace = 120,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.enableEdit = true,
    this.automaticallyImplyLeadingOnHome = true,
    this.sliverLayoutWhenModernDesignOnHome = false,
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const EditModuleHome(),
    this.top = const [],
    this.bottom = const [],
  }) : super(
          enabled: enabled,
          title: title,
          query: query,
          routePath: routePath,
          queryPath: queryPath,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig> get routeSettings {
    if (!enabled) {
      return const {};
    }

    final route = {
      "/$routePath/{$queryKey}": RouteConfig((_) => homePage),
    };
    return route;
  }

  /// Form padding.
  final EdgeInsetsGeometry padding;

  /// Top widget.
  final List<ModuleWidget<EditModule>> top;

  /// Bottom widget.
  final List<ModuleWidget<EditModule>> bottom;

  // Page settings.
  final PageModuleWidget<EditModule> homePage;

  /// True if editing is enabled.
  final bool enableEdit;

  /// Query key.
  final String queryKey;

  /// Title key.
  final String titleKey;

  /// List of forms.
  final List<VariableConfig> variables;

  /// True if Home is a sliver layout.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// True if you want to automatically display the back button when you are at home.
  final bool automaticallyImplyLeadingOnHome;

  /// Space under the form.
  final double bottomSpace;
}

class ViewModuleHome extends PageModuleWidget<ViewModule> {
  const ViewModuleHome();

  @override
  Widget build(BuildContext context, WidgetRef ref, ViewModule module) {
    final queryId = context.get(module.queryKey, "");
    final doc = ref.watchDocumentModel("${module.queryPath}/$queryId");
    final variables = module.variables;
    final title = doc.get(module.titleKey, module.title ?? "Edit".localize());

    return UIScaffold(
      appBar: UIAppBar(
        automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
        sliverLayoutWhenModernDesign: module.sliverLayoutWhenModernDesignOnHome,
        title: Text(title),
        actions: [
          if (module.enableEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.navigator
                    .pushNamed("/${module.routePath}/{$module.queryKey}/edit");
              },
            )
        ],
      ),
      body: LoadingBuilder(
        futures: [
          Future.value(doc.loading),
        ],
        builder: (context) {
          return ListView(
            padding: module.padding,
            children: [
              ...module.top,
              ...variables.buildForm(context: context, ref: ref, data: doc),
              ...module.bottom,
              if (variables.isNotEmpty && module.bottomSpace > 0) const Divid(),
              Space.height(module.bottomSpace),
            ],
          );
        },
      ),
    );
  }
}
