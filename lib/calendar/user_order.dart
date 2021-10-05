import 'package:masamune_module/masamune_module.dart';

class CalendarModuleUserOrder extends PageHookWidget {
  const CalendarModuleUserOrder({
    required this.title,
    this.subtitle,
    this.queryPath = "order",
    this.userKey = Const.user,
    this.nameKey = Const.name,
    this.userPath = Const.user,
    this.userQuery,
    this.startTimeKey = Const.startTime,
  });
  final String title;
  final String? subtitle;
  final String queryPath;
  final String userKey;
  final String userPath;
  final String nameKey;
  final String startTimeKey;
  final ModelQuery? userQuery;

  @override
  Widget build(BuildContext context) {
    final now = useNow();
    final orderList = <DynamicMap>[];
    final date = context.get("date_id", now.toDateID()).toDateTime();
    final users = useCollectionModel(userQuery?.value ?? userPath);

    final orders = useCollectionModel(queryPath);
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
        orders.future,
        users.future,
      ],
      body: ReorderableListBuilder<DynamicMap>(
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
            await context.model?.saveDocument(order).showIndicator(context);
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
              trailing: const Icon(Icons.reorder),
            ),
          ];
        },
      ),
    );
  }
}
