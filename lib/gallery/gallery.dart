part of masamune_module;

enum GalleryType {
  detail,
  tile,
  tileWithTab,
}

@immutable
class GalleryModule extends ModuleConfig {
  const GalleryModule({
    bool enabled = true,
    String title = "",
    this.galleryType = GalleryType.tile,
    this.routePath = "gallery",
    this.galleryPath = "gallery",
    this.userPath = "user",
    this.imageKey = "image",
    this.nameKey = "name",
    this.textKey = "text",
    this.roleKey = "role",
    this.categoryKey = "category",
    this.createdTimeKey = "createdTime",
    this.crossAxisCount = 4,
    this.childAspectRatio = 0.5625,
    this.heightOnDetailView = 200,
    this.tileSpacing = 1,
    this.tabConfig = const [],
    this.mediaType = PlatformMediaType.all,
  }) : super(enabled: enabled, title: title);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => Gallery(this)),
      "/$routePath/edit": RouteConfig((_) => _PhotoEdit(this, inAdd: true)),
      "/$routePath/{photo_id}": RouteConfig((_) => _PhotoDetail(this)),
      "/$routePath/{photo_id}/view": RouteConfig((_) => _PhotoView(this)),
      "/$routePath/{photo_id}/edit": RouteConfig((_) => _PhotoEdit(this)),
    };
    return route;
  }

  /// ルートのパス。
  final String routePath;

  /// ギャラリーのタイプ。
  final GalleryType galleryType;

  /// ギャラリーデータのパス。
  final String galleryPath;

  /// ユーザーのデータパス。
  final String userPath;

  /// 画像のキー。
  final String imageKey;

  /// タイトルのキー。
  final String nameKey;

  /// テキストのキー。
  final String textKey;

  /// カテゴリーのキー。
  final String categoryKey;

  /// 権限のキー。
  final String roleKey;

  /// 作成日のキー。
  final String createdTimeKey;

  /// タイルの横方向の要素数。
  final int crossAxisCount;

  /// タイルのアスペクト比。
  final double childAspectRatio;

  /// タイルのスペース。
  final double tileSpacing;

  /// 詳細画面の画像の高さ。
  final double heightOnDetailView;

  /// 対応するメディアタイプ。
  final PlatformMediaType mediaType;

  /// タブの設定。
  final List<TabConfig> tabConfig;
}

class Gallery extends PageHookWidget {
  const Gallery(this.config);
  final GalleryModule config;
  @override
  Widget build(BuildContext context) {
    switch (config.galleryType) {
      case GalleryType.tile:
        return TileGallery(config);
      case GalleryType.tileWithTab:
        return TileWithTabGallery(config);
      default:
        return Empty();
    }
  }
}

class TileWithTabGallery extends PageHookWidget {
  const TileWithTabGallery(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context) {
    final user = context.adapter!.loadDocument(
      useProvider(context.adapter!
          .documentProvider("${config.userPath}/${context.adapter?.userId}")),
    );
    final role = context.roles.firstWhereOrNull(
      (item) => item.id == user.get(config.roleKey, "registered"),
    );

    return TabScaffold<TabConfig>(
      title: Text(config.title ?? "Gallery".localize()),
      source: config.tabConfig,
      tabBuilder: (tab) => Text(tab.label),
      viewBuilder: (tab) => _GridView(config, category: tab.id),
      floatingActionButton: role.containsPermission("edit")
          ? FloatingActionButton.extended(
              label: Text("Add".localize()),
              icon: const Icon(Icons.add),
              onPressed: () {
                context.navigator.pushNamed(
                  "/gallery/edit",
                  arguments: RouteQuery.fullscreen,
                );
              },
            )
          : null,
    );
  }
}

class TileGallery extends PageHookWidget {
  const TileGallery(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context) {
    final user = context.adapter!.loadDocument(
      useProvider(context.adapter!
          .documentProvider("${config.userPath}/${context.adapter?.userId}")),
    );
    final role = context.roles.firstWhereOrNull(
      (item) => item.id == user.get(config.roleKey, "registered"),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(config.title ?? "Gallery".localize()),
      ),
      body: _GridView(config),
      floatingActionButton: role.containsPermission("edit")
          ? FloatingActionButton.extended(
              label: Text("Add".localize()),
              icon: const Icon(Icons.add),
              onPressed: () {
                context.navigator.pushNamed(
                  "/gallery/edit",
                  arguments: RouteQuery.fullscreen,
                );
              },
            )
          : null,
    );
  }
}

class _GridView extends HookWidget {
  const _GridView(this.config, {this.category});
  final GalleryModule config;
  final String? category;

  String get path => category.isEmpty
      ? config.galleryPath
      : "${config.galleryPath}?key=${config.categoryKey}&equalTo=$category";

