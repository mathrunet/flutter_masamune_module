import 'package:masamune/masamune.dart';
import 'package:masamune_module/masamune_module.dart';

@immutable
class MenuModule extends PageModule {
  const MenuModule({
    bool enabled = true,
    String? title,
    this.routePath = "menu",
    this.automaticallyImplyLeadingOnHome = true,
    this.sliverLayoutWhenModernDesignOnHome = true,
    required this.menu,
    Permission permission = const Permission(),
    List<RerouteConfig> rerouteConfigs = const [],
    this.top = const [],
    this.bottom = const [],
    this.home,
  }) : super(
          enabled: enabled,
          title: title,
          permission: permission,
          rerouteConfigs: rerouteConfigs,
        );

  @override
  Map<String, RouteConfig> get routeSettings {
    if (!enabled) {
      return const {};
    }

    final route = {
      "/$routePath": RouteConfig((_) => home ?? MenuModuleHome(this)),
    };
    return route;
  }

  // Page settings.
  final Widget? home;

  /// Widget parts.
  final List<Widget> top;
  final List<Widget> bottom;

  /// Route path.
  final String routePath;

  /// メニューの一覧。
  final List<MenuModuleItem> menu;

  /// True if Home is a sliver layout.
  final bool sliverLayoutWhenModernDesignOnHome;

  /// True if you want to automatically display the back button when you are at home.
  final bool automaticallyImplyLeadingOnHome;
}

@immutable
class MenuModuleItem {
  const MenuModuleItem({
    required this.name,
    this.icon,
    this.menus = const [],
  });

  final String name;
  final IconData? icon;
  final List<MenuConfig> menus;

  /// The equality operator.
  ///
  /// The default behavior for all [Object]s is to return true if and only if this object and [other] are the same object.
  ///
  /// Override this method to specify a different equality relation on a class. The overriding method must still be an equivalence relation. That is, it must be:
  ///
  /// Total: It must return a boolean for all arguments. It should never throw.
  ///
  /// Reflexive: For all objects o, o == o must be true.
  ///
  /// Symmetric: For all objects o1 and o2, o1 == o2 and o2 == o1 must either both be true, or both be false.
  ///
  /// Transitive: For all objects o1, o2, and o3, if o1 == o2 and o2 == o3 are true, then o1 == o3 must be true.
  ///
  /// The method should also be consistent over time, so whether two objects are equal should only change if at least one of the objects was modified.
  ///
  /// If a subclass overrides the equality operator, it should override the [hashCode] method as well to maintain consistency.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  /// The hash code for this object.
  ///
  /// A hash code is a single integer which represents the state of the object that affects [operator ==] comparisons.
  ///
  /// All objects have hash codes. The default hash code implemented by [Object] represents only the identity of the object,
  /// the same way as the default [operator ==] implementation only considers objects equal if they are identical (see [identityHashCode]).
  ///
  /// If [operator ==] is overridden to use the object state instead,
  /// the hash code must also be changed to represent that state,
  /// otherwise the object cannot be used in hash based data structures like the default [Set] and [Map] implementations.
  ///
  /// Hash codes must be the same for objects that are equal to each other according to [operator ==].
  /// The hash code of an object should only change if the object changes in a way that affects equality.
  /// There are no further requirements for the hash codes. They need not be consistent between executions of the same program and there are no distribution guarantees.
  ///
  /// Objects that are not equal are allowed to have the same hash code.
  /// It is even technically allowed that all instances have the same hash code,
  /// but if clashes happen too often, it may reduce the efficiency of hash-based data structures like [HashSet] or [HashMap].
  ///
  /// If a subclass overrides [hashCode],
  /// it should override the [operator ==] operator as well to maintain consistency.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => icon.hashCode ^ name.hashCode ^ menus.hashCode;
}

class MenuModuleHome extends PageScopedWidget {
  const MenuModuleHome(this.config);
  final MenuModule config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Please describe reference.

    // Please describe the Widget.
    return UIScaffold(
      appBar: UIAppBar(
        title: Text(config.title?.localize() ?? "Menu".localize()),
        automaticallyImplyLeading: config.automaticallyImplyLeadingOnHome,
        sliverLayoutWhenModernDesign: config.sliverLayoutWhenModernDesignOnHome,
      ),
      body: UIListBuilder<MenuModuleItem>(
        source: config.menu,
        padding: const EdgeInsets.symmetric(vertical: 8),
        top: config.top,
        bottom: config.bottom,
        builder: (context, item, index) {
          return [
            Headline(
              item.name,
              icon: item.icon,
            ),
            ...item.menus.expandAndRemoveEmpty((menu) {
              return [
                ListItem(
                  leading: menu.icon != null ? Icon(menu.icon!) : null,
                  title: Text(menu.name),
                  onTap: menu.path.isEmpty
                      ? null
                      : () {
                          context.rootNavigator.pushNamed(
                            menu.path!,
                            arguments: RouteQuery.fullscreenOrModal,
                          );
                        },
                ),
                const Divid(),
              ];
            })
          ];
        },
      ),
    );
  }
}
