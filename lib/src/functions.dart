part of masamune_module;

DynamicDocumentModel useDocumentModel(String path) {
  final context = useContext();

  return context.model!.loadDocument(
    useProvider(context.model!.documentProvider(path)),
  );
}

DynamicCollectionModel useCollectionModel(String path) {
  final context = useContext();

  return context.model!.loadCollection(
    useProvider(context.model!.collectionProvider(path)),
  );
}

DynamicDocumentModel useUserDocumentModel([String userPath = Const.user]) {
  final context = useContext();

  return context.model!.loadDocument(
    useProvider(
        context.model!.documentProvider("$userPath/${context.model?.userId}")),
  );
}
