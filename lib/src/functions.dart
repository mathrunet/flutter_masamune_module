part of masamune_module;

extension WidgetRefModelExtensions on WidgetRef {
  DynamicDocumentModel readDocumentModel(String path) {
    final context = this as BuildContext;

    return context.model!.loadDocument(
      read(
        context.model!.documentProvider(applyModuleTag(path)),
      ),
    );
  }

  DynamicCollectionModel readCollectionModel(String path) {
    final context = this as BuildContext;

    return context.model!.loadCollection(
      read(
        context.model!.collectionProvider(applyModuleTag(path)),
      ),
    );
  }

  DynamicSearchableCollectionModel readSearchableCollectionModel(String path) {
    final context = this as BuildContext;

    return read(
      context.model!.searchableCollectionProvider(applyModuleTag(path)),
    );
  }

  DynamicDocumentModel readUserDocumentModel([String userPath = Const.user]) {
    final context = this as BuildContext;

    return context.model!.loadDocument(
      read(
        context.model!.documentProvider(
          applyModuleTag("$userPath/${context.model?.userId}"),
        ),
      ),
    );
  }

  DynamicDocumentModel watchDocumentModel(String path) {
    final context = this as BuildContext;

    return context.model!.loadDocument(
      watch(
        context.model!.documentProvider(
          applyModuleTag(path),
        ),
      ),
    );
  }

  DynamicCollectionModel watchCollectionModel(String path) {
    final context = this as BuildContext;

    return context.model!.loadCollection(
      watch(
        context.model!.collectionProvider(
          applyModuleTag(path),
        ),
      ),
    );
  }

  DynamicSearchableCollectionModel watchSearchableCollectionModel(String path) {
    final context = this as BuildContext;

    return watch(
      context.model!.searchableCollectionProvider(
        applyModuleTag(path),
      ),
    );
  }

  DynamicDocumentModel watchUserDocumentModel([String userPath = Const.user]) {
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
