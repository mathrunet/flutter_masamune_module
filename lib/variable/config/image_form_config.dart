part of masamune_module.variable;

/// FormConfig for using Image.
@immutable
class ImageFormConfig extends FormConfig {
  const ImageFormConfig({
    this.color,
    this.backgroundColor,
    this.type = PlatformMediaType.all,
  });

  final Color? backgroundColor;

  final Color? color;

  final PlatformMediaType type;
}

@immutable
class ImageFormConfigBuilder extends FormConfigBuilder<ImageFormConfig> {
  const ImageFormConfigBuilder();

  @override
  Iterable<Widget> form(
    VariableConfig config,
    ImageFormConfig form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    return [
      FormItemMedia(
        dense: true,
        color: form.color,
        hintText: "Select %s".localize().format([config.label.localize()]),
        errorText: "No select %s".localize().format([config.label.localize()]),
        allowEmpty: !config.required,
        controller:
            ref.useTextEditingController(config.id, data.get(config.id, "")),
        onSaved: (value) {
          context[config.id] = value;
        },
        onTap: (onUpdate) async {
          try {
            final media = await context.platform?.mediaDialog(
              context,
              title: "Select %s".localize().format([config.label.localize()]),
              type: form.type,
            );
            if (media == null || media.path.isEmpty) {
              return;
            }
            final uploaded = await context.model
                ?.uploadMedia(media.path!)
                .showIndicator(context);
            if (uploaded.isEmpty) {
              return;
            }
            onUpdate(uploaded!);
          } catch (e) {
            UIDialog.show(
              context,
              title: "Error".localize(),
              text: "%s is not completed.".localize().format(
                ["Upload".localize()],
              ),
              submitText: "Close".localize(),
            );
          }
        },
      ),
    ];
  }

  @override
  Iterable<Widget> view(
    VariableConfig config,
    ImageFormConfig form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    final path = data.get(config.id, "");
    final type = getPlatformMediaType(path);
    switch (type) {
      case PlatformMediaType.image:
        return [
          Image(image: NetworkOrAsset.image(path), fit: BoxFit.cover),
        ];
      case PlatformMediaType.video:
        return [
          Video(NetworkOrAsset.video(path), fit: BoxFit.cover),
        ];
      default:
        return [
          const Empty(),
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
