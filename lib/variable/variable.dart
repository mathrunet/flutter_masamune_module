// Copyright 2022 mathru. All rights reserved.
// ignore_for_file: implementation_imports

library masamune_module.variable;

import 'dart:convert';

import 'package:flutter_quill/src/models/documents/document.dart';
import 'package:flutter_quill/src/widgets/controller.dart';
import 'package:flutter_quill/src/widgets/default_styles.dart';
import 'package:flutter_quill/src/widgets/editor.dart';
import 'package:flutter_quill/src/widgets/toolbar.dart';
import 'package:masamune_module/masamune_module.dart';
import 'package:tuple/tuple.dart';

part 'variable_config_definition.dart';

part 'src/extensions.dart';
part 'src/form_config_builder.dart';
part 'config/date_time_form_config.dart';
part 'config/hidden_form_config.dart';

part 'config/multiple_select_form_config.dart';
part 'config/multiple_text_form_config.dart';

part 'config/select_form_config.dart';

part 'config/slider_form_config.dart';

part 'config/text_form_config.dart';

part 'config/image_form_config.dart';

part 'config/chips_form_config.dart';
part 'config/range_form_config.dart';
part 'config/content_form_config.dart';

const _variables = <FormConfigBuilder>[
  TextFormConfigBuilder(),
  SelectFormConfigBuilder(),
  DateTimeFormConfigBuilder(),
  MultipleSelectFormConfigBuilder(),
  MultipleTextFormConfigBuilder(),
  SliderFormConfigBuilder(),
  HiddenFormConfigBuilder(),
  ImageFormConfigBuilder(),
  ChipsFormConfigBuilder(),
  RangeFormConfigBuilder(),
  ContentFormConfigBuilder(),
];
