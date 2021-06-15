import 'package:masamune/masamune.dart';
import 'package:masamune_module/masamune_module.dart';
import 'package:photo_view/photo_view.dart';

import 'gallery.dart';

part "single_media.m.dart";

@module
@immutable
class SingleMediaModule extends PageModule {
  const SingleMediaModule({
    bool enabled = true,
    String title = "",
    this.galleryType = GalleryType.tile,
    this.routePath = "media",
    this.mediaPath = "app/media",
    this.userPath = "user",
    this.mediaKey = Const.media,
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.categoryKey = Const.category,
    this.createdTimeKey = Const.createdTime,
    this.mediaType = PlatformMediaType.all,
    Permission permission = const Permission(),
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => SingleMedia(this)),
      "/$routePath/edit": RouteConfig((_) => _SingleMediaEdit(this)),
    };
    return route;
  }

  /// ルートのパス。
  final String routePath;

  /// ギャラリーのタイプ。
  final GalleryType galleryType;

  /// メディアデータのパス。
  final String mediaPath;

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

class SingleMedia extends PageHookWidget {
  const SingleMedia(this.config);
  final SingleMediaModule config;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final user = useUserDocumentModel(config.userPath);
    final item = useDocumentModel(config.mediaPath);
    final name = item.get(config.nameKey, "");
    final media = item.get(config.mediaKey, "");
    final date = item.get(config.createdTimeKey, now.millisecondsSinceEpoch);
    final type = getPlatformMediaType(media);

    return Scaffold(
      appBar: PlatformAppBar(
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

class _SingleMediaEdit extends PageHookWidget
    with UIPageFormMixin, UIPageUuidMixin {
  _SingleMediaEdit(this.config);
  final SingleMediaModule config;

  @override
  Widget build(BuildContext context) {
    final item = useDocumentModel(config.mediaPath);
    final name = item.get(config.nameKey, "");
    final media = item.get(config.mediaKey, "");

    return PlatformModalView(
      widthRatio: 0.8,
      heightRatio: 0.8,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Editing %s".localize().format([
              if (name.isEmpty) "Media".localize() else name,
            ]),
          ),
        ),
        body: PlatformScrollbar(
          child: FormBuilder(
            padding: const EdgeInsets.all(0),
            key: formKey,
            children: [
              FormItemMedia(
                height: 200,
                dense: true,
                controller: useMemoizedTextEditingController(media),
                onTap: (onUpdate) async {
                  final media = await context.platform?.mediaDialog(
                    context,
                    title: "Please select your media".localize(),
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
                controller: useMemoizedTextEditingController(name),
                onSaved: (value) {
                  context[config.nameKey] = value;
                },
              ),
              const Divid(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (!validate(context)) {
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
      ),
    );
  }
}
