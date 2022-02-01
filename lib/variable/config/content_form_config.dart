part of masamune_module.variable;

const _kQuillToolbarHeight = 80;

/// FormConfig for using TextField.
@immutable
class ContentFormConfig extends FormConfig {
  const ContentFormConfig({
    this.color,
    this.subColor,
    this.backgroundColor,
    this.toolbarColor,
    this.type = PostEditingType.planeText,
  });

  final Color? backgroundColor;

  final Color? color;

  final Color? subColor;

  final PostEditingType type;

  final Color? toolbarColor;
}

@immutable
class ContentFormConfigBuilder extends FormConfigBuilder<ContentFormConfig> {
  const ContentFormConfigBuilder();

  @override
  Iterable<Widget> form(
    VariableConfig config,
    ContentFormConfig form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
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
      ..._buildForm(config, form, context, ref, data, onlyRequired),
    ];
  }

  List<Widget> _buildForm(
      VariableConfig config,
      ContentFormConfig form,
      BuildContext context,
      WidgetRef ref,
      DynamicMap? data,
      bool onlyRequired) {
    final text = data.get(config.id, "");
    switch (form.type) {
      case PostEditingType.wysiwyg:
        final controller = ref.cache(
          config.id,
          () => text.isEmpty
              ? QuillController.basic()
              : QuillController(
                  document: Document.fromJson(jsonDecode(text)),
                  selection: const TextSelection.collapsed(offset: 0),
                ),
          keys: [text],
        );

        return [
          Theme(
            data: context.theme.copyWith(
                canvasColor:
                    form.toolbarColor ?? context.theme.scaffoldBackgroundColor),
            child: QuillToolbar.basic(
              controller: controller,
              toolbarIconSize: 24,
              multiRowsDisplay: false,
              onImagePickCallback: (file) async {
                if (file.path.isEmpty || !file.existsSync()) {
                  return "";
                }
                return await context.model!.uploadMedia(file.path);
              },
            ),
          ),
          Divid(color: context.theme.dividerColor.withOpacity(0.25)),
          Container(
            color: form.backgroundColor,
            height: (context.mediaQuery.size.height -
                    context.mediaQuery.viewInsets.bottom -
                    kToolbarHeight -
                    _kQuillToolbarHeight)
                .limitLow(0),
            child: QuillEditor(
              scrollController: ScrollController(),
              scrollable: true,
              focusNode: ref.useFocusNode("${config.id}FocusNode", false),
              autoFocus: false,
              controller: controller,
              placeholder:
                  "Input %s".localize().format([config.label.localize()]),
              readOnly: false,
              expands: true,
              padding: const EdgeInsets.all(12),
              customStyles: DefaultStyles(
                color: form.color,
                placeHolder: DefaultTextBlockStyle(
                  TextStyle(
                      color: form.subColor ?? context.theme.disabledColor,
                      fontSize: 16),
                  const Tuple2(16, 0),
                  const Tuple2(0, 0),
                  null,
                ),
              ),
            ),
          ),
        ];
      default:
        return [
          SizedBox(
            height: (context.mediaQuery.size.height -
                    context.mediaQuery.viewInsets.bottom -
                    kToolbarHeight -
                    _kQuillToolbarHeight)
                .limitLow(0),
            child: FormItemTextField(
              dense: true,
              expands: true,
              backgroundColor: form.backgroundColor,
              color: form.color,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              hintText: "Input %s".localize().format([config.label.localize()]),
              errorText:
                  "No input %s".localize().format([config.label.localize()]),
              subColor: form.subColor ?? context.theme.disabledColor,
              controller: ref.useTextEditingController(config.id, text),
              onSaved: (value) {
                context[config.id] = value;
              },
            ),
          ),
        ];
    }
  }

  @override
  Iterable<Widget> view(
    VariableConfig config,
    ContentFormConfig form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    return [
      if (config.label.isNotEmpty)
        DividHeadline(
          config.label.localize(),
        )
      else
        const Divid(),
      ..._buildView(config, form, context, ref, data, onlyRequired),
    ];
  }

  List<Widget> _buildView(
      VariableConfig config,
      ContentFormConfig form,
      BuildContext context,
      WidgetRef ref,
      DynamicMap? data,
      bool onlyRequired) {
    final text = data.get(config.id, "");

    switch (form.type) {
      case PostEditingType.wysiwyg:
        final controller = ref.cache(
          config.id,
          () => text.isEmpty
              ? QuillController.basic()
              : QuillController(
                  document: Document.fromJson(jsonDecode(text)),
                  selection: const TextSelection.collapsed(offset: 0),
                ),
          keys: [text],
        );

        return [
          Container(
            color: form.backgroundColor,
            child: QuillEditor(
              scrollController: ScrollController(),
              scrollable: false,
              focusNode: ref.useFocusNode("${config.id}FocusNode", false),
              autoFocus: false,
              controller: controller,
              placeholder: "",
              readOnly: true,
              expands: false,
              padding: EdgeInsets.zero,
              customStyles: DefaultStyles(
                color: form.color,
                placeHolder: DefaultTextBlockStyle(
                    TextStyle(color: context.theme.disabledColor, fontSize: 16),
                    const Tuple2(16, 0),
                    const Tuple2(0, 0),
                    null),
              ),
            ),
          ),
        ];
      default:
        return [
          Container(
            color: form.backgroundColor,
            child: UIMarkdown(
              text,
              fontSize: 16,
              color: form.color,
              onTapLink: (url) {
                ref.open(url);
              },
            ),
          ),
        ];
    }
  }

  @override
  dynamic value(
    VariableConfig config,
    BuildContext context,
    WidgetRef ref,
    bool updated,
  ) {
    return context.get(config.id, "");
  }
}
