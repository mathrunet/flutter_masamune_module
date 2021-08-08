import 'dart:convert';

import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:masamune/masamune.dart';
import 'package:masamune_module/masamune_module.dart';
import 'package:tuple/tuple.dart';

part 'calendar.m.dart';

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
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.roleKey = Const.role,
    this.typeKey = Const.type,
    this.createdTimeKey = Const.createdTime,
    this.modifiedTimeKey = Const.modifiedTime,
    this.startTimeKey = Const.startTime,
    this.endTimeKey = Const.endTime,
    this.allDayKey = "allDay",
    this.editingType = CalendarEditingType.planeText,
    Permission permission = const Permission(),
    this.designType = DesignType.modern,
    this.home,
    this.dayView,
    this.detail,
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => home ?? CalendarModuleHome(this)),
      "/$routePath/{date_id}":
          RouteConfig((_) => dayView ?? CalendarModuleDayView(this)),
      "/$routePath/{event_id}/detail":
          RouteConfig((_) => detail ?? CalendarModuleDetail(this)),
    };
    return route;
  }

  // ページ設定
  final Widget? home;
  final Widget? dayView;
  final Widget? detail;

  /// ルートのパス。
  final String routePath;

  /// イベントデータのパス。
  final String eventPath;

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

  /// デザインタイプ。
  final DesignType designType;

  /// 開始時間のキー。
  final String startTimeKey;

  /// 終了時間のキー。
  final String endTimeKey;

  /// 終日フラグのキー。
  final String allDayKey;

  /// エディターのタイプ。
  final CalendarEditingType editingType;

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
          context.rootNavigator.pushNamed(
            "/${config.routePath}/${day.format("yyyyMMdd")}",
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
                    context.navigator.pushNamed(
                      "/${config.routePath}/edit",
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
    final now = DateTime.now();
    final dateId = context.get("date_id", now.format("yyyyMMdd"));
    final year = int.tryParse(dateId.substring(0, 4));
    final month = int.tryParse(dateId.substring(4, 6));
    final day = int.tryParse(dateId.substring(6, 8));
    if (year == null || month == null || day == null) {
      return UIScaffold(
        designType: config.designType,
        appBar: UIAppBar(title: Text("Error".localize())),
        body: Center(
          child: Text("No data.".localize()),
        ),
      );
    }
    final date = DateTime(year, month, day);
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
                  color: context.theme.textColor,
                  width: 1,
                  backgroundColor: Colors.red,
                  radius: 8.0),
              child: Text(
                item.get(config.nameKey, ""),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UIDayCalendar extends StatelessWidget {
  const UIDayCalendar({
    required this.source,
    required this.builder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.day,
    this.height = 36,
    this.labelWidth = 56,
    this.startTimeKey = "startTime",
    this.endTimeKey = "endTime",
    this.titleKey = "name",
    this.textKey = "text",
    this.titleBuilder,
    this.textBuilder,
    this.allDayKey = "allDay",
  });

  final DateTime? day;
  final EdgeInsetsGeometry padding;
  final String startTimeKey;
  final String endTimeKey;
  final String titleKey;
  final String textKey;
  final double height;
  final double labelWidth;
  final List<DynamicMap> source;
  final String allDayKey;
  final String Function(DynamicMap data)? titleBuilder;
  final String Function(DynamicMap data)? textBuilder;
  final Widget? Function(BuildContext context, DynamicMap item) builder;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = DateTime(this.day?.year ?? now.year,
        this.day?.month ?? now.month, this.day?.day ?? now.day);
    final eventMap = <DateTime, List<DynamicMap>>{};
    source.forEach((item) {
      if (item.get(allDayKey, false) || !item.containsKey(endTimeKey)) {
        return;
      }
      final startTime = item.getAsDateTime(startTimeKey);
      if (eventMap.containsKey(startTime)) {
        eventMap[startTime]?.add(item);
      } else {
        eventMap[startTime] = [item];
      }
    });
    final events = eventMap.toList((key, value) {
      if (value.length > 1) {
        final startTime = value.first.getAsDateTime(startTimeKey);
        final start = startTime.difference(day);
        return Positioned(
          left: labelWidth + 8,
          right: 8,
          top: start.inMinutes * height / 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: value.mapAndRemoveEmpty((item) {
              final endTime = item.getAsDateTime(endTimeKey);
              final duration = endTime.difference(startTime);
              final widget = builder.call(context, item);
              if (widget == null) {
                return const Empty();
              }
              return Expanded(
                flex: 1,
                child: SizedBox(
                  height: (height * duration.inMinutes / 60) + 1,
                  child: widget,
                ),
              );
            }),
          ),
        );
      } else {
        final item = value.first;
        final startTime = item.getAsDateTime(startTimeKey);
        final endTime = item.getAsDateTime(endTimeKey);
        final duration = endTime.difference(startTime);
        final start = startTime.difference(day);
        final widget = builder.call(context, item);
        if (widget == null) {
          return const Empty();
        }
        return Positioned(
          left: labelWidth + 8,
          right: 8,
          top: start.inMinutes * height / 60,
          child: SizedBox(
            height: (height * duration.inMinutes / 60) + 1,
            child: widget,
          ),
        );
      }
    });

    final allDay = source.mapAndRemoveEmpty((item) {
      if (item.get(allDayKey, false) || !item.containsKey(endTimeKey)) {
        final widget = builder.call(context, item);
        if (widget == null) {
          return null;
        }
        return widget;
      }
      return null;
    });

    return UIScrollbar(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: labelWidth + 8,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              day.shortLocalizedWeekDay,
                              style: TextStyle(
                                  color: context.theme.dividerColor,
                                  fontSize: 12),
                            ),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                  color: context.theme.dividerColor,
                                  fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: allDay)),
                    const SizedBox(width: 8),
                  ],
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints.expand(height: 1),
                  child: ColoredBox(
                    color: context.theme.dividerColor,
                  ),
                ),
                Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: (height - 8).limitLow(0),
                        ),
                        for (var i = 1; i <= 11; i++)
                          SizedBox(
                            height: height,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  width: labelWidth,
                                  child: Text(
                                    "%s AM".localize().format([i]),
                                    style: TextStyle(
                                        color: context.theme.dividerColor),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints.expand(
                                          height: 1),
                                      child: ColoredBox(
                                        color: context.theme.dividerColor,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        for (var i = 0; i <= 11; i++)
                          SizedBox(
                            height: height,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  width: labelWidth,
                                  child: Text(
                                    "%s AM".localize().format([i]),
                                    style: TextStyle(
                                        color: context.theme.dividerColor),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints.expand(
                                          height: 1),
                                      child: ColoredBox(
                                        color: context.theme.dividerColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                    ...events,
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: labelWidth + 8,
              child: SizedBox(
                width: 1,
                child: ColoredBox(
                  color: context.theme.dividerColor,
                ),
              ),
            )
          ],
        ),
      ),
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
        useDocumentModel("/${config.eventPath}/${context.get("event_id", "")}");
    final name = event.get(config.nameKey, "");
    final text = event.get(config.textKey, "");
    final allDay = event.get(config.allDayKey, false);
    final startTime = event.getAsDateTime(config.startTimeKey);
    final endTimeValue = event.get<int?>(config.endTimeKey, null);
    final endTime = endTimeValue != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeValue)
        : null;
    // final time =

    final editingType = !text.startsWith(RegExp(r"^(\[|\{)"))
        ? PostEditingType.planeText
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

        return UIScaffold(
          designType: config.designType,
          appBar: appBar,
          body: UIListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              QuillEditor(
                scrollController: ScrollController(),
                scrollable: false,
                focusNode: useFocusNode(),
                autoFocus: false,
                controller: controller,
                placeholder: "Text".localize(),
                readOnly: true,
                expands: false,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
      default:
        return UIScaffold(
          designType: config.designType,
          appBar: appBar,
          body: UIListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
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
    return startTime.format("yyyy/MM/dd ${"AllDay".localize()}");
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
