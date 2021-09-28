part of masamune_module;

DynamicDocumentModel useDocumentModel(String path) {
  final context = useContext();

  return context.model!.loadDocument(
    useProvider(context.model!.documentProvider(context.applyModuleTag(path))),
  );
}

DynamicCollectionModel useCollectionModel(String path) {
  final context = useContext();

  return context.model!.loadCollection(
    useProvider(
        context.model!.collectionProvider(context.applyModuleTag(path))),
  );
}

DynamicDocumentModel useUserDocumentModel([String userPath = Const.user]) {
  final context = useContext();

  return context.model!.loadDocument(
    useProvider(context.model!.documentProvider(
        context.applyModuleTag("$userPath/${context.model?.userId}"))),
  );
}
