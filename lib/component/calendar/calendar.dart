import 'dart:convert';

import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:masamune_module/masamune_module.dart';
import 'package:tuple/tuple.dart';

part 'calendar.m.dart';

const _kQuillToolbarHeight = 80;
enum CalendarEditingType { planeText, wysiwyg }

@module
@immutable
class CalendarModule extends PageModule with VerifyAppReroutePageModuleMixin {
  const CalendarModule({
    bool enabled = true,
    String? title = "",
    this.routePath = "calendar",
    this.queryPath = "event",
    this.userPath = "user",
    this.commentPath = "comment",
    this.commentTemplatePath = "commentTemplate",
    this.nameKey = Const.name,
    this.userKey = Const.user,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.typeKey = Const.type,
    this.imageKey = Const.media,
    this.createdTimeKey = Const.createdTime,
    this.modifiedTimeKey = Const.modifiedTime,
    this.startTimeKey = Const.startTime,
    this.endTimeKey = Const.endTime,
    this.allDayKey = "allDay",
    this.detailLabel = "Detail",
    this.noteLabel = "Note",
    this.commentLabel = "Comment",
    this.noteKey = "note",
    this.enableNote = false,
    this.editingType = CalendarEditingType.planeText,
    this.markerType = UICalendarMarkerType.count,
    this.showAddingButton = true,
    this.markerIcon,
    Permission permission = const Permission(),
    this.initialCommentTemplate = const [],
    List<RerouteConfig> rerouteConfigs = const [],
    this.home,
    this.dayView,
    this.detail,
    this.template,
    this.edit,
  }) : super(
          enabled: enabled,
          title: title,
          permission: permission,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => home ?? CalendarModuleHome(this)),
      "/$routePath/templates":
          RouteConfig((_) => template ?? CalendarModuleTemplate(this)),
      "/$routePath/edit": RouteConfig((_) => edit ?? CalendarModuleEdit(this)),
      "/$routePath/edit/{date_id}":
          RouteConfig((_) => edit ?? CalendarModuleEdit(this)),
      "/$routePath/empty": RouteConfig((_) => const EmptyPage()),
      "/$routePath/{date_id}":
          RouteConfig((_) => dayView ?? CalendarModuleDayView(this)),
      "/$routePath/{event_id}/detail":
          RouteConfig((_) => detail ?? CalendarModuleDetail(this)),
      "/$routePath/{event_id}/edit":
          RouteConfig((_) => edit ?? CalendarModuleEdit(this)),
    };
    return route;
  }

  // ページ設定
  final Widget? home;
  final Widget? dayView;
  final Widget? template;
  final Widget? detail;
  final Widget? edit;

  /// ルートのパス。
  final String routePath;

  /// イベントデータのパス。
  final String queryPath;

  /// ユーザーのデータパス。
  final String userPath;

  /// コメントデータへのパス。
  final String commentPath;

  /// コメントテンプレートへのパス。
  final String commentTemplatePath;

  /// タイトルのキー。
  final String nameKey;

  /// ユーザーのキー。
  final String userKey;

  /// テキストのキー。
  final String textKey;

  /// 画像のキー。
  final String imageKey;

  /// チャットタイプのキー。
  final String typeKey;

  /// 権限のキー。
  final String roleKey;

  /// 作成日のキー。
  final String createdTimeKey;

  /// 更新日のキー。
  final String modifiedTimeKey;

  /// 開始時間のキー。
  final String startTimeKey;

  /// 終了時間のキー。
  final String endTimeKey;

  /// 終日フラグのキー。
  final String allDayKey;

  /// 詳細のラベル。
  final String detailLabel;

  /// ノートのラベル。
  final String noteLabel;

  /// ノートのキー。
  final String noteKey;

  /// カレンダーのノートを記載する場合True.
  final bool enableNote;

  /// コメントのラベル。
  final String commentLabel;

  /// カレンダーのマーカータイプ。
  final UICalendarMarkerType markerType;

  /// マーカーアイコン。
  final Widget? markerIcon;

  /// エディターのタイプ。
  final CalendarEditingType editingType;

  /// コメントテンプレートの設定。
  final List<String> initialCommentTemplate;

  /// 追加ボタンを表示する場合True.
  final bool showAddingButton;

  @override
  CalendarModule? fromMap(DynamicMap map) => _$CalendarModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$CalendarModuleToMap(this);
}

