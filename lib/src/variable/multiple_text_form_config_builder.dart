import 'package:masamune/masamune.dart';
import 'variable_config.dart';

@immutable
class MultipleTextFormConfigBuilder extends FormConfigBuilder {
  const MultipleTextFormConfigBuilder();

  @override
  bool check(FormConfig? form) {
    return form is MultipleTextFormConfig;
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
    if (form is! MultipleTextFormConfig) {
      return [];
    }
    return [
      if (config.label.isNotEmpty)
        DividHeadline(
          config.label.localize(),
          prefix: config.required ? context.widgetTheme.requiredIcon : null,
        )
      else
        const Divid(),
      FormItemMultipleTextField(
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
        controller: ref.useTextEditingController(
            config.id, data.getAsList(config.id).join(",")),
        onSaved: (value) {
          context[config.id] = value?.where((e) => e.isNotEmpty).toList() ?? [];
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
    if (form is! MultipleTextFormConfig) {
      return [];
    }
    final list = data.getAsList(config.id);
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
        for (final text in list) ListItem(title: UIText(text)),
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
