import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masamune/masamune.dart';
import 'package:masamune_module/masamune_module.dart';

part 'user.m.dart';

@module
@immutable
class UserModule extends PageModule with VerifyAppReroutePageModuleMixin {
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
    this.additionalInformation = const {},
    this.allowImageEditing = false,
    this.allowFollow = false,
    this.allowBlock = true,
    this.allowReport = true,
    Permission permission = const Permission(),
    RerouteConfig? rerouteConfig,
    this.home,
    this.editProfile,
  }) : super(
          enabled: enabled,
          title: title,
          permission: permission,
          rerouteConfig: rerouteConfig,
        );

  @override
  Map<String, RouteConfig>? get routeSettings {
    if (!enabled) {
      return const {};
    }
    final route = {
      "/$routePath": RouteConfig((_) => home ?? UserModuleHome(this)),
      "/$routePath/edit":
          RouteConfig((_) => editProfile ?? UserModuleEditProfile(this)),
      "/$routePath/{user_id}": RouteConfig((_) => home ?? UserModuleHome(this)),
      ...contents
          .expandAndRemoveEmpty<MapEntry<String, RouteConfig>>((item) =>
              item.routeSettings?.entries ?? <MapEntry<String, RouteConfig>>[])
          .toMap<String, RouteConfig>(
              key: (item) => item.key, value: (item) => item.value)
    };

    return route;
  }

  /// ページ設定。
  final Widget? home;
  final Widget? editProfile;

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

  @override
  UserModule? fromMap(DynamicMap map) => _$UserModuleFromMap(map, this);
  @override
  DynamicMap toMap() => _$UserModuleToMap(this);
}

abstract class UserWidgetModule extends PageModule
    with VerifyAppReroutePageModuleMixin {
  const UserWidgetModule({
    String? id,
    bool enabled = true,
    String? title,
    Map<String, RouteConfig>? routeSettings,
    Permission permission = const Permission(),
    RerouteConfig? rerouteConfig,
    bool verifyAppReroute = false,
  }) : super(
          id: id,
          enabled: enabled,
          title: title,
          routeSettings: routeSettings,
          permission: permission,
          verifyAppReroute: verifyAppReroute,
          rerouteConfig: rerouteConfig,
        );
  List<String> get allowRoles;
  Widget build(BuildContext context);
}

class UserModuleHome extends PageHookWidget {
  const UserModuleHome(this.config);
  final UserModule config;

