import 'package:masamune/masamune.dart';
import 'package:masamune_module/src/variable/date_time_form_config_builder.dart';
import 'package:masamune_module/src/variable/multiple_select_form_config_builder.dart';
import 'package:masamune_module/src/variable/multiple_text_form_config_builder.dart';
import 'package:masamune_module/src/variable/select_form_config_builder.dart';
import 'package:masamune_module/src/variable/text_form_config_builder.dart';

const _variables = <FormConfigBuilder>[
  TextFormConfigBuilder(),
  SelectFormConfigBuilder(),
  DateTimeFormConfigBuilder(),
  MultipleSelectFormConfigBuilder(),
  MultipleTextFormConfigBuilder(),
];

@immutable
abstract class FormConfigBuilder {
  const FormConfigBuilder();
  bool check(FormConfig? form);

  Iterable<Widget> view(
    VariableConfig config,
    FormConfig? form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  });

  Iterable<Widget> form(
    VariableConfig config,
    FormConfig? form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  });

  dynamic value(
    VariableConfig config,
    BuildContext context,
    WidgetRef ref,
  );
}

extension VariableConfigBuildExtensions on VariableConfig {
  Iterable<Widget> buildView(
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (onlyRequired && !this.required) {
      return [];
    }
    for (final variable in _variables) {
      if (!variable.check(form)) {
        continue;
      }
      return variable.view(
        this,
        form,
        context,
        ref,
        data: data,
        onlyRequired: onlyRequired,
      );
    }
    return const [];
  }

  Iterable<Widget> buildForm(
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (onlyRequired && !this.required) {
      return [];
    }
    for (final variable in _variables) {
      if (!variable.check(form)) {
        continue;
      }
      return variable.form(
        this,
        form,
        context,
        ref,
        data: data,
        onlyRequired: onlyRequired,
      );
    }
    return const [];
  }

  dynamic _buildValue(BuildContext context, WidgetRef ref) {
    for (final variable in _variables) {
      if (!variable.check(form)) {
        continue;
      }
      return variable.value(
        this,
        context,
        ref,
      );
    }
    return null;
  }

  dynamic buildValue(
    DynamicMap data,
    BuildContext context,
    WidgetRef ref, {
    bool onlyRequired = false,
  }) {
    if (onlyRequired && !this.required) {
      return;
    }
    final value = _buildValue(context, ref);
    if (value == null) {
      return;
    }
    data[id] = value;
  }
}

extension VariableConfigListExtensions on Iterable<VariableConfig>? {
  Iterable<Widget> buildView(
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (this == null) {
      return [];
    }
    return this!.expand((e) =>
        e.buildView(context, ref, data: data, onlyRequired: onlyRequired));
  }

  Iterable<Widget> buildForm(
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (this == null) {
      return [];
    }
    return this!.expand((e) =>
        e.buildForm(context, ref, data: data, onlyRequired: onlyRequired));
  }

  Map<String, dynamic> buildMap(
    BuildContext context,
    WidgetRef ref, {
    bool onlyRequired = false,
  }) {
    if (this == null) {
      return const {};
    }
    return this!
        .where((e) => !onlyRequired || e.required)
        .toMap<String, dynamic>(
          key: (val) => val.id,
          value: (val) => val._buildValue(context, ref),
        );
  }

  void buildValue(
    DynamicMap data,
    BuildContext context,
    WidgetRef ref, {
    bool onlyRequired = false,
  }) {
    if (this == null) {
      return;
    }
    for (final value in this!) {
      value.buildValue(
        data,
        context,
        ref,
        onlyRequired: onlyRequired,
      );
    }
  }
}
