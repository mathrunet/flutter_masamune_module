import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masamune_module/masamune_module.dart';

part 'user_account.m.dart';

@module
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
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
    this.home,
    this.reauth,
    this.editEmail,
    this.editPassword,
    this.blockList,
  }) : super(
          enabled: enabled,
          title: title,
          permission: permission,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig> get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath/account":
          RouteConfig((_) => home ?? UserAccountModuleHome(this)),
      "/$routePath/account/reauth":
          RouteConfig((_) => reauth ?? UserAccountModuleReauth(this)),
      "/$routePath/account/email":
          RouteConfig((_) => editEmail ?? UserAccountModuleEditEmail(this)),
      "/$routePath/account/password": RouteConfig(
          (_) => editPassword ?? UserAccountModuleEditPassword(this)),
      "/$routePath/account/block":
          RouteConfig((_) => blockList ?? UserAccountModuleBlockList(this)),
    };

    return route;
  }

  /// ページ設定。
  final Widget? home;
  final Widget? reauth;
  final Widget? editEmail;
  final Widget? editPassword;
  final Widget? blockList;

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
  Widget build(BuildContext context) => UserAccountModuleContent(this);

  @override
  UserAccountModule? fromMap(DynamicMap map) =>
      _$UserAccountModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$UserAccountModuleToMap(this);
}

class UserAccountModuleHome extends PageScopedWidget {
  const UserAccountModuleHome(this.config);
  final UserAccountModule config;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UIScaffold(
      appBar: UIAppBar(
        title: Text(config.title ?? "Account".localize()),
      ),
      body: SingleChildScrollView(
        child: PlatformScrollbar(
          child: UserAccountModuleContent(config),
        ),
      ),
    );
  }
}

class UserAccountModuleContent extends ScopedWidget {
  const UserAccountModuleContent(this.config);
  final UserAccountModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = context.get("user_id", context.model?.userId ?? "");
    final own = userId == context.model?.userId;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (own) ...[
          SubHeadline("Information".localize()),
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
                  context.navigator.pushNamed(
                    "/${config.routePath}/account/reauth",
                    arguments: RouteQuery(
                      parameters: {
                        "redirect_to": "/${config.routePath}/account/email"
                      },
                    ),
                  );
                  return;
                }
                context.navigator
                    .pushNamed("/${config.routePath}/account/email");
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
                  context.navigator.pushNamed(
                    "/${config.routePath}/account/reauth",
                    arguments: RouteQuery(
                      parameters: {
                        "redirect_to": "/${config.routePath}/account/password"
                      },
                    ),
                  );
                  return;
                }
                context.navigator
                    .pushNamed("/${config.routePath}/account/password");
              },
            ),
          ),
          SubHeadline("Menu".localize()),
          if (config.allowEditingBlockList)
            ListItem(
              title: Text("%s list".localize().format(["Block".localize()])),
              onTap: () {
                context.navigator
                    .pushNamed("/${config.routePath}/account/block");
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
                        context.navigator.resetAndPushNamed("/");
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
          if (config.allowUserDeleting)
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
                          context.navigator.resetAndPushNamed("/");
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

class UserAccountModuleReauth extends PageScopedWidget {
  const UserAccountModuleReauth(this.config);
  final UserAccountModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  context.navigator
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

class UserAccountModuleEditEmail extends PageScopedWidget {
  const UserAccountModuleEditEmail(this.config);
  final UserAccountModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      context.navigator.pop();
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

class UserAccountModuleEditPassword extends PageScopedWidget {
  const UserAccountModuleEditPassword(this.config);
  final UserAccountModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      context.navigator.pop();
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

class UserAccountModuleBlockList extends PageScopedWidget {
  const UserAccountModuleBlockList(this.config);
  final UserAccountModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watchCollectionModel(
        "${config.queryPath}/${context.model?.userId}/${config.blockPath}");
    final users = ref.watchCollectionModel(
      ModelQuery(
        config.queryPath,
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
      ),
      body: UIListBuilder<DynamicMap>(
        source: blockWithUsers,
        builder: (context, item, index) {
          return [
            ListItem(
              title: Text(item.get("${Const.user}${config.nameKey}", "")),
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
