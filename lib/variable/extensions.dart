part of masamune_module.variable;

extension VariableConfigBuildExtensions on VariableConfig {
  Iterable<Widget> buildView(
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (onlyRequired && !this.required) {
      return const [];
    }
    if (!show) {
      return const [];
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
      return const [];
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

  dynamic _buildValue(
    BuildContext context,
    WidgetRef ref, {
    bool updated = true,
  }) {
    for (final variable in _variables) {
      if (!variable.check(form)) {
        continue;
      }
      return variable.value(
        this,
        context,
        ref,
        updated,
      );
    }
    return null;
  }

  dynamic buildValue(
    DynamicMap data,
    BuildContext context,
    WidgetRef ref, {
    bool onlyRequired = false,
    bool updated = true,
  }) {
    if (onlyRequired && !this.required) {
      return;
    }
    final value = _buildValue(
      context,
      ref,
      updated: updated,
    );
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
      return const [];
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
      return const [];
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
          value: (val) => val._buildValue(
            context,
            ref,
            updated: false,
          ),
        );
  }

  void buildValue(
    DynamicMap data,
    BuildContext context,
    WidgetRef ref, {
    bool onlyRequired = false,
    bool updated = true,
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
        updated: updated,
      );
    }
  }
}
