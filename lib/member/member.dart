import 'package:masamune/masamune.dart';
import 'package:masamune_module/masamune_module.dart';

part 'member.m.dart';

enum MemberModuleInviteType {
  none,
  email,
}

@module
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
    this.roleKey = Const.role,
    this.profilePath = Const.user,
    this.formMessage,
    this.groupId,
    this.affiliationKey = "affiliation",
    Permission permission = const Permission(),
    RerouteConfig? rerouteConfig,
    this.home,
    this.invite,
    this.designType = DesignType.modern,
    this.inviteType = MemberModuleInviteType.none,
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
      "/$routePath": RouteConfig((_) => home ?? MemberModuleHome(this)),
      "/$routePath/invite":
          RouteConfig((_) => invite ?? MemberModuleInvite(this)),
    };
    return route;
  }

  // Page settings.
  final Widget? home;
  final Widget? invite;

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

  /// 権限のキー。
  final String roleKey;

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

  @override
  MemberModule? fromMap(DynamicMap map) => _$MemberModuleFromMap(map, this);

  @override
  DynamicMap toMap() => _$MemberModuleToMap(this);
}

class MemberModuleHome extends PageHookWidget {
  const MemberModuleHome(this.config);
  final MemberModule config;

  String _groupId(BuildContext context) {
    if (config.groupId.isEmpty) {
      final user = useUserDocumentModel();
      return user.uid;
    }
    return context.applyModuleTag(config.groupId!);
  }

  @override
  Widget build(BuildContext context) {
    // Please describe Hook.
    final members = useCollectionModel(config.query?.value ?? config.queryPath);
    final groupId = _groupId(context);
    final user = useUserDocumentModel();

    // Please describe the Widget.
    return UIScaffold(
      waitTransition: true,
      loadingFutures: [
        members.future,
        user.future,
      ],
      appBar: UIAppBar(
        title: Text(
            config.title ?? "%s list".localize().format(["Member".localize()])),
      ),
      body: UIListBuilder<DynamicMap>(
        source: members,
        builder: (context, item, index) {
          return [
            ListItem(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkOrAsset.image(item.get(config.iconKey, "")),
                backgroundColor: context.theme.disabledColor,
              ),
              title: Text(item.get(config.nameKey, "")),
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
                              item.getAsList(config.affiliationKey, []),
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
                            doc[config.affiliationKey] = affiliation
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
                context.navigator.pushNamed(
                  "/${config.profilePath}/${item.uid}",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
            )
          ];
        },
      ),
      floatingActionButton: config.inviteType == MemberModuleInviteType.none
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                context.navigator.pushNamed(
                  "/${config.routePath}/invite",
                  arguments: RouteQuery.fullscreenOrModal,
                );
              },
              label: Text("Invite".localize()),
              icon: const Icon(Icons.email),
            ),
    );
  }
}

class MemberModuleInvite extends PageHookWidget {
  const MemberModuleInvite(this.config);
  final MemberModule config;

  @override
  Widget build(BuildContext context) {
    final form = useForm();

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(title: Text("Invite".localize())),
      body: FormBuilder(
        key: form.key,
        type: _type(context),
        padding: const EdgeInsets.all(0),
        children: _form(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          switch (config.inviteType) {
            case MemberModuleInviteType.email:
            default:
          }
        },
        label: Text("Submit".localize()),
        icon: const Icon(Icons.check),
      ),
    );
  }

  FormBuilderType _type(BuildContext context) {
    switch (config.inviteType) {
      case MemberModuleInviteType.email:
      default:
        return FormBuilderType.center;
    }
  }

  List<Widget> _form(BuildContext context) {
    switch (config.inviteType) {
      case MemberModuleInviteType.email:
        return [
          MessageBox(
            config.formMessage ??
                "An invitation email will be sent to the email address you entered. You can complete the invitation by clicking the link in the invitation email."
                    .localize(),
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          ),
          DividHeadline("Email".localize()),
          FormItemTextField(
            dense: true,
            controller: useMemoizedTextEditingController(),
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
