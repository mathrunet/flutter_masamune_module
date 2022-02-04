part of masamune_module;

extension ListenableMapListExtensions on List<ListenableMap<String, dynamic>> {
  List<ListenableMap<String, dynamic>> mergeUserInformation(
    WidgetRef ref, {
    String userCollectionPath = "user",
    String userKey = "user",
    String keyPrefix = "user",
  }) {
    final user = ref.watchCollectionModel(
      ModelQuery(
        userCollectionPath,
        key: Const.uid,
        whereIn: map((e) => e.get(userKey, "")).distinct(),
      ).value,
    );
    return setWhereListenable(
      user,
      test: (o, a) => o.get(userKey, "") == a.uid,
      apply: (o, a) =>
          o.mergeListenable(a, convertKeys: (key) => "$keyPrefix$key"),
      orElse: (o) => o,
    ).toList();
  }

  List<ListenableMap<String, dynamic>> mergeDetailInformation(
    WidgetRef ref,
    String collectionPath, {
    String idKey = Const.uid,
    String keyPrefix = "",
  }) {
    final collection = ref.watchCollectionModel(
      ModelQuery(
        collectionPath,
        key: Const.uid,
        whereIn: map((e) => e.get(idKey, "")).distinct(),
      ).value,
    );
    return setWhereListenable(
      collection,
      test: (o, a) => o.get(idKey, "") == a.uid,
      apply: (o, a) =>
          o.mergeListenable(a, convertKeys: (key) => "$keyPrefix$key"),
      orElse: (o) => o,
    ).toList();
  }
}

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