class CalendarModuleHome extends PageScopedWidget {
  const CalendarModuleHome(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.state("selected", DateTime.now());
    final events = ref.watchCollectionModel(config.queryPath);
    final user = ref.watchUserDocumentModel(config.userPath);

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(config.title ?? "Calendar".localize()),
      ),
      body: UICalendar(
        markerType: config.markerType,
        markerIcon: config.markerIcon ?? const Icon(Icons.access_alarm),
        events: events,
        expand: true,
        onDaySelect: (day, events, holidays) {
          selected.value = day;
          context.rootNavigator.pushNamed(
            "/${config.routePath}/${day.toDateID()}",
            arguments: RouteQuery.fullscreenOrModal,
          );
        },
      ),
      floatingActionButton: config.showAddingButton &&
              config.permission.canEdit(user.get(config.roleKey, ""))
          ? FloatingActionButton.extended(
              label: Text("Add".localize()),
              icon: const Icon(Icons.add),
              onPressed: () {
                final dateId = selected.value
                    .combine(TimeOfDay.now())
                    .round(const Duration(minutes: 15))
                    .toDateTimeID();
                context.navigator.pushNamed(
                  "/${config.routePath}/edit/$dateId}",
                  arguments: RouteQuery.fullscreen,
                );
              },
            )
          : null,
    );
  }
}

class CalendarModuleDayView extends PageScopedWidget {
  const CalendarModuleDayView(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.useNow();
    final user = ref.watchUserDocumentModel(config.userPath);
    final date = context.get("date_id", now.toDateID()).toDateTime();
    final startTime = date;
    final endTime = date.add(const Duration(days: 1));

    final events = ref
        .watchCollectionModel(config.queryPath)
        .where(
          (element) => _inEvent(
            sourceStartTime: element.get(config.startTimeKey, 0),
            sourceEndTime: element.get<int?>(config.endTimeKey, null),
            targetStartTime: startTime.millisecondsSinceEpoch,
            targetEndTime: endTime.millisecondsSinceEpoch,
          ),
        )
        .toList();

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(date.format("yyyy/MM/dd")),
      ),
      body: UIDayCalendar(
        day: date,
        source: events,
        builder: (context, item) {
          return InkWell(
            onTap: () {
              context.navigator.pushNamed(
                "/${config.routePath}/${item.uid}/detail",
                arguments: RouteQuery.fullscreenOrModal,
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: DefaultBoxDecoration(
                  color: context.theme.dividerColor,
                  width: 1,
                  backgroundColor: context.theme.primaryColor,
                  radius: 8.0),
              child: Text(item.get(config.nameKey, ""),
                  style: TextStyle(color: context.theme.textColorOnPrimary)),
            ),
          );
        },
      ),
      floatingActionButton: config.showAddingButton &&
              config.permission.canEdit(user.get(config.roleKey, ""))
          ? FloatingActionButton.extended(
              label: Text("Add".localize()),
              icon: const Icon(Icons.add),
              onPressed: () {
                final dateId = date
                    .combine(TimeOfDay.now())
                    .round(const Duration(minutes: 15))
                    .toDateTimeID();
                context.navigator.pushNamed(
                  "/${config.routePath}/edit/$dateId",
                  arguments: RouteQuery.fullscreen,
                );
              },
            )
          : null,
    );
  }
}

