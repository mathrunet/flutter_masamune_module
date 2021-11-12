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
class ChatModule extends PageModule with VerifyAppReroutePageModuleMixin {
  const ChatModule({
    bool enabled = true,
    String? title = "",
    this.routePath = "chat",
    this.queryPath = "chat",
    this.userPath = "user",
    this.availableMemberPath = "user",
    this.mediaType = PlatformMediaType.all,
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.typeKey = Const.type,
    this.memberKey = Const.member,
    this.mediaKey = Const.media,
    this.createdTimeKey = Const.createdTime,
    this.modifiedTimeKey = Const.modifiedTime,
    this.chatRoomQuery,
    this.availableMemberQuery,
    Permission permission = const Permission(),
    RerouteConfig? rerouteConfig,
    this.home,
    this.timeline,
    this.mediaView,
    this.edit,
  }) : super(
          enabled: enabled,
          title: title,
          permission: permission,
          rerouteConfig: rerouteConfig,
        );

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

  /// ルートのパス。
  final String routePath;

  /// チャットデータのパス。
  final String queryPath;

  /// メンバーデータのキー。
  final String memberKey;

  /// ルームを作成可能なメンバーのリスト。
  final String? availableMemberPath;

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

  /// チャットルームのクエリ。
  final ModelQuery? chatRoomQuery;

  /// ルームを作成可能なメンバーのリスト。
  final ModelQuery? availableMemberQuery;

  @override
  ChatModule? fromMap(DynamicMap map) => _$ChatModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$ChatModuleToMap(this);
}

class ChatModuleHome extends PageScopedWidget {
  const ChatModuleHome(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.useNow();
    final user = ref.watchAsUserDocumentModel(config.userPath);
    final chat = ref.watchAsCollectionModel(
      config.chatRoomQuery?.value ??
          ModelQuery(
            config.queryPath,
            key: config.memberKey,
            arrayContains: user.get(Const.uid, ""),
          ).value,
    );
    final membersPath =
        config.availableMemberQuery?.value ?? config.availableMemberPath;
    final members =
        membersPath == null ? null : ref.watchAsCollectionModel(membersPath);
    final filteredMembers = members?.where((m) {
      if (context.model?.userId == m.uid) {
        return false;
      }
      return !chat.any((e) {
        final members = e.get(config.memberKey, []);
        if (members.length > 2) {
          return false;
        }
        return members.any((member) => member.toString() == m.uid);
      });
    }).toList();
    final users = ref.watchAsCollectionModel(
      ModelQuery(
        config.userPath,
        key: Const.uid,
        order: ModelQueryOrder.desc,
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
            (item) => item.toString() == a.get(Const.uid, ""));
        return u != null;
      },
      apply: (o, a) =>
          o.mergeListenable(a, convertKeys: (key) => "${Const.user}$key"),
      orElse: (o) => o,
    );
    final controller = ref.useNavigatorController(
      "/${config.routePath}/${chatWithUser.firstOrNull.get(Const.uid, "")}",
      (route) => chatWithUser.isEmpty,
    );

    return UIScaffold(
      waitTransition: true,
      loadingFutures: [
        chat.loading,
        users.loading,
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
                trailing: Icon(
                  Icons.check_circle,
                  color: context.theme.primaryColor,
                ),
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
          if (filteredMembers != null)
            ...filteredMembers.mapListenable(
              (item) {
                final name = item.get(config.nameKey, "");
                return ListItem(
                  selected: !context.isMobileOrModal &&
                      controller.route?.name.last() == item.get(Const.uid, ""),
                  selectedColor: context.theme.textColorOnPrimary,
                  selectedTileColor:
                      context.theme.primaryColor.withOpacity(0.8),
                  disabledTapOnSelected: true,
                  title: Text(
                    name.isNotEmpty
                        ? name
                        : item.get("${Const.user}${config.nameKey}", ""),
                  ),
                  subtitle: Text(
                    DateTime.fromMillisecondsSinceEpoch(
                      item.get(
                          config.createdTimeKey, now.millisecondsSinceEpoch),
                    ).format("yyyy/MM/dd HH:mm"),
                  ),
                  onTap: () async {
                    final uid = uuid;
                    final memberId = item.uid;
                    final userId = context.model?.userId;
                    final doc = context.model?.createDocument(chat, uid);
                    if (doc == null || userId.isEmpty) {
                      return;
                    }
                    doc[config.memberKey] = [
                      userId,
                      memberId,
                    ];
                    await context.model
                        ?.saveDocument(doc)
                        .showIndicator(context);
                    if (context.isMobile) {
                      context.navigator.pushNamed(
                        "/${config.routePath}/$uid",
                        arguments: RouteQuery.fullscreen,
                      );
                    } else {
                      controller.navigator.pushNamed(
                        "/${config.routePath}/$uid",
                      );
                    }
                  },
                );
              },
            )
        ],
      ),
    );
  }
}

class ChatModuleTimeline extends PageScopedWidget {
  const ChatModuleTimeline(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.useNow();
    final userId = context.model?.userId;
    final user = ref.watchAsUserDocumentModel();
    final chat = ref.watchAsDocumentModel(
        "${config.queryPath}/${context.get("chat_id", "")}");
    final timeline = ref.watchAsCollectionModel(
      ModelQuery(
              "${config.queryPath}/${context.get("chat_id", "")}/${config.queryPath}",
              order: ModelQueryOrder.desc,
              orderBy: config.createdTimeKey,
              limit: 500)
          .value,
    );
    timeline.sort((a, b) =>
        b.get(config.createdTimeKey, 0) - a.get(config.createdTimeKey, 0));
    final users = ref.watchAsCollectionModel(
      ModelQuery(
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
    final members = ref.watchAsCollectionModel(
      ModelQuery(
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
        builder: (context, item, index) {
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
                              backgroundColor:
                                  context.theme.colorScheme.secondary,
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
            title: "Please select your %s"
                .localize()
                .format(["Media".localize().toLowerCase()]),
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

class ChatModuleTimelineItem extends ScopedWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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

class ChatModuleMediaView extends PageScopedWidget {
  const ChatModuleMediaView(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watchAsDocumentModel(
        "${config.queryPath}/${context.get("chat_id", "")}/${config.queryPath}/${context.get("timeline_id", "")}");
    final media = item.get(config.mediaKey, "");
    final type = getPlatformMediaType(media);

    return UIScaffold(
      waitTransition: true,
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

class ChatModuleEdit extends PageScopedWidget {
  const ChatModuleEdit(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.useForm();
    final chat = ref.watchAsDocumentModel(
        "${config.queryPath}/${context.get("chat_id", "")}");
    final name = chat.get(config.nameKey, "");

    return UIScaffold(
      waitTransition: true,
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
            controller: ref.useTextEditingController(config.nameKey, name),
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
