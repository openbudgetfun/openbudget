import 'dart:ui';

import 'package:openbudget_wired/rough.dart';

abstract class WiredPainterBase {
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  );
}
