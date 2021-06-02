part of masamune_module;

extension BuildContextModelExtensions on BuildContext {
  DynamicDocumentModel readDocumentModel(String path) {
    return adapter!.loadDocument(
      read(adapter!.documentProvider(path)),
    );
  }

  DynamicCollectionModel readCollectionModel(String path) {
    return adapter!.loadCollection(
      read(adapter!.collectionProvider(path)),
    );
  }

  DynamicDocumentModel readUserDocumentModel([String userPath = Const.user]) {
    return adapter!.loadDocument(
      read(adapter!.documentProvider("$userPath/${adapter?.userId}")),
    );
  }
}
