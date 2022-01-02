part of masamune_module.variable;

/// FormConfig for using Select/DropdownField.
@immutable
class MultipleSelectFormConfig extends FormConfig {
  const MultipleSelectFormConfig({
    required this.items,
    required this.initialKeys,
    this.backgroundColor,
    this.color,
  });
  final Map<String, String> items;

  final List<String> initialKeys;

  final Color? backgroundColor;

  final Color? color;
}

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
          prefix: config.required
              ? IconTheme(
                  data: const IconThemeData(size: 16),
                  child: context.widgetTheme.requiredIcon,
                )
              : null,
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
    bool updated,
  ) {
    return context.getAsList(config.id);
  }
}