class CalendarModuleDetail extends PageScopedWidget {
  const CalendarModuleDetail(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watchUserDocumentModel(config.userPath);
    final event = ref.watchDocumentModel(
        "${config.queryPath}/${context.get("event_id", "")}");
    final author = ref.watchDocumentModel(
        "${config.userPath}/${event.get(config.userKey, uuid)}");
    final name = event.get(config.nameKey, "");
    final text = event.get(config.textKey, "");
    final noteValue = event.get(config.noteKey, "");
    final note = noteValue.isEmpty
        ? "No %s".localize().format([config.noteLabel.localize()])
        : noteValue;
    final allDay = event.get(config.allDayKey, false);
    final startTime = event.getAsDateTime(config.startTimeKey);
    final authorName = author.get(config.nameKey, "");
    final endTimeValue = event.get<int?>(config.endTimeKey, null);
    final endTime = endTimeValue != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeValue)
        : null;
    final userId = context.model?.userId;
    final commentController = ref.useTextEditingController("comment");

    final _comments = ref.watchCollectionModel(
      ModelQuery(
              "${config.queryPath}/${context.get("event_id", "")}/${config.commentPath}",
              order: ModelQueryOrder.desc,
              orderBy: Const.time)
          .value,
    );
    final _commentAuthor = ref.watchCollectionModel(
      ModelQuery(
        config.userPath,
        key: Const.uid,
        whereIn: _comments.map((e) => e.get(config.userKey, "")).distinct(),
      ).value,
    );
    final comments = _comments.setWhereListenable(
      _commentAuthor,
      test: (o, a) => o.get(config.userKey, "") == a.uid,
      apply: (o, a) =>
          o.mergeListenable(a, convertKeys: (key) => "${Const.user}$key"),
      orElse: (o) => o,
    );

    final editingType = note.isNotEmpty && !note.startsWith(RegExp(r"^(\[|\{)"))
        ? CalendarEditingType.planeText
        : config.editingType;

