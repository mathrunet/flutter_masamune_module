import 'package:masamune/masamune.dart';
import 'variable_config.dart';

@immutable
class MultipleSelectFormConfigBuilder extends FormConfigBuilder {
  const MultipleSelectFormConfigBuilder();
  @override
  bool check(FormConfig? form) {
    return form is MultipleSelectFormConfig;
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
    if (form is! MultipleSelectFormConfig) {
      return [];
    }
    return [
      if (config.label.isNotEmpty)
        DividHeadline(
          config.label.localize(),
          icon: config.required ? Icons.check_circle : null,
        )
      else
        const Divid(),
      FormItemMultipleCheckbox(
        dense: true,
        backgroundColor: form.backgroundColor,
        items: form.items,
        allowEmpty: !config.required,
        labelText: "Input %s".localize().format([config.label.localize()]),
        hintText: "Input %s".localize().format([config.label.localize()]),
        errorText: "No input %s".localize().format([config.label.localize()]),
        controller: ref.useTextEditingController(
            config.id, data.getAsList(config.id, form.initialKeys).join(",")),
        onSaved: (value) {
          if (value.isEmpty) {
            context[config.id] = form.initialKeys;
          } else {
            context[config.id] = value;
          }
        },
      ),
    ];
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
    if (form is! MultipleSelectFormConfig) {
      return [];
    }
    final list = data.getAsList(config.id, form.initialKeys);
    return [
      if (config.label.isNotEmpty)
        DividHeadline(
          config.label.localize(),
        )
      else
        const Divid(),
      if (list.isEmpty)
        const ListItem(title: Text("--"))
      else
        for (final key in list) ListItem(title: Text(form.items[key] ?? "")),
    ];
  }

  @override
  dynamic value(
    VariableConfig config,
    BuildContext context,
    WidgetRef ref,
  ) {
    return context.getAsList(config.id);
  }
}
