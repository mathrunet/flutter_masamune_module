part of masamune_module.variable;

class VariableConfigDefinition {
  const VariableConfigDefinition._();

  /// VariableConfig definition of the name.
  static const VariableConfig<String> name = VariableConfig(
    id: Const.name,
    label: "Name",
    value: "",
    required: true,
    form: TextFormConfig(),
  );

  /// VariableConfig definition of the image.
  static const VariableConfig<String> image = VariableConfig(
    id: Const.media,
    label: "Image",
    value: "assets/default.png",
    form: ImageFormConfig(
      type: PlatformMediaType.image,
    ),
  );

  /// VariableConfig definition of the media.
  static const VariableConfig<String> media = VariableConfig(
    id: Const.media,
    label: "Media",
    value: "assets/default.png",
    form: ImageFormConfig(
      type: PlatformMediaType.all,
    ),
  );

  /// VariableConfig definition of the text.
  static const VariableConfig<String> text = VariableConfig(
    id: Const.text,
    label: "Text",
    value: "",
    form: TextFormConfig(maxLines: 5, minLines: 5),
  );

  /// VariableConfig definition of the text.
  static const VariableConfig<String> content = VariableConfig(
    id: Const.text,
    label: "Text",
    value: "",
    form: ContentFormConfig(),
  );

  /// VariableConfig definition of the tags.
  static const VariableConfig<List<String>> tags = VariableConfig(
    id: Const.tag,
    label: "Tag",
    value: [],
    form: ChipsFormConfig(),
  );

  /// VariableConfig definition of the gender.
  static const VariableConfig<String> gender = VariableConfig(
    id: "gender",
    label: "gender",
    value: "other",
    form: SelectFormConfig(
      items: {
        "male": "Male",
        "female": "Female",
        "other": "Others",
      },
    ),
  );

  /// VariableConfig definition of the age.
  static const VariableConfig<String> ages = VariableConfig(
    id: "ages",
    label: "Ages",
    value: "twenties",
    form: SelectFormConfig(
      items: {
        "teens": "10s",
        "twenties": "20s",
        "thirties": "30s",
        "forties": "40s",
        "fifties": "50s",
        "sixties": "60s",
      },
    ),
  );

  /// VariableConfig definition of the order.
  static const VariableConfig<double> order = VariableConfig(
    id: "order",
    label: "Order",
    value: 0.0,
    form: HiddenFormConfig(
      type: HiddenFormConfigType.initialOrder,
      applyOnUpdate: false,
    ),
  );

  /// VariableConfig definition of the created time.
  static const VariableConfig<int> createdTime = VariableConfig(
    id: "createdTime",
    label: "Created time",
    value: 0,
    form: HiddenFormConfig(
      type: HiddenFormConfigType.dateTimeNow,
      applyOnUpdate: false,
    ),
  );

  /// VariableConfig definition of the updated time.
  static const VariableConfig<int> updatedTime = VariableConfig(
    id: "updatedTime",
    label: "Updated time",
    value: 0,
    form: HiddenFormConfig(
      type: HiddenFormConfigType.dateTimeNow,
    ),
  );

  /// VariableConfig definition of the name.
  static const VariableConfig<int> number = VariableConfig(
    id: "number",
    label: "Number",
    value: 0,
    form: TextFormConfig(
      keyboardType: TextInputType.number,
      inputFormatter: TextInputFormatterConfig(r"[0-9]"),
    ),
  );

  /// VariableConfig definition of the name.
  static const VariableConfig<num> range = VariableConfig(
    id: "range",
    label: "Range",
    value: 0,
    form: RangeFormConfig(
      inputFormatter: TextInputFormatterConfig(r"[0-9]"),
    ),
  );
}
