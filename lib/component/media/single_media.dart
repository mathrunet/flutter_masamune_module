import 'package:masamune/masamune.dart';
import 'package:masamune/ui/ui.dart';
import 'package:masamune_module/masamune_module.dart';
import 'package:photo_view/photo_view.dart';

import 'gallery.dart';

part "single_media.m.dart";

@module
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
    RerouteConfig? rerouteConfig,
    this.home,
    this.edit,
  }) : super(
            enabled: enabled,
            title: title,
            permission: permission,
            rerouteConfig: rerouteConfig);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => home ?? SingleMediaModuleHome(this)),
      "/$routePath/edit":
          RouteConfig((_) => edit ?? SingleMediaModuleEdit(this)),
    };
    return route;
  }

  // ページ設定。
  final Widget? home;
  final Widget? edit;

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

  @override
  SingleMediaModule? fromMap(DynamicMap map) =>
      _$SingleMediaModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$SingleMediaModuleToMap(this);
}

class SingleMediaModuleHome extends PageScopedWidget {
  const SingleMediaModuleHome(this.config);
  final SingleMediaModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.useNow();
    final user = ref.watchUserDocumentModel(config.userPath);
    final item = ref.watchDocumentModel(config.queryPath);
    final name = item.get(config.nameKey, "");
    final media = item.get(config.mediaKey, "");
    final date = item.get(config.createdTimeKey, now.millisecondsSinceEpoch);
    final type = getPlatformMediaType(media);

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(
          name.isNotEmpty
              ? name
              : (config.title ??
                  "%s's ${type == PlatformMediaType.video ? "Video" : "Image"}"
                      .localize()
                      .format([
                    DateTime.fromMillisecondsSinceEpoch(date)
                        .format("yyyy/MM/dd"),
                  ])),
        ),
        actions: [
          if (config.permission.canEdit(user.get(config.roleKey, "")))
            IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.navigator.pushNamed(
                    "/${config.routePath}/edit",
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
                  return PhotoView(imageProvider: NetworkOrAsset.image(media));
              }
            }(),
    );
  }
}

class SingleMediaModuleEdit extends PageScopedWidget {
  const SingleMediaModuleEdit(this.config);
  final SingleMediaModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.useForm();
    final item = ref.watchDocumentModel(config.queryPath);
    final name = item.get(config.nameKey, "");
    final media = item.get(config.mediaKey, "");

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
              config.mediaKey,
              media,
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
              name,
            ),
            onSaved: (value) {
              context[config.nameKey] = value;
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

          item[config.nameKey] = context.get(config.nameKey, "");
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