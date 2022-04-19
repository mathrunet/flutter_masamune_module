import 'package:masamune_module/masamune_module.dart';

@immutable
class UserAccountModule extends UserWidgetModule {
  const UserAccountModule({
    bool enabled = true,
    String? title,
    this.routePath = "user",
    this.queryPath = "user",
    this.blockPath = "block",
    this.nameKey = Const.name,
    this.allowRoles = const [],
    this.allowUserDeleting = false,
    this.allowEditingBlockList = true,
    this.sliverLayoutWhenModernDesignOnHome = true,
    this.automaticallyImplyLeadingOnHome = true,
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const UserAccountModuleHome(),
    this.contentWidget = const UserAccountModuleContent(),
    this.reauthPage = const UserAccountModuleReauth(),
    this.editEmailPage = const UserAccountModuleEditEmail(),
    this.editPasswordPage = const UserAccountModuleEditPassword(),
    this.blockListPage = const UserAccountModuleBlockList(),
  }) : super(
          enabled: enabled,
          title: title,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig> get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath/account": RouteConfig((_) => homePage),
      "/$routePath/account/reauth": RouteConfig((_) => reauthPage),
      "/$routePath/account/email": RouteConfig((_) => editEmailPage),
      "/$routePath/account/password": RouteConfig((_) => editPasswordPage),
      "/$routePath/account/block": RouteConfig((_) => blockListPage),
    };

    return route;
  }

  /// ページ設定。
  final PageModuleWidget<UserAccountModule> homePage;
  final ModuleWidget<UserAccountModule> contentWidget;
  final PageModuleWidget<UserAccountModule> reauthPage;
  final PageModuleWidget<UserAccountModule> editEmailPage;
  final PageModuleWidget<UserAccountModule> editPasswordPage;
  final PageModuleWidget<UserAccountModule> blockListPage;

  /// ホームをスライバーレイアウトにする場合True.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// ホームのときのバックボタンを削除するかどうか。
  final bool automaticallyImplyLeadingOnHome;

  /// ルートのパス。
  final String routePath;

  /// タイトルのキー。
  final String nameKey;

  /// ユーザー削除が可能な場合`true`。
  final bool allowUserDeleting;

  /// ブロックリストを編集可能な場合`true`。
  final bool allowEditingBlockList;

  @override
  final List<String> allowRoles;

  /// ユーザーのデータパス。
  final String queryPath;

  /// ブロックユーザーへのパス。
  final String blockPath;

  @override
  Widget build(BuildContext context) => contentWidget;
}

class UserAccountModuleHome extends PageModuleWidget<UserAccountModule> {
  const UserAccountModuleHome();
  @override
  Widget build(BuildContext context, WidgetRef ref, UserAccountModule module) {
    return UIScaffold(
      appBar: UIAppBar(
        title: Text(module.title ?? "Account".localize()),
        sliverLayoutWhenModernDesign: module.sliverLayoutWhenModernDesignOnHome,
        automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
      ),
      body: SingleChildScrollView(
        child: PlatformScrollbar(
          child: module.contentWidget,
        ),
      ),
    );
  }
}

class UserAccountModuleContent extends ModuleWidget<UserAccountModule> {
  const UserAccountModuleContent();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserAccountModule module) {
    final userId = context.get("user_id", context.model?.userId ?? "");
    final own = userId == context.model?.userId;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (own) ...[
          Headline("Information".localize()),
          ListItem(
            title: Text("Email".localize()),
            textWidth: 150,
            text: Text(
              context.model?.email ?? "",
              softWrap: false,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                if (context.model?.requiredReauthInEmailAndPassword() ??
                    false) {
                  ref.navigator.pushNamed(
                    "/${module.routePath}/account/reauth",
                    arguments: RouteQuery(
                      parameters: {
                        "redirect_to": "/${module.routePath}/account/email"
                      },
                    ),
                  );
                  return;
                }
                ref.navigator.pushNamed("/${module.routePath}/account/email");
              },
            ),
          ),
          ListItem(
            title: Text("Password".localize()),
            text: const Text(
              "********",
              softWrap: false,
            ),
            textWidth: 150,
            trailing: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                if (context.model?.requiredReauthInEmailAndPassword() ??
                    false) {
                  ref.navigator.pushNamed(
                    "/${module.routePath}/account/reauth",
                    arguments: RouteQuery(
                      parameters: {
                        "redirect_to": "/${module.routePath}/account/password"
                      },
                    ),
                  );
                  return;
                }
                ref.navigator
                    .pushNamed("/${module.routePath}/account/password");
              },
            ),
          ),
          Headline("Menu".localize()),
          if (module.allowEditingBlockList)
            ListItem(
              title: Text("%s list".localize().format(["Block".localize()])),
              onTap: () {
                ref.navigator.pushNamed("/${module.routePath}/account/block");
              },
            ),
          ListItem(
            title: Text(
              "Logout".localize(),
              style: TextStyle(color: context.theme.errorColor),
            ),
            onTap: () {
              UIConfirm.show(
                context,
                title: "Confirmation".localize(),
                text: "You're logging out. Are you sure?".localize(),
                onSubmit: () async {
                  try {
                    await context.model?.signOut();
                    UIDialog.show(
                      context,
                      title: "Success".localize(),
                      text: "Logout is complete.".localize(),
                      onSubmit: () {
                        ref.navigator.resetAndPushNamed("/");
                      },
                      submitText: "Back".localize(),
                    );
                  } catch (e) {
                    UIDialog.show(
                      context,
                      title: "Error".localize(),
                      text: "Unknown error.".localize(),
                      submitText: "Close".localize(),
                    );
                  }
                },
                submitText: "Yes".localize(),
                cacnelText: "No".localize(),
              );
            },
          ),
          if (module.allowUserDeleting)
            ListItem(
              title: Text(
                "Account deletion".localize(),
                style: TextStyle(color: context.theme.errorColor),
              ),
              onTap: () {
                UIConfirm.show(
                  context,
                  title: "Confirmation".localize(),
                  text:
                      "The account is deleted. After deleting the account, it cannot be restored. Are you sure?"
                          .localize(),
                  onSubmit: () async {
                    try {
                      await context.model?.deleteAccount();
                      UIDialog.show(
                        context,
                        title: "Success".localize(),
                        text: "Account deletion is complete.".localize(),
                        onSubmit: () {
                          ref.navigator.resetAndPushNamed("/");
                        },
                        submitText: "Back".localize(),
                      );
                    } catch (e) {
                      UIDialog.show(
                        context,
                        title: "Error".localize(),
                        text: "Unknown error.".localize(),
                        submitText: "Close".localize(),
                      );
                    }
                  },
                  submitText: "Yes".localize(),
                  cacnelText: "No".localize(),
                );
              },
            )
        ],
      ],
    );
  }
}

