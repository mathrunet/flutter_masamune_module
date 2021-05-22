part of masamune_module;

enum _QuenstionFormType { text, select }

extension _QuenstionFormTypeExtension on _QuenstionFormType {
  String get text {
    switch (this) {
      case _QuenstionFormType.select:
        return "select";
      default:
        return "text";
    }
  }

  String get name {
    switch (this) {
      case _QuenstionFormType.select:
        return "Choices".localize();
      default:
        return "Text".localize();
    }
  }
}

class QuestionnaireModule extends ModuleConfig {
  const QuestionnaireModule({
    bool enabled = true,
    String? title = "",
    this.routePath = "question",
    this.questionPath = "question",
    this.answerPath = "answer",
    this.userPath = "user",
    this.nameKey = "name",
    this.textKey = "text",
    this.requiredKey = "required",
    this.typeKey = "type",
    this.roleKey = "role",
    this.selectKey = "select",
    this.createdTimeKey = "createdTime",
    this.endTimeKey = "endTime",
    this.answerKey = "answer",
    PermissionConfig permission = const PermissionConfig(),
  }) : super(enabled: enabled, title: title, permission: permission);

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => Questionnaire(this)),
      "/$routePath/edit":
          RouteConfig((_) => _QuestionnaireEdit(this, inAdd: true)),
      // "/$routePath/{post_id}": RouteConfig((_) => _PostView(this)),
      "/$routePath/{question_id}": RouteConfig((_) => _QuestionnaireView(this)),
      "/$routePath/{question_id}/edit":
          RouteConfig((_) => _QuestionnaireEdit(this)),
      "/$routePath/{question_id}/question/edit":
          RouteConfig((_) => _QuestionnaireQuestionEdit(this, inAdd: true)),
      "/$routePath/{question_id}/question/{item_id}":
          RouteConfig((_) => _QuestionnaireQuestionEdit(this)),
    };
    return route;
  }

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
  final String selectKey;

  /// 答えのキー。
  final String answerKey;

  /// 締切日のキー。
  final String endTimeKey;
}

class Questionnaire extends PageHookWidget {
  const Questionnaire(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final question = useCollectionModel(config.questionPath);
    final answer = useCollectionModel(
        "${config.userPath}/${context.adapter?.userId}/${config.questionPath}");
    final questionWithAnswer = question.setWhere(
      answer,
      test: (o, a) => o.get("uid", "") == a.get("uid", ""),
      apply: (o, a) => {...o}..["answered"] = true,
      orElse: (o) => o,
    );
    final user = useUserDocumentModel(config.userPath);

    return Scaffold(
      appBar: AppBar(title: Text(config.title ?? "Questionnaire".localize())),
      body: ListView(
        children: [
          ...questionWithAnswer.mapAndRemoveEmpty((item) {
            return ListTile(
              title: Text(item.get(config.nameKey, "")),
              subtitle: Text(
                DateTime.fromMillisecondsSinceEpoch(
                  item.get(config.createdTimeKey, now.millisecondsSinceEpoch),
                ).format("yyyy/MM/dd HH:mm"),
              ),
              onTap: () {
                context.navigator.pushNamed(
                  "${config.routePath}/${item.get("uid", "")}",
                  arguments: RouteQuery.fullscreen,
                );
              },
              trailing: item.get("answered", false)
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            );
          })
        ],
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

class _QuestionnaireView extends PageHookWidget with UIPageFormMixin {
  _QuestionnaireView(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    int i = 0;
    final now = DateTime.now();
    final user = useUserDocumentModel(config.userPath);
    final question = useDocumentModel(
        "${config.questionPath}/${context.get("question_id", "")}");
    final questions = useCollectionModel(
        "${config.questionPath}/${context.get("question_id", "")}/${config.questionPath}");
    final answer = useDocumentModel(
        "${config.userPath}/${context.adapter?.userId}/${config.questionPath}/${context.get("question_id", "")}");
    final name = question.get(config.nameKey, "");
    final text = question.get(config.textKey, "");
    final endDate = question.get(config.endTimeKey, 0);
    final canEdit = config.permission.canEdit(user.get(config.roleKey, ""));

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          if (canEdit)
            IconButton(
              onPressed: () {
                context.navigator.pushNamed(
                    "${config.routePath}/${context.get("question_id", "")}/edit");
              },
              icon: const Icon(Icons.edit),
            )
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            if (text.isNotEmpty)
              MessageBox(
                text,
                color: context.theme.dividerColor,
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              ),
            if (answer.isNotEmpty)
              MessageBox(
                "Already responding",
                icon: Icons.check_circle,
                color: context.theme.primaryColor,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              )
            else if (endDate > 0)
              MessageBox(
                "Deadline %s".localize().format([
                  DateTime.fromMillisecondsSinceEpoch(endDate)
                      .format("yyyy/MM/dd")
                ]),
                color: context.theme.errorColor,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              ),
            ...questions.mapAndRemoveEmpty((item) {
              i++;
              return _QuestionnaireListTile(
                config,
                index: i,
                question: item,
                answer: answer,
                canEdit: canEdit,
              );
            }),
            const Divid(),
            const Space.height(100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (canEdit) {
            context.navigator.pushNamed(
                "/${config.routePath}/${context.get("question_id", "")}/question/edit");
          } else {}
        },
        icon: Icon(canEdit ? Icons.add : Icons.check),
        label: Text(
          canEdit ? "Add".localize() : "Submit".localize(),
        ),
      ),
    );
  }
}

class _QuestionnaireListTile extends PageHookWidget {
  const _QuestionnaireListTile(
    this.config, {
    required this.index,
    required this.question,
    required this.answer,
    required this.canEdit,
  });
  final int index;
  final bool canEdit;
  final QuestionnaireModule config;
  final DynamicDocumentModel question;
  final DynamicDocumentModel answer;

  @override
  Widget build(BuildContext context) {
    final uid = question.get("uid", "");
    final type = question.get(config.typeKey, "");
    final name = question.get(config.nameKey, "");
    final required = question.get(config.requiredKey, false);
    final answers = answer.get(config.answerKey, {});
    switch (type) {
      case "select":
        final select = question.get(config.selectKey, {});

        return InkWell(
          onTap: () {
            context.navigator.pushNamed(
                "/${config.routePath}/${context.get("question_id", "")}/question/$uid");
          },
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
              ],
            ],
          ),
        );
      default:
        return InkWell(
          onTap: () {
            context.navigator.pushNamed(
                "/${config.routePath}/${context.get("question_id", "")}/question/$uid");
          },
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
                  controller:
                      useMemoizedTextEditingController(answers.get(uid, "")),
                  onSaved: (value) {
                    final answers = context.get("answer", {});
                    answers[uid] = value;
                  },
                ),
              ],
            ],
          ),
        );
    }
  }
}

