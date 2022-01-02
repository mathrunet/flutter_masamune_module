import 'package:masamune/masamune.dart';
import 'variable_config.dart';

@immutable
class SliderFormConfigBuilder extends FormConfigBuilder {
  const SliderFormConfigBuilder();
  @override
  bool check(FormConfig? form) {
    return form is SliderFormConfig;
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
    if (form is! SliderFormConfig) {
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
    FormConfig? form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (form is! SliderFormConfig) {
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
