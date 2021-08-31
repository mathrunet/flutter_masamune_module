import 'dart:convert';

import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:masamune/masamune.dart';
import 'package:masamune_module/masamune_module.dart';
import 'package:tuple/tuple.dart';

part 'calendar.m.dart';

const _kQuillToolbarHeight = 80;
enum CalendarEditingType { planeText, wysiwyg }

@module
@immutable
class CalendarModule extends PageModule {
  const CalendarModule({
    bool enabled = true,
    String? title = "",
    this.routePath = "calendar",
    this.eventPath = "event",
    this.userPath = "user",
    this.commentPath = "comment",
    this.commentTemplatePath = "commentTemplate",
    this.nameKey = Const.name,
    this.userKey = Const.user,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.typeKey = Const.type,
    this.iamgeKey = Const.media,
    this.createdTimeKey = Const.createdTime,
    this.modifiedTimeKey = Const.modifiedTime,
    this.startTimeKey = Const.startTime,
    this.endTimeKey = Const.endTime,
    this.allDayKey = "allDay",
    this.detailLabel = "Detail",
    this.commentLabel = "Comment",
    this.editingType = CalendarEditingType.planeText,
    Permission permission = const Permission(),
    this.initialCommentTemplate = const [],
    this.designType = DesignType.modern,
    this.home,
    this.dayView,
    this.detail,
    this.template,
    this.edit,
  }) : super(enabled: enabled, title: title, permission: permission);

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
  final String eventPath;

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
  final String iamgeKey;

  /// チャットタイプのキー。
  final String typeKey;

  /// 権限のキー。
  final String roleKey;

  /// 作成日のキー。
  final String createdTimeKey;

  /// 更新日のキー。
  final String modifiedTimeKey;

  /// デザインタイプ。
  final DesignType designType;

  /// 開始時間のキー。
  final String startTimeKey;

  /// 終了時間のキー。
  final String endTimeKey;

  /// 終日フラグのキー。
  final String allDayKey;

  /// 詳細のラベル。
  final String detailLabel;

  /// コメントのラベル。
  final String commentLabel;

  /// エディターのタイプ。
  final CalendarEditingType editingType;

  /// コメントテンプレートの設定。
  final List<String> initialCommentTemplate;

  @override
  CalendarModule? fromMap(DynamicMap map) => _$CalendarModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$CalendarModuleToMap(this);
}