  @override
  Widget build(BuildContext context) {
    final gallery = context.adapter!
        .loadCollection(
      useProvider(context.adapter!.collectionProvider(path)),
    )
        .where(
      (item) {
        if (category.isEmpty) {
          return true;
        }
        return item.get(config.categoryKey, "") == category;
      },
    );

    return GridView.count(
      crossAxisCount: config.crossAxisCount,
      childAspectRatio: config.childAspectRatio,
      mainAxisSpacing: config.tileSpacing,
      crossAxisSpacing: config.tileSpacing,
      children: [
        ...gallery.mapWidget(
          (item) {
            return InkWell(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkOrAsset.image(
                      item.get(config.imageKey, ""),
                    ),
                    fit: BoxFit.cover,
                  ),
                  color: context.theme.disabledColor,
                ),
              ),
              onTap: () {
                context.navigator.pushNamed(
                  "/gallery/${item.get("uid", "")}",
                  arguments: RouteQuery.fullscreen,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _PhotoDetail extends PageHookWidget {
  const _PhotoDetail(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context) {
    final item = context.adapter!.loadDocument(
      useProvider(context.adapter!.documentProvider(
          "${config.galleryPath}/${context.get("photo_id", "")}")),
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
    final image = item.get(config.imageKey, "");
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
                    "/gallery/${context.get("photo_id", "")}/edit",
                    arguments: RouteQuery.fullscreen,
                  );
                })
        ],
      ),
      body: ListView(
        children: [
          InkWell(
            onTap: () {
              context.navigator.pushNamed(
                "/gallery/${context.get("photo_id", "")}/view",
                arguments: RouteQuery.fullscreen,
              );
            },
            child: Container(
              height: config.heightOnDetailView,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkOrAsset.image(image),
                  fit: BoxFit.cover,
                ),
                color: context.theme.disabledColor,
              ),
            ),
          ),
          Indent(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Space.height(12),
              if (text.isNotEmpty) ...[
                Text(text),
                const Space.height(12),
              ],
              Text(
                DateTime.fromMillisecondsSinceEpoch(createdTime)
                    .format("yyyy/MM/dd HH:mm"),
                style: TextStyle(
                  color: context.theme.disabledColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divid(),
        ],
      ),
    );
  }
}

class _PhotoView extends PageHookWidget {
  const _PhotoView(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context) {
    final item = context.adapter!.loadDocument(
      useProvider(context.adapter!.documentProvider(
          "${config.galleryPath}/${context.get("photo_id", "")}")),
    );
    final name = item.get(config.nameKey, "");
    final image = item.get(config.imageKey, "");

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      backgroundColor: Colors.black,
      body: image.isEmpty
          ? Center(
              child: Text(
                "No data.".localize(),
                style: const TextStyle(color: Colors.white),
              ),
            )
          : PhotoView(imageProvider: NetworkOrAsset.image(image)),
    );
  }
}

class _PhotoEdit extends PageHookWidget with UIPageFormMixin, UIPageUuidMixin {
  _PhotoEdit(this.config, {this.inAdd = false});
  final GalleryModule config;
  final bool inAdd;

  @override
  Widget build(BuildContext context) {
    final item = context.adapter!.loadDocument(
      useProvider(context.adapter!.documentProvider(
          "${config.galleryPath}/${context.get("photo_id", puid)}")),
    );
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final image = item.get(config.imageKey, "");

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
          FormItemImage(
            height: 200,
            controller: useMemoizedTextEditingController(
              inAdd ? "" : image,
            ),
            onTap: (onUpdate) async {
              final media = await context.platform?.mediaDialog(
                context,
                title: "Please select your media".localize(),
                type: config.mediaType,
              );
              onUpdate(media?.file);
            },
            onSaved: (value) {
              context[config.imageKey] = value;
            },
          ),
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
            allowEmpty: true,
            controller: useMemoizedTextEditingController(inAdd ? "" : text),
            onSaved: (value) {
              context[config.textKey] = value;
            },
          ),
          if (config.tabConfig.isNotEmpty)
            FormItemDropdownField(
              labelText: "Category".localize(),
              hintText: "Input %s".localize().format(["Category".localize()]),
              controller: useMemoizedTextEditingController(inAdd
                  ? config.tabConfig.first.id
                  : item.get(config.categoryKey, config.tabConfig.first.id)),
              items: <String, String>{
                for (final tab in config.tabConfig) tab.id: tab.label
              },
              onSaved: (value) {
                context[config.categoryKey] = value;
              },
            )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!validate(context)) {
            return;
          }

          item[config.nameKey] = context.get(config.nameKey, "");
          item[config.textKey] = context.get(config.textKey, "");
          item[config.categoryKey] = context.get(config.categoryKey, "");
          item[config.imageKey] = await context.adapter
              ?.uploadMedia(context.get(config.imageKey, ""))
              .showIndicator(context);
          await context.adapter?.saveDocument(item).showIndicator(context);
          context.navigator.pop();
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
