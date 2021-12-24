import 'package:masamune_module/masamune_module.dart';
import 'package:photo_view/photo_view.dart' as phto_view;

part "gallery.m.dart";

enum GalleryType {
  detail,
  tile,
  tileWithTab,
  tileWithList,
}

@module
@immutable
class GalleryModule extends PageModule with VerifyAppReroutePageModuleMixin {
  const GalleryModule({
    bool enabled = true,
    String title = "",
    this.galleryType = GalleryType.tile,
    this.routePath = "gallery",
    this.queryPath = "gallery",
    this.userPath = "user",
    this.mediaKey = Const.media,
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.categoryKey = Const.category,
    this.createdTimeKey = Const.createdTime,
    this.maxCrossAxisExtentForMobile = 200,
    this.maxCrossAxisExtentForDesktop = 200,
    this.childAspectRatioForMobile = 0.5625,
    this.childAspectRatioForDesktop = 1,
    this.heightOnDetailView = 200,
    this.tileSpacing = 1,
    this.categoryConfig = const [],
    this.mediaType = PlatformMediaType.all,
    this.skipDetailPage = false,
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
    this.contentQuery,
    this.categoryQuery,
    this.home,
    this.gridView,
    this.grid,
    this.edit,
    this.tileView,
    this.tileViewWithTab,
    this.tileViewWithList,
    this.mediaView,
    this.mediaDetail,
  }) : super(
          enabled: enabled,
          title: title,
          permission: permission,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => home ?? GalleryModuleHome(this)),
      "/$routePath/edit": RouteConfig((_) => edit ?? GalleryModuleEdit(this)),
      "/$routePath/{category_id}":
          RouteConfig((context) => gridView ?? GalleryModuleGridView(this)),
      "/$routePath/media/{media_id}":
          RouteConfig((_) => mediaDetail ?? GalleryModuleMediaDetail(this)),
      "/$routePath/media/{media_id}/view":
          RouteConfig((_) => mediaView ?? GalleryModuleMediaView(this)),
      "/$routePath/media/{media_id}/edit":
          RouteConfig((_) => edit ?? GalleryModuleEdit(this)),
    };
    return route;
  }

  // ページ設定。
  final Widget? home;
  final Widget? gridView;
  final Widget? grid;
  final Widget? edit;
  final Widget? mediaDetail;
  final Widget? mediaView;
  final Widget? tileView;
  final Widget? tileViewWithTab;
  final Widget? tileViewWithList;

  /// ルートのパス。
  final String routePath;

  /// ギャラリーのタイプ。
  final GalleryType galleryType;

  /// ギャラリーデータのパス。
  final String queryPath;

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

  /// コンテンツ用のクエリ。
  final ModelQuery? contentQuery;

  /// カテゴリー用のクエリ。
  final ModelQuery? categoryQuery;

  /// タイルの横方向のサイズ。
  final double maxCrossAxisExtentForMobile;
  final double maxCrossAxisExtentForDesktop;

  /// タイルのアスペクト比。
  final double childAspectRatioForMobile;
  final double childAspectRatioForDesktop;

  /// タイルのスペース。
  final double tileSpacing;

  /// 詳細画面の画像の高さ。
  final double heightOnDetailView;

  /// 対応するメディアタイプ。
  final PlatformMediaType mediaType;

  /// カテゴリーの設定。
  final List<GroupConfig> categoryConfig;

  /// 詳細のページは出さずに直接画像を表示する場合は`true`。
  final bool skipDetailPage;

  @override
  GalleryModule? fromMap(DynamicMap map) => _$GalleryModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$GalleryModuleToMap(this);
}

class GalleryModuleHome extends PageScopedWidget {
  const GalleryModuleHome(this.config);
  final GalleryModule config;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (config.galleryType) {
      case GalleryType.tile:
        return config.tileView ?? GalleryModuleTileView(config);
      case GalleryType.tileWithTab:
        return config.tileViewWithTab ?? GalleryModuleTileViewWithTab(config);
      case GalleryType.tileWithList:
        return config.tileViewWithList ?? GalleryModuleTileViewWithList(config);
      default:
        return const Empty();
    }
  }
}

class GalleryModuleTileViewWithList extends PageScopedWidget {
  const GalleryModuleTileViewWithList(this.config);
  final GalleryModule config;

  List<GroupConfig> _categories(BuildContext context, WidgetRef ref) {
    if (config.categoryQuery != null) {
      final categories = ref.watchCollectionModel(config.categoryQuery!.value);
      return categories.mapAndRemoveEmpty((item) =>
          GroupConfig(id: item.uid, label: item.get(config.nameKey, "")))
        ..addAll(config.categoryConfig);
    }
    return config.categoryConfig;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watchUserDocumentModel(config.userPath);
    final list = _categories(context, ref);
    final controller = ref.useNavigatorController(
      "/${config.routePath}/${list.firstOrNull?.id}",
    );

    return UIScaffold(
      waitTransition: true,
      inlineNavigatorControllerOnWeb: controller,
      appBar: UIAppBar(
        title: Text(config.title ?? "Gallery".localize()),
      ),
      body: UIListBuilder<GroupConfig>(
        source: list,
        builder: (context, item, index) {
          return [
            ListItem(
              title: Text(item.label),
              onTap: () {
                context.navigator.pushNamed("/${config.routePath}/${item.id}");
              },
            )
          ];
        },
      ),
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
    );
  }
}