class CalendarModuleHome extends PageHookWidget {
  const CalendarModuleHome(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context) {
    final selected = useState(DateTime.now());
    final events = useCollectionModel(config.eventPath);
    final user = useUserDocumentModel(config.userPath);

    return UIScaffold(
      designType: config.designType,
      appBar: UIAppBar(
        title: Text(config.title ?? "Calendar".localize()),
      ),
      body: UICalendar(
        markerType: UICalendarMarkerType.count,
        markerIcon: const Icon(Icons.access_alarm),
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
      floatingActionButton:
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

class CalendarModuleDayView extends PageHookWidget {
  const CalendarModuleDayView(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context) {
    final now = useNow();
    final user = useUserDocumentModel(config.userPath);
    final date = context.get("date_id", now.toDateID()).toDateTime();
    final startTime = date;
    final endTime = date.add(const Duration(days: 1));

    final events = useCollectionModel(config.eventPath)
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
      designType: config.designType,
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
      floatingActionButton:
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

class CalendarModuleDetail extends PageHookWidget {
  const CalendarModuleDetail(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel(config.userPath);
    final event =
        useDocumentModel("${config.eventPath}/${context.get("event_id", "")}");
    final author = useDocumentModel(
        "${config.userPath}/${event.get(config.userKey, uuid)}");
    final name = event.get(config.nameKey, "");
    final text = event.get(config.textKey, "");
    final allDay = event.get(config.allDayKey, false);
    final startTime = event.getAsDateTime(config.startTimeKey);
    final authorName = author.get(config.nameKey, "");
    final endTimeValue = event.get<int?>(config.endTimeKey, null);
    final endTime = endTimeValue != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeValue)
        : null;
    final userId = context.model?.userId;
    final commentController = useMemoizedTextEditingController();

    final _comments = useCollectionModel(
      CollectionQuery(
              "${config.eventPath}/${context.get("event_id", "")}/${config.commentPath}",
              order: CollectionQueryOrder.desc,
              orderBy: Const.time)
          .value,
    );
    final _commentAuthor = useCollectionModel(
      CollectionQuery(
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

    final editingType = text.isNotEmpty && !text.startsWith(RegExp(r"^(\[|\{)"))
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

    switch (editingType) {
      case CalendarEditingType.wysiwyg:
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
          body: UIListView(
            children: [
              ...header,
              QuillEditor(
                scrollController: ScrollController(),
                scrollable: false,
                focusNode: useFocusNode(),
                autoFocus: false,
                controller: controller,
                placeholder: "Text".localize(),
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
                      item.get("${Const.user}${config.iamgeKey}", "")),
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
          designType: config.designType,
          appBar: appBar,
          body: UIListView(
            children: [
              ...header,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: UIMarkdown(
                  text,
                  fontSize: 16,
                  onTapLink: (url) {
                    context.open(url);
                  },
                ),
              ),
              ...footer,
              ...comments.mapListenable((item) {
                return CommentTile(
                  avatar: NetworkOrAsset.image(
                      item.get("${Const.user}${config.iamgeKey}", "")),
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

class CalendarModuleTemplate extends PageHookWidget {
  const CalendarModuleTemplate(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context) {
    final template = useCollectionModel(
      "${config.userPath}/${context.model?.userId}/${config.commentTemplatePath}",
    );

    return UIScaffold(
      designType: config.designType,
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
                  text: "Editing is not completed.".localize(),
                );
              }
            },
          ),
        ],
        builder: (context, item) {
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
                            text: "Editing is not completed.".localize(),
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

class CalendarModuleEdit extends PageHookWidget {
  const CalendarModuleEdit(this.config);
  final CalendarModule config;

  @override
  Widget build(BuildContext context) {
    final date = context.get<String?>("date_id", null)?.toDateTime();
    final now = useDateTime(date);
    final form = useForm("event_id");
    final user = useUserDocumentModel(config.userPath);
    final item = useDocumentModel("${config.eventPath}/${form.uid}");
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final startTime = item.getAsDateTime(config.startTimeKey, now);
    final allDay = item.get(config.allDayKey, false);
    final endTimeValue = item.get<int?>(config.endTimeKey, null);
    final endTime = endTimeValue != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeValue)
        : null;
    final allDayState = useCollapse(allDay);
    final allDayController =
        useMemoizedTextEditingController(allDay.toString());
    final startTimeController =
        useMemoizedTextEditingController(startTime.toString());
    final endTimeController = useMemoizedTextEditingController(
        (endTime ?? startTime.add(const Duration(hours: 1))).toString());
    final titleController = useMemoizedTextEditingController(name);

    final editingType = text.isNotEmpty && !text.startsWith(RegExp(r"^(\[|\{)"))
        ? CalendarEditingType.planeText
        : config.editingType;

    final appBar = UIAppBar(
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
          form[config.allDayKey] = value ?? false;
        },
        onChanged: (value) {
          allDayState.value = value ?? false;
        },
      ),
      DividHeadline("Start date".localize()),
      FormItemDateTimeField(
        dense: true,
        errorText: "No input %s".localize().format(["Title".localize()]),
        type: allDayState.value
            ? FormItemDateTimeFieldPickerType.date
            : FormItemDateTimeFieldPickerType.dateTime,
        controller: startTimeController,
        format: allDayState.value ? "yyyy/MM/dd(E)" : "yyyy/MM/dd(E) HH:mm",
        onSaved: (value) {
          value ??= now;
          form[config.startTimeKey] = value.millisecondsSinceEpoch;
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
            format: "yyyy/MM/dd(E) HH:mm",
            validator: (value) {
              if (value == null || allDayState.value) {
                return null;
              }
              final start = DateTime.parse(startTimeController.text);
              if (start.millisecondsSinceEpoch >=
                  value.millisecondsSinceEpoch) {
                return "The end date and time must be a time after the start date and time."
                    .localize();
              }
              return null;
            },
            onSaved: (value) {
              value ??= now.add(const Duration(hours: 1));
              form[config.endTimeKey] = value.millisecondsSinceEpoch;
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
          form[config.nameKey] = value ?? "";
        },
      ),
      const Divid(),
    ];

    switch (editingType) {
      case CalendarEditingType.wysiwyg:
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
          appBar: appBar,
          designType: config.designType,
          body: FormBuilder(
            key: form.key,
            padding: const EdgeInsets.all(0),
            type: FormBuilderType.listView,
            children: [
              ...header,
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
                  focusNode: useFocusNode(),
                  autoFocus: false,
                  controller: controller,
                  placeholder: "Text".localize(),
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
                item[config.textKey] =
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
          appBar: appBar,
          designType: config.designType,
          body: FormBuilder(
            key: form.key,
            padding: const EdgeInsets.all(0),
            type: FormBuilderType.listView,
            children: [
              ...header,
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
                  hintText: "Text".localize(),
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
                final allDay = context.get(config.allDayKey, false);
                item[config.nameKey] = context.get(config.nameKey, "");
                item[config.textKey] = context.get(config.textKey, "");
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
