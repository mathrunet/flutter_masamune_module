import 'package:masamune_module/masamune_module.dart';

@immutable
class UserModule extends PageModule {
  const UserModule({
    bool enabled = true,
    String title = "",
    this.contents = const [UserModuleAccountContent()],
    this.accountContents = const [UserModuleAccountContent()],
    String routePath = "user",
    String queryPath = "user",
    ModelQuery? query,
    this.reportPath = "report",
    this.blockPath = "block",
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.imageKey = Const.image,
    this.iconKey = Const.icon,
    this.guestName = "Guest",
    this.expandedHeight = 160,
    this.additionalInformation = const {},
    this.enableImageEditing = false,
    this.enableFollow = false,
    this.enableBlock = true,
    this.enableReport = true,
    this.enableUserDeleting = false,
    this.sliverLayoutWhenModernDesignOnHome = true,
    this.automaticallyImplyLeadingOnHome = true,
    this.showHeaderDivider = true,
    this.enableText = true,
    List<RerouteConfig> rerouteConfigs = const [],
    this.variables = const [],
    this.meta,
    this.bottom = const [],
    this.homePage = const UserModuleHome(),
    this.editProfilePage = const UserModuleEditProfile(),
    this.accountPage = const UserModuleAccount(),
    this.reauthPage = const UserModuleAccountReauth(),
    this.editEmailPage = const UserModuleAccountEditEmail(),
    this.editPasswordPage = const UserModuleAccountEditPassword(),
    this.blockListPage = const UserModuleAccountBlockList(),
  }) : super(
          enabled: enabled,
          title: title,
          routePath: routePath,
          queryPath: queryPath,
          query: query,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig> get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => homePage),
      "/$routePath/edit": RouteConfig((_) => editProfilePage),
      "/$routePath/{user_id}": RouteConfig((_) => homePage),
      "/$routePath/account": RouteConfig((_) => accountPage),
      "/$routePath/account/reauth": RouteConfig((_) => reauthPage),
      "/$routePath/account/email": RouteConfig((_) => editEmailPage),
      "/$routePath/account/password": RouteConfig((_) => editPasswordPage),
      "/$routePath/account/block": RouteConfig((_) => blockListPage),
    };

    return route;
  }

  /// ページ設定。
  final Widget homePage;
  final PageModuleWidget<UserModule> editProfilePage;
  final PageModuleWidget<UserModule> accountPage;
  final PageModuleWidget<UserModule> reauthPage;
  final PageModuleWidget<UserModule> editEmailPage;
  final PageModuleWidget<UserModule> editPasswordPage;
  final PageModuleWidget<UserModule> blockListPage;

  /// 追加ウィジェット。
  final Widget? meta;
  final List<Widget> bottom;

  /// ホームをスライバーレイアウトにする場合True.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// ホームのときのバックボタンを削除するかどうか。
  final bool automaticallyImplyLeadingOnHome;

  /// ツールバーの高さ
  final double expandedHeight;

  /// メインコンテンツ。
  final List<ModuleWidget<UserModule>> contents;

  /// アカウント用コンテンツ。
  final List<ModuleWidget<UserModule>> accountContents;

  /// タイトルのキー。
  final String nameKey;

  /// イメージのキー。
  final String imageKey;

  /// アイコンのキー。
  final String iconKey;

  /// ユーザーの紹介文などを有効化する場合True.
  final bool enableText;

  /// テキストのキー。
  final String textKey;

  /// 通報ユーザーへのパス。
  final String reportPath;

  /// ブロックユーザーへのパス。
  final String blockPath;

  /// ゲストの名前。
  final String guestName;

  /// ユーザーのフィーチャー画像が編集可能な場合`true`.
  final bool enableImageEditing;

  /// フォロー機能を利用する場合`true`。
  final bool enableFollow;

  /// ブロック機能を有効にする場合`true`。
  final bool enableBlock;

  /// 通報機能を有効にする場合`true`。
  final bool enableReport;

  /// ユーザーの削除を有効にする場合`true`。
  final bool enableUserDeleting;

  /// 表示する追加情報。
  final Map<String, String> additionalInformation;

  /// ユーザーの値情報。
  final List<VariableConfig> variables;

  /// ヘッダーの線を表示する場合True.
  final bool showHeaderDivider;
}