    final appBar = UIAppBar(
      title: Text(name),
      subtitle: Text(_timeString(
        startTime: startTime,
        endTime: endTime,
        allDay: allDay,
      )),
      actions: [
        if (config.permission.canEdit(user.get(config.roleKey, "")))
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.rootNavigator.pushNamed(
                "/${config.routePath}/${context.get("event_id", "")}/edit",
                arguments: RouteQuery.fullscreenOrModal,
              );
            },
          )
      ],
    );

    final header = [
      const Space.height(16),
      ListItem(
        title: Text("DateTime".localize()),
        text: Text(
          _timeString(
            startTime: startTime,
            endTime: endTime,
            allDay: allDay,
          ),
        ),
      ),
      if (authorName.isNotEmpty)
        ListItem(
          title: Text("Author".localize()),
          text: Text(authorName),
        ),
      const Space.height(16),
      DividHeadline(config.detailLabel.localize()),
      const Space.height(16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: UIMarkdown(
          text,
          fontSize: 16,
          onTapLink: (url) {
            ref.open(url);
          },
        ),
      ),
    ];

    final footer = [
      const Space.height(24),
      DividHeadline(config.commentLabel.localize()),
      FormItemCommentField(
        maxLines: 4,
        controller: commentController,
        hintText: "Input %s".localize().format(["Comment".localize()]),
        onSubmitted: (value) {
          if (value.isEmpty) {
            return;
          }

          final doc = context.model?.createDocument(_comments);
          if (doc == null) {
            return;
          }
          doc[Const.user] = userId;
          doc[config.textKey] = value;
          context.model?.saveDocument(doc);
        },
        onTapTemplateIcon: () async {
          final res = await context.rootNavigator.pushNamed(
            "/${config.routePath}/templates",
            arguments: RouteQuery.fullscreenOrModal,
          );
          if (res is! String || res.isEmpty) {
            return;
          }
          commentController.text = res;
        },
      ),
      const Divid(),
      const Space.height(16),
    ];

    if (!config.enableNote) {
      return UIScaffold(
        waitTransition: true,
        appBar: appBar,
        body: UIListView(
          children: [
            ...header,
            ...footer,
            ...comments.mapListenable((item) {
              return CommentTile(
                avatar: NetworkOrAsset.image(
                    item.get("${Const.user}${config.imageKey}", "")),
                name: item.get("${Const.user}${config.nameKey}", ""),
                date: item.getAsDateTime(Const.time),
                text: item.get(config.textKey, ""),
              );
            }),
            const Space.height(24),
          ],
        ),
      );
    }

    switch (editingType) {
      case CalendarEditingType.wysiwyg:
        final controller = ref.cache(
          "controller",
          () => note.isEmpty
              ? QuillController.basic()
              : QuillController(
                  document: Document.fromJson(jsonDecode(note)),
                  selection: const TextSelection.collapsed(offset: 0),
                ),
          keys: [note],
        );

        return UIScaffold(
          waitTransition: true,
          appBar: appBar,
          body: UIListView(
            children: [
              ...header,
              const Space.height(16),
              DividHeadline(config.noteLabel.localize()),
              const Space.height(16),
              QuillEditor(
                scrollController: ScrollController(),
                scrollable: false,
                focusNode: ref.useFocusNode("note", false),
                autoFocus: false,
                controller: controller,
                placeholder: config.noteLabel.localize(),
                readOnly: true,
                expands: false,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                customStyles: DefaultStyles(
                  placeHolder: DefaultTextBlockStyle(
                      TextStyle(
                          color: context.theme.disabledColor, fontSize: 16),
                      const Tuple2(16, 0),
                      const Tuple2(0, 0),
                      null),
                ),
              ),
              ...footer,
              ...comments.mapListenable((item) {
                return CommentTile(
                  avatar: NetworkOrAsset.image(
                      item.get("${Const.user}${config.imageKey}", "")),
                  name: item.get("${Const.user}${config.nameKey}", ""),
                  date: item.getAsDateTime(Const.time),
                  text: item.get(config.textKey, ""),
                );
              }),
              const Space.height(24),
            ],
          ),
        );
      default:
        return UIScaffold(
          waitTransition: true,
          appBar: appBar,
          body: UIListView(
            children: [
              ...header,
              const Space.height(16),
              DividHeadline(config.noteLabel.localize()),
              const Space.height(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: UIMarkdown(
                  note,
                  fontSize: 16,
                  onTapLink: (url) {
                    ref.open(url);
                  },
                ),
              ),
              ...footer,
              ...comments.mapListenable((item) {
                return CommentTile(
                  avatar: NetworkOrAsset.image(
                      item.get("${Const.user}${config.imageKey}", "")),
                  name: item.get("${Const.user}${config.nameKey}", ""),
                  date: item.getAsDateTime(Const.time),
                  text: item.get(config.textKey, ""),
                );
              }),
              const Space.height(24),
            ],
          ),
        );
    }
  }
}

class CalendarModuleTemplate extends PageScopedWidget {
  const CalendarModuleTemplate(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final template = ref.watchCollectionModel(
      "${config.userPath}/${context.model?.userId}/${config.commentTemplatePath}",
    );

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(title: Text("Template".localize())),
      body: UIListBuilder<String>(
        source: [
          ...config.initialCommentTemplate,
          ...template.mapAndRemoveEmpty(
            (item) => item.get<String?>(config.textKey, null),
          )
        ],
        bottom: [
          ListTextField(
            label: "Add".localize(),
            onSubmitted: (value) async {
              if (value.isEmpty) {
                return;
              }
              try {
                final doc = context.model?.createDocument(template);
                if (doc == null) {
                  return;
                }
                doc[config.textKey] = value;
                await context.model?.saveDocument(doc).showIndicator(context);
              } catch (e) {
                UIDialog.show(
                  context,
                  title: "Error".localize(),
                  text: "%s is not completed."
                      .localize()
                      .format(["Editing".localize()]),
                );
              }
            },
          ),
        ],
        builder: (context, item, index) {
          return [
            ListItem(
              title: Text(item),
              trailing: config.initialCommentTemplate.contains(item)
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        try {
                          final tmp = template.firstWhereOrNull(
                              (e) => e.get(config.textKey, "") == item);
                          if (tmp == null) {
                            return;
                          }
                          await context.model
                              ?.deleteDocument(tmp)
                              .showIndicator(context);
                        } catch (e) {
                          UIDialog.show(
                            context,
                            title: "Error".localize(),
                            text: "%s is not completed."
                                .localize()
                                .format(["Editing".localize()]),
                          );
                        }
                      },
                    ),
              onTap: () {
                context.navigator.pop(item);
              },
            ),
          ];
        },
      ),
    );
  }
}

