import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';

class WiredCard extends HookWidget {
  final Widget? child;
  final bool fill;
  final double? height;

  const WiredCard({
    super.key,
    this.child,
    this.fill = false,
    this.height = 130.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      height: height,
      child: Stack(
        children: [
          WiredCanvas(
            painter: WiredRectangleBase(),
            fillerType: fill ? RoughFilter.hachureFiller : RoughFilter.noFiller,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Card(
                  color: Colors.transparent,
                  shadowColor: Colors.transparent,
                  child: child,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
