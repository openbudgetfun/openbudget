import 'package:flutter/material.dart';

/// Every colour OpenBudget draws with.
///
/// This is the only place colour values are written down. Each pair that
/// carries text is checked against WCAG 2.2 AA in `ob_palette_test.dart`:
/// every hue reads at 4.5:1 or better on its page and on its own wash.
abstract final class ObSwatch {
  // Paper (light).
  static const Color paper = Color(0xFFFCF8EF);
  static const Color ink = Color(0xFF262C44);
  static const Color mutedInk = Color(0xFF5C627A);
  static const Color line = Color(0xFFC8C5D3);
  static const Color indigo = Color(0xFF3E4CC9);
  static const Color indigoWash = Color(0xFFE6E8FA);
  static const Color funded = Color(0xFF2B6B45);
  static const Color fundedWash = Color(0xFFDCEBDD);
  static const Color overspent = Color(0xFFB23A2B);
  static const Color overspentWash = Color(0xFFF7DFD8);
  static const Color underfunded = Color(0xFF86560A);
  static const Color underfundedWash = Color(0xFFF6E7B8);
  static const Color plum = Color(0xFF5B45A6);
  static const Color plumWash = Color(0xFFE8E1F5);
  static const Color highlighter = Color(0xFFFFEC8A);

  // Night (dark).
  static const Color night = Color(0xFF1D2131);
  static const Color nightInk = Color(0xFFF4EFE3);
  static const Color nightMutedInk = Color(0xFFB5B7C9);
  static const Color nightLine = Color(0xFF3B4159);
  static const Color dusk = Color(0xFF2D3349);
  static const Color nightIndigo = Color(0xFFA3ACFF);
  static const Color nightFunded = Color(0xFF86D3A0);
  static const Color nightOverspent = Color(0xFFFF9B87);
  static const Color nightUnderfunded = Color(0xFFEDC266);
  static const Color nightPlum = Color(0xFFC3B3F2);
  static const Color nightHighlighter = Color(0xFF4A4426);

  static const Color black = Color(0xFF000000);
  static const Color clear = Color(0x00000000);
}

/// A meaning OpenBudget gives a colour.
///
/// Every tone has a hue for figures, icons, and short labels, and a wash for
/// the field behind them. Text on a wash is always [ObPalette.ink]. Colour is
/// never the only signal: a toned element also says what it means in words.
enum ObTone {
  /// No meaning: ink on the quiet indigo wash.
  neutral,

  /// The brand and the one next step: links, selection, the OpenBudget mark.
  brand,

  /// Money that is in place: funded envelopes, income, positive balances.
  funded,

  /// Money that is missing: overspent envelopes, negative balances, errors.
  overspent,

  /// Money still to find: underfunded goals and warnings.
  underfunded,

  /// Something a person should look at: review, rules, and insights.
  review,
}

/// OpenBudget's colour roles for the active brightness.
///
/// Read it with `Theme.of(context).ob`. Roles are named by purpose, so a
/// widget written against them follows light and dark mode without knowing
/// either palette. Light mode is warm envelope paper with indigo-black ink;
/// dark mode is night paper with paper ink.
@immutable
class ObPalette extends ThemeExtension<ObPalette> {
  const ObPalette({
    required this.canvas,
    required this.surface,
    required this.ink,
    required this.mutedInk,
    required this.line,
    required this.action,
    required this.onAction,
    required this.highlight,
    required this.highlighter,
    required this.brand,
    required this.brandWash,
    required this.funded,
    required this.fundedWash,
    required this.overspent,
    required this.overspentWash,
    required this.underfunded,
    required this.underfundedWash,
    required this.review,
    required this.reviewWash,
  });

  /// The light theme: envelope paper.
  const ObPalette.paper()
    : canvas = ObSwatch.paper,
      surface = ObSwatch.paper,
      ink = ObSwatch.ink,
      mutedInk = ObSwatch.mutedInk,
      line = ObSwatch.line,
      action = ObSwatch.ink,
      onAction = ObSwatch.paper,
      highlight = ObSwatch.indigoWash,
      highlighter = ObSwatch.highlighter,
      brand = ObSwatch.indigo,
      brandWash = ObSwatch.indigoWash,
      funded = ObSwatch.funded,
      fundedWash = ObSwatch.fundedWash,
      overspent = ObSwatch.overspent,
      overspentWash = ObSwatch.overspentWash,
      underfunded = ObSwatch.underfunded,
      underfundedWash = ObSwatch.underfundedWash,
      review = ObSwatch.plum,
      reviewWash = ObSwatch.plumWash;

  /// The dark theme: night paper. Every wash is dusk, the one fill on night.
  const ObPalette.night()
    : canvas = ObSwatch.night,
      surface = ObSwatch.night,
      ink = ObSwatch.nightInk,
      mutedInk = ObSwatch.nightMutedInk,
      line = ObSwatch.nightLine,
      action = ObSwatch.nightInk,
      onAction = ObSwatch.night,
      highlight = ObSwatch.dusk,
      highlighter = ObSwatch.nightHighlighter,
      brand = ObSwatch.nightIndigo,
      brandWash = ObSwatch.dusk,
      funded = ObSwatch.nightFunded,
      fundedWash = ObSwatch.dusk,
      overspent = ObSwatch.nightOverspent,
      overspentWash = ObSwatch.dusk,
      underfunded = ObSwatch.nightUnderfunded,
      underfundedWash = ObSwatch.dusk,
      review = ObSwatch.nightPlum,
      reviewWash = ObSwatch.dusk;