class CalendarModuleEdit extends PageScopedWidget {
  const CalendarModuleEdit(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = context.get<String?>("date_id", null)?.toDateTime();
    final now = ref.useDateTime("now", date ?? DateTime.now());
    final form = ref.useForm("event_id");
    final user = ref.watchUserDocumentModel(config.userPath);
    final item = ref.watchDocumentModel("${config.queryPath}/${form.uid}");
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final note = item.get(config.noteKey, "");
    final startTime = item.getAsDateTime(config.startTimeKey, now);
    final allDay = item.get(config.allDayKey, false);
    final endTimeValue = item.get<int?>(config.endTimeKey, null);
    final endTime = endTimeValue != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeValue)
        : null;
    final allDayState = ref.state("allDay", allDay);
    final allDayController =
        ref.useTextEditingController("allDay", allDay.toString());
    final startTimeController = ref.useTextEditingController(
      "startTime",
      allDayState.value
          ? FormItemDateTimeField.formatDate(startTime.millisecondsSinceEpoch)
          : FormItemDateTimeField.formatDateTime(
              startTime.millisecondsSinceEpoch),
    );
    final endTimeOrStartTime =
        endTime ?? startTime.add(const Duration(hours: 1));
    final endTimeController = ref.useTextEditingController(
      "endTime",
      allDayState.value
          ? FormItemDateTimeField.formatDate(
              endTimeOrStartTime.millisecondsSinceEpoch)
          : FormItemDateTimeField.formatDateTime(
              endTimeOrStartTime.millisecondsSinceEpoch),
    );
    final titleController = ref.useTextEditingController("title", name);
    final textController = ref.useTextEditingController("text", text);

    final editingType = note.isNotEmpty && !note.startsWith(RegExp(r"^(\[|\{)"))
        ? CalendarEditingType.planeText
        : config.editingType;

