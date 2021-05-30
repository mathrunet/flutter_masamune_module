part of masamune_module;

class TileMenuHome extends HookWidget {
  const TileMenuHome(this.config);
  final HomeModule config;
  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel(config.userPath);
    final name = user.get(config.nameKey, "Unknown".localize());
    final role = context.roles.firstWhereOrNull(
      (item) => item.id == user.get(config.roleKey, ""),
    );

    return Scaffold(
      body: PlatformScrollbar(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: config.headerHeight,
                width: context.isMobileOrSmall
                    ? null
                    : () {
                        return context.mediaQuery.size.width / 2;
                      }(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: config.textColor ??
                              context.theme.textColorOnPrimary,
                          fontWeight: FontWeight.bold,
                        ),
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
                    ),
                    const Space.width(4),
                    Expanded(
                      flex: 1,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: config.textColor ??
                              context.theme.textColorOnPrimary,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                                color:
                                    config.color ?? context.theme.primaryColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (role?.icon != null) ...[
                                          Icon(
                                            role?.icon,
                                            color: config.textColor ??
                                                context.theme.colorScheme
                                                    .onPrimary,
                                            size: 15,
                                          ),
                                          const Space.width(4),
                                        ],
                                        Text(
                                          role?.label ?? "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Space.width(4),
                                    Text(
                                      "%s san".localize().format([name]),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Space.height(4),
                            ClickableBox(
                              color: config.color ?? context.theme.primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Text(
                                  "MyPage".localize(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Space.height(8),
            if (config.info.enabled) ...[
              _TileMenuHomeInformation(config),
              const Space.height(8),
            ],
            if (config.calendar.enabled) ...[
              _TileMenuHomeCalendar(config),
              const Space.height(8),
            ],
            _TileMenuHomeHeadline(
              "Menu".localize(),
              icon: Icons.menu,
              color: config.textColor ?? context.theme.textColorOnPrimary,
              backgroundColor:
                  config.color ?? context.theme.primaryColor.lighten(0.15),
            ),
            const Space.height(4),
            Grid(
              crossAxisCount: context.isMobileOrSmall ? 3 : 6,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              children: [
                ...config.menuByRole(role).mapAndRemoveEmpty((item) {
                  return ClickableBox(
                    color: config.color ?? context.theme.primaryColor,
                    onTap: item.path.isEmpty
                        ? null
                        : () {
                            context.open(item.path!);
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon ?? Icons.info,
                            size: context.isMobileOrSmall ? 64 : 78,
                            color: config.textColor ??
                                context.theme.textColorOnPrimary,
                          ),
                          const Space.height(8),
                          Text(
                            item.name,
                            style: TextStyle(
                                color: config.textColor ??
                                    context.theme.textColorOnPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: context.isMobileOrSmall ? null : 15),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
            const Space.height(8),
            Grid(
              crossAxisCount: context.isMobileOrSmall ? 2 : 4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 3,
              children: [
                ...config.subMenu.mapAndRemoveEmpty((item) {
                  return ClickableBox(
                    color: config.color ?? context.theme.primaryColor,
                    onTap: item.path.isEmpty
                        ? null
                        : () {
                            context.open(item.path!);
                          },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: config.textColor ??
                              context.theme.textColorOnPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _TileMenuHomeInformation extends HookWidget {
  const _TileMenuHomeInformation(this.config);
  final HomeModule config;

  @override
  Widget build(BuildContext context) {
    final info = useCollectionModel(config.info.postPath);
    info.sort((a, b) {
      return b.get("created", DateTime.now().millisecondsSinceEpoch) -
          a.get("created", DateTime.now().millisecondsSinceEpoch);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TileMenuHomeHeadline(
          config.info.title ?? "Information".localize(),
          icon: config.info.icon,
          color: config.textColor ?? context.theme.textColorOnPrimary,
          backgroundColor:
              config.color ?? context.theme.primaryColor.lighten(0.15),
        ),
        const Space.height(4),
        Grid(
          crossAxisCount: context.isMobileOrSmall ? 2 : 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 2,
          children: [
            ...info.limitEnd(4).mapAndRemoveEmpty((item) {
              final dateTime = DateTime.fromMillisecondsSinceEpoch(
                item.get("created", DateTime.now().millisecondsSinceEpoch),
              );
              return DefaultTextStyle(
                style: TextStyle(
                  color: config.textColor ?? context.theme.textColorOnPrimary,
                ),
                child: ClickableBox(
                  color: config.color ?? context.theme.primaryColor,
                  onTap: () {
                    context.navigator.pushNamed(
                      "/info/${item.get(Const.uid, "")}",
                      arguments: RouteQuery.fullscreenOrModal,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(dateTime.format("yyyy/MM/dd HH:mm")),
                            if (dateTime.isToday()) ...[
                              const Space.width(4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                color: context.theme.colorScheme.error,
                                child: Text(
                                  "NEW".localize(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: context.theme.colorScheme.onError,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                        const Space.height(8),
                        Text(item.get(Const.name, "--")),
                      ],
                    ),
                  ),
                ),
              );
            })
          ],
        ),
      ],
    );
  }
}

class _TileMenuHomeCalendar extends HookWidget {
  const _TileMenuHomeCalendar(this.config);
  final HomeModule config;

  @override
  Widget build(BuildContext context) {
    final event = useCollectionModel(config.calendar.path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TileMenuHomeHeadline(
          config.calendar.title ?? "Calendar".localize(),
          icon: config.calendar.icon,
          color: config.textColor ?? context.theme.textColorOnPrimary,
          backgroundColor:
              config.color ?? context.theme.primaryColor.lighten(0.15),
        ),
      ],
    );
  }
}

class _TileMenuHomeHeadline extends StatelessWidget {
  const _TileMenuHomeHeadline(
    this.label, {
    this.icon,
    this.color,
    this.backgroundColor,
  });
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: DefaultBoxDecoration(
        radius: 0,
        backgroundColor: backgroundColor ?? context.theme.primaryColor,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: color ?? context.theme.textColorOnPrimary,
            ),
            const Space.width(12),
          ],
          Text(
            label,
            style: TextStyle(
              color: color ?? context.theme.textColorOnPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
