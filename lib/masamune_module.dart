// Copyright 2022 mathru. All rights reserved.

/// The module library of Masamune framework.
///
/// To use, import `package:masamune_module/masamune_module.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune_module;

import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:tuple/tuple.dart';

import 'masamune_module.dart';

export 'package:masamune/masamune.dart';

export 'component/chat/chat.dart';
export 'component/common/login_and_register.dart';
export 'component/common/sns_login.dart';
export 'component/detail/detail.dart';
export 'component/home/bottom_tab_home.dart';
export 'component/home/home.dart';
export 'component/media/gallery.dart';
export 'component/media/single_media.dart';
export 'component/menu/menu.dart';
export 'component/post/post.dart';
export 'component/questionnaire/questionnaire.dart';
export 'component/user/user.dart';
export 'component/user/user_account.dart';

part 'src/group_config.dart';
part 'src/login_config.dart';

part 'variable/content_form_config.dart';
part 'variable/default_module_form_config_builders.dart';
part 'variable/module_variable_config_definition.dart';
