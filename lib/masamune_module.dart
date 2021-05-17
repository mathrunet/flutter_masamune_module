// Copyright 2021 mathru. All rights reserved.

/// The module library of Masamune framework.
///
/// To use, import `package:masamune_module/masamune_module.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune_module;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masamune/masamune.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sprintf/sprintf.dart';
import 'package:share/share.dart';
export 'package:masamune/masamune.dart';

part 'src/form_config.dart';
part 'src/menu_config.dart';
part 'src/tab_config.dart';

part 'common/login_and_register.dart';

part 'home/home.dart';
part 'home/tile_menu_home.dart';

part 'gallery/gallery.dart';

part 'information/information.dart';

part 'post/post.dart';

part 'questionnaire/questionnaire.dart';
