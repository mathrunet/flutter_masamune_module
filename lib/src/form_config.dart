part of masamune_module;

enum FormType {
  submit,
  label,
  textField,
}

class FormConfig {
  const FormConfig({
    required this.id,
    required this.name,
    required this.formType,
    this.onSubmit,
    this.icon,
    this.color,
    this.backgroundColor,
    this.obscureText = false,
    this.minLines,
    this.maxLines,
    this.minLength,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  });

  final String id;

  final String name;

  final FormType formType;

  final Color? backgroundColor;

  final Color? color;

  final IconData? icon;

  final void Function()? onSubmit;

  final TextInputType keyboardType;

  final int? minLines;

  final int? maxLines;

  final int? minLength;

  final int? maxLength;

  final bool obscureText;

  Widget build(
    BuildContext context, [
    DynamicMap? input,
    void Function()? onSubmit,
  ]) {
    switch (formType) {
      case FormType.submit:
        return FormItemSubmit(
          name.localize(),
          color: color,
          backgroundColor: backgroundColor,
          icon: icon,
          onPressed: this.onSubmit ?? onSubmit,
        );
      case FormType.label:
        return FormItemLabel(
          name.localize(),
          color: color,
          backgroundColor: backgroundColor,
        );
      case FormType.textField:
        return FormItemTextField(
          controller: useMemoizedTextEditingController(input.get(id, "")),
          labelText: name.localize(),
          keyboardType: keyboardType,
          minLines: minLines ?? 1,
          maxLines: maxLines,
          minLength: minLength,
          maxLength: maxLength,
          obscureText: obscureText,
          onSaved: (value) {
            context[id] = value;
          },
          color: color,
          backgroundColor: backgroundColor,
        );
    }
  }

  static FormConfig? _fromMap(DynamicMap map) {
    if (map.isEmpty ||
        !map.containsKey("id") ||
        !map.containsKey("name") ||
        !map.containsKey("type")) {
      return null;
    }

    return FormConfig(
      id: map.get("id", ""),
      name: map.get("name", ""),
      formType: FormType.values.firstWhere(
          (e) => e.index == map.get("type", FormType.textField.index)),
      icon: map.getAsMap("icon").toIconData(),
      color: map.getAsMap("color").toColor(),
      backgroundColor: map.getAsMap("backgroundColor").toColor(),
      obscureText: map.get("obscureText", false),
      minLines: map.get<int?>("minLines", null),
      maxLines: map.get<int?>("maxLines", null),
      minLength: map.get<int?>("minLength", null),
      maxLength: map.get<int?>("maxLength", null),
      keyboardType: TextInputType.values.firstWhere(
          (e) => e.index == map.get("keyboardType", TextInputType.text.index)),
    );
  }

  DynamicMap toMap() {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "type": formType.index,
      if (icon != null) "icon": icon.toMap(),
      if (color != null) "color": color.toMap(),
      if (backgroundColor != null) "backgroundColor": backgroundColor.toMap(),
      "obscureText": obscureText,
      if (minLines != null) "minLines": minLines,
      if (maxLines != null) "maxLines": maxLines,
      if (minLength != null) "minLength": minLength,
      if (maxLength != null) "maxLength": maxLength,
      "keyboardType": keyboardType,
    };
  }
}