  @override
  Widget build(BuildContext context) {
    final userId = context.get("user_id", context.model?.userId ?? "");
    final user = useDocumentModel("${config.queryPath}/$userId");
    final name = user.get(config.nameKey, "");
    final text = user.get(config.textKey, "");
    final image = user.get(config.imageKey, "");
    final icon = user.get(config.iconKey, "");
    final roles = context.roles;
    final role = roles
        .firstWhereOrNull((item) => user.get(config.roleKey, "") == item.id);
    final own = userId == context.model?.userId;

    if (userId.isEmpty) {
      return UIScaffold(
        appBar: const UIAppBar(),
        body: Center(
          child: Text("No data.".localize()),
        ),
      );
    }

    final report = useDocumentModel("${config.reportPath}/$userId");
    final block = useDocumentModel(
        "${config.queryPath}/${context.model?.userId}/${config.blockPath}/$userId");

    if (block.isNotEmpty) {
      return UIScaffold(
        appBar: UIAppBar(
          title: Text(name),
        ),
        body: Center(
          child: Text(
            "This user has already been blocked.".localize(),
          ),
        ),
      );
    }

    return UIScaffold(
      waitTransition: true,
      designType: DesignType.modern,
      loadingFutures: [
        user.future,
      ],
      appBar: UIUserProfileAppBar(
        designType: DesignType.modern,
        expandedHeight: 160,
        icon: NetworkOrAsset.image(icon),
        backgroundImage: image.isNotEmpty ? NetworkOrAsset.image(image) : null,
        bottomActions: [
          if (own)
            TextButton(
              onPressed: () {
                context.navigator.pushNamed("/${config.routePath}/edit");
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
          else if (config.allowFollow)
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
            if (config.allowBlock)
              IconButton(
                icon: const Icon(FontAwesomeIcons.ban),
                onPressed: () {
                  if (block.isNotEmpty) {
                    UIDialog.show(
                      context,
                      title: "Error".localize(),
                      text: "This user has already been blocked.".localize(),
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
                    text: "You will block this user. Are you sure?".localize(),
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
                          text: "You have blocked this user.".localize(),
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
            if (config.allowReport)
              IconButton(
                icon: const Icon(FontAwesomeIcons.flag),
                onPressed: () {
                  UIConfirm.show(
                    context,
                    title: "Confirmation".localize(),
                    text: "You will report this user. Are you sure?".localize(),
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
                          text: "You have reported this user.".localize(),
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
            ],
          ),
          ...config.contents.mapAndRemoveEmpty((item) {
            if (role != null &&
                role.id.isNotEmpty &&
                item.allowRoles.isNotEmpty &&
                !item.allowRoles.contains(role.id)) {
              return null;
            }
            return item.build(context);
          }),
        ],
      ),
    );
  }
}

class UserModuleEditProfile extends PageHookWidget {
  const UserModuleEditProfile(this.config);
  final UserModule config;

  @override
  Widget build(BuildContext context) {
    final form = useForm();
    final user =
        useDocumentModel("${config.queryPath}/${context.model?.userId}");
    final name = user.get(config.nameKey, "");
    final text = user.get(config.textKey, "");
    final image = user.get(config.imageKey, "");
    final icon = user.get(config.iconKey, "");

    return UIScaffold(
      waitTransition: true,
      loadingFutures: [
        user.future,
      ],
      appBar: UIAppBar(
        sliverLayoutWhenModernDesign: false,
        title: Text("Edit Profile".localize()),
      ),
      body: FormBuilder(
        key: form.key,
        padding: const EdgeInsets.all(0),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints.expand(height: 160),
            child: Stack(
              children: [
                Container(
                  constraints: const BoxConstraints.expand(height: 120),
                  decoration: BoxDecoration(
                    color: context.theme.disabledColor,
                    image: config.allowImageEditing
                        ? DecorationImage(
                            image: NetworkOrAsset.image(image),
                            fit: BoxFit.cover,
                            colorFilter: const ColorFilter.mode(
                              Colors.black87,
                              BlendMode.color,
                            ),
                          )
                        : null,
                  ),
                  child: config.allowImageEditing
                      ? InkWell(
                          onTap: () async {
                            final media = await context.platform?.mediaDialog(
                              context,
                              title: "Please select your media".localize(),
                              type: PlatformMediaType.image,
                            );
                            if (media?.path == null) {
                              return;
                            }

                            final url = await context.model
                                ?.uploadMedia(media?.path)
                                .showIndicator(context);
                            user[config.iconKey] = url;
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
                      backgroundImage: NetworkOrAsset.image(icon),
                      child: InkWell(
                        onTap: () async {
                          final media = await context.platform?.mediaDialog(
                            context,
                            title: "Please select your media".localize(),
                            type: PlatformMediaType.image,
                          );
                          if (media?.path == null) {
                            return;
                          }

                          final url = await context.model
                              ?.uploadMedia(media?.path)
                              .showIndicator(context);
                          user[config.iconKey] = url;
                          await context.model
                              ?.saveDocument(user)
                              .showIndicator(context);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: const [
                            ClipOval(child: ColoredBox(color: Colors.black54)),
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
          DividHeadline("Name".localize()),
          FormItemTextField(
            dense: true,
            controller: useMemoizedTextEditingController(name),
            hintText: "Input %s".localize().format(["Name".localize()]),
            errorText: "No input %s".localize().format(["Name".localize()]),
            onSaved: (value) {
              context[config.nameKey] = value;
            },
          ),
          DividHeadline("Text".localize()),
          FormItemTextField(
            dense: true,
            controller: useMemoizedTextEditingController(text),
            hintText: "Input %s".localize().format(["Text".localize()]),
            errorText: "No input %s".localize().format(["Text".localize()]),
            allowEmpty: true,
            minLines: 5,
            maxLines: 10,
            onSaved: (value) {
              context[config.textKey] = value;
            },
          ),
          const Divid(),
          const Space.height(240),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: Text("Submit".localize()),
        onPressed: () async {
          if (!form.validate()) {
            return;
          }

          try {
            user[config.nameKey] = context.get(config.nameKey, "");
            user[config.textKey] = context.get(config.textKey, "");
            await context.model?.saveDocument(user).showIndicator(context);
            UIDialog.show(
              context,
              title: "Success".localize(),
              text: "Editing is completed.".localize(),
              submitText: "Back".localize(),
              onSubmit: () {
                context.navigator.pop();
              },
            );
          } catch (e) {
            UIDialog.show(
              context,
              title: "Error".localize(),
              text: "Editing is not completed.".localize(),
              submitText: "Close".localize(),
            );
          }
        },
      ),
    );
  }
}
