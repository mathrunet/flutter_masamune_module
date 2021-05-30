part of masamune_module;

DynamicDocumentModel useDocumentModel(String path) {
  final context = useContext();

  return context.adapter!.loadDocument(
    useProvider(context.adapter!.documentProvider(path)),
  );
}

DynamicCollectionModel useCollectionModel(String path) {
  final context = useContext();

  return context.adapter!.loadCollection(
    useProvider(context.adapter!.collectionProvider(path)),
  );
}

DynamicDocumentModel useUserDocumentModel([String userPath = Const.user]) {
  final context = useContext();

  return context.adapter!.loadDocument(
    useProvider(context.adapter!
        .documentProvider("$userPath/${context.adapter?.userId}")),
  );
}
