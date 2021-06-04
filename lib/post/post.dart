part of masamune_module;

enum PostEditingType { planeText, wysiwyg }

class PostModule extends ModuleConfig {
  const PostModule({
    bool enabled = true,
    String? title = "",
    this.routePath = "post",
    this.postPath = "post",
    this.userPath = "user",
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.createdTimeKey = Const.createdTime,
    this.editingType = PostEditingType.planeText,
    PermissionConfig permission = const PermissionConfig(),
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => Post(this)),
      "/$routePath/edit": RouteConfig((_) => _PostEdit(this, inAdd: true)),
      "/$routePath/empty": RouteConfig((_) => const EmptyPage()),
      "/$routePath/{post_id}": RouteConfig((_) => _PostView(this)),
      "/$routePath/{post_id}/edit": RouteConfig((_) => _PostEdit(this)),
    };
    return route;
  }

  /// ルートのパス。
  final String routePath;

  /// 投稿データのパス。
  final String postPath;

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

  /// エディターのタイプ。
  final PostEditingType editingType;
}

class Post extends PageHookWidget {
  const Post(this.config);
  final PostModule config;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final user = useUserDocumentModel(config.userPath);
    final post = useCollectionModel(config.postPath);
    final users = useCollectionModel(
      CollectionQuery(
        config.userPath,
        key: Const.uid,
        whereIn: post.map((e) => e.get(Const.user, "")).distinct(),
      ).value,
    );
    final postWithUser = post.setWhere(
      users,
      test: (o, a) => o.get(Const.user, "") == a.get(Const.uid, ""),
      apply: (o, a) => o.merge(a, convertKeys: (key) => "${Const.user}$key"),
      orElse: (o) => o,
    );

    return Scaffold(
      appBar: PlatformAppBar(
        title: Text(config.title ?? "Post".localize()),
      ),
      body: PlatformAppLayout(
        initialPath:
            "/${config.routePath}/${postWithUser.firstOrNull.get(Const.uid, "empty")}",
        builder: (context, isMobile, controller, routeId) {
          return ListBuilder<DynamicMap>(
            source: postWithUser.toList(),
            builder: (context, item) {
              return [
                ListItem(
                  selected: routeId ==
                      item.get(Const.uid, ""),
                  selectedColor: context.theme.textColorOnPrimary,
                  selectedTileColor:
                      context.theme.primaryColor.withOpacity(0.8),
                  title: Text(item.get(config.nameKey, "")),
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
                      controller?.navigator.pushReplacementNamed(
                        "/${config.routePath}/${item.get(Const.uid, "")}",
                      );
                    }
                  },
                ),
              ];
            },
          );
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

class _PostView extends PageHookWidget {
  const _PostView(this.config);
  final PostModule config;

  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel(config.userPath);
    final item =
        useDocumentModel("${config.postPath}/${context.get("post_id", "")}");
    final now = DateTime.now();
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final createdTime =
        item.get(config.createdTimeKey, now.millisecondsSinceEpoch);

    final editingType = !text.startsWith(RegExp(r"^(\[|\{)"))
        ? PostEditingType.planeText
        : config.editingType;

    final appBar = PlatformInlineAppBar(
      title: Text(name),
      actions: [
        if (config.permission.canEdit(user.get(config.roleKey, "")))
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.rootNavigator.pushNamed(
                "/${config.routePath}/${context.get("post_id", "")}/edit",
                arguments: RouteQuery.fullscreenOrModal,
              );
            },
          )
      ],
    );

