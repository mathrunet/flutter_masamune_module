part of 'home.dart';

class HomeModuleTileMenuHome extends HookWidget {
  const HomeModuleTileMenuHome(this.config);
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
                            image: config.featureImage.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkOrAsset.image(
                                        config.featureImage!),
                                    fit: config.featureImageFit,
                                    alignment: config.featureImageAlignment,
                                  )
                                : null,
                            color: config.color ?? context.theme.primaryColor,
                          ),
                          child: Row(
                            children: [
                              if (config.featureIcon.isNotEmpty) ...[
                                Image(
                                    image: NetworkOrAsset.image(
                                        config.featureIcon!)),
                                const Space.width(8),
                              ],
                              Expanded(
                                child: DefaultTextStyle(
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  child: Text(
                                    config.title ?? "",
                                    textAlign: TextAlign.center,
                                    style: config.titleTextStyle,
                                  ),
                                ),
                              ),
                            ],
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
                                    const Space.height(4),
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
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              onTap: () {
                                context.navigator.pushNamed(
                                    "/${config.profileRoutePath}/${context.model?.userId}");
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (config.header != null) ...[
              const Space.height(8),
              config.header!,
            ],
            const Space.height(8),
            if (config.info.enabled) ...[
              config.tileMenuHomeInformation ??
                  HomeModuleTileMenuHomeInformation(config),
              const Space.height(8),
            ],
            if (config.calendar.enabled) ...[
              config.tileMenuHomeCalendar ??
                  HomeModuleTileMenuHomeCalendar(config),
              const Space.height(8),
            ],
            HomeModuleTileMenuHomeHeadline(
              "Menu".localize(),
              icon: Icons.menu,
              color: config.textColor ?? context.theme.textColorOnPrimary,
              backgroundColor:
                  config.color ?? context.theme.primaryColor.lighten(0.15),
            ),
            const Space.height(4),
            Grid.extent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              children: [
                ...config.menu.mapAndRemoveEmpty(
                  (item) {
                    if (role != null &&
                        role.id.isNotEmpty &&
                        item.availableRole.isNotEmpty &&
                        !item.availableRole.contains(role.id)) {
                      return null;
                    }
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
                                  fontSize:
                                      context.isMobileOrSmall ? null : 15),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Space.height(8),
            Grid.extent(
              maxCrossAxisExtent: 400,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 3,
              children: [
                ...config.subMenu.mapAndRemoveEmpty((item) {
                  if (role != null &&
                      role.id.isNotEmpty &&
                      item.availableRole.isNotEmpty &&
                      !item.availableRole.contains(role.id)) {
                    return null;
                  }
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
            ),
            if (config.footer != null) ...[
              const Space.height(8),
              config.footer!,
            ],
          ],
        ),
      ),
      bottomNavigationBar: _banner(context),
    );
  }

  Widget? _banner(BuildContext context) {
    if (context.ads == null || !context.ads!.enabled) {
      return null;
    }
    return context.ads!.banner(context);
  }
}

class HomeModuleTileMenuHomeInformation extends HookWidget {
  const HomeModuleTileMenuHomeInformation(this.config);
  final HomeModule config;

  @override
  Widget build(BuildContext context) {
    if (config.info.widget != null) {
      return config.info.widget!;
    }

    final now = useNow();
    final info = useCollectionModel(config.info.queryPath);
    info.sort((a, b) {
      return b.get(config.info.createdTimeKey, now.millisecondsSinceEpoch) -
          a.get(config.info.createdTimeKey, now.millisecondsSinceEpoch);
    });

    return LoadingBuilder(
      futures: [info.future],
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeModuleTileMenuHomeHeadline(
              config.info.title ?? "Information".localize(),
              icon: config.info.icon,
              color: config.textColor ?? context.theme.textColorOnPrimary,
              backgroundColor:
                  config.color ?? context.theme.primaryColor.lighten(0.15),
            ),
            const Space.height(4),
            Grid.extent(
              maxCrossAxisExtent: 300,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 2,
              children: [
                ...info.limitEnd(config.info.limit).mapListenable((item) {
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(
                    item.get(
                        config.info.createdTimeKey, now.millisecondsSinceEpoch),
                  );
                  return DefaultTextStyle(
                    style: TextStyle(
                      color:
                          config.textColor ?? context.theme.textColorOnPrimary,
                    ),
                    child: ClickableBox(
                      color: config.color ?? context.theme.primaryColor,
                      onTap: () {
                        context.navigator.pushNamed(
                          "/${config.info.routePath}/${item.get(Const.uid, "")}",
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
                                        color:
                                            context.theme.colorScheme.onError,
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                            const Space.height(8),
                            Text(item.get(config.info.nameKey, "--")),
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
      },
    );
  }
}

class HomeModuleTileMenuHomeCalendar extends HookWidget {
  const HomeModuleTileMenuHomeCalendar(this.config);
  final HomeModule config;

  @override
  Widget build(BuildContext context) {
    if (config.info.widget != null) {
      return config.info.widget!;
    }

    final now = useNow();
    final start = now.toDate();
    final event =
        useCollectionModel(config.calendar.queryPath).where((element) {
      final time = element.getAsDateTime(config.calendar.startTimeKey);
      return time.millisecondsSinceEpoch >= start.millisecondsSinceEpoch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeModuleTileMenuHomeHeadline(
          config.calendar.title ?? "Calendar".localize(),
          icon: config.calendar.icon,
          color: config.textColor ?? context.theme.textColorOnPrimary,
          backgroundColor:
              config.color ?? context.theme.primaryColor.lighten(0.15),
        ),
        const Space.height(4),
        ColoredBox(
          color: context.theme.primaryColor,
          child: event.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  height: 100,
                  child: Text(
                    "No data.".localize(),
                    style: TextStyle(
                      color: context.theme.scaffoldBackgroundColor,
                    ),
                  ),
                )
              : UIScheduleCalendar(
                  source: event,
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  dayTextStyle:
                      TextStyle(color: context.theme.textColorOnPrimary),
                  builder: (context, item) {
                    final endTimeValue =
                        item.get<int?>(config.calendar.endTimeKey, null);
                    final endTime = endTimeValue != null
                        ? DateTime.fromMillisecondsSinceEpoch(endTimeValue)
                        : null;

                    return InkWell(
                      onTap: () {
                        context.navigator.pushNamed(
                          "/${config.calendar.routePath}/${item.uid}/detail",
                          arguments: RouteQuery.fullscreenOrModal,
                        );
                      },
                      child: Container(
                        color: context.theme.scaffoldBackgroundColor,
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.get(config.nameKey, ""),
                              style: TextStyle(
                                color: context.theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _timeString(
                                startTime: item.getAsDateTime(
                                    config.calendar.startTimeKey),
                                endTime: endTime,
                                allDay:
                                    item.get(config.calendar.allDayKey, false),
                              ),
                              style: TextStyle(
                                color: context.theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

String _timeString({
  required DateTime startTime,
  DateTime? endTime,
  bool allDay = false,
}) {
  if (endTime == null) {
    allDay = true;
  }
  if (allDay) {
    return "${startTime.format("yyyy/MM/dd")} ${"All day".localize()}";
  } else {
    return "${startTime.format("yyyy/MM/dd HH:mm")} - ${endTime?.format("yyyy/MM/dd HH:mm")}";
  }
}

class HomeModuleTileMenuHomeHeadline extends StatelessWidget {
  const HomeModuleTileMenuHomeHeadline(
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

class HomeModuleChangeAffiliation extends HookWidget {
  const HomeModuleChangeAffiliation({
    required this.title,
    this.roleKey = Const.role,
    this.affiliationKey = "affiliation",
    this.targetPath = "user",
    this.namekey = Const.name,
    this.imageKey = Const.icon,
    this.availableRole = const [],
    this.affiliationListKey = "affiliations",
  });
  final String title;
  final String namekey;
  final String roleKey;
  final String imageKey;
  final String affiliationKey;
  final String affiliationListKey;
  final List<String> availableRole;
  final String targetPath;

  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel();
    final affiliationId = user.get(affiliationKey, "");
    final role = context.roles.firstWhereOrNull(
      (item) => item.id == user.get(roleKey, ""),
    );
    final affiliation = useCollectionModel(
      ModelQuery(targetPath, key: Const.uid, isEqualTo: affiliationId).value,
    ).firstOrNull;
    final name = affiliation?.get(namekey, "") ?? "";
    final enabled = role == null ||
        role.id.isEmpty ||
        availableRole.isEmpty ||
        availableRole.contains(role.id);

    return DefaultTextStyle(
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: context.theme.colorScheme.onPrimary),
      child: SizedBox(
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title.isNotEmpty)
              Expanded(
                flex: 1,
                child: Container(
                  color: context.theme.primaryColor,
                  child: Text(title),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            const Space.width(4),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
                color: context.theme.primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (affiliation != null && enabled)
                      IconButton(
                        color: context.theme.colorScheme.onPrimary,
                        onPressed: () async {
                          final uid = await context.navigator.push<String>(
                            UIPageRoute<String>(
                              builder: (context) =>
                                  HomeModuleChangeAffiliationSelection(
                                title: title,
                                roleKey: roleKey,
                                affiliationKey: affiliationKey,
                                targetPath: targetPath,
                                imageKey: imageKey,
                                namekey: namekey,
                                availableRole: availableRole,
                                affiliationListKey: affiliationListKey,
                              ),
                              transition: PageTransition.fullscreen,
                            ),
                          );
                          if (uid.isEmpty) {
                            return;
                          }
                          user[affiliationKey] = uid;
                          context.model
                              ?.saveDocument(user)
                              .showIndicator(context);
                          UIDialog.show(
                            context,
                            title: "Success".localize(),
                            text: "%s is completed."
                                .localize()
                                .format(["Editing".localize()]),
                            submitText: "Close".localize(),
                          );
                        },
                        icon: const Icon(Icons.change_circle),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeModuleChangeAffiliationSelection extends PageHookWidget {
  const HomeModuleChangeAffiliationSelection({
    required this.title,
    this.roleKey = Const.role,
    this.affiliationKey = "affiliation",
    this.targetPath = "user",
    this.imageKey = Const.icon,
    this.namekey = Const.name,
    this.availableRole = const [],
    this.affiliationListKey = "affiliations",
  });
  final String title;
  final String namekey;
  final String imageKey;
  final String roleKey;
  final String affiliationKey;
  final String affiliationListKey;
  final List<String> availableRole;
  final String targetPath;

  @override
  Widget build(BuildContext context) {
    final user = useUserDocumentModel();
    final affiliationId = user.get(affiliationKey, "");
    final affiliationList = user.getAsList<String>(affiliationListKey, []);
    final affiliation = useCollectionModel(
      ModelQuery(targetPath, key: Const.uid, whereIn: affiliationList).value,
    );

    return UIScaffold(
      waitTransition: true,
      loadingFutures: [
        user.future,
        affiliation.future,
      ],
      appBar: UIAppBar(title: Text("Select %s".localize().format([title]))),
      body: UIListBuilder<DynamicMap>(
        source: affiliation,
        builder: (context, item, index) {
          return [
            ListItem(
              leading: CircleAvatar(
                backgroundImage: NetworkOrAsset.image(item.get(imageKey, "")),
              ),
              onTap: affiliationId == item.uid
                  ? null
                  : () {
                      context.navigator.pop(item.uid);
                    },
              title: Text(item.get(namekey, "")),
              trailing: affiliationId == item.uid
                  ? Icon(Icons.check_circle, color: context.theme.primaryColor)
                  : null,
            )
          ];
        },
      ),
    );
  }
}
