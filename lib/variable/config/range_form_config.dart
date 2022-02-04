part of masamune_module.variable;

/// FormConfig for using rage TextField.
@immutable
class RangeFormConfig extends FormConfig<num> {
  const RangeFormConfig({
    this.color,
    this.backgroundColor,
    this.minLength,
    this.maxLength,
    this.keyboardType = TextInputType.number,
    this.inputFormatter,
    this.prefix,
    this.prefixText,
    this.suffix,
    this.suffixText,
    this.minKeySuffix = "Min",
    this.maxKeySuffix = "Max",
  });

  final String? prefixText;
  final String? suffixText;

  final Widget? prefix;
  final Widget? suffix;

  final String minKeySuffix;
  final String maxKeySuffix;

  final Color? backgroundColor;

  final Color? color;

  final TextInputType keyboardType;

  final int? minLength;

  final int? maxLength;

  final TextInputFormatterConfig? inputFormatter;
}

@immutable
class RangeFormConfigBuilder extends FormConfigBuilder<num, RangeFormConfig> {
  const RangeFormConfigBuilder();

  @override
  Iterable<Widget> form(
    VariableConfig<num> config,
    RangeFormConfig form,
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
      Row(
        children: [
          FormItemTextField(
            dense: true,
            color: form.color,
            inputFormatters: [
              if (form.inputFormatter != null) form.inputFormatter!.value
            ],
            errorText:
                "No input %s".localize().format([config.label.localize()]),
            minLength: form.minLength,
            maxLength: form.maxLength,
            keyboardType: form.keyboardType,
            backgroundColor: form.backgroundColor,
            allowEmpty: !config.required,
            controller: ref.useTextEditingController(
                config.id, data.get("${config.id}${form.minKeySuffix}", "")),
            onSaved: (value) {
              context["${config.id}${form.minKeySuffix}"] = value;
            },
            prefix: form.prefix ??
                (form.prefixText != null
                    ? Text(form.prefixText?.localize() ?? "")
                    : null),
            suffix: form.suffix ??
                (form.suffixText != null
                    ? Text(form.suffixText?.localize() ?? "")
                    : null),
          ),
          const Space.width(8),
          const Text("～"),
          const Space.width(8),
          FormItemTextField(
            dense: true,
            color: form.color,
            inputFormatters: [
              if (form.inputFormatter != null) form.inputFormatter!.value
            ],
            errorText:
                "No input %s".localize().format([config.label.localize()]),
            minLength: form.minLength,
            maxLength: form.maxLength,
            keyboardType: form.keyboardType,
            backgroundColor: form.backgroundColor,
            allowEmpty: !config.required,
            controller: ref.useTextEditingController(
                config.id,
                data
                    .get("${config.id}${form.maxKeySuffix}", config.value)
                    .toString()),
            onSaved: (value) {
              context["${config.id}${form.maxKeySuffix}"] = value;
            },
            prefix: form.prefix ??
                (form.prefixText != null
                    ? Text(form.prefixText?.localize() ?? "")
                    : null),
            suffix: form.suffix ??
                (form.suffixText != null
                    ? Text(form.suffixText?.localize() ?? "")
                    : null),
          ),
        ],
      ),
    ];
  }

  @override
  Iterable<Widget> view(
    VariableConfig<num> config,
    RangeFormConfig form,
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
        title: UIText(
            "${data.get("${config.id}${form.minKeySuffix}", config.value)} ～ ${data.get("${config.id}${form.maxKeySuffix}", config.value)}"),
      ),
    ];
  }

  @override
  dynamic value(
    VariableConfig<num> config,
    BuildContext context,
    WidgetRef ref,
    bool updated,
  ) {
    return context.get(config.id, config.value);
  }
}
