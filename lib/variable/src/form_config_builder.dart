part of masamune_module.variable;

@immutable
abstract class FormConfigBuilder<TVariable, TForm extends FormConfig> {
  const FormConfigBuilder();
  bool check(FormConfig? form) {
    return form is TForm;
  }

  Iterable<Widget> view(
    VariableConfig<TVariable> config,
    TForm form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  });

  Iterable<Widget> form(
    VariableConfig<TVariable> config,
    TForm form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  });

  dynamic value(
    VariableConfig<TVariable> config,
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
      config as VariableConfig<TVariable>,
      // ignore: cast_nullable_to_non_nullable
      form as TForm,
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
      config as VariableConfig<TVariable>,
      // ignore: cast_nullable_to_non_nullable
      form as TForm,
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
      config as VariableConfig<TVariable>,
      context,
      ref,
      updated,
    );
  }
}
