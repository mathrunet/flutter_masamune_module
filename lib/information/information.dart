part of masamune_module;

@immutable
class InformationModule extends ModuleConfig {
  const InformationModule({
    bool enabled = true,
    String? title = "",
    this.infoPath = "info",
    this.userPath = "user",
    this.nameKey = "name",
    this.textKey = "text",
    this.roleKey = "role",
    this.createdTimeKey = "createdTime",
  }) : super(enabled: enabled, title: title);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/info": RouteConfig((_) => Information(this)),
      "/info/edit": RouteConfig((_) => _InformationEdit(this, inAdd: true)),
      "/info/{info_id}": RouteConfig((_) => _InformationView(this)),
      "/info/{info_id}/edit": RouteConfig((_) => _InformationEdit(this)),
    };
    return route;
  }

  /// お知らせデータのパス。
  final String infoPath;

  /// ユーザーのデータパス。
  final String userPath;

  /// タイトルのキー。
  final String nameKey;

  /// テキストのキー。
  final String textKey;

  /// 権限のキー。
  final String roleKey;

  /// 作成日のキー。
  final String createdTimeKey;
}

class Information extends PageHookWidget {
  const Information(this.config);
  final InformationModule config;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final info = context.adapter!.loadCollection(
      useProvider(context.adapter!.collectionProvider(config.infoPath)),
    );
    final user = context.adapter!.loadDocument(
      useProvider(context.adapter!
          .documentProvider("${config.userPath}/${context.adapter?.userId}")),
    );
    final role = context.roles.firstWhereOrNull(
      (item) => item.id == user.get(config.roleKey, "registered"),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(config.title ?? "Information".localize()),
      ),
      body: ListView(
        children: [
          ...info.mapWidget(
            (item) {
              return ListTile(
                title: Text(item.get(config.nameKey, "")),
                subtitle: Text(
                  DateTime.fromMillisecondsSinceEpoch(
                    item.get(config.createdTimeKey, now.millisecondsSinceEpoch),
                  ).format("yyyy/MM/dd HH:mm"),
                ),
                onTap: () {
                  context.navigator.pushNamed(
                    "/info/${item.get("uid", "")}",
                    arguments: RouteQuery.fullscreen,
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: role.containsPermission("edit")
          ? FloatingActionButton.extended(
              label: Text("Add".localize()),
              icon: const Icon(Icons.add),
              onPressed: () {
                context.navigator.pushNamed(
                  "/info/edit",
                  arguments: RouteQuery.fullscreen,
                );
              },
            )
          : null,
    );
  }
}

class _InformationView extends PageHookWidget {
  const _InformationView(this.config);
  final InformationModule config;

  @override
  Widget build(BuildContext context) {
    final item = context.adapter!.loadDocument(
      useProvider(context.adapter!.documentProvider(
          "${config.infoPath}/${context.get("info_id", "")}")),
    );
    final user = context.adapter!.loadDocument(
      useProvider(context.adapter!
          .documentProvider("${config.userPath}/${context.adapter?.userId}")),
    );
    final role = context.roles.firstWhereOrNull(
      (item) => item.id == user.get(config.roleKey, "registered"),
    );
    final now = DateTime.now();
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final createdTime =
        item.get(config.createdTimeKey, now.millisecondsSinceEpoch);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          if (role.containsPermission("edit"))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.navigator.pushNamed(
                  "/info/${context.get("info_id", "")}/edit",
                  arguments: RouteQuery.fullscreen,
                );
              },
            )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Text(
            DateTime.fromMillisecondsSinceEpoch(createdTime)
                .format("yyyy/MM/dd HH:mm"),
            style: TextStyle(
              color: context.theme.disabledColor,
              fontSize: 12,
            ),
          ),
          const Space.height(16),
          UIMarkdown(
            text,
            fontSize: 16,
            onTapLink: (url) {
              context.open(url);
            },
          )
        ],
      ),
    );
  }
}

class _InformationEdit extends PageHookWidget
    with UIPageFormMixin, UIPageUuidMixin {
  _InformationEdit(this.config, {this.inAdd = false});
  final InformationModule config;
  final bool inAdd;

  @override
  Widget build(BuildContext context) {
    final item = context.adapter!.loadDocument(
      useProvider(context.adapter!.documentProvider(
          "${config.infoPath}/${context.get("info_id", puid)}")),
    );
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          inAdd
              ? "A new entry".localize()
              : "Editing %s".localize().format([name]),
        ),
        actions: [
          if (!inAdd)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                UIConfirm.show(
                  context,
                  title: "Confirmation".localize(),
                  text: "You can't undo it after deleting it. May I delete it?"
                      .localize(),
                  submitText: "Yes".localize(),
                  cacnelText: "No".localize(),
                  onSubmit: () async {
                    await context.adapter
                        ?.deleteDocument(item)
                        .showIndicator(context);
                    context.navigator.pop();
                  },
                );
              },
            ),
        ],
      ),
      body: FormBuilder(
        key: formKey,
        children: [
          FormItemTextField(
            labelText: "Title".localize(),
            hintText: "Input %s".localize().format(["Title".localize()]),
            controller: useMemoizedTextEditingController(inAdd ? "" : name),
            onSaved: (value) {
              context[config.nameKey] = value;
            },
          ),
          FormItemTextField(
            labelText: "Description".localize(),
            hintText: "Input %s".localize().format(["Description".localize()]),
            controller: useMemoizedTextEditingController(inAdd ? "" : text),
            onSaved: (value) {
              context[config.textKey] = value;
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!validate(context)) {
            return;
          }

          item[config.nameKey] = context.get(config.nameKey, "");
          item[config.textKey] = context.get(config.textKey, "");
          await context.adapter?.saveDocument(item).showIndicator(context);
          context.navigator.pop();
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