    switch (editingType) {
      case PostEditingType.wysiwyg:
        final controller = useMemoized(
          () => text.isEmpty
              ? QuillController.basic()
              : QuillController(
                  document: Document.fromJson(jsonDecode(text)),
                  selection: const TextSelection.collapsed(offset: 0),
                ),
          [text],
        );

        final child = Scaffold(
          appBar: appBar,
          body: PlatformScrollbar(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Text(
                  DateTime.fromMillisecondsSinceEpoch(createdTime)
                      .format("yyyy/MM/dd HH:mm"),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: context.theme.disabledColor,
                    fontSize: 13,
                  ),
                ),
                const Space.height(12),
                QuillEditor(
                  scrollController: ScrollController(),
                  scrollable: false,
                  focusNode: useFocusNode(),
                  autoFocus: false,
                  controller: controller,
                  placeholder: "Text".localize(),
                  readOnly: true,
                  expands: false,
                  padding: EdgeInsets.zero,
                  customStyles: DefaultStyles(
                    placeHolder: DefaultTextBlockStyle(
                        TextStyle(
                            color: context.theme.disabledColor, fontSize: 16),
                        const Tuple2(16, 0),
                        const Tuple2(0, 0),
                        null),
                  ),
                ),
              ],
            ),
          ),
        );
        if (context.isMobile) {
          return child;
        } else {
          return PlatformModalView(
            widthRatio: 0.8,
            heightRatio: 0.8,
            child: child,
          );
        }
      default:
        final child = Scaffold(
          appBar: appBar,
          body: PlatformScrollbar(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Text(
                  DateTime.fromMillisecondsSinceEpoch(createdTime)
                      .format("yyyy/MM/dd HH:mm"),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: context.theme.disabledColor,
                    fontSize: 13,
                  ),
                ),
                const Space.height(12),
                UIMarkdown(
                  text,
                  fontSize: 16,
                  onTapLink: (url) {
                    context.open(url);
                  },
                )
              ],
            ),
          ),
        );
        if (context.isMobile) {
          return child;
        } else {
          return PlatformModalView(
            widthRatio: 0.8,
            heightRatio: 0.8,
            child: child,
          );
        }
    }
  }
}

class _PostEdit extends PageHookWidget with UIPageFormMixin, UIPageUuidMixin {
  _PostEdit(this.config, {this.inAdd = false});
  final PostModule config;
  final bool inAdd;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final user = useUserDocumentModel(config.userPath);
    final item =
        useDocumentModel("${config.postPath}/${context.get("post_id", puid)}");
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final dateTime =
        item.get(config.createdTimeKey, now.millisecondsSinceEpoch);