class UserAccountModuleReauth extends PageModuleWidget<UserAccountModule> {
  const UserAccountModuleReauth();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserAccountModule module) {
    final form = ref.useForm();
    final showPassword = ref.state("showPassword", false);

    return UIScaffold(
      appBar: UIAppBar(
        sliverLayoutWhenModernDesign: false,
        title: Text("Reauthentication".localize()),
      ),
      body: FormBuilder(
        key: form.key,
        type: FormBuilderType.center,
        padding: const EdgeInsets.all(0),
        children: [
          DividHeadline("Password".localize()),
          FormItemTextField(
            dense: true,
            obscureText: !showPassword.value,
            hintText: "Input %s".localize().format(["Password".localize()]),
            errorText: "No input %s".localize().format(["Password".localize()]),
            suffixIcon: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 18, 0),
                child: Icon(
                  !showPassword.value
                      ? FontAwesomeIcons.solidEyeSlash
                      : FontAwesomeIcons.solidEye,
                  color: context.theme.textColor.withOpacity(0.5),
                  size: 21,
                ),
              ),
              onTap: () {
                showPassword.value = !showPassword.value;
              },
            ),
            suffixIconConstraints:
                const BoxConstraints(minHeight: 0, minWidth: 0),
            onSubmitted: (value) {
              if (value.isEmpty) {
                return;
              }
              context["password"] = value;
            },
          ),
          const Divid(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: FormItemSubmit(
              "Reauthentication".localize(),
              icon: Icons.check,
              borderRadius: 35,
              height: 70,
              onPressed: () async {
                if (!form.validate()) {
                  return;
                }

                try {
                  final password = context.get("password", "");
                  await context.model
                      ?.reauthInEmailAndPassword(password: password)
                      .showIndicator(context);
                  ref.navigator
                      .pushReplacementNamed(context.get("redirect_to", "/"));
                } catch (e) {
                  UIDialog.show(
                    context,
                    title: "Error".localize(),
                    text:
                        "Could not login. Please check your email address and password."
                            .localize(),
                    submitText: "Close".localize(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserAccountModuleEditEmail extends PageModuleWidget<UserAccountModule> {
  const UserAccountModuleEditEmail();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserAccountModule module) {
    final form = ref.useForm();
    final controller = ref.useTextEditingController(
      "email",
      context.model?.email ?? "",
    );

    return UIScaffold(
      appBar: UIAppBar(
        sliverLayoutWhenModernDesign: false,
        title: Text("Change Email".localize()),
      ),
      body: FormBuilder(
        key: form.key,
        type: FormBuilderType.center,
        padding: const EdgeInsets.all(0),
        children: [
          DividHeadline("Email".localize()),
          FormItemTextField(
            dense: true,
            controller: controller,
            hintText: "Input %s".localize().format(["Email".localize()]),
            errorText: "No input %s".localize().format(["Email".localize()]),
            onSubmitted: (value) {
              if (value.isEmpty) {
                return;
              }
              context["email"] = value;
            },
          ),
          const Divid(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: FormItemSubmit(
              "Submit".localize(),
              icon: Icons.check,
              borderRadius: 35,
              height: 70,
              onPressed: () async {
                if (!form.validate()) {
                  return;
                }

                try {
                  final email = context.get("email", "");
                  await context.model
                      ?.changeEmail(email: email)
                      .showIndicator(context);
                  UIDialog.show(
                    context,
                    title: "Success".localize(),
                    text: "%s is completed."
                        .localize()
                        .format(["Editing".localize()]),
                    onSubmit: () {
                      ref.navigator.pop();
                    },
                    submitText: "Back".localize(),
                  );
                } catch (e) {
                  UIDialog.show(
                    context,
                    title: "Error".localize(),
                    text: "%s is not completed."
                        .localize()
                        .format(["Editing".localize()]),
                    submitText: "Close".localize(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserAccountModuleEditPassword
    extends PageModuleWidget<UserAccountModule> {
  const UserAccountModuleEditPassword();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserAccountModule module) {
    final form = ref.useForm();

    return UIScaffold(
      appBar: UIAppBar(
        sliverLayoutWhenModernDesign: false,
        title: Text("Change Password".localize()),
      ),
      body: FormBuilder(
        key: form.key,
        type: FormBuilderType.center,
        padding: const EdgeInsets.all(0),
        children: [
          DividHeadline("Password".localize()),
          FormItemTextField(
            dense: true,
            hintText: "Input %s".localize().format(["Password".localize()]),
            errorText: "No input %s".localize().format(["Password".localize()]),
            onSubmitted: (value) {
              if (value.isEmpty) {
                return;
              }
              context["password"] = value;
            },
          ),
          DividHeadline("ConfirmationPassword".localize()),
          FormItemTextField(
            dense: true,
            hintText: "Input %s".localize().format(["Password".localize()]),
            errorText: "No input %s".localize().format(["Password".localize()]),
            onSubmitted: (value) {
              if (value.isEmpty) {
                return;
              }
              context["passwordConfirm"] = value;
            },
          ),
          const Divid(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: FormItemSubmit(
              "Submit".localize(),
              icon: Icons.check,
              borderRadius: 35,
              height: 70,
              onPressed: () async {
                if (!form.validate()) {
                  return;
                }

                try {
                  final password = context.get("password", "");
                  final passwordConfirm = context.get("passwordConfirm", "");
                  if (password != passwordConfirm) {
                    UIDialog.show(
                      context,
                      title: "Error".localize(),
                      text: "Passwords do not match.".localize(),
                      submitText: "Close".localize(),
                    );
                    return;
                  }
                  await context.model
                      ?.changePassword(password: password)
                      .showIndicator(context);
                  UIDialog.show(
                    context,
                    title: "Success".localize(),
                    text: "%s is completed."
                        .localize()
                        .format(["Editing".localize()]),
                    onSubmit: () {
                      ref.navigator.pop();
                    },
                    submitText: "Back".localize(),
                  );
                } catch (e) {
                  UIDialog.show(
                    context,
                    title: "Error".localize(),
                    text: "%s is not completed."
                        .localize()
                        .format(["Editing".localize()]),
                    submitText: "Close".localize(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserAccountModuleBlockList extends PageModuleWidget<UserAccountModule> {
  const UserAccountModuleBlockList();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserAccountModule module) {
    final blocks = ref.watchCollectionModel(
        "${module.queryPath}/${context.model?.userId}/${module.blockPath}");
    final users = ref.watchCollectionModel(
      ModelQuery(
        module.queryPath,
        key: Const.uid,
        whereIn: blocks.map((e) => e.get(Const.user, "")).distinct(),
      ).value,
    );
    final blockWithUsers = blocks
        .setWhere(
          users,
          test: (o, a) => o.get(Const.user, "") == a.get(Const.uid, ""),
          apply: (o, a) =>
              o.merge(a, convertKeys: (key) => "${Const.user}$key"),
          orElse: (o) => o,
        )
        .toList();

    return UIScaffold(
      loadingFutures: [
        blocks.loading,
        users.loading,
      ],
      waitTransition: true,
      appBar: UIAppBar(
        title: Text("%s list".localize().format(["Block".localize()])),
        sliverLayoutWhenModernDesign: false,
      ),
      body: UIListBuilder<DynamicMap>(
        source: blockWithUsers,
        builder: (context, item, index) {
          return [
            ListItem(
              title: Text(item.get("${Const.user}${module.nameKey}", "")),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  UIConfirm.show(
                    context,
                    title: "Confirmation".localize(),
                    text:
                        "You will unblock this user. Are you sure?".localize(),
                    submitText: "Yes".localize(),
                    cacnelText: "No".localize(),
                    onSubmit: () async {
                      try {
                        final doc =
                            blocks.firstWhereOrNull((e) => e.uid == item.uid);
                        if (doc == null) {
                          return;
                        }
                        await context.model
                            ?.deleteDocument(doc)
                            .showIndicator(context);
                      } catch (e) {
                        UIDialog.show(
                          context,
                          title: "Error".localize(),
                          text: "Unknown error.".localize(),
                          submitText: "Close".localize(),
                        );
                      }
                    },
                  );
                },
              ),
            )
          ];
        },
      ),
    );
  }
}
