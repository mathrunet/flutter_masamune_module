import 'package:masamune_module/masamune_module.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

@immutable
class DetailModule extends PageModule {
  const DetailModule({
    bool enabled = true,
    String? title,
    this.routePath = "detail",
    required this.queryPath,
    this.commentQueryPath = "comment",
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.imageKey = Const.image,
    this.iconKey = Const.icon,
    this.timeKey = Const.time,
    this.userKey = Const.user,
    this.tagKey = Const.tag,
    this.searchPath = "search",
    this.likeCountKey = "likeCount",
    this.userPath = Const.user,
    this.enableBookmark = true,
    this.enableComment = true,
    this.enableLike = true,
    this.enableShare = true,
    this.multipleImage = false,
    this.enableFeatureImage = true,
    this.bookmarkPath = "bookmark",
    this.likePath = "like",
    this.automaticallyImplyLeadingOnHome = true,
    this.expandedHeight = 240,
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
    this.home,
    this.image,
    this.appBarBottomActions = const [],
    this.contents = const [],
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
      "/$routePath/{detail_id}":
          RouteConfig((_) => home ?? DetailModuleHome(this)),
      "/$routePath/{detail_id}/view":
          RouteConfig((_) => image ?? DetailModuleImageView(this)),
    };
    return route;
  }

  // Page settings.
  final Widget? home;
  final Widget? image;

  /// Keys.
  final String tagKey;
  final String nameKey;
  final String iconKey;
  final String textKey;
  final String imageKey;
  final String timeKey;
  final String userKey;
  final String likeCountKey;

  /// ホームのときのバックボタンを削除するかどうか。
  final bool automaticallyImplyLeadingOnHome;

  /// ツールバーの高さ
  final double expandedHeight;

  /// Route path.
  final String routePath;

  /// Query path.
  final String queryPath;
  final String searchPath;
  final String userPath;
  final String likePath;
  final String bookmarkPath;
  final String commentQueryPath;

  final bool enableLike;
  final bool enableBookmark;
  final bool enableComment;
  final bool enableShare;
  final bool enableFeatureImage;

  final bool multipleImage;

  // Widget.
  final List<Widget> appBarBottomActions;
  final List<Widget> contents;
}

class DetailModuleHome extends PageScopedWidget {
  const DetailModuleHome(this.config);
  final DetailModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Please describe reference.
    final detailId = context.get("detail_id", "");
    final detail = ref.watchDocumentModel("${config.queryPath}/$detailId");
    final name = detail.get(config.nameKey, "");
    final images = config.multipleImage
        ? detail.getAsList(config.imageKey)
        : [
            if (detail.containsKey(config.imageKey))
              detail.get(config.imageKey, "")
          ];
    final focus = ref.useFocusNode(
      "comment",
      context.get("comment", false),
    );
    final comment = ref.watchCollectionModel(
      ModelQuery(
        "${config.queryPath}/$detailId/${config.commentQueryPath}",
        order: ModelQueryOrder.desc,
        orderBy: config.timeKey,
      ).value,
    );
    final commentWithUser = comment.mergeUserInformation(
      ref,
      userCollectionPath: config.userPath,
      userKey: config.userKey,
    );
    final multipleImage = images.length > 1;