    final appBar = UIAppBar(
      sliverLayoutWhenModernDesign: false,
      title: Text(
        form.select(
          item.get(config.nameKey, ""),
          "New Events".localize(),
        ),
      ),
      subtitle: form.select(
        Text(_timeString(
          startTime: startTime,
          endTime: endTime,
          allDay: allDay,
        )),
        null,
      ),
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

    final header = [
      FormItemSwitch(
        labelText: "All day".localize(),
        type: FormItemSwitchType.list,
        controller: allDayController,
        onSaved: (value) {
          context[config.allDayKey] = value ?? false;
        },
        onChanged: (value) {
          allDayState.value = value ?? false;
        },
      ),
      DividHeadline("Start date".localize()),
      FormItemDateTimeField(
        dense: true,
        errorText: "No input %s".localize().format(["Start date".localize()]),
        type: allDayState.value
            ? FormItemDateTimeFieldPickerType.date
            : FormItemDateTimeFieldPickerType.dateTime,
        controller: startTimeController,
        // format: allDayState.value ? "yyyy/MM/dd(E)" : "yyyy/MM/dd(E) HH:mm",
        onSaved: (value) {
          value ??= now;
          context[config.startTimeKey] = value.millisecondsSinceEpoch;
        },
      ),
      Collapse(
        show: !allDayState.value,
        children: [
          DividHeadline("End date".localize()),
          FormItemDateTimeField(
            dense: true,
            controller: endTimeController,
            allowEmpty: true,
            // format: "yyyy/MM/dd(E) HH:mm",
            validator: (value) {
              if (value == null || allDayState.value) {
                return null;
              }
              final start = allDayState.value
                  ? FormItemDateTimeField.tryParseFromDate(
                      startTimeController.text)
                  : FormItemDateTimeField.tryParseFromDateTime(
                      startTimeController.text);
              if (start == null) {
                return "No input %s"
                    .localize()
                    .format(["Start date".localize()]);
              }
              if (start.millisecondsSinceEpoch >=
                  value.millisecondsSinceEpoch) {
                return "The end date and time must be a time after the start date and time."
                    .localize();
              }
              return null;
            },
            onSaved: (value) {
              value ??= now.add(const Duration(hours: 1));
              context[config.endTimeKey] = value.millisecondsSinceEpoch;
            },
          ),
        ],
      ),
      DividHeadline("Title".localize()),
      FormItemTextField(
        dense: true,
        errorText: "No input %s".localize().format(["Title".localize()]),
        subColor: context.theme.disabledColor,
        controller: titleController,
        onSaved: (value) {
          context[config.nameKey] = value ?? "";
        },
      ),
      DividHeadline(config.detailLabel.localize()),
      FormItemTextField(
        dense: true,
        allowEmpty: true,
        keyboardType: TextInputType.multiline,
        expands: !config.enableNote,
        subColor: context.theme.disabledColor,
        controller: textController,
        onSaved: (value) {
          context[config.textKey] = value ?? "";
        },
      ),
    ];

    if (!config.enableNote) {
      return UIScaffold(
        waitTransition: true,
        appBar: appBar,
        body: FormBuilder(
          key: form.key,
          padding: const EdgeInsets.all(0),
          type: FormBuilderType.listView,
          children: header,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (!form.validate()) {
              return;
            }
            try {
              final allDay = context.get(config.allDayKey, false);
              item[config.nameKey] = context.get(config.nameKey, "");
              item[config.textKey] = context.get(config.textKey, "");
              item[config.allDayKey] = allDay;
              item[config.userKey] = user.uid;
              item[config.startTimeKey] =
                  context.get(config.startTimeKey, now.millisecondsSinceEpoch);
              item[config.endTimeKey] =
                  allDay ? null : context.get<int?>(config.endTimeKey, null);
              await context.model?.saveDocument(item).showIndicator(context);
              context.navigator.pop();
            } catch (e) {
              UIDialog.show(
                context,
                title: "Error".localize(),
                text: "%s is not completed."
                    .localize()
                    .format(["Editing".localize()]),
              );
            }
          },
          label: Text("Submit".localize()),
          icon: const Icon(Icons.check),
        ),
      );
    }

