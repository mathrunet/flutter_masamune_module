import 'package:flutter/foundation.dart';
import 'package:masamune/masamune.dart';
import 'package:masamune/ui/ui.dart';
import 'package:masamune_module/masamune_module.dart';
import 'package:photo_view/photo_view.dart';

part 'chat.m.dart';

enum ChatType { direct, group }

extension ChatTypeExtensions on ChatType {
  String get text {
    switch (this) {
      case ChatType.group:
        return "group";
      default:
        return "direct";
    }
  }
}

@module
@immutable
class ChatModule extends PageModule {
  const ChatModule({
    bool enabled = true,
    String? title = "",
    this.routePath = "chat",
    this.chatPath = "chat",
    this.userPath = "user",
    this.mediaType = PlatformMediaType.all,
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.typeKey = Const.type,
    this.memberKey = Const.member,
    this.mediaKey = Const.media,
    this.createdTimeKey = Const.createdTime,
    this.modifiedTimeKey = Const.modifiedTime,
    this.chatQuery,
    Permission permission = const Permission(),
    this.designType = DesignType.modern,
    this.home,
    this.timeline,
    this.mediaView,
    this.edit,
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => home ?? ChatModuleHome(this)),
      "/$routePath/{chat_id}":
          RouteConfig((_) => timeline ?? ChatModuleTimeline(this)),
      "/$routePath/{chat_id}/media/{timeline_id}":
          RouteConfig((_) => mediaView ?? ChatModuleMediaView(this)),
      "/$routePath/{chat_id}/edit":
          RouteConfig((_) => edit ?? ChatModuleEdit(this)),
    };
    return route;
  }

  // ページ設定
  final Widget? home;
  final Widget? timeline;
  final Widget? mediaView;
  final Widget? edit;

  /// デザインタイプ。
  final DesignType designType;

  /// ルートのパス。
  final String routePath;

  /// チャットデータのパス。
  final String chatPath;

  /// メンバーデータのキー。
  final String memberKey;

  /// ユーザーのデータパス。
  final String userPath;

  /// タイトルのキー。
  final String nameKey;

  /// テキストのキー。
  final String textKey;

  /// チャットタイプのキー。
  final String typeKey;

  /// 権限のキー。
  final String roleKey;

  /// 作成日のキー。
  final String createdTimeKey;

  /// 更新日のキー。
  final String modifiedTimeKey;

  /// メディアのキー。
  final String mediaKey;

  /// 対応するメディアタイプ。
  final PlatformMediaType mediaType;

  /// チャットのクエリ。
  final CollectionQuery? chatQuery;

  @override
  ChatModule? fromMap(DynamicMap map) => _$ChatModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$ChatModuleToMap(this);
}

