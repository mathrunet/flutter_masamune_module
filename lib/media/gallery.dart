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
    this.mediaKey = Const.media,
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.categoryKey = Const.category,
    this.createdTimeKey = Const.createdTime,
    this.crossAxisCountForMobile = 4,
    this.crossAxisCountForDesktop = 6,
    this.childAspectRatioForMobile = 0.5625,
    this.childAspectRatioForDesktop = 1,
    this.heightOnDetailView = 200,
    this.tileSpacing = 1,
    this.tabConfig = const [],
    this.mediaType = PlatformMediaType.all,
    this.skipDetailPage = false,
    PermissionConfig permission = const PermissionConfig(),
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => Gallery(this)),
      "/$routePath/tab/{tab_id}": RouteConfig(
          (context) => _GridView(this, category: context.get("tab_id", ""))),
      "/$routePath/edit": RouteConfig((_) => _MediaEdit(this, inAdd: true)),
      "/$routePath/{media_id}": RouteConfig((_) => _MediaDetail(this)),
      "/$routePath/{media_id}/view": RouteConfig((_) => _MediaView(this)),
      "/$routePath/{media_id}/edit": RouteConfig((_) => _MediaEdit(this)),
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

  /// 画像・映像のキー。
  final String mediaKey;

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
  final int crossAxisCountForMobile;
  final int crossAxisCountForDesktop;

  /// タイルのアスペクト比。
  final double childAspectRatioForMobile;
  final double childAspectRatioForDesktop;

  /// タイルのスペース。
  final double tileSpacing;

  /// 詳細画面の画像の高さ。
  final double heightOnDetailView;

  /// 対応するメディアタイプ。
  final PlatformMediaType mediaType;

  /// タブの設定。
  final List<TabConfig> tabConfig;

  /// 詳細のページは出さずに直接画像を表示する場合は`true`。
  final bool skipDetailPage;
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
    final user = useUserDocumentModel(config.userPath);

    return PlatformBuilder(
      mobile: TabScaffold<TabConfig>(
        title: Text(config.title ?? "Gallery".localize()),
        source: config.tabConfig,
        tabBuilder: (tab) => Text(tab.label),
        viewBuilder: (tab) => _GridView(config, category: tab.id),
        floatingActionButton:
            config.permission.canEdit(user.get(config.roleKey, ""))
                ? FloatingActionButton.extended(
                    label: Text("Add".localize()),
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      context.navigator.pushNamed(
                        "/${config.routePath}/edit",
                        arguments: RouteQuery.fullscreenOrModal,
                      );
                    },
                  )
                : null,
      ),
      desktop: () {
        final controller = useNavigatorController(
          "/${config.routePath}/tab/${config.tabConfig.firstOrNull?.id}",
        );
        final tabId = controller.route?.name?.last();

        return Scaffold(
          appBar: PlatformAppBar(
            title: Text(config.title ?? "Gallery".localize()),
          ),
          body: BlogContainer(
            leftBar: Scrollbar(
              child: ListView(
                children: [
                  ...config.tabConfig.map(
                    (e) => ListTile(
                      title: Text(
                        e.label,
                        style: TextStyle(
                          color: tabId == e.id
                              ? context.theme.textColorOnPrimary
                              : null,
                          fontWeight: tabId == e.id ? FontWeight.bold : null,
                        ),
                      ),
                      tileColor: tabId == e.id
                          ? context.theme.primaryColor.withOpacity(0.8)
                          : null,
                      onTap: tabId == e.id
                          ? null
                          : () {
                              controller.navigator.pushReplacementNamed(
                                  "/${config.routePath}/tab/${e.id}");
                            },
                    ),
                  ),
                ],
              ),
            ),
            child: InlinePageBuilder(controller: controller),
          ),
          floatingActionButton:
              config.permission.canEdit(user.get(config.roleKey, ""))
                  ? FloatingActionButton.extended(
                      label: Text("Add".localize()),
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        context.rootNavigator.pushNamed(
                          "/${config.routePath}/edit",
                          arguments: RouteQuery.fullscreenOrModal,
                        );
                      },
                    )
                  : null,
        );
      }(),
    );
  }
}

