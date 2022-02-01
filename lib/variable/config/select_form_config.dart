part of masamune_module.variable;

/// FormConfig for using Select/DropdownField.
@immutable
class SelectFormConfig extends FormConfig {
  const SelectFormConfig({
    required this.items,
    required this.initialKey,
    this.backgroundColor,
    this.color,
  });

  final Map<String, String> items;

  final String initialKey;

  final Color? backgroundColor;

  final Color? color;
}

@immutable
class SelectFormConfigBuilder extends FormConfigBuilder<SelectFormConfig> {
  const SelectFormConfigBuilder();

  @override
  Iterable<Widget> form(
    VariableConfig config,
    SelectFormConfig form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
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
      FormItemDropdownField(
        dense: true,
        backgroundColor: form.backgroundColor,
        items: form.items,
        allowEmpty: !config.required,
        hintText: "Input %s".localize().format([config.label.localize()]),
        errorText: "No input %s".localize().format([config.label.localize()]),
        controller: ref.useTextEditingController(
            config.id, data.get(config.id, form.initialKey)),
        onSaved: (value) {
          if (value.isEmpty) {
            context[config.id] = form.initialKey;
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
    SelectFormConfig form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    return [
      if (config.label.isNotEmpty)
        DividHeadline(
          config.label.localize(),
        )
      else
        const Divid(),
      ListItem(
        title: Text(form.items[data.get(config.id, "")] ?? ""),
      ),
    ];
  }

  @override
  dynamic value(
    VariableConfig config,
    BuildContext context,
    WidgetRef ref,
    bool updated,
  ) {
    return context.get(config.id, "");
  }
}
