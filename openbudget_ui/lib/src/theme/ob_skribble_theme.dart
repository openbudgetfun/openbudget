import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/openbudget_theme.dart';
import 'package:skribble/skribble.dart';

/// Binds Skribble's hand-drawn components to the active [ObPalette].
///
/// Wired components read ink, surface, marker, and muted-ink roles from the
/// resolved palette, so hand-drawn controls follow light and dark mode
/// without raw colours reaching widgets.
abstract final class ObSkribbleTheme {
  /// Resolves the wired theme for [context]'s palette.
  ///
  /// Decorative ink motion is disabled when the platform requests reduced
  /// animations; the final rough shape then appears immediately.
  static WiredThemeData of(
    BuildContext context, {
    WiredRoughness roughnessLevel = WiredRoughness.expressive,
  }) {
    final palette = Theme.of(context).ob;
    return WiredThemeData(
      borderColor: palette.ink,
      textColor: palette.ink,
      disabledTextColor: palette.mutedInk,
      fillColor: palette.surface,
      // Progress fills, slider and switch tracks, and selections take the
      // quiet highlight; ink draws the shape and the value on top.
      markerColor: palette.highlight,
      strokeWidth: 2.5,
      roughnessLevel: roughnessLevel,
      fontFamily: obTextTypeface,
      motionEnabled: !MediaQuery.disableAnimationsOf(context),
    );
  }
}

/// Renders descendant Skribble components with the active OpenBudget palette.
///
/// The app installs one scope above its navigator, so every route, dialog,
/// and sheet draws Wired components in OpenBudget ink. A nested scope may
/// pick a different [roughnessLevel] for one section.
class ObWiredScope extends HookWidget {
  const ObWiredScope({
    required this.child,
    this.roughnessLevel = WiredRoughness.expressive,
    super.key,
  });

  /// Coordinated border preset for this subtree.
  final WiredRoughness roughnessLevel;

  final Widget child;

  @override
  Widget build(BuildContext context) => WiredThemeScope(
    data: ObSkribbleTheme.of(context, roughnessLevel: roughnessLevel),
    child: child,
  );
}
