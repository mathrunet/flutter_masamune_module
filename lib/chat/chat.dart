part of masamune_module;

class ChatModule extends ModuleConfig {
  const ChatModule({
    bool enabled = true,
    String? title = "",
    this.routePath = "chat",
    this.chatPath = "chat",
    this.userPath = "user",
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.memberKey = Const.member,
    this.mediaKey = Const.media,
    this.createdTimeKey = Const.createdTime,
    this.modifiedTimeKey = Const.modifiedTime,
    PermissionConfig permission = const PermissionConfig(),
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => Chat(this)),
      "/$routePath/{chat_id}": RouteConfig((_) => ChatTimeline(this)),
      "/$routePath/{chat_id}/edit": RouteConfig((_) => _ChatEdit(this)),
    };
    return route;
  }

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

  /// 権限のキー。
  final String roleKey;

  /// 作成日のキー。
  final String createdTimeKey;

  /// 更新日のキー。
  final String modifiedTimeKey;

  /// メディアのキー。
  final String mediaKey;
}

class Chat extends PageHookWidget {
  const Chat(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final user = useUserDocumentModel(config.userPath);
    final chat = useCollectionModel(
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
    final chatWithUser = chat.setWhere(
      users,
      test: (o, a) {
        final member = o.get(config.memberKey, []);
        final u = member.firstWhereOrNull(
            (item) => item.toString() != a.get(Const.uid, ""));
        return u != null;
      },
      apply: (o, a) => o.merge(a, convertKeys: (key) => "${Const.user}$key"),
      orElse: (o) => o,
    );

    return Scaffold(
      appBar: PlatformAppBar(
        title: Text(config.title ?? "Chat".localize()),
      ),
      body: PlatformAppLayout(
        initialPath:
            "/${config.routePath}/${chatWithUser.firstOrNull.get(Const.uid, "empty")}",
        builder: (context, isMobile, controller, routeId) {
          return ListView(
            children: [
              ...chatWithUser.mapAndRemoveEmpty(
                (item) {
                  return ListItem(
                    selected: routeId == item.get(Const.uid, ""),
                    selectedColor: context.theme.textColorOnPrimary,
                    selectedTileColor:
                        context.theme.primaryColor.withOpacity(0.8),
                    disabledTapOnSelected: true,
                    title: Text(item.get("${Const.user}${config.nameKey}", "")),
                    subtitle: Text(
                      DateTime.fromMillisecondsSinceEpoch(
                        item.get(
                            config.createdTimeKey, now.millisecondsSinceEpoch),
                      ).format("yyyy/MM/dd HH:mm"),
                    ),
                    onTap: () {
                      if (isMobile) {
                        context.navigator.pushNamed(
                          "/${config.routePath}/${item.get(Const.uid, "")}",
                          arguments: RouteQuery.fullscreen,
                        );
                      } else {
                        controller?.navigator.pushNamed(
                          "/${config.routePath}/${item.get(Const.uid, "")}",
                        );
                      }
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class ChatTimeline extends PageHookWidget {
  const ChatTimeline(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final userId = context.adapter?.userId;
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

    final focusNode = useFocusNode();
    useWidgetState(onInit: () {
      focusNode.requestFocus();
    });
    final textEditingController = useTextEditingController();

    return Scaffold(
      appBar: PlatformInlineAppBar(
        title: Text(name.isEmpty ? title : name),
        actions: [
          if (config.permission.canEdit(user.get(config.roleKey, "")))
            IconButton(
              onPressed: () {
                context.rootNavigator.pushNamed(
                  "/${config.routePath}/${context.get("chat_id", "")}/edit",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              icon: const Icon(Icons.settings),
            )
        ],
      ),
      body: ListBuilder<Map<String, dynamic>>(
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: DefaultBoxDecoration(
                          width: 0,
                          backgroundColor: context.theme.primaryColor,
                        ),
                        child: Text(
                          item.get(config.textKey, ""),
                          style: TextStyle(
                            fontSize: 16,
                            color: context.theme.colorScheme.onPrimary,
                          ),
                        ),
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: DefaultBoxDecoration(
                                width: 0,
                                backgroundColor: context.theme.accentColor,
                              ),
                              child: Text(
                                item.get(config.textKey, ""),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: context.theme.colorScheme.onSecondary,
                                ),
                              ),
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
      bottomSheet: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            color: context.theme.backgroundColor,
            border: Border(
                top: BorderSide(
                    color: Theme.of(context).dividerColor, width: 1))),
        child: Stack(
          children: [
            FormItemTextField(
              dense: true,
              hintText: "Input %s".localize().format(["Text".localize()]),
              focusNode: focusNode,
              controller: textEditingController,
              keyboardType: TextInputType.text,
              maxLines: 4,
              minLines: 1,
              textAlignVertical: TextAlignVertical.top,
              textAlign: TextAlign.start,
              contentPadding: const EdgeInsets.fromLTRB(12, 0, 48, 0),
              onSubmitted: (value) {
                if (value.isEmpty) {
                  return;
                }

                final doc = context.adapter?.createDocument(timeline);
                if (doc == null) {
                  return;
                }
                doc[Const.user] = userId;
                doc[config.textKey] = value;
                chat[config.modifiedTimeKey] = doc[config.createdTimeKey] =
                    DateTime.now().millisecondsSinceEpoch;
                context.adapter?.saveDocument(doc);
                context.adapter?.saveDocument(chat);
                textEditingController.text = "";
                focusNode.requestFocus();
              },
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: IconButton(
                onPressed: () {
                  final value = textEditingController.text;
                  if (value.isEmpty) {
                    return;
                  }

                  final doc = context.adapter?.createDocument(timeline);
                  if (doc == null) {
                    return;
                  }
                  doc[Const.user] = userId;
                  doc[config.textKey] = value;
                  chat[config.modifiedTimeKey] = doc[config.createdTimeKey] =
                      DateTime.now().millisecondsSinceEpoch;
                  context.adapter?.saveDocument(doc);
                  context.adapter?.saveDocument(chat);
                  textEditingController.text = "";
                  focusNode.requestFocus();
                },
                padding: const EdgeInsets.all(0),
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.send,
                  size: 25,
                  color: context.theme.disabledColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ChatEdit extends PageHookWidget with UIPageFormMixin {
  _ChatEdit(this.config);
  final ChatModule config;

  @override
  Widget build(BuildContext context) {
    final chat =
        useDocumentModel("${config.chatPath}/${context.get("chat_id", "")}");
    final name = chat.get(config.nameKey, "");

    return PlatformModalView(
      widthRatio: 0.8,
      heightRatio: 0.8,
      child: Scaffold(
        appBar: AppBar(
            title: Text("Editing %s".localize().format(["Chat".localize()]))),
        body: FormBuilder(
          padding: const EdgeInsets.all(0),
          key: formKey,
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
            if (!validate(context)) {
              return;
            }

            chat[config.nameKey] = context.get(config.nameKey, "");
            await context.adapter?.saveDocument(chat).showIndicator(context);
            context.navigator.pop();
          },
          label: Text("Submit".localize()),
          icon: const Icon(Icons.check),
        ),
      ),
    );
  }
}
