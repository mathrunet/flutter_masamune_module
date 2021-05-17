part of masamune_module;

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
    this.roleKey = "role",
    this.createdTimeKey = "createdTime",
    this.endTimeKey = "endTime",
  }) : super(enabled: enabled, title: title);

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
      "/$routePath/{post_id}/edit":
          RouteConfig((_) => _QuestionnaireEdit(this)),
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

  /// 締切日のキー。
  final String endTimeKey;
}

class Questionnaire extends PageHookWidget {
  const Questionnaire(this.config);
  final QuestionnaireModule config;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final question = context.adapter!.loadCollection(
      useProvider(context.adapter!.collectionProvider(config.questionPath)),
    );
    final answer = context.adapter!.loadCollection(
      useProvider(context.adapter!.collectionProvider(
          "${config.userPath}/${context.adapter?.userId}/${config.questionPath}")),
    );
    final questionWithAnswer = question.setWhere(
      answer,
      test: (o, a) => o.get("uid", "") == a.get("uid", ""),
      apply: (o, a) => {...o}..["answered"] = true,
      orElse: (o) => o,
    );

    final user = context.adapter!.loadDocument(
      useProvider(context.adapter!
          .documentProvider("${config.userPath}/${context.adapter?.userId}")),
    );
    final role = context.roles.firstWhereOrNull(
      (item) => item.id == user.get(config.roleKey, "registered"),
    );

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
              onTap: () {},
              trailing: item.get("answered", false)
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            );
          })
        ],
      ),
      floatingActionButton: role.containsPermission("edit")
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

class _QuestionnaireEdit extends PageHookWidget
    with UIPageFormMixin, UIPageUuidMixin {
  _QuestionnaireEdit(this.config, {this.inAdd = false});
  final QuestionnaireModule config;
  final bool inAdd;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final item = context.adapter!.loadDocument(
      useProvider(
          context.adapter!.documentProvider("${config.questionPath}/$puid")),
    );
    final name = item.get(config.nameKey, "");
    final text = item.get(config.textKey, "");
    final endTime = item.get(config.endTimeKey, 0);
    // final questions = context.adapter!.loadCollection(
    //   useProvider(context.adapter!.collectionProvider(
    //       "${config.questionPath}/$puid/${config.questionPath}")),
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          inAdd
              ? "A new entry".localize()
              : "Editing %s".localize().format([name]),
        ),
        actions: [
          if (!inAdd)
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
