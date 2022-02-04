import 'package:masamune_module/masamune_module.dart';

@immutable
class UserModule extends PageModule {
  const UserModule({
    bool enabled = true,
    String title = "",
    this.contents = const [],
    this.routePath = "user",
    this.queryPath = "user",
    this.reportPath = "report",
    this.blockPath = "block",
    this.nameKey = Const.name,
    this.textKey = Const.text,
    this.imageKey = Const.image,
    this.iconKey = Const.icon,
    this.roleKey = Const.role,
    this.guestName = "Guest",
    this.expandedHeight = 160,
    this.additionalInformation = const {},
    this.allowImageEditing = false,
    this.allowFollow = false,
    this.allowBlock = true,
    this.allowReport = true,
    this.sliverLayoutWhenModernDesignOnHome = true,
    this.automaticallyImplyLeadingOnHome = true,
    this.showHeaderDivider = true,
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
    this.variables = const [],
    this.meta,
    this.bottom = const [],
    this.homePage = const UserModuleHome(),
    this.editProfilePage = const UserModuleEditProfile(),
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
      "/$routePath": RouteConfig((_) => homePage),
      "/$routePath/edit": RouteConfig((_) => editProfilePage),
      "/$routePath/{user_id}": RouteConfig((_) => homePage),
      ...contents
          .expandAndRemoveEmpty<MapEntry<String, RouteConfig>>(
              (item) => item.routeSettings.entries)
          .toMap<String, RouteConfig>(
              key: (item) => item.key, value: (item) => item.value)
    };

    return route;
  }

  /// ページ設定。
  final Widget homePage;
  final PageModuleWidget<UserModule> editProfilePage;

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
  final List<UserWidgetModule> contents;

  /// ルートのパス。
  final String routePath;

  /// ユーザーのデータパス。
  final String queryPath;

  /// タイトルのキー。
  final String nameKey;

  /// イメージのキー。
  final String imageKey;

  /// アイコンのキー。
  final String iconKey;

  /// テキストのキー。
  final String textKey;

  /// 権限のキー。
  final String roleKey;

  /// 通報ユーザーへのパス。
  final String reportPath;

  /// ブロックユーザーへのパス。
  final String blockPath;

  /// ゲストの名前。
  final String guestName;

  /// ユーザーのフィーチャー画像が編集可能な場合`true`.
  final bool allowImageEditing;

  /// フォロー機能を利用する場合`true`。
  final bool allowFollow;

  /// ブロック機能を有効にする場合`true`。
  final bool allowBlock;

  /// 通報機能を有効にする場合`true`。
  final bool allowReport;

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
    Map<String, RouteConfig> routeSettings = const {},
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
    bool verifyAppReroute = false,
  }) : super(
          id: id,
          enabled: enabled,
          title: title,
          routeSettings: routeSettings,
          permission: permission,
          verifyAppReroute: verifyAppReroute,
          rerouteConfigs: rerouteConfigs,
        );
  List<String> get allowRoles;
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
    final roles = context.roles;
    final role = roles
        .firstWhereOrNull((item) => user.get(module.roleKey, "") == item.id);
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
          else if (module.allowFollow)
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
            if (module.allowBlock)
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
            if (module.allowReport)
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
              if (role != null) ...[
                Text(
                  role.label.localize(""),
                  style: context.theme.textTheme.caption
                      ?.copyWith(color: context.theme.dividerColor),
                ),
                const Space.height(4),
              ],
              const Space.height(8),
              Text(text),
              if (module.meta != null) ...[
                const Space.height(16),
                module.meta!,
              ],
            ],
          ),
          ...context.app?.userVariables.buildView(context, ref, data: user) ??
              [],
          ...module.variables.buildView(context, ref, data: user),
          ...module.contents.mapAndRemoveEmpty((item) {
            if (role != null &&
                role.id.isNotEmpty &&
                item.allowRoles.isNotEmpty &&
                !item.allowRoles.contains(role.id)) {
              return null;
            }
            return item.build(context);
          }),
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
                    color: module.allowImageEditing
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
                        color: module.allowImageEditing
                            ? context.theme.disabledColor
                            : (context.theme.appBarTheme.backgroundColor ??
                                (context.theme.colorScheme.brightness ==
                                        Brightness.dark
                                    ? context.theme.colorScheme.surface
                                    : context.theme.colorScheme.primary)),
                        image: module.allowImageEditing
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
                      child: module.allowImageEditing
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
              ...variables.buildForm(context, ref, data: user),
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
            variables.buildValue(user, context, ref, updated: true);
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
        VariableConfigDefinition.text.copyWith(show: false),
      ];
    } else {
      return variables;
    }
  }
}
