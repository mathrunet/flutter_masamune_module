import 'package:masamune_module/masamune_module.dart';
import 'package:photo_view/photo_view.dart' as photo_view;

@immutable
class TileGalleryMediaModule extends PageModule {
  const TileGalleryMediaModule({
    bool enabled = true,
    String? title,
    this.routePath = "gallery",
    this.queryPath = "gallery",
    this.query,
    this.mediaKey = Const.media,
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.createdTimeKey = Const.createdTime,
    this.maxCrossAxisExtentForMobile = 200,
    this.maxCrossAxisExtentForDesktop = 200,
    this.childAspectRatioForMobile = 0.5625,
    this.childAspectRatioForDesktop = 1,
    this.heightOnDetailView = 200,
    this.tileSpacing = 1,
    this.automaticallyImplyLeadingOnHome = true,
    this.sliverLayoutWhenModernDesignOnHome = true,
    this.enableEdit = true,
    this.enableDetail = true,
    this.mediaType = PlatformMediaType.all,
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const TileGalleryMediaModuleHome(),
    this.editPage = const TileGalleryMediaModuleEdit(),
    this.mediaViewPage = const TileGalleryMediaModuleMediaView(),
    this.mediaDetailPage = const TileGalleryMediaModuleMediaDetail(),
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
      "/$routePath/edit": RouteConfig((_) => editPage),
      "/$routePath/media/{media_id}": RouteConfig((_) => mediaDetailPage),
      "/$routePath/media/{media_id}/view": RouteConfig((_) => mediaViewPage),
      "/$routePath/media/{media_id}/edit": RouteConfig((_) => editPage),
    };
    return route;
  }

  // Widget.
  final PageModuleWidget<TileGalleryMediaModule> homePage;
  final PageModuleWidget<TileGalleryMediaModule> editPage;
  final PageModuleWidget<TileGalleryMediaModule> mediaDetailPage;
  final PageModuleWidget<TileGalleryMediaModule> mediaViewPage;

  /// Route path.
  final String routePath;

  /// Query path.
  final String queryPath;

  /// Query.
  final ModelQuery? query;

  /// 画像・映像のキー。
  final String mediaKey;

  /// タイトルのキー。
  final String nameKey;

  /// テキストのキー。
  final String textKey;

  /// 作成日のキー。
  final String createdTimeKey;

  /// 編集を可能にする場合true.
  final bool enableEdit;

  /// 詳細ページを表示する場合true.
  final bool enableDetail;

  /// 詳細画面の画像の高さ。
  final double heightOnDetailView;

  /// 対応するメディアタイプ。
  final PlatformMediaType mediaType;

  /// タイルの横方向のサイズ。
  final double maxCrossAxisExtentForMobile;
  final double maxCrossAxisExtentForDesktop;

  /// タイルのアスペクト比。
  final double childAspectRatioForMobile;
  final double childAspectRatioForDesktop;

  /// タイルのスペース。
  final double tileSpacing;

  /// True if Home is a sliver layout.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// True if you want to automatically display the back button when you are at home.
  final bool automaticallyImplyLeadingOnHome;
}

