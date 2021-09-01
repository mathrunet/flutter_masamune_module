import 'package:masamune/masamune.dart';
import 'package:masamune_module/masamune_module.dart';

part "questionnaire.m.dart";

enum _QuenstionFormType { text, selection }

extension _StringExtension on String {
  _QuenstionFormType get quenstionFormType {
    for (final type in _QuenstionFormType.values) {
      if (type.text == this) {
        return type;
      }
    }
    return _QuenstionFormType.text;
  }
}

extension _QuenstionFormTypeExtension on _QuenstionFormType {
  String get text {
    switch (this) {
      case _QuenstionFormType.selection:
        return "selection";
      default:
        return "text";
    }
  }

  String get name {
    switch (this) {
      case _QuenstionFormType.selection:
        return "Choices".localize();
      default:
        return "Text".localize();
    }
  }
}

@module
@immutable
class QuestionnaireModule extends PageModule {
  const QuestionnaireModule({
    bool enabled = true,
    String? title = "",
    this.routePath = "question",
    this.questionPath = "question",
    this.answerPath = "answer",
    this.userPath = "user",
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.requiredKey = Const.required,
    this.typeKey = Const.type,
    this.roleKey = Const.role,
    this.selectionKey = Const.selection,
    this.createdTimeKey = Const.createdTime,
    this.endTimeKey = Const.endTime,
    this.answerKey = Const.answer,
    Permission permission = const Permission(),
    this.questionnaireQuery,
    this.designType = DesignType.modern,
    this.home,
    this.edit,
    this.view,
    this.answerView,
    this.answerDetail,
    this.questionView,
    this.questionEdit,
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => home ?? QuestionnaireModuleHome(this)),
      "/$routePath/edit":
          RouteConfig((_) => edit ?? QuestionnaireModuleEdit(this)),
      // "/$routePath/{post_id}": RouteConfig((_) => _PostView(this)),
      "/$routePath/{question_id}":
          RouteConfig((_) => view ?? QuestionnaireModuleView(this)),
      "/$routePath/{question_id}/edit":
          RouteConfig((_) => edit ?? QuestionnaireModuleEdit(this)),
      "/$routePath/{question_id}/question": RouteConfig(
          (_) => questionView ?? QuestionnaireModuleQuestionView(this)),
      "/$routePath/{question_id}/answer/empty":
          RouteConfig((_) => const EmptyPage()),
      "/$routePath/{question_id}/answer/{answer_id}": RouteConfig(
          (_) => answerDetail ?? QuestionnaireModuleAanswerDetail(this)),
      "/$routePath/{question_id}/question/edit": RouteConfig(
          (_) => questionEdit ?? QuestionnaireModuleQuestionEdit(this)),
      "/$routePath/{question_id}/question/{item_id}": RouteConfig(
          (_) => questionEdit ?? QuestionnaireModuleQuestionEdit(this)),
    };
    return route;
  }

  final Widget? home;
  final Widget? edit;
  final Widget? view;
  final Widget? questionView;
  final Widget? answerView;
  final Widget? answerDetail;
  final Widget? questionEdit;

  /// デザインタイプ。
  final DesignType designType;

  /// ルートのパス。
  final String routePath;

  /// アンケートデータのパス。
  final String questionPath;

  /// 回答データのパス。
  final String answerPath;

  /// ユーザーのデータパス。
  final String userPath;

  /// 権限のキー。
  final String roleKey;

  /// 作成日のキー。
  final String createdTimeKey;

  /// タイトルのキー。
  final String nameKey;

  /// テキストのキー。
  final String textKey;

  /// タイプのキー。
  final String typeKey;

  /// 任意項目であるかどうかのキー。
  final String requiredKey;

  /// 選択項目のキー。
  final String selectionKey;

  /// 答えのキー。
  final String answerKey;

  /// 締切日のキー。
  final String endTimeKey;

  /// クエリー。
  final CollectionQuery? questionnaireQuery;

  @override
  QuestionnaireModule? fromMap(DynamicMap map) =>
      _$QuestionnaireModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$QuestionnaireModuleToMap(this);
}