class ChatModuleHome extends PageHookWidget {
  const ChatModuleHome(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context) {
    final now = useNow();
    final user = useUserDocumentModel(config.userPath);
    final chat = useCollectionModel(
      config.chatQuery?.value ??
          CollectionQuery(
            config.chatPath,
            key: config.memberKey,
            arrayContains: user.get(Const.uid, ""),
          ).value,
    );
    final users = useCollectionModel(
      CollectionQuery(
        config.userPath,
        key: Const.uid,
        order: CollectionQueryOrder.desc,
        orderBy: config.modifiedTimeKey,
        whereIn: chat.map((e) {
          final member = e.get(config.memberKey, []);
          final u = member.firstWhereOrNull(
              (item) => item.toString() != user.get(Const.uid, ""));
          return u.toString();
        }).distinct(),
      ).value,
    );
    final chatWithUser = chat.setWhereListenable(
      users,
      test: (o, a) {
        final member = o.get(config.memberKey, []);
        final u = member.firstWhereOrNull(
            (item) => item.toString() != a.get(Const.uid, ""));
        return u != null;
      },
      apply: (o, a) =>
          o.mergeListenable(a, convertKeys: (key) => "${Const.user}$key"),
      orElse: (o) => o,
    );
    final controller = useNavigatorController(
      "/${config.routePath}/${chatWithUser.firstOrNull.get(Const.uid, "")}",
      (route) => chatWithUser.isEmpty,
    );

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      loadingFutures: [
        chat.future,
        users.future,
      ],
      inlineNavigatorControllerOnWeb: controller,
      appBar: UIAppBar(
        title: Text(config.title ?? "Chat".localize()),
      ),
      body: UIListView(
        children: [
          ...chatWithUser.mapListenable(
            (item) {
              final name = item.get(config.nameKey, "");
              return ListItem(
                selected: !context.isMobileOrModal &&
                    controller.route?.name.last() == item.get(Const.uid, ""),
                selectedColor: context.theme.textColorOnPrimary,
                selectedTileColor: context.theme.primaryColor.withOpacity(0.8),
                disabledTapOnSelected: true,
                title: Text(
                  name.isNotEmpty
                      ? name
                      : item.get("${Const.user}${config.nameKey}", ""),
                ),
                subtitle: Text(
                  DateTime.fromMillisecondsSinceEpoch(
                    item.get(config.createdTimeKey, now.millisecondsSinceEpoch),
                  ).format("yyyy/MM/dd HH:mm"),
                ),
                onTap: () {
                  if (context.isMobile) {
                    context.navigator.pushNamed(
                      "/${config.routePath}/${item.get(Const.uid, "")}",
                      arguments: RouteQuery.fullscreen,
                    );
                  } else {
                    controller.navigator.pushNamed(
                      "/${config.routePath}/${item.get(Const.uid, "")}",
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChatModuleTimeline extends PageHookWidget {
  const ChatModuleTimeline(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context) {
    final now = useNow();
    final userId = context.model?.userId;
    final user = useUserDocumentModel();
    final chat =
        useDocumentModel("${config.chatPath}/${context.get("chat_id", "")}");
    final timeline = useCollectionModel(
      CollectionQuery(
              "${config.chatPath}/${context.get("chat_id", "")}/${config.chatPath}",
              order: CollectionQueryOrder.desc,
              orderBy: config.createdTimeKey,
              limit: 500)
          .value,
    );
    timeline.sort((a, b) =>
        b.get(config.createdTimeKey, 0) - a.get(config.createdTimeKey, 0));
    final users = useCollectionModel(
      CollectionQuery(
        config.userPath,
        key: Const.uid,
        whereIn: timeline.map((e) => e.get(Const.user, "")).distinct(),
      ).value,
    );
    final timlineWithUser = timeline.setWhere(
      users,
      test: (o, a) => o.get(Const.user, "") == a.get(Const.uid, ""),
      apply: (o, a) => o.merge(a, convertKeys: (key) => "${Const.user}$key"),
      orElse: (o) => o,
    );
    final members = useCollectionModel(
      CollectionQuery(
        config.userPath,
        key: Const.uid,
        whereIn:
            chat.get(config.memberKey, []).map((e) => e.toString()).distinct(),
      ).value,
    );
    final title = members.fold<List<String>>(
      <String>[],
      (previousValue, element) => element.get(Const.uid, "") == userId
          ? previousValue
          : (previousValue..add(element.get(config.nameKey, ""))),
    ).join(", ");
    final name = chat.get(config.nameKey, "");

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      appBar: UIAppBar(
        title: Text(name.isEmpty ? title : name),
        actions: [
          if (config.permission.canEdit(user.get(config.roleKey, ""))) ...[
            if (chat.get(config.typeKey, "") == ChatType.group.text)
              IconButton(
                  onPressed: () {
                    context.rootNavigator.pushNamed(
                      "/${config.routePath}/${context.get("chat_id", "")}/member",
                      arguments: RouteQuery.fullscreenOrModal,
                    );
                  },
                  icon: const Icon(Icons.people_alt)),
            IconButton(
              onPressed: () {
                context.rootNavigator.pushNamed(
                  "/${config.routePath}/${context.get("chat_id", "")}/edit",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ]
        ],
      ),
      body: UIListBuilder<DynamicMap>(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 64),
        reverse: true,
        source: timlineWithUser.toList(),
        builder: (context, item) {
          final date = DateTime.fromMillisecondsSinceEpoch(
            item.get(config.createdTimeKey, now.millisecondsSinceEpoch),
          );
          return [
            if (item.get(Const.user, "") == userId)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(
                          fontSize: 10, color: context.theme.disabledColor),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(date.format("HH:mm")),
                          Text(date.format("yyyy/MM/dd")),
                        ],
                      ),
                    ),
                    const Space.width(4),
                    Flexible(
                      child: ChatModuleTimelineItem(
                        config,
                        data: item,
                        color: context.theme.colorScheme.onPrimary,
                        backgroundColor: context.theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 48,
                      child: CircleAvatar(
                        backgroundImage: NetworkOrAsset.image(
                            item.get("${Const.user}${config.mediaKey}", ""),
                            "assets/default.png"),
                      ),
                    ),
                    const Space.width(4),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: ChatModuleTimelineItem(
                              config,
                              data: item,
                              color: context.theme.colorScheme.onSecondary,
                              backgroundColor: context.theme.accentColor,
                            ),
                          ),
                          const Space.width(4),
                          DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 10,
                              color: context.theme.disabledColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(date.format("HH:mm")),
                                Text(date.format("yyyy/MM/dd")),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ];
        },
      ),
      bottomSheet: FormItemCommentField(
        maxLines: 4,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        borderColor: context.theme.dividerColor,
        hintText: "Input %s".localize().format(["Text".localize()]),
        onSubmitted: (value) {
          if (value.isEmpty) {
            return;
          }

          final doc = context.model?.createDocument(timeline);
          if (doc == null) {
            return;
          }
          doc[Const.user] = userId;
          doc[config.textKey] = value;
          chat[config.modifiedTimeKey] = doc[config.createdTimeKey] =
              DateTime.now().millisecondsSinceEpoch;
          context.model?.saveDocument(doc);
          context.model?.saveDocument(chat);
        },
        onTapMediaIcon: () async {
          final media = await context.platform?.mediaDialog(
            context,
            title: "Please select your media".localize(),
            type: config.mediaType,
          );
          if (media?.path == null) {
            return;
          }

          final url = await context.model
              ?.uploadMedia(media?.path)
              .showIndicator(context);
          if (url.isEmpty) {
            return;
          }

          final doc = context.model?.createDocument(timeline);
          if (doc == null) {
            return;
          }
          doc[Const.user] = userId;
          doc[config.mediaKey] = url;
          chat[config.modifiedTimeKey] = doc[config.createdTimeKey] =
              DateTime.now().millisecondsSinceEpoch;
          context.model?.saveDocument(doc);
          context.model?.saveDocument(chat);
        },
      ),
    );
  }
}

class ChatModuleTimelineItem extends StatelessWidget {
  const ChatModuleTimelineItem(
    this.config, {
    required this.data,
    this.color,
    this.backgroundColor,
  });
  final ChatModule config;

  final DynamicMap data;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final media = data.get(config.mediaKey, "");
    if (media.isNotEmpty) {
      final type = getPlatformMediaType(media);
      switch (type) {
        case PlatformMediaType.video:
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: InkWell(
              onTap: () {
                context.rootNavigator.pushNamed(
                  "/${config.routePath}/${context.get("chat_id", "")}/media/${data.get(Const.uid, "")}",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Video(NetworkOrAsset.video(media)),
              ),
            ),
          );
        default:
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: InkWell(
              onTap: () {
                context.rootNavigator.pushNamed(
                  "/${config.routePath}/${context.get("chat_id", "")}/media/${data.get(Const.uid, "")}",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image(image: NetworkOrAsset.image(media)),
              ),
            ),
          );
      }
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: DefaultBoxDecoration(
          width: 0,
          backgroundColor: backgroundColor,
        ),
        child: Text(
          data.get(config.textKey, ""),
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
        ),
      );
    }
  }
}

class ChatModuleMediaView extends PageHookWidget {
  const ChatModuleMediaView(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context) {
    final item = useDocumentModel(
        "${config.chatPath}/${context.get("chat_id", "")}/${config.chatPath}/${context.get("timeline_id", "")}");
    final media = item.get(config.mediaKey, "");
    final type = getPlatformMediaType(media);

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      appBar: const UIAppBar(),
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
    );
  }
}

class ChatModuleEdit extends PageHookWidget {
  const ChatModuleEdit(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context) {
    final form = useForm();
    final chat =
        useDocumentModel("${config.chatPath}/${context.get("chat_id", "")}");
    final name = chat.get(config.nameKey, "");

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      appBar: UIAppBar(
          sliverLayoutWhenModernDesign: false,
          title: Text("Editing %s".localize().format(["Chat".localize()]))),
      body: FormBuilder(
        padding: const EdgeInsets.all(0),
        key: form.key,
        children: [
          const Space.height(16),
          DividHeadline("Title".localize()),
          FormItemTextField(
            dense: true,
            allowEmpty: true,
            hintText: "Input %s".localize().format(["Title".localize()]),
            controller: useMemoizedTextEditingController(name),
            onSaved: (value) {
              context[config.nameKey] = value;
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

          chat[config.nameKey] = context.get(config.nameKey, "");
          await context.model?.saveDocument(chat).showIndicator(context);
          context.navigator.pop();
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