    switch (editingType) {
      case CalendarEditingType.wysiwyg:
        final controller = ref.cache(
          "controller",
          () => note.isEmpty
              ? QuillController.basic()
              : QuillController(
                  document: Document.fromJson(jsonDecode(note)),
                  selection: const TextSelection.collapsed(offset: 0),
                ),
          keys: [note],
        );

        return UIScaffold(
          waitTransition: true,
          appBar: appBar,
          body: FormBuilder(
            key: form.key,
            padding: const EdgeInsets.all(0),
            type: FormBuilderType.listView,
            children: [
              ...header,
              const Divid(),
              Theme(
                data: context.theme.copyWith(
                    canvasColor: context.theme.scaffoldBackgroundColor),
                child: QuillToolbar.basic(
                  controller: controller,
                  toolbarIconSize: 24,
                  multiRowsDisplay: false,
                  onImagePickCallback: (file) async {
                    if (file.path.isEmpty || !file.existsSync()) {
                      return "";
                    }
                    return await context.model!.uploadMedia(file.path);
                  },
                ),
              ),
              Divid(color: context.theme.dividerColor.withOpacity(0.25)),
              SizedBox(
                height: (context.mediaQuery.size.height -
                        context.mediaQuery.viewInsets.bottom -
                        kToolbarHeight -
                        _kQuillToolbarHeight)
                    .limitLow(0),
                child: QuillEditor(
                  scrollController: ScrollController(),
                  scrollable: true,
                  focusNode: ref.useFocusNode("note"),
                  autoFocus: false,
                  controller: controller,
                  placeholder: config.noteLabel.localize(),
                  readOnly: false,
                  expands: false,
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
                final allDay = context.get(config.allDayKey, false);
                item[config.nameKey] = context.get(config.nameKey, "");
                item[config.textKey] = context.get(config.textKey, "");
                item[config.noteKey] =
                    jsonEncode(controller.document.toDelta().toJson());
                item[config.allDayKey] = allDay;
                item[config.userKey] = user.uid;
                item[config.startTimeKey] = context.get(
                    config.startTimeKey, now.millisecondsSinceEpoch);
                item[config.endTimeKey] =
                    allDay ? null : context.get<int?>(config.endTimeKey, null);
                await context.model?.saveDocument(item).showIndicator(context);
                context.navigator.pop();
              } catch (e) {
                UIDialog.show(
                  context,
                  title: "Error".localize(),
                  text: "%s is not completed."
                      .localize()
                      .format(["Editing".localize()]),
                );
              }
            },
            label: Text("Submit".localize()),
            icon: const Icon(Icons.check),
          ),
        );
      default:
        return UIScaffold(
          waitTransition: true,
          appBar: appBar,
          body: FormBuilder(
            key: form.key,
            padding: const EdgeInsets.all(0),
            type: FormBuilderType.listView,
            children: [
              ...header,
              const Divid(),
              SizedBox(
                height: (context.mediaQuery.size.height -
                        context.mediaQuery.viewInsets.bottom -
                        kToolbarHeight)
                    .limitLow(0),
                child: FormItemTextField(
                  dense: true,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  hintText: config.noteLabel.localize(),
                  subColor: context.theme.disabledColor,
                  controller: ref.useTextEditingController("note", note),
                  onSaved: (value) {
                    context[config.noteKey] = value;
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
                final allDay = context.get(config.allDayKey, false);
                item[config.nameKey] = context.get(config.nameKey, "");
                item[config.textKey] = context.get(config.textKey, "");
                item[config.noteKey] = context.get(config.noteKey, "");
                item[config.allDayKey] = allDay;
                item[config.userKey] = user.uid;
                item[config.startTimeKey] = context.get(
                    config.startTimeKey, now.millisecondsSinceEpoch);
                item[config.endTimeKey] =
                    allDay ? null : context.get<int?>(config.endTimeKey, null);
                await context.model?.saveDocument(item).showIndicator(context);
                context.navigator.pop();
              } catch (e) {
                UIDialog.show(
                  context,
                  title: "Error".localize(),
                  text: "%s is not completed."
                      .localize()
                      .format(["Editing".localize()]),
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

String _timeString({
  required DateTime startTime,
  DateTime? endTime,
  bool allDay = false,
}) {
  if (endTime == null) {
    allDay = true;
  }
  if (allDay) {
    return "${startTime.format("yyyy/MM/dd")} ${"All day".localize()}";
  } else {
    return "${startTime.format("yyyy/MM/dd HH:mm")} - ${endTime?.format("yyyy/MM/dd HH:mm")}";
  }
}

bool _inEvent({
  required num sourceStartTime,
  num? sourceEndTime,
  required num targetStartTime,
  num? targetEndTime,
}) {
  sourceEndTime ??= sourceStartTime;
  targetEndTime ??= targetStartTime;
  if (sourceStartTime <= targetStartTime && targetStartTime < sourceEndTime) {
    if (sourceStartTime <= targetEndTime && targetEndTime < sourceEndTime) {
      return true;
    }
  }
  if (targetStartTime <= sourceStartTime && sourceStartTime < targetEndTime) {
    return true;
  }
  if (targetStartTime <= sourceEndTime && sourceEndTime < targetEndTime) {
    return true;
  }
  return false;
}