  /// The page behind everything.
  final Color canvas;

  /// Cards, sheets, fields, and bars. Drawn on the same paper as the page;
  /// the pen outline separates them.
  final Color surface;

  /// Text, icons, and outlines. Readable on every surface and wash.
  final Color ink;

  /// Secondary text. At least 4.5:1 on [surface].
  final Color mutedInk;

  /// Dividers and disabled outlines. Decorative only, never text.
  final Color line;

  /// The fill of the one deliberate next step on a page.
  final Color action;

  /// Text and icons on an [action] fill.
  final Color onAction;

  /// The quiet wash under selections, tracks, and neutral chips.
  final Color highlight;

  /// The highlighter stroke behind money that is ready to assign. Carries
  /// [ink].
  final Color highlighter;

  final Color brand;
  final Color brandWash;
  final Color funded;
  final Color fundedWash;
  final Color overspent;
  final Color overspentWash;
  final Color underfunded;
  final Color underfundedWash;
  final Color review;
  final Color reviewWash;

  /// The ink of [tone], for figures, icons, and short labels.
  Color hue(ObTone tone) => switch (tone) {
    ObTone.neutral => ink,
    ObTone.brand => brand,
    ObTone.funded => funded,
    ObTone.overspent => overspent,
    ObTone.underfunded => underfunded,
    ObTone.review => review,
  };

  /// The wash of [tone]. Text on a wash uses [ink].
  Color wash(ObTone tone) => switch (tone) {
    ObTone.neutral => highlight,
    ObTone.brand => brandWash,
    ObTone.funded => fundedWash,
    ObTone.overspent => overspentWash,
    ObTone.underfunded => underfundedWash,
    ObTone.review => reviewWash,
  };

  /// Whether this is the night palette.
  bool get isNight => surface.computeLuminance() < 0.3;

  /// The quiet pen around fields, chips, and secondary controls; 3:1 or
  /// better on [surface] in both modes.
  Color get quietPen => ink.withValues(alpha: isNight ? 0.5 : 0.56);

  /// The firm pen around sheets, menus, and selected markers.
  Color get firmPen => ink.withValues(alpha: 0.82);

  @override
  ObPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? ink,
    Color? mutedInk,
    Color? line,
    Color? action,
    Color? onAction,
    Color? highlight,
    Color? highlighter,
    Color? brand,
    Color? brandWash,
    Color? funded,
    Color? fundedWash,
    Color? overspent,
    Color? overspentWash,
    Color? underfunded,
    Color? underfundedWash,
    Color? review,
    Color? reviewWash,
  }) => ObPalette(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    ink: ink ?? this.ink,
    mutedInk: mutedInk ?? this.mutedInk,
    line: line ?? this.line,
    action: action ?? this.action,
    onAction: onAction ?? this.onAction,
    highlight: highlight ?? this.highlight,
    highlighter: highlighter ?? this.highlighter,
    brand: brand ?? this.brand,
    brandWash: brandWash ?? this.brandWash,
    funded: funded ?? this.funded,
    fundedWash: fundedWash ?? this.fundedWash,
    overspent: overspent ?? this.overspent,
    overspentWash: overspentWash ?? this.overspentWash,
    underfunded: underfunded ?? this.underfunded,
    underfundedWash: underfundedWash ?? this.underfundedWash,
    review: review ?? this.review,
    reviewWash: reviewWash ?? this.reviewWash,
  );

  @override
  ObPalette lerp(ThemeExtension<ObPalette>? other, double t) {
    if (other is! ObPalette) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return ObPalette(
      canvas: mix(canvas, other.canvas),
      surface: mix(surface, other.surface),
      ink: mix(ink, other.ink),
      mutedInk: mix(mutedInk, other.mutedInk),
      line: mix(line, other.line),
      action: mix(action, other.action),
      onAction: mix(onAction, other.onAction),
      highlight: mix(highlight, other.highlight),
      highlighter: mix(highlighter, other.highlighter),
      brand: mix(brand, other.brand),
      brandWash: mix(brandWash, other.brandWash),
      funded: mix(funded, other.funded),
      fundedWash: mix(fundedWash, other.fundedWash),
      overspent: mix(overspent, other.overspent),
      overspentWash: mix(overspentWash, other.overspentWash),
      underfunded: mix(underfunded, other.underfunded),
      underfundedWash: mix(underfundedWash, other.underfundedWash),
      review: mix(review, other.review),
      reviewWash: mix(reviewWash, other.reviewWash),
    );
  }
}

extension ObThemeX on ThemeData {
  /// The active [ObPalette]. Every theme built by `OpenBudgetTheme` carries
  /// one; a bare `ThemeData` falls back to the palette for its brightness.
  ObPalette get ob =>
      extension<ObPalette>() ??
      (brightness == Brightness.dark
          ? const ObPalette.night()
          : const ObPalette.paper());
}

/// The WCAG 2.2 contrast ratio between two opaque colours, from 1 to 21.
double obContrastRatio(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}
