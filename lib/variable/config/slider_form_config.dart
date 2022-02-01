part of masamune_module.variable;

/// FormConfig for using Slider.
@immutable
class SliderFormConfig extends FormConfig {
  const SliderFormConfig({
    required this.min,
    required this.max,
    this.divisions,
    this.initialValue,
    this.backgroundColor,
    this.color,
    this.suffixLabel,
  });

  final double min;
  final double max;
  final int? divisions;

  final String? suffixLabel;

  final double? initialValue;

  final Color? backgroundColor;

  final Color? color;
}

@immutable
class SliderFormConfigBuilder extends FormConfigBuilder<SliderFormConfig> {
  const SliderFormConfigBuilder();

  @override
  Iterable<Widget> form(
    VariableConfig config,
    SliderFormConfig form,
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
      FormItemSlider(
        controller: ref.useTextEditingController(
          config.id,
          data.get(config.id, form.initialValue ?? form.min).toString(),
        ),
        min: form.min,
        max: form.max,
        format:
            "0.##${form.suffixLabel != null ? " " + form.suffixLabel! : ""}",
        divisions: form.divisions,
        inaciveColor: form.backgroundColor,
        showLabel: true,
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        activeColor: form.color,
        onSaved: (value) {
          if (value.isEmpty) {
            context[config.id] = form.initialValue ?? form.min;
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
    SliderFormConfig form,
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
        title: Text(data.get(config.id, form.min).toString()),
        trailing: form.suffixLabel.isEmpty
            ? null
            : Text(form.suffixLabel!.localize()),
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
    return context.get(config.id, 0.0);
  }
}