    // Please describe the Widget.
    return UIScaffold(
      appBar: config.enableFeatureImage
          ? UIModernDetailAppBar(
              title: Text(name),
              onTapImage: () {
                context.navigator
                    .pushNamed("/${config.routePath}/$detailId/view");
              },
              designType: DesignType.modern,
              expandedHeight: config.expandedHeight,
              automaticallyImplyLeading: config.automaticallyImplyLeadingOnHome,
              background: multipleImage
                  ? ColoredBox(
                      color: context.theme.dividerColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Image(
                                image: NetworkOrAsset.image(images.first),
                                fit: BoxFit.cover),
                          ),
                          const Space.height(1),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                for (int i = 1; i < 4; i++)
                                  if (i < images.length) ...[
                                    Expanded(
                                      child: Image(
                                          image:
                                              NetworkOrAsset.image(images[i]),
                                          fit: BoxFit.cover),
                                    ),
                                    const Space.width(1),
                                  ] else ...[
                                    const Expanded(
                                      child: ColoredBox(color: Colors.black),
                                    ),
                                    const Space.width(1),
                                  ]
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : null,
              backgroundImage:
                  images.isNotEmpty ? NetworkOrAsset.image(images.first) : null,
              bottomActions: [
                if (config.appBarBottomActions.isNotEmpty)
                  ...config.appBarBottomActions
                else
                  DetailModuleDateWidget(config),
              ],
            )
          : AppBar(
              title: Text(name),
              automaticallyImplyLeading: config.automaticallyImplyLeadingOnHome,
            ),
      body: ListBuilder<DynamicMap>(
        padding: const EdgeInsets.all(0),
        source: commentWithUser,
        top: [
          if (!config.enableFeatureImage)
            if (config.appBarBottomActions.isNotEmpty)
              ...config.appBarBottomActions
            else
              DetailModuleDateWidget(config),
          if (config.contents.isNotEmpty)
            ...config.contents
          else ...[
            DetailModuleNameWidget(config),
            DetailModuleTextWidget(config),
            DetailModuleTagsWidget(config),
            const Space.height(16),
            DetailModuleActionWidget(
              config,
              focusNode: focus,
            ),
          ],
          if (config.enableComment) ...[
            const Divid(),
            FormItemCommentField(
              focusNode: focus,
              hintText: "Input %s".localize().format(["Comment".localize()]),
              controller: ref.useTextEditingController("comment"),
              onSubmitted: (value) async {
                if (value.isEmpty) {
                  return;
                }
                final doc = context.model?.createDocument(comment);
                if (doc == null) {
                  return;
                }
                doc[config.userKey] = context.model?.userId;
                doc[config.textKey] = value;
                await context.model?.saveDocument(doc);
              },
            ),
            const Divid(),
          ],
        ],
        builder: (context, item, index) {
          return [
            CommentTile(
              avatar: NetworkOrAsset.image(
                item.get("${config.userKey}${config.iconKey}", ""),
              ),
              name: item.get("${config.userKey}${config.nameKey}", ""),
              text: item.get(config.textKey, ""),
              date: item.getAsDateTime(config.timeKey),
            ),
            const Divid(),
          ];
        },
      ),
    );
  }
}

class DetailModuleDateWidget extends ScopedWidget {
  const DetailModuleDateWidget(this.config);
  final DetailModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailId = context.get("detail_id", "");
    final detail = ref.watchDocumentModel("${config.queryPath}/$detailId");
    final time = detail.getAsDateTime(config.timeKey);

    return Text(
      time.format("yyyy/MM/dd HH:mm"),
      style: TextStyle(
        color: context.theme.textColor.withOpacity(0.5),
      ),
    );
  }
}

class DetailModuleNameWidget extends ScopedWidget {
  const DetailModuleNameWidget(this.config);
  final DetailModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailId = context.get("detail_id", "");
    final detail = ref.watchDocumentModel("${config.queryPath}/$detailId");
    final name = detail.get(config.nameKey, "");

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(name, style: context.theme.textTheme.headline5),
    );
  }
}

class DetailModuleTextWidget extends ScopedWidget {
  const DetailModuleTextWidget(this.config);
  final DetailModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailId = context.get("detail_id", "");
    final detail = ref.watchDocumentModel("${config.queryPath}/$detailId");
    final text = detail.get(config.textKey, "");

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(text),
    );
  }
}

class DetailModuleContentWidget extends ScopedWidget {
  const DetailModuleContentWidget(
    this.config, {
    this.contentLabel,
  });
  final DetailModule config;
  final String? contentLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailId = context.get("detail_id", "");
    final detail = ref.watchDocumentModel("${config.queryPath}/$detailId");
    final text = detail.get(config.textKey, "");

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          if (contentLabel.isNotEmpty) ...[
            Text(
              contentLabel!.localize(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Space.height(16),
          ],
          Text(text),
        ],
      ),
    );
  }
}

class DetailModuleTagsWidget extends ScopedWidget {
  const DetailModuleTagsWidget(this.config);
  final DetailModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailId = context.get("detail_id", "");
    final detail = ref.watchDocumentModel("${config.queryPath}/$detailId");
    final tags = detail.getAsList(config.tagKey);