abstract class UserWidgetModule extends PageModule
    with VerifyAppReroutePageModuleMixin {
  const UserWidgetModule({
    String? id,
    bool enabled = true,
    String? title,
    ModelQuery? query,
    String routePath = "",
    String queryPath = "",
    Map<String, RouteConfig> routeSettings = const {},
    List<RerouteConfig> rerouteConfigs = const [],
    bool verifyAppReroute = false,
  }) : super(
          id: id,
          enabled: enabled,
          title: title,
          routePath: routePath,
          query: query,
          queryPath: queryPath,
          routeSettings: routeSettings,
          verifyAppReroute: verifyAppReroute,
          rerouteConfigs: rerouteConfigs,
        );
  List<String> get enableRoles;
  Widget build(BuildContext context);
}

class UserModuleHome extends PageModuleWidget<UserModule> {
  const UserModuleHome();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserModule module) {
    final userId = context.get("user_id", context.model?.userId ?? "");
    final user = ref.watchDocumentModel("${module.queryPath}/$userId");
    final name = user.get(module.nameKey, module.guestName.localize());
    final text = user.get(module.textKey, "");
    final image = user.get(module.imageKey, "");
    final icon = user.get(module.iconKey, "");
    final own = userId == context.model?.userId;

    if (userId.isEmpty) {
      return UIScaffold(
        appBar: const UIAppBar(),
        body: Center(
          child: Text("No data.".localize()),
        ),
      );
    }

    final report = ref.watchDocumentModel("${module.reportPath}/$userId");
    final block = ref.watchDocumentModel(
        "${module.queryPath}/${context.model?.userId}/${module.blockPath}/$userId");

    if (block.isNotEmpty) {
      return UIScaffold(
        appBar: UIAppBar(
          title: Text(name),
          sliverLayoutWhenModernDesign:
              module.sliverLayoutWhenModernDesignOnHome,
          automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
        ),
        body: Center(
          child: Text(
            "This %s has already been blocked."
                .localize()
                .format(["User".localize()]),
          ),
        ),
      );
    }

    return UIScaffold(
      waitTransition: true,
      designType: DesignType.modern,
      loadingFutures: [
        user.loading,
      ],
      appBar: UIModernDetailAppBar(
        designType: DesignType.modern,
        expandedHeight: module.expandedHeight,
        icon: NetworkOrAsset.image(icon, ImageSize.thumbnail),
        automaticallyImplyLeading:
            !own || module.automaticallyImplyLeadingOnHome,
        backgroundImage: image.isNotEmpty
            ? NetworkOrAsset.image(image, ImageSize.large)
            : null,
        bottomActions: [
          if (own)
            TextButton(
              onPressed: () {
                context.rootNavigator.pushNamed(
                  "/${module.routePath}/edit",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              child: Text("Edit Profile".localize()),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: StadiumBorder(
                  side: BorderSide(color: context.theme.textColor, width: 2),
                ),
                primary: context.theme.textColor,
                backgroundColor: context.theme.scaffoldBackgroundColor,
              ),
            )
          else if (module.enableFollow)
            TextButton(
              onPressed: () {},
              child: Text("Follow".localize()),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: StadiumBorder(
                    side: BorderSide(color: context.theme.textColor, width: 2)),
                primary: context.theme.textColor,
                backgroundColor: context.theme.scaffoldBackgroundColor,
              ),
            )
        ],
        title: Text(name),
        actions: [
          if (!own) ...[
            if (module.enableBlock)
              IconButton(
                icon: const Icon(FontAwesomeIcons.ban),
                onPressed: () {
                  if (block.isNotEmpty) {
                    UIDialog.show(
                      context,
                      title: "Error".localize(),
                      text: "This %s has already been blocked."
                          .localize()
                          .format(["User".localize()]),
                      submitText: "Back".localize(),
                      onSubmit: () {
                        context.navigator.pop();
                      },
                    );
                    return;
                  }
                  UIConfirm.show(
                    context,
                    title: "Confirmation".localize(),
                    text: "You will block this %s. Are you sure?"
                        .localize()
                        .format(["User".localize()]),
                    submitText: "Yes".localize(),
                    cacnelText: "No".localize(),
                    onSubmit: () async {
                      try {
                        block[Const.user] = context.model?.userId;
                        await context.model
                            ?.saveDocument(block)
                            .showIndicator(context);
                        UIDialog.show(
                          context,
                          title: "Success".localize(),
                          text: "You have blocked this %s."
                              .localize()
                              .format(["User".localize()]),
                          submitText: "Back".localize(),
                          onSubmit: () {
                            context.navigator.pop();
                          },
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
                  );
                },
              ),
            if (module.enableReport)
              IconButton(
                icon: const Icon(FontAwesomeIcons.flag),
                onPressed: () {
                  UIConfirm.show(
                    context,
                    title: "Confirmation".localize(),
                    text: "You will report this %s. Are you sure?"
                        .localize()
                        .format(["User".localize()]),
                    submitText: "Yes".localize(),
                    cacnelText: "No".localize(),
                    onSubmit: () async {
                      try {
                        final count = report.get(Const.count, 0);
                        report[Const.count] = count + 1;
                        await context.model
                            ?.saveDocument(report)
                            .showIndicator(context);
                        UIDialog.show(
                          context,
                          title: "Success".localize(),
                          text: "You have reported this %s."
                              .localize()
                              .format(["User".localize()]),
                          submitText: "Close".localize(),
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
                  );
                },
              )
          ],
        ],
      ),
      body: UIListView(
        children: [
          Indent(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            children: [
              Text(name, style: context.theme.textTheme.headline5),
              if (module.enableText) ...[
                const Space.height(8),
                Text(text),
              ],
              if (module.meta != null) ...[
                const Space.height(16),
                module.meta!,
              ],
            ],
          ),
          ...context.app?.userVariables
                  .buildView(context: context, ref: ref, data: user) ??
              [],
          ...module.variables.buildView(context: context, ref: ref, data: user),
          ...module.contents,
          if (module.showHeaderDivider) const Divid(),
          ...module.bottom,
          const Space.height(120),
        ],
      ),
    );
  }
}

class UserModuleEditProfile extends PageModuleWidget<UserModule> {
  const UserModuleEditProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserModule module) {
    final form = ref.useForm();
    final user =
        ref.watchDocumentModel("${module.queryPath}/${context.model?.userId}");
    final image = user.get(module.imageKey, "");
    final icon = user.get(module.iconKey, "");
    final variables = _buildVariables(context, module);

    return UIScaffold(
      appBar: UIAppBar(
        sliverLayoutWhenModernDesign: false,
        title: Text("Edit Profile".localize()),
      ),
      body: FutureBuilder(
        future: Future.value(user.loading),
        builder: (context, state) {
          if (state.connectionState != ConnectionState.done) {
            return ConstrainedBox(
              constraints:
                  BoxConstraints.expand(height: module.expandedHeight - 16),
              child: Stack(
                children: [
                  Container(
                    constraints: BoxConstraints.expand(
                        height: module.expandedHeight - 56),
                    color: module.enableImageEditing
                        ? context.theme.disabledColor
                        : (context.theme.appBarTheme.backgroundColor ??
                            (context.theme.colorScheme.brightness ==
                                    Brightness.dark
                                ? context.theme.colorScheme.surface
                                : context.theme.colorScheme.primary)),
                  ),
                  Positioned(
                    left: 24,
                    bottom: 0,
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.theme.scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return FormBuilder(
            key: form.key,
            padding: const EdgeInsets.all(0),
            children: [
              ConstrainedBox(
                constraints:
                    BoxConstraints.expand(height: module.expandedHeight - 16),
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints.expand(
                          height: module.expandedHeight - 56),
                      decoration: BoxDecoration(
                        color: module.enableImageEditing
                            ? context.theme.disabledColor
                            : (context.theme.appBarTheme.backgroundColor ??
                                (context.theme.colorScheme.brightness ==
                                        Brightness.dark
                                    ? context.theme.colorScheme.surface
                                    : context.theme.colorScheme.primary)),
                        image: module.enableImageEditing
                            ? DecorationImage(
                                image: NetworkOrAsset.image(
                                    image, ImageSize.large),
                                fit: BoxFit.cover,
                                colorFilter: const ColorFilter.mode(
                                  Colors.black87,
                                  BlendMode.color,
                                ),
                              )
                            : null,
                      ),
                      child: module.enableImageEditing
                          ? InkWell(
                              onTap: () async {
                                final media =
                                    await context.platform?.mediaDialog(
                                  context,
                                  title: "Please select your %s"
                                      .localize()
                                      .format(
                                          ["Media".localize().toLowerCase()]),
                                  type: PlatformMediaType.image,
                                );
                                if (media?.path == null) {
                                  return;
                                }

                                final url = await context.model
                                    ?.uploadMedia(media!.path!)
                                    .showIndicator(context);
                                user[module.imageKey] = url;
                                await context.model
                                    ?.saveDocument(user)
                                    .showIndicator(context);
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: const [
                                  ColoredBox(color: Colors.black54),
                                  Icon(Icons.add_a_photo,
                                      color: Colors.white, size: 48),
                                ],
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      left: 24,
                      bottom: 0,
                      child: Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.theme.scaffoldBackgroundColor,
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkOrAsset.image(icon, ImageSize.thumbnail),
                          child: InkWell(
                            onTap: () async {
                              final media = await context.platform?.mediaDialog(
                                context,
                                title: "Please select your %s"
                                    .localize()
                                    .format(["Media".localize().toLowerCase()]),
                                type: PlatformMediaType.image,
                              );
                              if (media?.path == null) {
                                return;
                              }

                              final url = await context.model
                                  ?.uploadMedia(media!.path!)
                                  .showIndicator(context);
                              user[module.iconKey] = url;
                              await context.model
                                  ?.saveDocument(user)
                                  .showIndicator(context);
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: const [
                                ClipOval(
                                    child: ColoredBox(color: Colors.black54)),
                                Icon(Icons.add_a_photo,
                                    color: Colors.white, size: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Space.height(24),
              ...variables.buildForm(context: context, ref: ref, data: user),
              const Divid(),
              const Space.height(240),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: Text("Submit".localize()),
        onPressed: () async {
          if (!form.validate()) {
            return;
          }

          try {
            variables.setValue(
              target: user,
              context: context,
              ref: ref,
              updated: true,
            );
            await context.model?.saveDocument(user).showIndicator(context);
            UIDialog.show(
              context,
              title: "Success".localize(),
              text:
                  "%s is completed.".localize().format(["Editing".localize()]),
              submitText: "Back".localize(),
              onSubmit: () {
                context.navigator.pop();
              },
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
    );
  }

  List<VariableConfig> _buildVariables(
      BuildContext context, UserModule module) {
    final variables = <VariableConfig>[
      ...context.app?.userVariables ?? [],
      ...module.variables,
    ];
    if (variables.isEmpty) {
      return [
        VariableConfigDefinition.name.copyWith(show: false),
        if (module.enableText)
          VariableConfigDefinition.text.copyWith(show: false),
      ];
    } else {
      return variables;
    }
  }
}

class UserModuleAccount extends PageModuleWidget<UserModule> {
  const UserModuleAccount();
  @override
  Widget build(BuildContext context, WidgetRef ref, UserModule module) {
    return UIScaffold(
      appBar: UIAppBar(
        title: Text(module.title ?? "Account".localize()),
        sliverLayoutWhenModernDesign: module.sliverLayoutWhenModernDesignOnHome,
        automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
      ),
      body: PlatformScrollbar(
        child: ListView(
          children: module.accountContents,
        ),
      ),
    );
  }
}

class UserModuleAccountContent extends ModuleWidget<UserModule> {
  const UserModuleAccountContent();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserModule module) {
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
                  context.navigator.pushNamed(
                    "/${module.routePath}/account/reauth",
                    arguments: RouteQuery(
                      parameters: {
                        "redirect_to": "/${module.routePath}/account/email"
                      },
                    ),
                  );
                  return;
                }
                context.navigator
                    .pushNamed("/${module.routePath}/account/email");
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
                    "/${module.routePath}/account/reauth",
                    arguments: RouteQuery(
                      parameters: {
                        "redirect_to": "/${module.routePath}/account/password"
                      },
                    ),
                  );
                  return;
                }
                context.navigator
                    .pushNamed("/${module.routePath}/account/password");
              },
            ),
          ),
          Headline("Menu".localize()),
          if (module.enableBlock)
            ListItem(
              title: Text("%s list".localize().format(["Block".localize()])),
              onTap: () {
                context.navigator
                    .pushNamed("/${module.routePath}/account/block");
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
          if (module.enableUserDeleting)
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

class UserModuleAccountReauth extends PageModuleWidget<UserModule> {
  const UserModuleAccountReauth();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserModule module) {
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

class UserModuleAccountEditEmail extends PageModuleWidget<UserModule> {
  const UserModuleAccountEditEmail();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserModule module) {
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

class UserModuleAccountEditPassword extends PageModuleWidget<UserModule> {
  const UserModuleAccountEditPassword();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserModule module) {
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

class UserModuleAccountBlockList extends PageModuleWidget<UserModule> {
  const UserModuleAccountBlockList();

  @override
  Widget build(BuildContext context, WidgetRef ref, UserModule module) {
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