class _QuestionnaireQuestionEdit extends PageHookWidget
    with UIPageFormMixin, UIPageUuidMixin {
  _QuestionnaireQuestionEdit(this.config, {this.inAdd = false});
  final QuestionnaireModule config;
  final bool inAdd;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final item = useDocumentModel(
        "${config.questionPath}/${context.get("question_id", "")}/${config.questionPath}/${context.get("item_id", "")}");
    final user = useUserDocumentModel(config.userPath);
    final name = item.get(config.nameKey, "");
    final type = item.get(config.typeKey, "");
    final required = item.get(config.requiredKey, false);
    final view = useState(type);
    final selection = item.get(config.selectKey, {});
    final selectionTextEditingControllers =
        useMemoizedTextEditingControllerMap(selection);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          inAdd
              ? "A new entry".localize()
              : "Editing %s".localize().format([name]),
        ),
        actions: [
          if (!inAdd &&
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
                    await context.adapter
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
        key: formKey,
        padding: const EdgeInsets.all(0),
        children: [
          const Space.height(16),
          DividHeadline("Question".localize()),
          FormItemTextField(
            dense: true,
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
              view.value = value ?? "text";
            },
            onSaved: (value) {
              context[config.typeKey] = value;
            },
          ),
          if (view.value == "select") ...[
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
                    keyboardType: TextInputType.text,
                    controller: selectionTextEditingControllers[id],
                    onSaved: (value) {
                      final select = context.get(config.selectKey, {});
                      select[id] = value;
                      context[config.selectKey] = select;
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
          if (!validate(context)) {
            return;
          }

          final type = context.get(config.typeKey, "text");
          item[config.nameKey] = context.get(config.nameKey, "");
          item[config.requiredKey] = context.get(config.requiredKey, false);
          item[config.typeKey] = context.get(config.typeKey, "text");
          if (type == "select") {
            item[config.selectKey] = context.get(config.selectKey, {});
          }
          await context.adapter?.saveDocument(item).showIndicator(context);
          context.navigator.pop();
        },
        icon: const Icon(Icons.check),
        label: Text("Submit".localize()),
      ),
    );
  }
}

class _QuestionnaireEdit extends PageHookWidget
    with UIPageFormMixin, UIPageUuidMixin {
  _QuestionnaireEdit(this.config, {this.inAdd = false});
  final QuestionnaireModule config;
  final bool inAdd;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final item = useDocumentModel(
        "${config.questionPath}/${context.get("question_id", puid)}");
    final user = useUserDocumentModel(config.userPath);
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final endTime = item.get(config.endTimeKey, 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          inAdd
              ? "A new entry".localize()
              : "Editing %s".localize().format([name]),
        ),
        actions: [
          if (!inAdd &&
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
                    await context.adapter
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
        padding: const EdgeInsets.all(0),
        key: formKey,
        children: [
          const Space.height(20),
          DividHeadline("Title".localize()),
          FormItemTextField(
            dense: true,
            hintText: "Input %s".localize().format(["Title".localize()]),
            controller: useMemoizedTextEditingController(inAdd ? "" : name),
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
            controller: useMemoizedTextEditingController(inAdd ? "" : text),
            onSaved: (value) {
              context[config.textKey] = value;
            },
          ),
          DividHeadline("End date".localize()),
          FormItemDateTimeField(
            dense: true,
            allowEmpty: true,
            hintText: "Input %s".localize().format(["End date".localize()]),
            controller: useMemoizedTextEditingController(
                inAdd ? "" : FormItemDateTimeField.formatDate(endTime)),
            onSaved: (value) {
              context[config.endTimeKey] = value?.millisecondsSinceEpoch ?? 0;
            },
          ),
          const Divid(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!validate(context)) {
            return;
          }

          item[config.nameKey] = context.get(config.nameKey, "");
          item[config.textKey] = context.get(config.textKey, "");
          item[config.endTimeKey] = context.get(config.endTimeKey, 0);
          await context.adapter?.saveDocument(item).showIndicator(context);
          context.navigator.pop();
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
