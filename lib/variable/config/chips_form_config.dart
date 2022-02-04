part of masamune_module.variable;

/// FormConfig for using ChipsField.
@immutable
class ChipsFormConfig extends FormConfig<List<String>> {
  const ChipsFormConfig({
    this.color,
    this.backgroundColor,
    this.chipColor,
    this.chipTextColor,
    this.keyboardType = TextInputType.text,
  });

  final Color? backgroundColor;

  final Color? color;

  final Color? chipColor;

  final Color? chipTextColor;

  final TextInputType keyboardType;
}

@immutable
class ChipsFormConfigBuilder
    extends FormConfigBuilder<List<String>, ChipsFormConfig> {
  const ChipsFormConfigBuilder();

  @override
  Iterable<Widget> form(
    VariableConfig config,
    ChipsFormConfig form,
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
      FormItemChipsField(
        dense: true,
        color: form.color,
        inputType: form.keyboardType,
        hintText: "Input %s".localize().format([config.label.localize()]),
        errorText: "No input %s".localize().format([config.label.localize()]),
        backgroundColor: form.backgroundColor,
        allowEmpty: !config.required,
        controller: ref.useTextEditingController(
          config.id,
          data
              .getAsList(config.id, config.value)
              .map((e) => e.toString())
              .join(","),
        ),
        onSaved: (value) {
          context[config.id] = value;
        },
        chipBuilder: (context, state, value) {
          return Chip(
            label: Text(
              value,
              style: TextStyle(
                color: form.chipTextColor ?? context.theme.textColorOnPrimary,
              ),
            ),
            backgroundColor: form.chipColor ?? context.theme.primaryColor,
            deleteIcon: const Icon(Icons.close),
            deleteIconColor:
                form.chipTextColor ?? context.theme.textColorOnPrimary,
            onDeleted: () {
              state.deleteChip(value);
            },
          );
        },
      ),
    ];
  }

  @override
  Iterable<Widget> view(
    VariableConfig<List<String>> config,
    ChipsFormConfig form,
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
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Wrap(
          children: data.getAsList(config.id, config.value).mapAndRemoveEmpty(
            (value) {
              return Chip(
                label: Text(
                  value,
                  style: TextStyle(
                    color:
                        form.chipTextColor ?? context.theme.textColorOnPrimary,
                  ),
                ),
                backgroundColor: form.chipColor ?? context.theme.primaryColor,
              );
            },
          ),
        ),
      ),
    ];
  }

  @override
  dynamic value(
    VariableConfig<List<String>> config,
    BuildContext context,
    WidgetRef ref,
    bool updated,
  ) {
    return context.getAsList(config.id, config.value);
  }
}
