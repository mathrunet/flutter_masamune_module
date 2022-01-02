part of masamune_module.variable;

class VariableConfigDefinition {
  const VariableConfigDefinition._();

  /// VariableConfig definition of the name.
  static const VariableConfig name = VariableConfig(
    id: Const.name,
    label: "Name",
    required: true,
    form: TextFormConfig(),
  );

  /// VariableConfig definition of the text.
  static const VariableConfig text = VariableConfig(
    id: Const.text,
    label: "Text",
    form: TextFormConfig(maxLines: 5, minLines: 5),
  );

  /// VariableConfig definition of the gender.
  static const VariableConfig gender = VariableConfig(
    id: "gender",
    label: "gender",
    form: SelectFormConfig(
      items: {
        "male": "Male",
        "female": "Female",
        "other": "Others",
      },
      initialKey: "other",
    ),
  );

  /// VariableConfig definition of the age.
  static const VariableConfig ages = VariableConfig(
    id: "ages",
    label: "Ages",
    form: SelectFormConfig(
      items: {
        "teens": "10s",
        "twenties": "20s",
        "thirties": "30s",
        "forties": "40s",
        "fifties": "50s",
        "sixties": "60s",
      },
      initialKey: "twenties",
    ),
  );

  /// VariableConfig definition of the order.
  static const VariableConfig order = VariableConfig(
    id: "order",
    label: "Order",
    form: HiddenFormConfig(
      type: HiddenFormConfigType.initialOrder,
      applyOnUpdate: false,
    ),
  );

  /// VariableConfig definition of the created time.
  static const VariableConfig createdTime = VariableConfig(
    id: "createdTime",
    label: "Created time",
    form: HiddenFormConfig(
      type: HiddenFormConfigType.dateTimeNow,
      applyOnUpdate: false,
    ),
  );

  /// VariableConfig definition of the updated time.
  static const VariableConfig updatedTime = VariableConfig(
    id: "updatedTime",
    label: "Updated time",
    form: HiddenFormConfig(
      type: HiddenFormConfigType.dateTimeNow,
    ),
  );
}
