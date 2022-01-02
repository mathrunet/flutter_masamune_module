part of masamune_module.variable;

/// FormConfig for using Hidden.
@immutable
class HiddenFormConfig extends FormConfig {
  const HiddenFormConfig({
    this.type = HiddenFormConfigType.variable,
    this.value,
    this.applyOnUpdate = true,
  });

  final HiddenFormConfigType type;

  final Object? value;

  final bool applyOnUpdate;
}

/// The type of Hidden form config.
enum HiddenFormConfigType {
  /// Value.
  variable,

  /// Current time.
  dateTimeNow,

  /// Initial Order.
  initialOrder,
}

@immutable
class HiddenFormConfigBuilder extends FormConfigBuilder {
  const HiddenFormConfigBuilder();
  @override
  bool check(FormConfig? form) {
    return form is HiddenFormConfig;
  }

  @override
  Iterable<Widget> form(
    VariableConfig config,
    FormConfig? form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    return [];
  }

  @override
  Iterable<Widget> view(
    VariableConfig config,
    FormConfig? form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    return [];
  }

  @override
  dynamic value(
    VariableConfig config,
    BuildContext context,
    WidgetRef ref,
    bool updated,
  ) {
    final form = config.form;
    if (form is! HiddenFormConfig) {
      return null;
    }
    if (!form.applyOnUpdate && !updated) {
      return null;
    }
    switch (form.type) {
      case HiddenFormConfigType.dateTimeNow:
        return DateTime.now().millisecondsSinceEpoch;
      case HiddenFormConfigType.initialOrder:
        return DateTime.now().millisecondsSinceEpoch.toDouble();
      default:
        return form.value;
    }
  }
}
