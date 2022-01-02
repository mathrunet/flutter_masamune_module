// Copyright 2022 mathru. All rights reserved.
library masamune_module.variable;

import 'package:masamune_module/masamune_module.dart';

part 'extensions.dart';
part 'variable_config_definition.dart';
part 'date_time_form_config.dart';
part 'hidden_form_config.dart';

part 'multiple_select_form_config.dart';
part 'multiple_text_form_config.dart';

part 'select_form_config.dart';

part 'slider_form_config.dart';

part 'text_form_config.dart';

const _variables = <FormConfigBuilder>[
  TextFormConfigBuilder(),
  SelectFormConfigBuilder(),
  DateTimeFormConfigBuilder(),
  MultipleSelectFormConfigBuilder(),
  MultipleTextFormConfigBuilder(),
  SliderFormConfigBuilder(),
  HiddenFormConfigBuilder(),
];