    if (tags.isEmpty) {
      return const Empty();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: tags.mapAndRemoveEmpty(
          (e) => TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              alignment: Alignment.centerLeft,
              primary: context.theme.textColor.withOpacity(0.5),
            ),
            child: Text(
              "#$e",
              style: const TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
            onPressed: () {
              context.rootNavigator.pushNamed(
                "/${config.searchPath}",
                arguments: RouteQuery(
                  transition: PageTransition.fullscreen,
                  parameters: {"query": e},
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DetailModuleActionWidget extends ScopedWidget {
  const DetailModuleActionWidget(
    this.config, {
    this.focusNode,
  });
  final DetailModule config;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailId = context.get("detail_id", "");
    final detail = ref.watchDocumentModel("${config.queryPath}/$detailId");
    final count = detail.get(config.likeCountKey, 0);
    final like = ref
        .watchDocumentModel(
            "${config.userPath}/${context.model?.userId}/${config.likePath}/$detailId")
        .isNotEmpty;
    final bookmark = ref
        .watchDocumentModel(
            "${config.userPath}/${context.model?.userId}/${config.bookmarkPath}/$detailId")
        .isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (config.enableLike)
            TextButton.icon(
              style: TextButton.styleFrom(
                primary:
                    like ? context.theme.primaryColor : context.theme.textColor,
              ),
              icon: const Icon(Icons.thumb_up),
              onPressed: () {
                final counter = context.model?.incrementCounter(
                  collectionPath:
                      "${config.queryPath}/$detailId/${config.likePath}",
                  linkedCollectionPath:
                      "${config.userPath}/${context.model!.userId}/${config.likePath}",
                );
                if (like) {
                  counter?.remove(context.model!.userId, linkId: detail.uid);
                } else {
                  counter?.append(context.model!.userId, linkId: detail.uid);
                }
              },
              label: Text(
                count.toString(),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          if (config.enableComment)
            IconButton(
              color: context.theme.textColor,
              icon: const Icon(Icons.comment),
              onPressed: () {
                focusNode?.requestFocus();
              },
            ),
          if (config.enableShare)
            IconButton(
              color: context.theme.textColor,
              icon: const Icon(Icons.share),
              onPressed: () {},
            ),
          if (config.enableBookmark)
            IconButton(
              color: bookmark
                  ? context.theme.primaryColor
                  : context.theme.textColor,
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                final counter = context.model?.incrementCounter(
                  collectionPath:
                      "${config.queryPath}/$detailId/${config.bookmarkPath}",
                  linkedCollectionPath:
                      "${config.userPath}/${context.model!.userId}/${config.bookmarkPath}",
                );
                if (bookmark) {
                  counter?.remove(context.model!.userId, linkId: detail.uid);
                } else {
                  counter?.append(context.model!.userId, linkId: detail.uid);
                }
              },
            )
        ],
      ),
    );
  }
}

class DetailModuleProfileWidget extends ScopedWidget {
  const DetailModuleProfileWidget(this.config);
  final DetailModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watchUserDocumentModel();
    final icon = user.get(config.iconKey, "assets/default.png");
    final name = user.get(config.nameKey, "");
    final text = user.get(config.textKey, "");

    return InkWell(
      onTap: () {
        context.rootNavigator.pushNamed(
          "/user/${context.model?.userId}",
          arguments: RouteQuery.fullscreenOrModal,
        );
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.symmetric(
                horizontal: BorderSide(
          color: context.theme.dividerColor.withOpacity(0.25),
          width: 1,
        ))),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircleAvatar(
                backgroundImage: NetworkOrAsset.image(icon),
              ),
            ),
            const Space.width(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Space.height(8),
                  Text(text,
                      style: TextStyle(
                          fontSize: 14, color: context.theme.disabledColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailModuleImageView extends PageScopedWidget {
  const DetailModuleImageView(this.config);
  final DetailModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailId = context.get("detail_id", "");
    final detail = ref.watchDocumentModel("${config.queryPath}/$detailId");
    final name = detail.get(config.nameKey, "");
    final images = config.multipleImage
        ? detail.getAsList(config.imageKey)
        : [
            if (detail.containsKey(config.imageKey))
              detail.get(config.imageKey, "")
          ];
    final controller = ref.usePageController();
    final page = !controller.hasClients ? 0.0 : controller.page ?? 0.0;
    final length = images.length - 1;

    return UIScaffold(
      designType: DesignType.material,
      backgroundColor: Colors.black,
      appBar: UIAppBar(
        title: Text(name),
      ),
      body: images.length >= 2
          ? Stack(
              fit: StackFit.expand,
              children: [
                PhotoViewGallery.builder(
                  itemCount: images.length,
                  gaplessPlayback: true,
                  pageController: controller,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkOrAsset.image(images[index]),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 16, 24),
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Slider(
                            divisions: length,
                            value: page / length,
                            onChanged: (value) {
                              if (!controller.hasClients) {
                                return;
                              }
                              final page = (value * length).round();
                              if (page == controller.page) {
                                return;
                              }
                              controller.animateToPage(
                                page,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutQuart,
                              );
                            },
                          ),
                        ),
                        Text(
                          "${(page + 1).round()}/${images.length}",
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          : PhotoView(
              imageProvider: NetworkOrAsset.image(images.firstOrNull),
            ),
    );
  }
}