class GalleryModuleTileViewWithTab extends PageScopedWidget {
  const GalleryModuleTileViewWithTab(this.config);
  final GalleryModule config;

  List<GroupConfig> _categories(BuildContext context, WidgetRef ref) {
    if (config.categoryQuery != null) {
      final categories = ref.watchCollectionModel(config.categoryQuery!.value);
      return categories.mapAndRemoveEmpty((item) =>
          GroupConfig(id: item.uid, label: item.get(config.nameKey, "")))
        ..addAll(config.categoryConfig);
    }
    return config.categoryConfig;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watchUserDocumentModel(config.userPath);
    final list = _categories(context, ref);
    final tab = ref.useTab(list);
    final controller = ref.useNavigatorController(
      "/${config.routePath}/${config.categoryConfig.firstOrNull?.id}",
    );

    return UIScaffold(
      waitTransition: true,
      inlineNavigatorControllerOnWeb: controller,
      appBar: UIAppBar(
        title: Text(config.title ?? "Gallery".localize()),
        bottom: UITabBar<GroupConfig>(tab),
      ),
      body: UITabView<GroupConfig>(
        tab,
        builder: (context, item, key) {
          return config.grid ?? GalleryModuleGrid(config, category: item);
        },
      ),
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
    );
  }
}

class GalleryModuleTileView extends PageScopedWidget {
  const GalleryModuleTileView(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watchUserDocumentModel(config.userPath);
    final controller = ref.useNavigatorController(
      "/${config.routePath}/${config.categoryConfig.firstOrNull?.id}",
    );

    return UIScaffold(
      waitTransition: true,
      inlineNavigatorControllerOnWeb: controller,
      appBar: UIAppBar(
        title: Text(config.title ?? "Gallery".localize()),
      ),
      body: config.grid ?? GalleryModuleGrid(config),
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

class GalleryModuleGridView extends PageScopedWidget {
  const GalleryModuleGridView(this.config);
  final GalleryModule config;

  List<GroupConfig> _categories(BuildContext context, WidgetRef ref) {
    if (config.categoryQuery != null) {
      final categories = ref.watchCollectionModel(config.categoryQuery!.value);
      return categories.mapAndRemoveEmpty((item) =>
          GroupConfig(id: item.uid, label: item.get(config.nameKey, "")))
        ..addAll(config.categoryConfig);
    }
    return config.categoryConfig;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = _categories(context, ref);
    final category = list
        .firstWhereOrNull((item) => item.id == context.get("category_id", ""));

    if (category == null) {
      return UIScaffold(
        appBar: UIAppBar(
          title: Text(config.title ?? "Gallery".localize()),
        ),
        body: Center(
          child: Text("No data.".localize()),
        ),
      );
    }

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(category.label.localize()),
      ),
      body: GalleryModuleGrid(config, category: category),
    );
  }
}

class GalleryModuleGrid extends ScopedWidget {
  const GalleryModuleGrid(this.config, {this.category});
  final GalleryModule config;
  final GroupConfig? category;

  DynamicCollectionModel _gallery(BuildContext context, WidgetRef ref) {
    if (category == null) {
      return ref
          .watchCollectionModel(config.contentQuery?.value ?? config.queryPath);
    }
    return ref.watchCollectionModel(
      category!.query?.value ??
          config.contentQuery?.value ??
          ModelQuery(
            config.queryPath,
            key: config.categoryKey,
            isEqualTo: category!.id,
          ).value,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gallery = _gallery(context, ref);
    final filtered = gallery.where(
      (item) {
        if (category == null) {
          return true;
        }
        return item.get(config.categoryKey, "") == category!.id;
      },
    );

    return LoadingBuilder(
      futures: [
        gallery.loading,
      ],
      builder: (context) {
        return UIGridBuilder<DynamicDocumentModel>.extent(
          maxCrossAxisExtent: context.isMobile
              ? config.maxCrossAxisExtentForMobile
              : config.maxCrossAxisExtentForDesktop,
          childAspectRatio: context.isMobile
              ? config.childAspectRatioForMobile
              : config.childAspectRatioForDesktop,
          mainAxisSpacing: config.tileSpacing,
          crossAxisSpacing: config.tileSpacing,
          source: filtered.toList(),
          builder: (context, item) {
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
                              ? "/${config.routePath}/media/${item.get(Const.uid, "")}/view"
                              : "/${config.routePath}/media/${item.get(Const.uid, "")}",
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
                          ? "/${config.routePath}/media/${item.get(Const.uid, "")}/view"
                          : "/${config.routePath}/media/${item.get(Const.uid, "")}",
                      arguments: RouteQuery.fullscreenOrModal,
                    );
                  },
                );
            }
          },
        );
      },
    );
  }
}

