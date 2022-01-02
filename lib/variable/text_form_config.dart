part of masamune_module.variable;

/// FormConfig for using TextField.
@immutable
class TextFormConfig extends FormConfig {
  const TextFormConfig({
    this.color,
    this.backgroundColor,
    this.obscureText = false,
    this.minLines,
    this.maxLines,
    this.minLength,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  });

  final Color? backgroundColor;

  final Color? color;

  final int? minLines;

  final int? maxLines;

  final TextInputType keyboardType;

  final int? minLength;

  final int? maxLength;

  final bool obscureText;
}

@immutable
class TextFormConfigBuilder extends FormConfigBuilder {
  const TextFormConfigBuilder();

  @override
  bool check(FormConfig? form) {
    return form is TextFormConfig;
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
    if (form is! TextFormConfig) {
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
      FormItemTextField(
        dense: true,
        color: form.color,
        minLines: form.minLines ?? 1,
        hintText: "Input %s".localize().format([config.label.localize()]),
        errorText: "No input %s".localize().format([config.label.localize()]),
        maxLines: form.maxLines,
        minLength: form.minLength,
        maxLength: form.maxLength,
        keyboardType: form.keyboardType,
        backgroundColor: form.backgroundColor,
        obscureText: form.obscureText,
        allowEmpty: !config.required,
        controller:
            ref.useTextEditingController(config.id, data.get(config.id, "")),
        onSaved: (value) {
          context[config.id] = value;
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
    if (form is! TextFormConfig) {
      return [];
    }
    return [
      if (config.label.isNotEmpty)
        DividHeadline(
          config.label.localize(),
        )
      else
        const Divid(),
      ListItem(
        title: UIText(data.get(config.id, "")),
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
