part of masamune_module;

DynamicDocumentModel useReadDocumentModel(String path) {
  final context = useContext();

  return context.model!.loadDocument(
    useReadProvider(
        context.model!.documentProvider(context.applyModuleTag(path))),
  );
}

DynamicCollectionModel useReadCollectionModel(String path) {
  final context = useContext();

  return context.model!.loadCollection(
    useReadProvider(
        context.model!.collectionProvider(context.applyModuleTag(path))),
  );
}

DynamicSearchableCollectionModel useReadSearchableCollectionModel(String path) {
  final context = useContext();

  return useReadProvider(context.model!
      .searchableCollectionProvider(context.applyModuleTag(path)));
}

DynamicDocumentModel useReadUserDocumentModel([String userPath = Const.user]) {
  final context = useContext();

  return context.model!.loadDocument(
    useReadProvider(context.model!.documentProvider(
        context.applyModuleTag("$userPath/${context.model?.userId}"))),
  );
}

DynamicDocumentModel useWatchDocumentModel(String path) {
  final context = useContext();

  return context.model!.loadDocument(
    useWatchProvider(
        context.model!.documentProvider(context.applyModuleTag(path))),
  );
}

DynamicCollectionModel useWatchCollectionModel(String path) {
  final context = useContext();

  return context.model!.loadCollection(
    useWatchProvider(
        context.model!.collectionProvider(context.applyModuleTag(path))),
  );
}

DynamicSearchableCollectionModel useWatchSearchableCollectionModel(
    String path) {
  final context = useContext();

  return useWatchProvider(context.model!
      .searchableCollectionProvider(context.applyModuleTag(path)));
}

DynamicDocumentModel useWatchUserDocumentModel([String userPath = Const.user]) {
  final context = useContext();

  return context.model!.loadDocument(
    useWatchProvider(context.model!.documentProvider(
        context.applyModuleTag("$userPath/${context.model?.userId}"))),
  );
}
