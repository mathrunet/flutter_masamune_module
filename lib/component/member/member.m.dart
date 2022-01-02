// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

MemberModule? _$MemberModuleFromMap(DynamicMap map, MemberModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return MemberModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", null),
      routePath: map.get<String>("routePath", "member"),
      queryPath: map.get<String>("queryPath", "user"),
      query: map.get<DynamicMap>("query", <String, dynamic>{}).toModelQuery(),
      nameKey: map.get<String>("nameKey", Const.name),
      iconKey: map.get<String>("iconKey", Const.icon),
      roleKey: map.get<String>("roleKey", Const.role),
      profilePath: map.get<String>("profilePath", Const.user),
      formMessage: map.get<String?>("formMessage", null),
      groupId: map.get<String?>("groupId", null),
      affiliationKey: map.get<String>("affiliationKey", "affiliation"),
      sliverLayoutWhenModernDesignOnHome:
          map.get<bool>("sliverLayoutWhenModernDesignOnHome", true),
      automaticallyImplyLeadingOnHome:
          map.get<bool>("automaticallyImplyLeadingOnHome", true),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty(),
      designType: DesignType.values.firstWhere((e) =>
          e.index == map.get<int>("designType", DesignType.modern.index)),
      inviteType: MemberModuleInviteType.values.firstWhere((e) =>
          e.index ==
          map.get<int>("inviteType", MemberModuleInviteType.none.index)));
}

DynamicMap _$MemberModuleToMap(MemberModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.query != null) "query": ref.query?.toMap(),
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.iconKey.isNotEmpty) "iconKey": ref.iconKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.profilePath.isNotEmpty) "profilePath": ref.profilePath,
    if (ref.formMessage.isNotEmpty) "formMessage": ref.formMessage,
    if (ref.groupId.isNotEmpty) "groupId": ref.groupId,
    if (ref.affiliationKey.isNotEmpty) "affiliationKey": ref.affiliationKey,
    "sliverLayoutWhenModernDesignOnHome":
        ref.sliverLayoutWhenModernDesignOnHome,
    "automaticallyImplyLeadingOnHome": ref.automaticallyImplyLeadingOnHome,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap()),
    "designType": ref.designType.index,
    "inviteType": ref.inviteType.index
  };
}