class QuestionnaireModuleHome extends PageHookWidget {
  const QuestionnaireModuleHome(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    final now = useNow();
    final question = useCollectionModel(
        config.questionnaireQuery?.value ?? config.questionPath);
    final answered = useCollectionModel(
        "${config.userPath}/${context.model?.userId}/${config.answerPath}");

    final questionWithAnswer = question.map((e) {
      final uid = e.get(Const.uid, "");
      if (uid.isEmpty) {
        return e;
      }
      if (answered.any((element) => element.uid == uid)) {
        return {...e}..["answered"] = true;
      }
      return e;
    });
    final user = useUserDocumentModel(config.userPath);
    final controller = useNavigatorController(
      "${config.routePath}/${questionWithAnswer.firstOrNull.get(Const.uid, "")}",
      (route) => questionWithAnswer.isEmpty,
    );

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      loadingFutures: [
        question.future,
        user.future,
      ],
      appBar: UIAppBar(
        title: Text(config.title ?? "Questionnaire".localize()),
      ),
      body: UIListBuilder<DynamicMap>(
        source: questionWithAnswer.toList(),
        builder: (context, item) {
          return [
            ListItem(
              selected: !context.isMobileOrModal &&
                  controller.route?.name.last() == item.get(Const.uid, ""),
              selectedColor: context.theme.textColorOnPrimary,
              iconColor: Colors.green,
              selectedTileColor: context.theme.primaryColor.withOpacity(0.8),
              disabledTapOnSelected: true,
              title: Text(item.get(config.nameKey, "")),
              subtitle: Text(
                DateTime.fromMillisecondsSinceEpoch(
                  item.get(config.createdTimeKey, now.millisecondsSinceEpoch),
                ).format("yyyy/MM/dd HH:mm"),
              ),
              onTap: () {
                if (context.isMobile) {
                  context.navigator.pushNamed(
                    "${config.routePath}/${item.get(Const.uid, "")}",
                    arguments: RouteQuery.fullscreen,
                  );
                } else {
                  controller.navigator.pushReplacementNamed(
                    "${config.routePath}/${item.get(Const.uid, "")}",
                  );
                }
              },
              trailing: item.get("answered", false)
                  ? const Icon(Icons.check_circle)
                  : null,
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
                    context.rootNavigator.pushNamed(
                      "/${config.routePath}/edit",
                      arguments: RouteQuery.fullscreenOrModal,
                    );
                  },
                )
              : null,
    );
  }
}

class QuestionnaireModuleView extends HookWidget {
  const QuestionnaireModuleView(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel();
    if (config.permission.canEdit(user.get(config.roleKey, ""))) {
      return QuestionnaireAanswerView(config);
    } else {
      return QuestionnaireModuleQuestionView(config);
    }
  }
}

class QuestionnaireAanswerView extends PageHookWidget {
  const QuestionnaireAanswerView(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    final now = useNow();
    final question = useDocumentModel(
        "${config.questionPath}/${context.get("question_id", "")}");
    final questions = useCollectionModel(
        "${config.questionPath}/${context.get("question_id", "")}/${config.questionPath}");
    final answers = useCollectionModel(
      "${config.questionPath}/${context.get("question_id", "")}/${config.answerPath}",
    );
    final users = useCollectionModel(
      CollectionQuery(config.userPath,
              key: Const.uid,
              whereIn: answers.map((e) => e.get(Const.user, "")).toList())
          .value,
    );
    final answersWithUsers = answers.setWhere(
      users,
      test: (o, a) => o.get(Const.user, "") == a.get(Const.uid, ""),
      apply: (o, a) => o.merge(
        a,
        convertKeys: (key) => "${Const.user}$key",
      ),
      orElse: (o) => o,
    );
    final name = question.get(config.nameKey, "");
    final text = question.get(config.textKey, "");
    final endDate = question.get(config.endTimeKey, 0);

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      appBar: UIAppBar(
        title: Text(name),
        actions: [
          IconButton(
            onPressed: () {
              context.rootNavigator.pushNamed(
                "${config.routePath}/${context.get("question_id", "")}/edit",
                arguments: RouteQuery.fullscreenOrModal,
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              context.rootNavigator.pushNamed(
                "/${config.routePath}/${context.get("question_id", "")}/question",
                arguments: RouteQuery.fullscreenOrModal,
              );
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: () {
        if (questions.isEmpty) {
          return InkWell(
            onTap: () {
              context.rootNavigator.pushNamed(
                "/${config.routePath}/${context.get("question_id", "")}/question",
                arguments: RouteQuery.fullscreenOrModal,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: MessageBox("設問が設定されていません。こちらから設問を設定してください。",
                    color: context.theme.errorColor),
              ),
            ),
          );
        }
        return UIListBuilder<DynamicMap>(
          source: answersWithUsers.toList(),
          top: [
            if (text.isNotEmpty)
              MessageBox(
                text,
                color: context.theme.dividerColor,
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              ),
            if (endDate > 0)
              MessageBox(
                "Deadline %s".localize().format([
                  DateTime.fromMillisecondsSinceEpoch(endDate)
                      .format("yyyy/MM/dd")
                ]),
                color: context.theme.errorColor,
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              ),
            const Space.height(10),
            if (answers.isEmpty)
              MessageBox(
                "回答がまだありません。",
                color: context.theme.dividerColor,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              )
            else
              DividHeadline(
                "List of %s answers".localize().format([name]),
              ),
          ],
          builder: (context, item) {
            return [
              ListItem(
                title: Text(item.get("${Const.user}${config.nameKey}", "")),
                subtitle: Text(
                  DateTime.fromMillisecondsSinceEpoch(item.get(
                          config.createdTimeKey, now.millisecondsSinceEpoch))
                      .format("yyyy/MM/dd HH:mm"),
                ),
                onTap: () {
                  context.rootNavigator.pushNamed(
                    "/${config.routePath}/${context.get("question_id", "")}/answer/${item.get(Const.uid, "")}",
                    arguments: RouteQuery.fullscreenOrModal,
                  );
                },
              ),
            ];
          },
        );
      }(),
    );
  }
}

class QuestionnaireModuleAanswerDetail extends PageHookWidget {
  const QuestionnaireModuleAanswerDetail(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    int i = 0;
    final questions = useCollectionModel(
        "${config.questionPath}/${context.get("question_id", "")}/${config.questionPath}");
    final answer = useDocumentModel(
      "${config.questionPath}/${context.get("question_id", "")}/${config.answerPath}/${context.get("answer_id", "")}",
    );
    final user =
        useDocumentModel("${config.userPath}/${answer.get(Const.user, "")}");

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      appBar: UIAppBar(
        title: Text(
          "%s answers".localize().format([user.get(config.nameKey, "")]),
        ),
      ),
      body: UIListBuilder<DynamicDocumentModel>(
        padding: const EdgeInsets.only(top: 12),
        source: questions,
        builder: (contex, item) {
          i++;
          return [
            QuestionnaireModuleListTile(
              config,
              index: i,
              question: item,
              answer: answer,
              canEdit: true,
              onlyView: true,
            ),
          ];
        },
      ),
    );
  }
}

class QuestionnaireModuleQuestionView extends PageHookWidget {
  const QuestionnaireModuleQuestionView(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    int i = 0;
    final form = useForm();
    final user = useUserDocumentModel(config.userPath);
    final question = useDocumentModel(
        "${config.questionPath}/${context.get("question_id", "")}");
    final questions = useCollectionModel(
        "${config.questionPath}/${context.get("question_id", "")}/${config.questionPath}");
    final answer = useDocumentModel(
      "${config.questionPath}/${context.get("question_id", "")}/${config.answerPath}/${context.model?.userId}",
    );
    final name = question.get(config.nameKey, "");
    final text = question.get(config.textKey, "");
    final endDate = question.get(config.endTimeKey, 0);
    final canEdit = config.permission.canEdit(user.get(config.roleKey, ""));

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      appBar: UIAppBar(
        title: Text(name),
        actions: [
          if (canEdit && !context.isMobileOrModal)
            IconButton(
              onPressed: () {
                context.rootNavigator.pushNamed(
                  "/${config.routePath}/${context.get("question_id", "")}/question/edit",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: questions.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  canEdit
                      ? "設問は空です。新規追加ボタンから新しく設問を設定してください。"
                      : "まだ設問が設定されていません。設問が設定されるまでしばらくお待ち下さい。",
                ),
              ),
            )
          : FormBuilder(
              key: form.key,
              padding: const EdgeInsets.all(0),
              children: [
                if (text.isNotEmpty)
                  MessageBox(
                    text,
                    color: context.theme.dividerColor,
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  ),
                if (answer.isNotEmpty)
                  MessageBox(
                    "Already responding",
                    icon: Icons.check_circle,
                    color: context.theme.primaryColor,
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  )
                else if (endDate > 0)
                  MessageBox(
                    "Deadline %s".localize().format([
                      DateTime.fromMillisecondsSinceEpoch(endDate)
                          .format("yyyy/MM/dd")
                    ]),
                    color: context.theme.errorColor,
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  ),
                const Space.height(10),
                ...questions.mapListenable((item) {
                  i++;
                  return QuestionnaireModuleListTile(
                    config,
                    index: i,
                    question: item,
                    answer: answer,
                    canEdit: canEdit,
                    onlyView: false,
                  );
                }),
                const Divid(),
                const Space.height(100),
              ],
            ),
      floatingActionButton: !canEdit || context.isMobileOrModal
          ? FloatingActionButton.extended(
              onPressed: () {
                if (canEdit) {
                  context.navigator.pushNamed(
                    "/${config.routePath}/${context.get("question_id", "")}/question/edit",
                    arguments: RouteQuery.fullscreenOrModal,
                  );
                } else {}
              },
              icon: Icon(canEdit ? Icons.add : Icons.check),
              label: Text(
                canEdit ? "Add".localize() : "Submit".localize(),
              ),
            )
          : null,
    );
  }
}

class QuestionnaireModuleListTile extends PageHookWidget {
  const QuestionnaireModuleListTile(
    this.config, {
    required this.index,
    required this.question,
    required this.answer,
    required this.canEdit,
    required this.onlyView,
  });
  final bool onlyView;
  final int index;
  final bool canEdit;
  final QuestionnaireModule config;
  final DynamicDocumentModel question;
  final DynamicDocumentModel answer;

  @override
  Widget build(BuildContext context) {
    final uid = question.get(Const.uid, "");
    final type = question.get(config.typeKey, "").quenstionFormType;
    final name = question.get(config.nameKey, "");
    final required = question.get(config.requiredKey, false);
    final answers = answer.get(config.answerKey, {});
    switch (type) {
      case _QuenstionFormType.selection:
        final select = question.get(config.selectionKey, {});

        return InkWell(
          onTap: canEdit && !onlyView
              ? () {
                  context.rootNavigator.pushNamed(
                    "/${config.routePath}/${context.get("question_id", "")}/question/$uid",
                    arguments: RouteQuery.fullscreenOrModal,
                  );
                }
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DividHeadline(
                "Question No.%s".localize().format([index]),
                icon: required ? Icons.check_circle : null,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(name),
              ),
              if (!canEdit) ...[
                Divid(
                    indent: 12,
                    endIndent: 12,
                    color: context.theme.dividerColor.withOpacity(0.5)),
                FormItemDropdownField(
                  dense: true,
                  allowEmpty: !required,
                  items: {...select},
                  hintText: "Please select your answer".localize(),
                  controller:
                      useMemoizedTextEditingController(answers.get(uid, "")),
                  onSaved: (value) {
                    final answers = context.get("answer", {});
                    answers[uid] = value;
                  },
                ),
              ] else if (onlyView) ...[
                Divid(
                    indent: 12,
                    endIndent: 12,
                    color: context.theme.dividerColor.withOpacity(0.5)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(answers.get(uid, "")),
                ),
              ],
            ],
          ),
        );
      default:
        return InkWell(
          onTap: canEdit && !onlyView
              ? () {
                  context.rootNavigator.pushNamed(
                    "/${config.routePath}/${context.get("question_id", "")}/question/$uid",
                    arguments: RouteQuery.fullscreenOrModal,
                  );
                }
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DividHeadline(
                "Question No.%s".localize().format([index]),
                icon: required ? Icons.check_circle : null,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(name),
              ),
              if (!canEdit) ...[
                Divid(
                    indent: 12,
                    endIndent: 12,
                    color: context.theme.dividerColor.withOpacity(0.5)),
                FormItemTextField(
                  dense: true,
                  allowEmpty: !required,
                  hintText: "Please enter your answer".localize(),
                  errorText:
                      "No input %s".localize().format(["Answer".localize()]),
                  controller:
                      useMemoizedTextEditingController(answers.get(uid, "")),
                  onSaved: (value) {
                    final answers = context.get("answer", {});
                    answers[uid] = value;
                  },
                ),
              ] else if (onlyView) ...[
                Divid(
                    indent: 12,
                    endIndent: 12,
                    color: context.theme.dividerColor.withOpacity(0.5)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(answers.get(uid, "")),
                ),
              ],
            ],
          ),
        );
    }
  }
}

class QuestionnaireModuleQuestionEdit extends PageHookWidget {
  const QuestionnaireModuleQuestionEdit(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    final form = useForm("item_id");
    final item = useDocumentModel(
        "${config.questionPath}/${context.get("question_id", "")}/${config.questionPath}/${form.uid}");
    final user = useUserDocumentModel(config.userPath);
    final name = item.get(config.nameKey, "");
    final type = item.get(config.typeKey, Const.text);
    final required = item.get(config.requiredKey, false);
    final view = useState(type);
    final selection = item.get(config.selectionKey, {});
    final selectionTextEditingControllers =
        useMemoizedTextEditingControllerMap(selection);

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      appBar: UIAppBar(
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
      ),
      body: FormBuilder(
        key: form.key,
        padding: const EdgeInsets.all(0),
        children: [
          const Space.height(16),
          DividHeadline("Question".localize()),
          FormItemTextField(
            dense: true,
            hintText: "Input %s".localize().format(["Question".localize()]),
            errorText: "No input %s".localize().format(["Question".localize()]),
            keyboardType: TextInputType.multiline,
            controller: useMemoizedTextEditingController(name),
            minLines: 3,
            maxLines: 5,
            onSaved: (value) {
              context[config.nameKey] = value;
            },
          ),
          DividHeadline("Required".localize()),
          FormItemDropdownField(
            dense: true,
            items: {
              "yes": "Required".localize(),
              "no": "Optional".localize(),
            },
            controller:
                useMemoizedTextEditingController(required ? "yes" : "no"),
            onSaved: (value) {
              context[config.requiredKey] = value == "yes";
            },
          ),
          DividHeadline("Type".localize()),
          FormItemDropdownField(
            dense: true,
            items: {
              ..._QuenstionFormType.values.toMap(
                key: (e) => (e as _QuenstionFormType).text,
                value: (e) => (e as _QuenstionFormType).name,
              )
            },
            controller: useMemoizedTextEditingController(type),
            onChanged: (value) {
              view.value = value ?? Const.text;
            },
            onSaved: (value) {
              context[config.typeKey] = value;
            },
          ),
          if (view.value == _QuenstionFormType.selection.text) ...[
            DividHeadline("Choices".localize()),
            AppendableBuilder(
              initialValues: selection.keys.cast<String>(),
              builder: (context, id, onAdd, onRemove) {
                return AppendableBuilderItem(
                  onPressed: () {
                    onRemove(id);
                  },
                  child: FormItemTextField(
                    dense: true,
                    hintText:
                        "Input %s".localize().format(["Choices".localize()]),
                    errorText:
                        "No input %s".localize().format(["Choices".localize()]),
                    keyboardType: TextInputType.text,
                    controller: selectionTextEditingControllers[id],
                    onSaved: (value) {
                      final select = context.get(config.selectionKey, {});
                      select[id] = value;
                      context[config.selectionKey] = select;
                    },
                  ),
                );
              },
              child: (context, children, onAdd, onRemove) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...children,
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                      ),
                      onPressed: () {
                        onAdd.call();
                      },
                    ),
                  ],
                );
              },
            )
          ],
          const Divid(),
          const Space.height(100),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!form.validate()) {
            return;
          }

          final type = context.get(config.typeKey, Const.text);
          item[config.nameKey] = context.get(config.nameKey, "");
          item[config.requiredKey] = context.get(config.requiredKey, false);
          item[config.typeKey] = context.get(config.typeKey, Const.text);
          if (type == _QuenstionFormType.selection.text) {
            item[config.selectionKey] = context.get(config.selectionKey, {});
          }
          await context.model?.saveDocument(item).showIndicator(context);
          context.navigator.pop();
        },
        icon: const Icon(Icons.check),
        label: Text("Submit".localize()),
      ),
    );
  }
}

