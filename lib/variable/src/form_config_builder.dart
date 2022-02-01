part of masamune_module.variable;

@immutable
abstract class FormConfigBuilder<T extends FormConfig> {
  const FormConfigBuilder();
  bool check(FormConfig? form) {
    return form is T;
  }

  Iterable<Widget> view(
    VariableConfig config,
    T form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  });

  Iterable<Widget> form(
    VariableConfig config,
    T form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  });

  dynamic value(
    VariableConfig config,
    BuildContext context,
    WidgetRef ref,
    bool updated,
  );

  Iterable<Widget> _view(
    VariableConfig config,
    FormConfig? form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (form == null || !check(form)) {
      return [];
    }
    return view(
      config,
      // ignore: cast_nullable_to_non_nullable
      form as T,
      context,
      ref,
      data: data,
      onlyRequired: onlyRequired,
    );
  }

  Iterable<Widget> _form(
    VariableConfig config,
    FormConfig? form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (form == null || !check(form)) {
      return [];
    }
    return this.form(
      config,
      // ignore: cast_nullable_to_non_nullable
      form as T,
      context,
      ref,
      data: data,
      onlyRequired: onlyRequired,
    );
  }

  dynamic _value(
    VariableConfig config,
    BuildContext context,
    WidgetRef ref,
    bool updated,
  ) {
    return value(
      config,
      context,
      ref,
      updated,
    );
  }
}