    final appBar = AppBar(
      title: Text(
        inAdd
            ? "A new entry".localize()
            : "Editing %s".localize().format([name]),
      ),
      actions: [
        if (!inAdd && config.permission.canDelete(user.get(config.roleKey, "")))
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
                  await context.adapter
                      ?.deleteDocument(item)
                      .showIndicator(context);
                  context.navigator.pop();
                },
              );
            },
          ),
      ],
    );

    final editingType = text.isNotEmpty && !text.startsWith(RegExp(r"^(\[|\{)"))
        ? PostEditingType.planeText
        : config.editingType;

    switch (editingType) {
      case PostEditingType.wysiwyg:
        final controller = useMemoized(
          () => text.isEmpty
              ? QuillController.basic()
              : QuillController(
                  document: Document.fromJson(jsonDecode(text)),
                  selection: const TextSelection.collapsed(offset: 0),
                ),
          [text],
        );

        return PlatformModalView(
          widthRatio: 0.8,
          heightRatio: 0.8,
          child: Scaffold(
            appBar: appBar,
            body: PlatformScrollbar(
              child: FormBuilder(
                key: formKey,
                padding: const EdgeInsets.all(0),
                type: FormBuilderType.fixed,
                children: [
                  FormItemTextField(
                    dense: true,
                    hintText: "Title".localize(),
                    errorText:
                        "Input %s".localize().format(["Title".localize()]),
                    subColor: context.theme.disabledColor,
                    controller: useMemoizedTextEditingController(name),
                    onSaved: (value) {
                      context[config.nameKey] = value;
                    },
                  ),
                  const Divid(),
                  FormItemDateTimeField(
                    dense: true,
                    hintText: "Post time".localize(),
                    errorText:
                        "Input %s".localize().format(["Post time".localize()]),
                    controller: useMemoizedTextEditingController(
                        FormItemDateTimeField.formatDateTime(dateTime)),
                    onSaved: (value) {
                      context[config.createdTimeKey] =
                          value?.millisecondsSinceEpoch ??
                              now.millisecondsSinceEpoch;
                    },
                  ),
                  const Divid(),
                  QuillToolbar.basic(
                    controller: controller,
                    toolbarIconSize: 24,
                    onImagePickCallback: (file) async {
                      if (file.path.isEmpty || !file.existsSync()) {
                        return "";
                      }
                      return await context.adapter!.uploadMedia(file.path);
                    },
                  ),
                  Expanded(
                    child: QuillEditor(
                      scrollController: ScrollController(),
                      scrollable: true,
                      focusNode: useFocusNode(),
                      autoFocus: false,
                      controller: controller,
                      placeholder: "Text".localize(),
                      readOnly: false,
                      expands: true,
                      padding: const EdgeInsets.all(12),
                      customStyles: DefaultStyles(
                        placeHolder: DefaultTextBlockStyle(
                            TextStyle(
                                color: context.theme.disabledColor,
                                fontSize: 16),
                            const Tuple2(16, 0),
                            const Tuple2(0, 0),
                            null),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (!validate(context)) {
                  return;
                }
                try {
                  item[config.nameKey] = context.get(config.nameKey, "");
                  item[config.textKey] =
                      jsonEncode(controller.document.toDelta().toJson());
                  item[config.createdTimeKey] = context.get(
                      config.createdTimeKey, now.millisecondsSinceEpoch);
                  await context.adapter
                      ?.saveDocument(item)
                      .showIndicator(context);
                  context.navigator.pop();
                } catch (e) {
                  UIDialog.show(
                    context,
                    title: "Error".localize(),
                    text: "Editing is not completed.".localize(),
                  );
                }
              },
              label: Text("Submit".localize()),
              icon: const Icon(Icons.check),
            ),
          ),
        );
      default:
        return PlatformModalView(
          widthRatio: 0.8,
          heightRatio: 0.8,
          child: Scaffold(
            appBar: appBar,
            body: PlatformScrollbar(
              child: FormBuilder(
                key: formKey,
                padding: const EdgeInsets.all(0),
                type: FormBuilderType.fixed,
                children: [
                  FormItemTextField(
                    dense: true,
                    hintText: "Title".localize(),
                    errorText:
                        "Input %s".localize().format(["Title".localize()]),
                    subColor: context.theme.disabledColor,
                    controller: useMemoizedTextEditingController(name),
                    onSaved: (value) {
                      context[config.nameKey] = value;
                    },
                  ),
                  const Divid(),
                  FormItemDateTimeField(
                    dense: true,
                    hintText: "Post time".localize(),
                    errorText:
                        "Input %s".localize().format(["Post time".localize()]),
                    controller: useMemoizedTextEditingController(
                        FormItemDateTimeField.formatDateTime(dateTime)),
                    onSaved: (value) {
                      context[config.createdTimeKey] =
                          value?.millisecondsSinceEpoch ??
                              now.millisecondsSinceEpoch;
                    },
                  ),
                  const Divid(),
                  Expanded(
                    child: FormItemTextField(
                      dense: true,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      hintText: "Commenct".localize(),
                      subColor: context.theme.disabledColor,
                      controller: useMemoizedTextEditingController(text),
                      onSaved: (value) {
                        context[config.textKey] = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (!validate(context)) {
                  return;
                }
                try {
                  item[config.nameKey] = context.get(config.nameKey, "");
                  item[config.textKey] = context.get(config.textKey, "");
                  item[config.createdTimeKey] = context.get(
                      config.createdTimeKey, now.millisecondsSinceEpoch);
                  await context.adapter
                      ?.saveDocument(item)
                      .showIndicator(context);
                  context.navigator.pop();
                } catch (e) {
                  UIDialog.show(
                    context,
                    title: "Error".localize(),
                    text: "Editing is not completed.".localize(),
                  );
                }
              },
              label: Text("Submit".localize()),
              icon: const Icon(Icons.check),
            ),
          ),
        );
    }
  }
}
