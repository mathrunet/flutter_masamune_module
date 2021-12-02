part of masamune_module;

// extension BuildContextModelExtensions on BuildContext {
//   DynamicDocumentModel readDocumentModel(String path) {
//     return model!.loadDocument(
//       read(model!.documentProvider(path)),
//     );
//   }

//   DynamicCollectionModel readCollectionModel(String path) {
//     return model!.loadCollection(
//       read(model!.collectionProvider(path)),
//     );
//   }

//   DynamicDocumentModel readUserDocumentModel([String userPath = Const.user]) {
//     return model!.loadDocument(
//       read(model!.documentProvider("$userPath/${model?.userId}")),
//     );
//   }
// }

extension MasamuneModuleDynamicMapExtensions on DynamicMap {
  GroupConfig? toGroupConfig() {
    return GroupConfig._fromMap(this);
  }

  FormConfig? toFormConfig() {
    return FormConfig._fromMap(this);
  }
  
  LoginConfig? toLoginConfig() {
    return LoginConfig._fromMap(this);
  }
}

extension ModuleTagsWidgetRefExtensions on WidgetRef {
  static final _converter = RegExp(r"\{([^\{\}]+?)\}");
  String applyModuleTag(String path) {
    final context = this as BuildContext;

    int i = 0;
    while (path.contains("{") || path.contains("}")) {
      path = path.replaceAllMapped(
        _converter,
        (match) {
          final command = match.group(1);
          if (command.isEmpty || !command!.contains(":")) {
            return "";
          }
          final split = command.split(":");
          final key = split.first;
          switch (key) {
            case "context":
              return context[split.last]?.toString() ?? "";
            case "user":
              switch (split.last) {
                case "id":
                  return context.model?.userId ?? "";
                default:
                  final doc = context.model!.loadDocument(
                    watch(context.model!.documentProvider(
                        "${Const.user}/${context.model?.userId}")),
                  );
                  return doc.get<dynamic>(split.last, "").toString();
              }
            case "document":
              if (split.length < 3) {
                return "";
              }
              final doc = context.model!.loadDocument(
                watch(context.model!.documentProvider(split[1])),
              );
              return doc.get<dynamic>(split.last, "").toString();
            case "collection":
              if (split.length < 3) {
                return "";
              }
              final col = context.model!.loadCollection(
                watch(context.model!.collectionProvider(split[1])),
              );
              return col
                  .mapAndRemoveEmpty(
                      (item) => item.get<dynamic>(split.last, "").toString())
                  .join(",");
          }
          return "";
        },
      );
      i++;
      if (i > 10) {
        break;
      }
    }
    return path;
  }
}