class QuestionnaireModuleEdit extends PageHookWidget {
  const QuestionnaireModuleEdit(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    final form = useForm("question_id");
    final item = useDocumentModel("${config.questionPath}/${form.uid}");
    final user = useUserDocumentModel(config.userPath);
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final endTime = item.get(config.endTimeKey, 0);

    return UIScaffold(
      waitTransition: true,
      designType: config.designType,
      appBar: UIAppBar(
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
                    context.navigator.pop();
                  },
                );
              },
            ),
        ],
      ),
      body: FormBuilder(
        padding: const EdgeInsets.all(0),
        key: form.key,
        children: [
          const Space.height(20),
          DividHeadline("Title".localize()),
          FormItemTextField(
            dense: true,
            hintText: "Input %s".localize().format(["Title".localize()]),
            errorText: "No input %s".localize().format(["Title".localize()]),
            controller: useMemoizedTextEditingController(form.select(name, "")),
            onSaved: (value) {
              context[config.nameKey] = value;
            },
          ),
          DividHeadline("Description".localize()),
          FormItemTextField(
            dense: true,
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 5,
            hintText: "Input %s".localize().format(["Description".localize()]),
            allowEmpty: true,
            controller: useMemoizedTextEditingController(form.select(text, "")),
            onSaved: (value) {
              context[config.textKey] = value;
            },
          ),
          DividHeadline("End date".localize()),
          FormItemDateTimeField(
            dense: true,
            allowEmpty: true,
            hintText: "Input %s".localize().format(["End date".localize()]),
            errorText: "No input %s".localize().format(["End date".localize()]),
            controller: useMemoizedTextEditingController(
              form.select(FormItemDateTimeField.formatDate(endTime), ""),
            ),
            type: FormItemDateTimeFieldPickerType.date,
            onSaved: (value) {
              context[config.endTimeKey] = value?.millisecondsSinceEpoch ?? 0;
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

          item[config.nameKey] = context.get(config.nameKey, "");
          item[config.textKey] = context.get(config.textKey, "");
          item[config.endTimeKey] = context.get(config.endTimeKey, 0);
          await context.model?.saveDocument(item).showIndicator(context);
          context.navigator.pop();
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
