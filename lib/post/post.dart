import 'dart:convert';

import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:masamune/masamune.dart';
import 'package:masamune/ui/ui.dart';
import 'package:masamune_module/masamune_module.dart';
import 'package:tuple/tuple.dart';

part "post.m.dart";

enum PostEditingType { planeText, wysiwyg }

@module
@immutable
class PostModule extends PageModule {
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
    Permission permission = const Permission(),
    this.postQuery,
    this.home,
    this.edit,
    this.view,
    this.designType = DesignType.modern,
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => home ?? PostModuleHome(this)),
      "/$routePath/edit": RouteConfig((_) => edit ?? PostModuleEdit(this)),
      "/$routePath/empty": RouteConfig((_) => const EmptyPage()),
      "/$routePath/{post_id}": RouteConfig((_) => view ?? PostModuleView(this)),
      "/$routePath/{post_id}/edit":
          RouteConfig((_) => edit ?? PostModuleEdit(this)),
    };
    return route;
  }

  /// ページ設定。
  final Widget? home;
  final Widget? edit;
  final Widget? view;

  /// デザインタイプ。
  final DesignType designType;

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

  /// クエリー。
  final CollectionQuery? postQuery;

  @override
  PostModule? fromMap(DynamicMap map) => _$PostModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$PostModuleToMap(this);
}

class PostModuleHome extends PageHookWidget {
  const PostModuleHome(this.config);
  final PostModule config;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final user = useUserDocumentModel(config.userPath);
    final post = useCollectionModel(config.postQuery?.value ?? config.postPath);
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
    final controller = useNavigatorController(
      "/${config.routePath}/${postWithUser.firstOrNull.get(Const.uid, "empty")}",
    );

    return UIScaffold(
      designType: config.designType,
      loadingFutures: [
        user.future,
        post.future,
        users.future,
      ],
      inlineNavigatorControllerOnWeb: controller,
      appBar: UIAppBar(
        title: Text(config.title ?? "Post".localize()),
      ),
      body: UIListBuilder<DynamicMap>(
        source: postWithUser.toList(),
        builder: (context, item) {
          return [
            ListItem(
              selected: controller.route?.name.last() == item.get(Const.uid, ""),
              selectedColor: context.theme.textColorOnPrimary,
              selectedTileColor: context.theme.primaryColor.withOpacity(0.8),
              title: Text(item.get(config.nameKey, "")),
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
                  controller.navigator.pushReplacementNamed(
                    "/${config.routePath}/${item.get(Const.uid, "")}",
                  );
                }
              },
            ),
          ];
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

class PostModuleView extends PageHookWidget {
  const PostModuleView(this.config);
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

    final appBar = UIAppBar(
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

        final child = UIScaffold(
      designType: config.designType,
          appBar: appBar,
          body: UIListView(
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
        );
        return child;
      default:
        final child = UIScaffold(
      designType: config.designType,
          appBar: appBar,
          body: UIListView(
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
        );
        return child;
    }
  }
}

class PostModuleEdit extends PageHookWidget {
  const PostModuleEdit(this.config);
  final PostModule config;

  @override
  Widget build(BuildContext context) {
    final form = useForm("post_id");
    final now = DateTime.now();
    final user = useUserDocumentModel(config.userPath);
    final item = useDocumentModel("${config.postPath}/${form.uid}");
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final dateTime =
        item.get(config.createdTimeKey, now.millisecondsSinceEpoch);

    final appBar = UIAppBar(
      title: Text(form.select(
        "Editing %s".localize().format([name]),
        "A new entry".localize(),
      )),
      actions: [
        if (form.exists &&
            config.permission.canDelete(user.get(config.roleKey, "")))
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

        return UIScaffold(
      designType: config.designType,
          appBar: appBar,
          body: FormBuilder(
              key: form.key,
              padding: const EdgeInsets.all(0),
              type: FormBuilderType.fixed,
              children: [
                FormItemTextField(
                  dense: true,
                  hintText: "Title".localize(),
                  errorText:
                      "No input %s".localize().format(["Title".localize()]),
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
                      "No input %s".localize().format(["Post time".localize()]),
                  controller: useMemoizedTextEditingController(
                      FormItemDateTimeField.formatDateTime(dateTime)),
                  onSaved: (value) {
                    context[config.createdTimeKey] =
                        value?.millisecondsSinceEpoch ??
                            now.millisecondsSinceEpoch;
                  },
                ),
                const Divid(),
                Theme(
                  data: context.theme.copyWith(canvasColor: context.theme.scaffoldBackgroundColor),
                  child:
                QuillToolbar.basic(
                  controller: controller,
                  toolbarIconSize: 24,
                  multiRowsDisplay: false,
                  onImagePickCallback: (file) async {
                    if (file.path.isEmpty || !file.existsSync()) {
                      return "";
                    }
                    return await context.model!.uploadMedia(file.path);
                  },
                ),),
                Divid(color: context.theme.dividerColor.withOpacity(0.25)),
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
                              color: context.theme.disabledColor, fontSize: 16),
                          const Tuple2(16, 0),
                          const Tuple2(0, 0),
                          null),
                    ),
                  ),
                ),
              ],
            ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              if (!form.validate()) {
                return;
              }
              try {
                item[config.nameKey] = context.get(config.nameKey, "");
                item[config.textKey] =
                    jsonEncode(controller.document.toDelta().toJson());
                item[config.createdTimeKey] = context.get(
                    config.createdTimeKey, now.millisecondsSinceEpoch);
                await context.model?.saveDocument(item).showIndicator(context);
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
        );
      default:
        return UIScaffold(
          designType: config.designType,
          appBar: appBar,
          body: FormBuilder(
              key: form.key,
              padding: const EdgeInsets.all(0),
              type: FormBuilderType.fixed,
              children: [
                FormItemTextField(
                  dense: true,
                  hintText: "Title".localize(),
                  errorText: "Input %s".localize().format(["Title".localize()]),
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              if (!form.validate()) {
                return;
              }
              try {
                item[config.nameKey] = context.get(config.nameKey, "");
                item[config.textKey] = context.get(config.textKey, "");
                item[config.createdTimeKey] = context.get(
                    config.createdTimeKey, now.millisecondsSinceEpoch);
                await context.model?.saveDocument(item).showIndicator(context);
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
        );
    }
  }
}
