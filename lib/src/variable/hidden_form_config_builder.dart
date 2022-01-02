import 'package:masamune/masamune.dart';
import 'variable_config.dart';

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
