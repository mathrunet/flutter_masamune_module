part of masamune_module;

extension WidgetRefModelExtensions on WidgetRef {
  DynamicDocumentModel readAsDocumentModel(String path) {
    final context = this as BuildContext;

    return context.model!.loadDocument(
      read(
        context.model!.documentProvider(applyModuleTag(path)),
      ),
    );
  }

  DynamicCollectionModel readAsCollectionModel(String path) {
    final context = this as BuildContext;

    return context.model!.loadCollection(
      read(
        context.model!.collectionProvider(applyModuleTag(path)),
      ),
    );
  }

  DynamicSearchableCollectionModel readAsSearchableCollectionModel(
      String path) {
    final context = this as BuildContext;

    return read(
      context.model!.searchableCollectionProvider(applyModuleTag(path)),
    );
  }

  DynamicDocumentModel readAsUserDocumentModel([String userPath = Const.user]) {
    final context = this as BuildContext;

    return context.model!.loadDocument(
      read(
        context.model!.documentProvider(
          applyModuleTag("$userPath/${context.model?.userId}"),
        ),
      ),
    );
  }

  DynamicDocumentModel watchAsDocumentModel(String path) {
    final context = this as BuildContext;

    return context.model!.loadDocument(
      watch(
        context.model!.documentProvider(
          applyModuleTag(path),
        ),
      ),
    );
  }

  DynamicCollectionModel watchAsCollectionModel(String path) {
    final context = this as BuildContext;

    return context.model!.loadCollection(
      watch(
        context.model!.collectionProvider(
          applyModuleTag(path),
        ),
      ),
    );
  }

  DynamicSearchableCollectionModel watchAsSearchableCollectionModel(
      String path) {
    final context = this as BuildContext;

    return watch(
      context.model!.searchableCollectionProvider(
        applyModuleTag(path),
      ),
    );
  }

  DynamicDocumentModel watchAsUserDocumentModel(
      [String userPath = Const.user]) {
    final context = this as BuildContext;

    return context.model!.loadDocument(
      watch(
        context.model!.documentProvider(
          applyModuleTag("$userPath/${context.model?.userId}"),
        ),
      ),
    );
  }
}
