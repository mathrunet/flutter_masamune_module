import 'package:masamune_module/masamune_module.dart';
import 'package:photo_view/photo_view.dart';

@immutable
class SingleMediaModule extends PageModule
    with VerifyAppReroutePageModuleMixin {
  const SingleMediaModule({
    bool enabled = true,
    String title = "",
    this.galleryType = GalleryType.tile,
    this.routePath = "media",
    this.queryPath = "app/media",
    this.userPath = "user",
    this.mediaKey = Const.media,
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.categoryKey = Const.category,
    this.createdTimeKey = Const.createdTime,
    this.mediaType = PlatformMediaType.all,
    Permission permission = const Permission(),
    this.sliverLayoutWhenModernDesignOnHome = true,
    this.automaticallyImplyLeadingOnHome = true,
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const SingleMediaModuleHome(),
    this.editPage = const SingleMediaModuleEdit(),
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
      "/$routePath": RouteConfig((_) => homePage),
      "/$routePath/edit": RouteConfig((_) => editPage),
    };
    return route;
  }

  // ページ設定。
  final PageModuleWidget<SingleMediaModule> homePage;
  final PageModuleWidget<SingleMediaModule> editPage;

  /// ホームをスライバーレイアウトにする場合True.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// ホームのときのバックボタンを削除するかどうか。
  final bool automaticallyImplyLeadingOnHome;

  /// ルートのパス。
  final String routePath;

  /// ギャラリーのタイプ。
  final GalleryType galleryType;

  /// メディアデータのパス。
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

  /// 対応するメディアタイプ。
  final PlatformMediaType mediaType;
}

class SingleMediaModuleHome extends PageModuleWidget<SingleMediaModule> {
  const SingleMediaModuleHome();

  @override
  Widget build(BuildContext context, WidgetRef ref, SingleMediaModule module) {
    final now = ref.useNow();
    final user = ref.watchUserDocumentModel(module.userPath);
    final item = ref.watchDocumentModel(module.queryPath);
    final name = item.get(module.nameKey, "");
    final media = item.get(module.mediaKey, "");
    final date = item.get(module.createdTimeKey, now.millisecondsSinceEpoch);
    final type = getPlatformMediaType(media);

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(
          name.isNotEmpty
              ? name
              : (module.title ??
                  "%s's ${type == PlatformMediaType.video ? "Video" : "Image"}"
                      .localize()
                      .format([
                    DateTime.fromMillisecondsSinceEpoch(date)
                        .format("yyyy/MM/dd"),
                  ])),
        ),
        actions: [
          if (module.permission.canEdit(user.get(module.roleKey, "")))
            IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.navigator.pushNamed(
                    "/${module.routePath}/edit",
                    arguments: RouteQuery.fullscreenOrModal,
                  );
                })
        ],
        sliverLayoutWhenModernDesign: module.sliverLayoutWhenModernDesignOnHome,
        automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
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
                  return PhotoView(imageProvider: NetworkOrAsset.image(media));
              }
            }(),
    );
  }
}

class SingleMediaModuleEdit extends PageModuleWidget<SingleMediaModule> {
  const SingleMediaModuleEdit();

  @override
  Widget build(BuildContext context, WidgetRef ref, SingleMediaModule module) {
    final form = ref.useForm();
    final item = ref.watchDocumentModel(module.queryPath);
    final name = item.get(module.nameKey, "");
    final media = item.get(module.mediaKey, "");

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        sliverLayoutWhenModernDesign: false,
        title: Text(
          "Editing %s".localize().format([
            if (name.isEmpty) "Media".localize() else name,
          ]),
        ),
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
              media,
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
              name,
            ),
            onSaved: (value) {
              context[module.nameKey] = value;
            },
          ),
          const Divid(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!form.validate()) {
            return;
          }

          item[module.nameKey] = context.get(module.nameKey, "");
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
