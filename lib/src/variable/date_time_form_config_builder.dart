import 'package:masamune/masamune.dart';
import 'variable_config.dart';

@immutable
class DateTimeFormConfigBuilder extends FormConfigBuilder {
  const DateTimeFormConfigBuilder();
  @override
  bool check(FormConfig? form) {
    return form is DateTimeFormConfig;
  }

  FormItemDateTimeFieldPickerType _type(DateTimeFormConfig form) {
    switch (form.type) {
      case DateTimeFormConfigType.date:
        return FormItemDateTimeFieldPickerType.date;
      case DateTimeFormConfigType.time:
        return FormItemDateTimeFieldPickerType.time;
      default:
        return FormItemDateTimeFieldPickerType.dateTime;
    }
  }

  String _tryParseFromDateTime(DateTimeFormConfig form, DateTime dateTime) {
    switch (form.type) {
      case DateTimeFormConfigType.date:
        return FormItemDateTimeField.formatDate(
            dateTime.millisecondsSinceEpoch);
      case DateTimeFormConfigType.time:
        return FormItemDateTimeField.formatTime(
            dateTime.millisecondsSinceEpoch);
      default:
        return FormItemDateTimeField.formatDateTime(
            dateTime.millisecondsSinceEpoch);
    }
  }

  DateTime? _value(
    VariableConfig config,
    DateTimeFormConfig form,
    DynamicMap? data,
  ) {
    if (data.containsKey(config.id)) {
      return data.getAsDateTime(config.id);
    }
    if (form.initialDate.isEmpty) {
      return null;
    }
    return FormItemDateTimeField.tryParseFromDate(form.initialDate!);
  }

  Future<DateTime> Function(BuildContext context, DateTime dateTime)
      _onShowPicker(
    VariableConfig config,
    DateTimeFormConfig form,
  ) {
    final startDate = form.startSelectingDate.isEmpty
        ? null
        : FormItemDateTimeField.tryParseFromDate(form.startSelectingDate!);
    final endDate = form.endSelectingDate.isEmpty
        ? null
        : FormItemDateTimeField.tryParseFromDate(form.endSelectingDate!);
    switch (form.type) {
      case DateTimeFormConfigType.date:
        return FormItemDateTimeField.datePicker(
          startDate: startDate,
          endDate: endDate,
        );
      case DateTimeFormConfigType.time:
        return FormItemDateTimeField.timePicker();
      default:
        return FormItemDateTimeField.dateTimePicker(
          startDate: startDate,
          endDate: endDate,
        );
    }
  }

  @override
  Iterable<Widget> form(
    VariableConfig config,
    FormConfig? form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (form is! DateTimeFormConfig) {
      return [];
    }
    final initialValue = _value(config, form, data);
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
      FormItemDateTimeField(
        dense: true,
        type: _type(form),
        controller: ref.useTextEditingController(
          config.id,
          initialValue != null ? _tryParseFromDateTime(form, initialValue) : "",
        ),
        hintText: "Input %s".localize().format([config.label.localize()]),
        errorText: "No input %s".localize().format([config.label.localize()]),
        allowEmpty: !config.required,
        onShowPicker: _onShowPicker(config, form),
        onSaved: (value) {
          if (value != null) {
            context[config.id] = value;
          } else {
            context[config.id] = initialValue;
          }
        },
      ),
    ];
  }

  @override
  Iterable<Widget> view(
    VariableConfig config,
    FormConfig? form,
    BuildContext context,
    WidgetRef ref, {
    DynamicMap? data,
    bool onlyRequired = false,
  }) {
    if (form is! DateTimeFormConfig) {
      return [];
    }
    final initialValue = _value(config, form, data);
    return [
      if (config.label.isNotEmpty)
        DividHeadline(
          config.label.localize(),
        )
      else
        const Divid(),
      ListItem(
        title: Text(
          initialValue != null ? _tryParseFromDateTime(form, initialValue) : "",
        ),
      ),
    ];
  }

  @override
  dynamic value(
    VariableConfig config,
    BuildContext context,
    WidgetRef ref,
    bool updated,
  ) {
    return context.get<DateTime?>(config.id, null)?.millisecondsSinceEpoch;
  }
}
