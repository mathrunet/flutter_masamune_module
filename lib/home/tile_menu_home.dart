part of masamune_module;

class TileMenuHome extends HookWidget {
  const TileMenuHome(this.config);
  final HomeModule config;
  @override
  Widget build(BuildContext context) {
    final user = context.adapter!.loadDocument(
      useProvider(context.adapter!.documentProvider("${config.userPath}/$userId")),
    );
    final name = user.get(config.nameKey, "Unknown".localize());
    final role = config.roles.firstWhereOrNull(
        (item) => item.id == user.get(config.roleKey, "register"));

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          SizedBox(
            height: config.headerHeight,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: config.titleAlignment,
                    padding: config.titlePadding,
                    decoration: BoxDecoration(
                      image: config.featureImage != null
                          ? DecorationImage(
                              image: config.featureImage!,
                              fit: config.featureImageFit,
                            )
                          : null,
                      color: config.color ?? context.theme.primaryColor,
                    ),
                    child: Text(
                      config.title ?? "",
                      style: config.titleTextStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: config.textColor ??
                          context.theme.colorScheme.onPrimary,
                    ),
                    child: Container(
                      color: config.color ?? context.theme.primaryColor,
                      padding: config.contentPadding,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              if (role?.icon != null) Icon(role?.icon),
                              Text(
                                role?.label ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            sprintf("%s san".localize(), [name]),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TileMenuHomeInformation extends HookWidget {
  const _TileMenuHomeInformation(this.config);
  final HomeModule config;

  @override
  Widget build(BuildContext context) {
    final info = context.adapter!.loadCollection(
      useProvider(context.adapter!.collectionProvider(config.infoPath)),
    );

    return Container(
      color: ,
    );
  }
}
