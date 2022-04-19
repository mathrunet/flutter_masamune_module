import 'package:masamune_module/masamune_module.dart';

enum MemberModuleInviteType {
  none,
  email,
}

@immutable
class MemberModule extends PageModule {
  const MemberModule({
    bool enabled = true,
    String? title,
    this.routePath = "member",
    this.queryPath = "user",
    this.query,
    this.nameKey = Const.name,
    this.iconKey = Const.icon,
    this.profilePath = Const.user,
    this.formMessage,
    this.groupId,
    this.affiliationKey = "affiliation",
    this.sliverLayoutWhenModernDesignOnHome = true,
    this.automaticallyImplyLeadingOnHome = true,
    List<RerouteConfig> rerouteConfigs = const [],
    this.homePage = const MemberModuleHome(),
    this.invitePage = const MemberModuleInvite(),
    this.designType = DesignType.modern,
    this.inviteType = MemberModuleInviteType.none,
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
      "/$routePath": RouteConfig((_) => homePage),
      "/$routePath/invite": RouteConfig((_) => invitePage),
    };
    return route;
  }

  // Page settings.
  final PageModuleWidget<MemberModule> homePage;
  final PageModuleWidget<MemberModule> invitePage;

  /// ホームをスライバーレイアウトにする場合True.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// ホームのときのバックボタンを削除するかどうか。
  final bool automaticallyImplyLeadingOnHome;

  /// Design type.
  final DesignType designType;

  /// Route path.
  final String routePath;

  /// Query path.
  final String queryPath;

  /// Query.
  final ModelQuery? query;

  /// タイトルのキー。
  final String nameKey;

  /// アイコンのキー。
  final String iconKey;

  /// プロフィールへのパス。
  final String profilePath;

  /// 招待のタイプ。
  final MemberModuleInviteType inviteType;

  /// 所属リストのキー。
  final String affiliationKey;

  /// グループID.
  final String? groupId;

  /// フォームのメッセージ。
  final String? formMessage;
}

class MemberModuleHome extends PageModuleWidget<MemberModule> {
  const MemberModuleHome();

  String _groupId(BuildContext context, WidgetRef ref, MemberModule module) {
    if (module.groupId.isEmpty) {
      final user = ref.watchUserDocumentModel();
      return user.uid;
    }
    return ref.applyModuleTag(module.groupId!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref, MemberModule module) {
    // Please describe Hook.
    final members =
        ref.watchCollectionModel(module.query?.value ?? module.queryPath);
    final groupId = _groupId(context, ref, module);
    final user = ref.watchUserDocumentModel();

    // Please describe the Widget.
    return UIScaffold(
      waitTransition: true,
      loadingFutures: [
        members.loading,
        user.loading,
      ],
      appBar: UIAppBar(
        title: Text(
            module.title ?? "%s list".localize().format(["Member".localize()])),
        sliverLayoutWhenModernDesign: module.sliverLayoutWhenModernDesignOnHome,
        automaticallyImplyLeading: module.automaticallyImplyLeadingOnHome,
      ),
      body: UIListBuilder<DynamicMap>(
        source: members,
        builder: (context, item, index) {
          return [
            ListItem(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkOrAsset.image(item.get(module.iconKey, "")),
                backgroundColor: context.theme.disabledColor,
              ),
              title: Text(item.get(module.nameKey, "")),
              trailing: item.uid == user.uid
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        UIConfirm.show(
                          context,
                          title: "Confirmation".localize(),
                          text:
                              "You will remove this %s from the list. Are you sure?"
                                  .localize()
                                  .format(["User".localize()]),
                          submitText: "Yes".localize(),
                          cacnelText: "No".localize(),
                          onSubmit: () async {
                            final doc = members
                                .firstWhereOrNull((e) => e.uid == item.uid);
                            if (doc == null) {
                              return;
                            }
                            final affiliation = List<String>.from(
                              item.getAsList(module.affiliationKey, []),
                            );
                            if (affiliation.isEmpty ||
                                !affiliation.contains(groupId)) {
                              return UIDialog.show(
                                context,
                                title: "Error".localize(),
                                text: "This %s has already been removed."
                                    .localize()
                                    .format(["User".localize()]),
                                submitText: "Close".localize(),
                              );
                            }
                            doc[module.affiliationKey] = affiliation
                              ..remove(groupId);
                            await context.model
                                ?.saveDocument(doc)
                                .showIndicator(context);
                            UIDialog.show(
                              context,
                              title: "Success".localize(),
                              text: "You have removed this %s from the list."
                                  .localize()
                                  .format(["User".localize()]),
                              submitText: "Close".localize(),
                            );
                          },
                        );
                      },
                    ),
              onTap: () {
                ref.navigator.pushNamed(
                  "/${module.profilePath}/${item.uid}",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
            )
          ];
        },
      ),
      floatingActionButton: module.inviteType == MemberModuleInviteType.none
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                ref.navigator.pushNamed(
                  "/${module.routePath}/invite",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              label: Text("Invite".localize()),
              icon: const Icon(Icons.email),
            ),
    );
  }
}

class MemberModuleInvite extends PageModuleWidget<MemberModule> {
  const MemberModuleInvite();

  @override
  Widget build(BuildContext context, WidgetRef ref, MemberModule module) {
    final form = ref.useForm();

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(title: Text("Invite".localize())),
      body: FormBuilder(
        key: form.key,
        type: _type(context, module),
        padding: const EdgeInsets.all(0),
        children: _form(context, ref, module),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          switch (module.inviteType) {
            case MemberModuleInviteType.email:
            default:
          }
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }

  FormBuilderType _type(BuildContext context, MemberModule module) {
    switch (module.inviteType) {
      case MemberModuleInviteType.email:
      default:
        return FormBuilderType.center;
    }
  }

  List<Widget> _form(BuildContext context, WidgetRef ref, MemberModule module) {
    switch (module.inviteType) {
      case MemberModuleInviteType.email:
        return [
          MessageBox(
            module.formMessage ??
                "An invitation email will be sent to the email address you entered. You can complete the invitation by clicking the link in the invitation email."
                    .localize(),
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          ),
          DividHeadline("Email".localize()),
          FormItemTextField(
            dense: true,
            controller: ref.useTextEditingController("email"),
            hintText: "Input %s".localize().format(["Email".localize()]),
            errorText: "No input %s".localize().format(["Email".localize()]),
            onSaved: (value) {
              context["email"] = value;
            },
          ),
          const Divid(),
        ];
      default:
        return [];
    }
  }
}