class TileGalleryMediaModuleHome
    extends PageModuleWidget<TileGalleryMediaModule> {
  const TileGalleryMediaModuleHome();

  @override
  Widget build(
      BuildContext context, WidgetRef ref, TileGalleryMediaModule module) {
    final gallery = ref.watchCollectionModel(
      module.query?.value ?? module.queryPath,
    );

    return UIScaffold(
      appBar: UIAppBar(
        title: Text(module.title ?? "Gallery".localize()),
        automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
        sliverLayoutWhenModernDesign: module.sliverLayoutWhenModernDesignOnHome,
      ),
      body: LoadingBuilder(
        futures: [
          gallery.loading,
        ],
        builder: (context) {
          return UIGridBuilder<DynamicDocumentModel>.extent(
            maxCrossAxisExtent: context.isMobile
                ? module.maxCrossAxisExtentForMobile
                : module.maxCrossAxisExtentForDesktop,
            childAspectRatio: context.isMobile
                ? module.childAspectRatioForMobile
                : module.childAspectRatioForDesktop,
            mainAxisSpacing: module.tileSpacing,
            crossAxisSpacing: module.tileSpacing,
            source: gallery,
            builder: (context, item) {
              final path = item.get(module.mediaKey, "");
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
                            !module.enableDetail
                                ? "/${module.routePath}/media/${item.get(Const.uid, "")}/view"
                                : "/${module.routePath}/media/${item.get(Const.uid, "")}",
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
                        !module.enableDetail
                            ? "/${module.routePath}/media/${item.get(Const.uid, "")}/view"
                            : "/${module.routePath}/media/${item.get(Const.uid, "")}",
                        arguments: RouteQuery.fullscreenOrModal,
                      );
                    },
                  );
              }
            },
          );
        },
      ),
      floatingActionButton: module.enableEdit
          ? FloatingActionButton.extended(
              onPressed: () {
                context.navigator.pushNamed(
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

class TileGalleryMediaModuleMediaDetail
    extends PageModuleWidget<TileGalleryMediaModule> {
  const TileGalleryMediaModuleMediaDetail();

  @override
  Widget build(
      BuildContext context, WidgetRef ref, TileGalleryMediaModule module) {
    final item = ref.watchDocumentModel(
        "${module.query?.value.trimQuery() ?? module.queryPath}/${context.get("media_id", "")}");

    final now = ref.useNow();
    final name = item.get(module.nameKey, "");
    final text = item.get(module.textKey, "");
    final media = item.get(module.mediaKey, "");
    final createdTime =
        item.get(module.createdTimeKey, now.millisecondsSinceEpoch);
    final type = getPlatformMediaType(media);

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(name),
        actions: [
          if (module.enableEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.navigator.pushNamed(
                  "/${module.routePath}/media/${context.get("media_id", "")}/edit",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
            ),
        ],
      ),
      body: UIListView(
        children: [
          InkWell(
            onTap: () {
              context.navigator.pushNamed(
                "/${module.routePath}/media/${context.get("media_id", "")}/view",
                arguments: RouteQuery.fullscreenOrModal,
              );
            },
            child: () {
              switch (type) {
                case PlatformMediaType.video:
                  return Container(
                    color: context.theme.dividerColor,
                    height: module.heightOnDetailView,
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
                    height: module.heightOnDetailView,
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

class TileGalleryMediaModuleMediaView
    extends PageModuleWidget<TileGalleryMediaModule> {
  const TileGalleryMediaModuleMediaView();

  @override
  Widget build(
      BuildContext context, WidgetRef ref, TileGalleryMediaModule module) {
    final item = ref.watchDocumentModel(
        "${module.query?.value.trimQuery() ?? module.queryPath}/${context.get("media_id", "")}");
    final name = item.get(module.nameKey, "");
    final media = item.get(module.mediaKey, "");
    final type = getPlatformMediaType(media);

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(name),
        actions: [
          if (module.enableEdit && !module.enableDetail)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.navigator.pushNamed(
                  "/${module.routePath}/media/${context.get("media_id", "")}/edit",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
            ),
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
                  return photo_view.PhotoView(
                    imageProvider: NetworkOrAsset.image(media),
                  );
              }
            }(),
    );
  }
}

class TileGalleryMediaModuleEdit
    extends PageModuleWidget<TileGalleryMediaModule> {
  const TileGalleryMediaModuleEdit();

  @override
  Widget build(
      BuildContext context, WidgetRef ref, TileGalleryMediaModule module) {
    final form = ref.useForm("media_id");
    final item = ref.watchDocumentModel(
        "${module.query?.value.trimQuery() ?? module.queryPath}/${form.uid}");
    final name = item.get(module.nameKey, "");
    final text = item.get(module.textKey, "");
    final media = item.get(module.mediaKey, "");

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        sliverLayoutWhenModernDesign: false,
        title: Text(form.select(
          "Editing %s".localize().format([name]),
          "A new entry".localize(),
        )),
        actions: [
          if (form.exists)
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
                    if (module.enableDetail) {
                      context.navigator.pop();
                      context.navigator.pop();
                      context.navigator.pop();
                    } else {
                      context.navigator.pop();
                      context.navigator.pop();
                    }
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
              module.mediaKey,
              form.select(media, ""),
            ),
            errorText: "No input %s".localize().format(["Image".localize()]),
            onTap: (onUpdate) async {
              final media = await context.platform?.mediaDialog(
                context,
                title: "Please select your %s"
                    .localize()
                    .format(["Media".localize().toLowerCase()]),
                type: module.mediaType,
              );
              onUpdate(media?.path);
            },
            onSaved: (value) {
              context[module.mediaKey] = value;
            },
          ),
          const Space.height(12),
          DividHeadline("Title".localize()),
          FormItemTextField(
            dense: true,
            hintText: "Input %s".localize().format(["Title".localize()]),
            errorText: "No input %s".localize().format(["Title".localize()]),
            controller: ref.useTextEditingController(
              module.nameKey,
              form.select(name, ""),
            ),
            onSaved: (value) {
              context[module.nameKey] = value;
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
              module.textKey,
              form.select(text, ""),
            ),
            onSaved: (value) {
              context[module.textKey] = value;
            },
          ),
          const Divid(),
          const Space.height(100),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!form.validate()) {
            return;
          }

          item[module.nameKey] = context.get(module.nameKey, "");
          item[module.textKey] = context.get(module.textKey, "");
          item[module.mediaKey] = await context.model
              ?.uploadMedia(context.get(module.mediaKey, ""))
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
