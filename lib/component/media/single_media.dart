import 'package:masamune_module/masamune_module.dart';
import 'package:photo_view/photo_view.dart';

@immutable
class SingleMediaModule extends PageModule {
  const SingleMediaModule({
    bool enabled = true,
    String? title,
    this.routePath = "media",
    this.queryPath = "media",
    this.query,
    this.mediaKey = Const.media,
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.createdTimeKey = Const.createdTime,
    this.mediaType = PlatformMediaType.all,
    this.enableEdit = true,
    this.automaticallyImplyLeadingOnHome = true,
    this.sliverLayoutWhenModernDesignOnHome = true,
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const SingleMediaModuleHome(),
    this.editPage = const SingleMediaModuleEdit(),
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
    };
    return route;
  }

  // Widget.
  final PageModuleWidget<SingleMediaModule> homePage;
  final PageModuleWidget<SingleMediaModule> editPage;

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

  /// 編集を可能にする場合true.
  final bool enableEdit;

  /// 作成日のキー。
  final String createdTimeKey;

  /// True if Home is a sliver layout.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// True if you want to automatically display the back button when you are at home.
  final bool automaticallyImplyLeadingOnHome;

  /// 対応するメディアタイプ。
  final PlatformMediaType mediaType;
}

class SingleMediaModuleHome extends PageModuleWidget<SingleMediaModule> {
  const SingleMediaModuleHome();

  @override
  Widget build(BuildContext context, WidgetRef ref, SingleMediaModule module) {
    // Please describe reference.
    final now = ref.useNow();
    final item =
        ref.watchDocumentModel(module.query?.value ?? module.queryPath);
    final name = item.get(module.nameKey, "");
    final media = item.get(module.mediaKey, "");
    final date = item.get(module.createdTimeKey, now.millisecondsSinceEpoch);
    final type = getPlatformMediaType(media);

    // Please describe the Widget.
    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(
          name.isNotEmpty ? name : "Media".localize(),
        ),
        actions: [
          if (module.enableEdit && media.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                ref.navigator.pushNamed(
                  "/${module.routePath}/edit",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
            ),
        ],
        sliverLayoutWhenModernDesign: module.sliverLayoutWhenModernDesignOnHome,
        automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
      ),
      backgroundColor: Colors.black,
      body: media.isEmpty
          ? Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  primary: context.theme.textColorOnPrimary,
                  backgroundColor: context.theme.primaryColor,
                ),
                label: Text("Add".localize()),
                icon: const Icon(Icons.add),
                onPressed: () {
                  ref.navigator.pushNamed(
                    "/${module.routePath}/edit",
                    arguments: RouteQuery.fullscreenOrModal,
                  );
                },
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
    final item = ref.watchDocumentModel(
        module.query?.value.trimQuery() ?? module.queryPath);
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
          ref.navigator.pop();
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