class GalleryModuleMediaDetail extends PageScopedWidget {
  const GalleryModuleMediaDetail(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watchUserDocumentModel(config.userPath);
    final item = ref.watchDocumentModel(
        "${config.queryPath}/${context.get("media_id", "")}");

    final now = ref.useNow();
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final media = item.get(config.mediaKey, "");
    final createdTime =
        item.get(config.createdTimeKey, now.millisecondsSinceEpoch);
    final type = getPlatformMediaType(media);

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(name),
        actions: [
          if (config.permission.canEdit(user.get(config.roleKey, "")))
            IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.navigator.pushNamed(
                    "/${config.routePath}/media/${context.get("media_id", "")}/edit",
                    arguments: RouteQuery.fullscreenOrModal,
                  );
                })
        ],
      ),
      body: UIListView(
        children: [
          InkWell(
            onTap: () {
              context.navigator.pushNamed(
                "/${config.routePath}/media/${context.get("media_id", "")}/view",
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
    );
  }
}

class GalleryModuleMediaView extends PageScopedWidget {
  const GalleryModuleMediaView(this.config);
  final GalleryModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watchUserDocumentModel(config.userPath);
    final item = ref.watchDocumentModel(
        "${config.queryPath}/${context.get("media_id", "")}");
    final name = item.get(config.nameKey, "");
    final media = item.get(config.mediaKey, "");
    final type = getPlatformMediaType(media);

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(name),
        actions: [
          if (config.skipDetailPage &&
              config.permission.canEdit(user.get(config.roleKey, "")))
            IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.navigator.pushNamed(
                    "/${config.routePath}/media/${context.get("media_id", "")}/edit",
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
                  return phto_view.PhotoView(
                    imageProvider: NetworkOrAsset.image(media),
                  );
              }
            }(),
    );
  }
}

class GalleryModuleEdit extends PageScopedWidget {
  const GalleryModuleEdit(this.config);
  final GalleryModule config;

  List<GroupConfig> _categories(BuildContext context, WidgetRef ref) {
    if (config.categoryQuery != null) {
      final categories = ref.watchCollectionModel(config.categoryQuery!.value);
      return categories.mapAndRemoveEmpty((item) =>
          GroupConfig(id: item.uid, label: item.get(config.nameKey, "")))
        ..addAll(config.categoryConfig);
    }
    return config.categoryConfig;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.useForm("media_id");
    final user = ref.watchUserDocumentModel(config.userPath);
    final item = ref.watchDocumentModel("${config.queryPath}/${form.uid}");
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final media = item.get(config.mediaKey, "");
    final categories = _categories(context, ref);

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        sliverLayoutWhenModernDesign: false,
        title: Text(form.select(
          "Editing %s".localize().format([name]),
          "A new entry".localize(),
        )),
        actions: [
          if (form.exists &&
              config.permission.canDelete(user.get(config.roleKey, "")))
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
                    await context.model
                        ?.deleteDocument(item)
                        .showIndicator(context);
                    context.navigator.popUntilNamed("/${config.routePath}");
                  },
                );
              },
            ),
        ],
      ),
      body: FormBuilder(
        padding: const EdgeInsets.all(0),
        key: form.key,
        children: [
          FormItemMedia(
            height: 200,
            dense: true,
            controller: ref.useTextEditingController(
              config.mediaKey,
              form.select(media, ""),
            ),
            errorText: "No input %s".localize().format(["Image".localize()]),
            onTap: (onUpdate) async {
              final media = await context.platform?.mediaDialog(
                context,
                title: "Please select your %s"
                    .localize()
                    .format(["Media".localize().toLowerCase()]),
                type: config.mediaType,
              );
              onUpdate(media?.path);
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
            errorText: "No input %s".localize().format(["Title".localize()]),
            controller: ref.useTextEditingController(
              config.nameKey,
              form.select(name, ""),
            ),
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
            hintText: "Input %s".localize().format(["Description".localize()]),
            allowEmpty: true,
            controller: ref.useTextEditingController(
              config.textKey,
              form.select(text, ""),
            ),
            onSaved: (value) {
              context[config.textKey] = value;
            },
          ),
          if (categories.isNotEmpty) ...[
            DividHeadline("Category".localize()),
            FormItemDropdownField(
              dense: true,
              // labelText: "Category".localize(),
              hintText: "Input %s".localize().format(["Category".localize()]),
              controller: ref.useTextEditingController(
                config.categoryKey,
                form.select(
                  item.get(config.categoryKey, categories.first.id),
                  categories.first.id,
                ),
              ),
              items: <String, String>{
                for (final category in categories) category.id: category.label
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!form.validate()) {
            return;
          }

          item[config.nameKey] = context.get(config.nameKey, "");
          item[config.textKey] = context.get(config.textKey, "");
          item[config.categoryKey] = context.get(config.categoryKey, "");
          item[config.mediaKey] = await context.model
              ?.uploadMedia(context.get(config.mediaKey, ""))
              .showIndicator(context);
          await context.model?.saveDocument(item).showIndicator(context);
          context.navigator.pop();
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
