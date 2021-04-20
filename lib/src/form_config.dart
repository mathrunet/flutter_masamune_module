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

  Widget build(BuildContext context, Map<String, dynamic>? input) {
    switch (formType) {
      case FormType.submit:
        return FormItemSubmit(
          name.localize(),
          color: color,
          backgroundColor: backgroundColor,
          icon: icon,
          onPressed: onSubmit,
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
}
