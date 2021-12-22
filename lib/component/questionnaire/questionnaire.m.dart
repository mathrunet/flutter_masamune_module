// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire.dart';

// **************************************************************************
// MasamuneModuleGenerator
// **************************************************************************

QuestionnaireModule? _$QuestionnaireModuleFromMap(
    DynamicMap map, QuestionnaireModule ref) {
  if (map.isEmpty || map.get("type", "") != ref.type) {
    return null;
  }
  return QuestionnaireModule(
      enabled: map.get<bool>("enabled", true),
      title: map.get<String?>("title", "") ?? "",
      routePath: map.get<String>("routePath", "question"),
      queryPath: map.get<String>("queryPath", "question"),
      questionPath: map.get<String>("questionPath", "question"),
      answerPath: map.get<String>("answerPath", "answer"),
      userPath: map.get<String>("userPath", "user"),
      nameKey: map.get<String>("nameKey", Const.name),
      textKey: map.get<String>("textKey", Const.text),
      requiredKey: map.get<String>("requiredKey", Const.required),
      typeKey: map.get<String>("typeKey", Const.type),
      roleKey: map.get<String>("roleKey", Const.role),
      selectionKey: map.get<String>("selectionKey", Const.selection),
      createdTimeKey: map.get<String>("createdTimeKey", Const.createdTime),
      endTimeKey: map.get<String>("endTimeKey", Const.endTime),
      answerKey: map.get<String>("answerKey", Const.answer),
      permission: map.get<DynamicMap>(
              "permission", <String, dynamic>{}).toPermission() ??
          const Permission(),
      rerouteConfigs: map
          .get<List>("rerouteConfigs", const [])
          .cast<DynamicMap>()
          .map((e) => e.toRerouteConfig())
          .removeEmpty(),
      questionnaireQuery: map.get<DynamicMap>(
          "questionnaireQuery", <String, dynamic>{}).toModelQuery());
}

DynamicMap _$QuestionnaireModuleToMap(QuestionnaireModule ref) {
  return <String, dynamic>{
    "type": ref.type,
    "enabled": ref.enabled,
    if (ref.title.isNotEmpty) "title": ref.title,
    if (ref.routePath.isNotEmpty) "routePath": ref.routePath,
    if (ref.queryPath.isNotEmpty) "queryPath": ref.queryPath,
    if (ref.questionPath.isNotEmpty) "questionPath": ref.questionPath,
    if (ref.answerPath.isNotEmpty) "answerPath": ref.answerPath,
    if (ref.userPath.isNotEmpty) "userPath": ref.userPath,
    if (ref.nameKey.isNotEmpty) "nameKey": ref.nameKey,
    if (ref.textKey.isNotEmpty) "textKey": ref.textKey,
    if (ref.requiredKey.isNotEmpty) "requiredKey": ref.requiredKey,
    if (ref.typeKey.isNotEmpty) "typeKey": ref.typeKey,
    if (ref.roleKey.isNotEmpty) "roleKey": ref.roleKey,
    if (ref.selectionKey.isNotEmpty) "selectionKey": ref.selectionKey,
    if (ref.createdTimeKey.isNotEmpty) "createdTimeKey": ref.createdTimeKey,
    if (ref.endTimeKey.isNotEmpty) "endTimeKey": ref.endTimeKey,
    if (ref.answerKey.isNotEmpty) "answerKey": ref.answerKey,
    "permission": ref.permission.toMap(),
    if (ref.rerouteConfigs.isNotEmpty)
      "rerouteConfigs": ref.rerouteConfigs.map((e) => e.toMap()),
    if (ref.questionnaireQuery != null)
      "questionnaireQuery": ref.questionnaireQuery?.toMap()
  };
}
