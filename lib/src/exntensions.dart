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
  TabConfig? toTabConfig() {
    return TabConfig._fromMap(this);
  }

  FormConfig? toFormConfig() {
    return FormConfig._fromMap(this);
  }
}
