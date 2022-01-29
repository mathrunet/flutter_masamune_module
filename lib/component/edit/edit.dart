import 'package:masamune_module/masamune_module.dart';

@immutable
class EditModule extends PageModule {
  const EditModule({
    bool enabled = true,
    required this.variables,
    String? title,
    this.routePath = "edit",
    this.queryPath = "edit",
    this.queryKey = "edit_id",
    this.enableDelete = true,
    this.automaticallyImplyLeadingOnHome = true,
    this.sliverLayoutWhenModernDesignOnHome = false,
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const EditModuleHome(),
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
      "/$routePath/edit": RouteConfig((_) => homePage),
      "/$routePath/{$queryKey}/edit": RouteConfig((_) => homePage),
    };
    return route;
  }

  // Page settings.
  final PageModuleWidget<EditModule> homePage;

  /// Route path.
  final String routePath;

  /// True if you want to enable deletion.
  final bool enableDelete;

  /// Query path.
  final String queryPath;

  /// Query key.
  final String queryKey;

  /// List of forms.
  final List<VariableConfig> variables;

  /// True if Home is a sliver layout.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// True if you want to automatically display the back button when you are at home.
  final bool automaticallyImplyLeadingOnHome;
}

class EditModuleHome extends PageModuleWidget<EditModule> {
  const EditModuleHome();

  @override
  Widget build(BuildContext context, WidgetRef ref, EditModule module) {
    final form = ref.useForm(module.queryKey);
    final doc = ref.watchDocumentModel("${module.queryPath}/${form.uid}");
    final variables = module.variables;

    return UIScaffold(
      appBar: UIAppBar(
        automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
        sliverLayoutWhenModernDesign: module.sliverLayoutWhenModernDesignOnHome,
        title: Text(module.title ?? "Edit".localize()),
        actions: [
          if (module.enableDelete && form.exists)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                try {
                  UIConfirm.show(
                    context,
                    title: "Confirmation".localize(),
                    text: "You will delete this %s. Are you sure?"
                        .localize()
                        .format(["Data".localize()]),
                    submitText: "Yes".localize(),
                    onSubmit: () async {
                      await context.model
                          ?.deleteDocument(doc)
                          .showIndicator(context);
                      UIDialog.show(
                        context,
                        title: "Success".localize(),
                        text: "%s is completed."
                            .localize()
                            .format(["Deletion".localize()]),
                        submitText: "Back".localize(),
                        onSubmit: () {
                          context.navigator.pop();
                        },
                      );
                    },
                    cacnelText: "No".localize(),
                  );
                } catch (e) {
                  UIDialog.show(
                    context,
                    title: "Error".localize(),
                    text: "%s is not completed."
                        .localize()
                        .format(["Deletion".localize()]),
                    submitText: "Close".localize(),
                  );
                }
              },
            )
        ],
      ),
      body: LoadingBuilder(
        futures: [
          Future.value(doc.loading),
        ],
        builder: (context) {
          return FormBuilder(
            key: form.key,
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              ...variables.buildForm(context, ref, data: doc),
              if (variables.isNotEmpty) const Divid(),
              const Space.height(120),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: Text("Submit".localize()),
        onPressed: () async {
          if (!form.validate()) {
            return;
          }

          try {
            if (form.exists) {
              variables.buildValue(doc, context, ref, updated: form.exists);
              await context.model?.saveDocument(doc).showIndicator(context);
              UIDialog.show(
                context,
                title: "Success".localize(),
                text: "%s is completed."
                    .localize()
                    .format(["Editing".localize()]),
                submitText: "Back".localize(),
                onSubmit: () {
                  context.navigator.pop();
                },
              );
            } else {
              final model = context.model;
              if (model == null) {
                return;
              }
              final collection = ref.readCollectionModel(module.queryPath);
              final doc = model.createDocument(collection);
              variables.buildValue(doc, context, ref, updated: form.exists);
              await context.model?.saveDocument(doc).showIndicator(context);
              UIDialog.show(
                context,
                title: "Success".localize(),
                text: "%s is completed."
                    .localize()
                    .format(["Editing".localize()]),
                submitText: "Back".localize(),
                onSubmit: () {
                  context.navigator.pop();
                },
              );
            }
          } catch (e) {
            UIDialog.show(
              context,
              title: "Error".localize(),
              text: "%s is not completed."
                  .localize()
                  .format(["Editing".localize()]),
              submitText: "Close".localize(),
            );
          }
        },
      ),
    );
  }
}