class TileGallery extends PageHookWidget {
  const TileGallery(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel(config.userPath);

    return Scaffold(
      appBar: PlatformAppBar(
        title: Text(config.title ?? "Gallery".localize()),
      ),
      body: _GridView(config),
      floatingActionButton:
          config.permission.canEdit(user.get(config.roleKey, ""))
              ? FloatingActionButton.extended(
                  label: Text("Add".localize()),
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.navigator.pushNamed(
                      "/${config.routePath}/edit",
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
    final gallery = useCollectionModel(path).where(
      (item) {
        if (category.isEmpty) {
          return true;
        }
        return item.get(config.categoryKey, "") == category;
      },
    );

    return PlatformScrollbar(
      child: GridView.count(
        crossAxisCount: context.isMobileOrSmall
            ? config.crossAxisCountForMobile
            : config.crossAxisCountForDesktop,
        childAspectRatio: context.isMobile
            ? config.childAspectRatioForMobile
            : config.childAspectRatioForDesktop,
        mainAxisSpacing: config.tileSpacing,
        crossAxisSpacing: config.tileSpacing,
        children: [
          ...gallery.mapWidget(
            (item) {
              final path = item.get(config.mediaKey, "");
              final type = getPlatformMediaType(path);
              switch (type) {
                case PlatformMediaType.video:
                  return Container(
                    color: context.theme.dividerColor,
                    child: ClipRRect(
                      child: ClickableBox.video(
                        video: NetworkOrAsset.video(path),
                        fit: BoxFit.cover,
                        onTap: () {
                          context.rootNavigator.pushNamed(
                            config.skipDetailPage
                                ? "/${config.routePath}/${item.get(Const.uid, "")}/view"
                                : "/${config.routePath}/${item.get(Const.uid, "")}",
                            arguments: RouteQuery.fullscreenOrModal,
                          );
                        },
                      ),
                    ),
                  );
                default:
                  return ClickableBox.image(
                    image: NetworkOrAsset.image(path),
                    fit: BoxFit.cover,
                    onTap: () {
                      context.rootNavigator.pushNamed(
                        config.skipDetailPage
                            ? "/${config.routePath}/${item.get(Const.uid, "")}/view"
                            : "/${config.routePath}/${item.get(Const.uid, "")}",
                        arguments: RouteQuery.fullscreenOrModal,
                      );
                    },
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MediaDetail extends PageHookWidget {
  const _MediaDetail(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel(config.userPath);
    final item = useDocumentModel(
        "${config.galleryPath}/${context.get("media_id", "")}");

    final now = DateTime.now();
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final media = item.get(config.mediaKey, "");
    final createdTime =
        item.get(config.createdTimeKey, now.millisecondsSinceEpoch);
    final type = getPlatformMediaType(media);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          if (config.permission.canEdit(user.get(config.roleKey, "")))
            IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.navigator.pushNamed(
                    "/${config.routePath}/${context.get("media_id", "")}/edit",
                    arguments: RouteQuery.fullscreenOrModal,
                  );
                })
        ],
      ),
      body: PlatformScrollbar(
        child: ListView(
          children: [
            InkWell(
              onTap: () {
                context.navigator.pushNamed(
                  "/${config.routePath}/${context.get("media_id", "")}/view",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              child: () {
                switch (type) {
                  case PlatformMediaType.video:
                    return Container(
                      color: context.theme.dividerColor,
                      height: config.heightOnDetailView,
                      child: ClipRRect(
                        child: Video(
                          NetworkOrAsset.video(media),
                          fit: BoxFit.cover,
                          autoplay: true,
                          mute: true,
                          mixWithOthers: true,
                        ),
                      ),
                    );
                  default:
                    return Container(
                      height: config.heightOnDetailView,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkOrAsset.image(media),
                          fit: BoxFit.cover,
                        ),
                        color: context.theme.disabledColor,
                      ),
                    );
                }
              }(),
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
      ),
    );
  }
}

class _MediaView extends PageHookWidget {
  const _MediaView(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel(config.userPath);
    final item = useDocumentModel(
        "${config.galleryPath}/${context.get("media_id", "")}");
    final name = item.get(config.nameKey, "");
    final media = item.get(config.mediaKey, "");
    final type = getPlatformMediaType(media);

    return PlatformModalView(
      widthRatio: 0.8,
      heightRatio: 0.8,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
          actions: [
            if (config.skipDetailPage &&
                config.permission.canEdit(user.get(config.roleKey, "")))
              IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.navigator.pushNamed(
                      "/${config.routePath}/${context.get("media_id", "")}/edit",
                      arguments: RouteQuery.fullscreenOrModal,
                    );
                  })
          ],
        ),
        backgroundColor: Colors.black,
        body: media.isEmpty
            ? Center(
                child: Text(
                  "No data.".localize(),
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : () {
                switch (type) {
                  case PlatformMediaType.video:
                    return Center(
                      child: Video(
                        NetworkOrAsset.video(media),
                        fit: BoxFit.contain,
                        controllable: true,
                        mixWithOthers: true,
                      ),
                    );
                  default:
                    return PhotoView(
                      imageProvider: NetworkOrAsset.image(media),
                    );
                }
              }(),
      ),
    );
  }
}

class _MediaEdit extends PageHookWidget with UIPageFormMixin, UIPageUuidMixin {
  _MediaEdit(this.config, {this.inAdd = false});
  final GalleryModule config;
  final bool inAdd;

  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel(config.userPath);
    final item = useDocumentModel(
        "${config.galleryPath}/${context.get("media_id", puid)}");
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final media = item.get(config.mediaKey, "");

    return PlatformModalView(
      widthRatio: 0.8,
      heightRatio: 0.8,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            inAdd
                ? "A new entry".localize()
                : "Editing %s".localize().format([name]),
          ),
          actions: [
            if (!inAdd &&
                config.permission.canDelete(user.get(config.roleKey, "")))
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  UIConfirm.show(
                    context,
                    title: "Confirmation".localize(),
                    text:
                        "You can't undo it after deleting it. May I delete it?"
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
        body: PlatformScrollbar(
          child: FormBuilder(
            padding: const EdgeInsets.all(0),
            key: formKey,
            children: [
              FormItemMedia(
                height: 200,
                dense: true,
                controller: useMemoizedTextEditingController(
                  inAdd ? "" : media,
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
                  context[config.mediaKey] = value;
                },
              ),
              const Space.height(12),
              DividHeadline("Title".localize()),
              FormItemTextField(
                dense: true,
                hintText: "Input %s".localize().format(["Title".localize()]),
                controller: useMemoizedTextEditingController(inAdd ? "" : name),
                onSaved: (value) {
                  context[config.nameKey] = value;
                },
              ),
              DividHeadline("Description".localize()),
              FormItemTextField(
                dense: true,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 5,
                hintText:
                    "Input %s".localize().format(["Description".localize()]),
                allowEmpty: true,
                controller: useMemoizedTextEditingController(inAdd ? "" : text),
                onSaved: (value) {
                  context[config.textKey] = value;
                },
              ),
              if (config.tabConfig.isNotEmpty) ...[
                DividHeadline("Category".localize()),
                FormItemDropdownField(
                  dense: true,
                  // labelText: "Category".localize(),
                  hintText:
                      "Input %s".localize().format(["Category".localize()]),
                  controller: useMemoizedTextEditingController(inAdd
                      ? config.tabConfig.first.id
                      : item.get(
                          config.categoryKey, config.tabConfig.first.id)),
                  items: <String, String>{
                    for (final tab in config.tabConfig) tab.id: tab.label
                  },
                  onSaved: (value) {
                    context[config.categoryKey] = value;
                  },
                ),
              ],
              const Divid(),
              const Space.height(100),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (!validate(context)) {
              return;
            }

            item[config.nameKey] = context.get(config.nameKey, "");
            item[config.textKey] = context.get(config.textKey, "");
            item[config.categoryKey] = context.get(config.categoryKey, "");
            item[config.mediaKey] = await context.adapter
                ?.uploadMedia(context.get(config.mediaKey, ""))
                .showIndicator(context);
            await context.adapter?.saveDocument(item).showIndicator(context);
            context.navigator.pop();
          },
          label: Text("Submit".localize()),
          icon: const Icon(Icons.check),
        ),
      ),
    );
  }
}
