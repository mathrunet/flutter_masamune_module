import 'package:masamune_module/masamune_module.dart';

class CalendarModuleUserOrder extends PageScopedWidget {
  const CalendarModuleUserOrder({
    required this.title,
    this.subtitle,
    this.queryPath = "order",
    this.userKey = Const.user,
    this.nameKey = Const.name,
    this.userPath = Const.user,
    this.userQuery,
    this.roleKey = Const.role,
    this.startTimeKey = Const.startTime,
    this.permission = const Permission(),
  });
  final String title;
  final String? subtitle;
  final String queryPath;
  final String userKey;
  final String userPath;
  final String nameKey;
  final String startTimeKey;
  final ModelQuery? userQuery;
  final Permission permission;
  final String roleKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.useNow();
    final orderList = <DynamicMap>[];
    final user = ref.watchAsUserDocumentModel();
    final role = context.roles.firstWhereOrNull(
      (item) => item.id == user.get(roleKey, ""),
    );
    final date = context.get("date_id", now.toDateID()).toDateTime();
    final users = ref.watchAsCollectionModel(userQuery?.value ?? userPath);

    final canEdit = permission.canEdit(role?.id ?? "");
    final orders = ref.watchAsCollectionModel(queryPath);
    orders.sort((a, b) => b.get(startTimeKey, 0) - a.get(startTimeKey, 0));
    final order = orders.firstWhereOrNull((element) {
          return element.get(startTimeKey, 0) <= date.millisecondsSinceEpoch;
        }) ??
        orders.lastOrNull;
    final userOrder = order.getAsList<DynamicMap>(userKey, []);

    for (final o in userOrder) {
      final user = users.firstWhereOrNull((item) => item.uid == o.uid);
      if (user == null) {
        continue;
      }
      orderList.add(user);
    }
    for (final user in users) {
      if (orderList.any((element) => element.uid == user.uid)) {
        continue;
      }
      orderList.add(user);
    }

    return UIScaffold(
      waitTransition: true,
      appBar: UIAppBar(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
      ),
      loadingFutures: [
        orders.loading,
        users.loading,
      ],
      body: canEdit
          ? ReorderableListBuilder<DynamicMap>(
              onReorder: (o, n, item, reordered) async {
                if (order == null) {
                  final doc = context.model?.createDocument(orders);
                  if (doc == null) {
                    return;
                  }
                  doc[userKey] = reordered.mapAndRemoveEmpty((item) {
                    return {
                      Const.uid: item.uid,
                    };
                  });
                  doc[startTimeKey] = date.millisecondsSinceEpoch;
                  await context.model?.saveDocument(doc).showIndicator(context);
                } else if (order.get(startTimeKey, 0) !=
                    date.millisecondsSinceEpoch) {
                  final doc = context.model?.createDocument(orders);
                  if (doc == null) {
                    return;
                  }
                  doc[userKey] = reordered.mapAndRemoveEmpty((item) {
                    return {
                      Const.uid: item.uid,
                    };
                  });
                  doc[startTimeKey] = date.millisecondsSinceEpoch;
                  await context.model?.saveDocument(doc).showIndicator(context);
                } else {
                  order[userKey] = reordered.mapAndRemoveEmpty((item) {
                    return {
                      Const.uid: item.uid,
                    };
                  });
                  order[startTimeKey] = date.millisecondsSinceEpoch;
                  await context.model
                      ?.saveDocument(order)
                      .showIndicator(context);
                }
              },
              source: orderList.toList(),
              builder: (context, item, index) {
                return [
                  ListItem(
                    leading: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(item.get(nameKey, "")),
                    trailing: canEdit ? const Icon(Icons.reorder) : null,
                  ),
                ];
              },
            )
          : UIListBuilder<DynamicMap>(
              source: orderList.toList(),
              builder: (context, item, index) {
                return [
                  ListItem(
                    leading: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(item.get(nameKey, "")),
                    trailing: canEdit ? const Icon(Icons.reorder) : null,
                  ),
                ];
              },
            ),
    );
  }
}
