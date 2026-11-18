import 'package:flutter/material.dart';

/// Every colour OpenBudget draws with.
///
/// This is the only place colour values are written down. OpenBudget is
/// printed, not painted: a sunny cream page, paper-white sheets, one deep
/// violet ink, and saturated spot inks (hot pink, teal, sunflower, cobalt,
/// tangerine, lilac) laid down flat and slightly off-register. Vivid inks are
/// fills, washes and accents; words on them are always the deep ink. Each pair that carries text is checked against
/// WCAG 2.2 AA in `ob_palette_test.dart`.
abstract final class ObSwatch {
  // Day (light).

  /// The page: sunny cream, so white sheets lift off it.
  static const Color newsprint = Color(0xFFFFF4DE);

  /// Sheets, cards, fields and bars: clean paper white.
  static const Color paper = Color(0xFFFFFFFF);

  /// The one ink every outline, figure and word is drawn in.
  static const Color ink = Color(0xFF1A1233);
  static const Color mutedInk = Color(0xFF5B4F7A);

  /// The pencil line: dividers and disabled outlines, never text.
  static const Color line = Color(0xFFE8D9BC);

  /// The quiet wash under tracks, selections and neutral chips.
  static const Color fog = Color(0xFFF5EAD3);

  /// The brand's spot ink. A fill that carries [ink]; never text.
  static const Color pink = Color(0xFFFF3D8B);

  /// [pink] deepened until it reads as text on paper.
  static const Color pinkText = Color(0xFFB8005A);
  static const Color pinkWash = Color(0xFFFFD1E4);

  /// The second spot ink, printed off-register under heroes and the mark.
  static const Color teal = Color(0xFF00C2A8);

  /// The highlighter, the coin and the wax seal.
  static const Color sunflower = Color(0xFFFFC400);

  /// The third spot ink: charts and review.
  static const Color cobalt = Color(0xFF2F45E0);
  static const Color cobaltWash = Color(0xFFD6DEFF);

  /// Cobalt lightened into a fill that carries [ink], for chart series.
  static const Color sky = Color(0xFF5C8DFF);

  /// Chart ink for a fifth and sixth series.
  static const Color tangerine = Color(0xFFFF7A1F);
  static const Color lilac = Color(0xFFA77BFF);

  static const Color funded = Color(0xFF0A7040);
  static const Color fundedWash = Color(0xFFC2F5D5);
  static const Color overspent = Color(0xFFBA1E15);
  static const Color overspentWash = Color(0xFFFFD6CC);
  static const Color underfunded = Color(0xFF8A5000);
  static const Color underfundedWash = Color(0xFFFFE58A);

  // Night (dark).

  /// The night page: deep violet, the day ink thinned.
  static const Color night = Color(0xFF140F26);

  /// Night sheets, lifted a step off the page.
  static const Color nightPaper = Color(0xFF1F1838);

  /// Chalk: the night ink.
  static const Color chalk = Color(0xFFFFF6E5);
  static const Color nightMutedInk = Color(0xFFC0B6DD);
  static const Color nightLine = Color(0xFF3D3360);
  static const Color nightFog = Color(0xFF2C2448);
  static const Color nightPink = Color(0xFFFF5C9E);
  static const Color nightPinkText = Color(0xFFFF8DBA);
  static const Color nightPinkWash = Color(0xFF4D1838);
  static const Color nightTeal = Color(0xFF1FE0C4);
  static const Color nightCobalt = Color(0xFF9FB2FF);
  static const Color nightCobaltWash = Color(0xFF232D66);
  static const Color nightFunded = Color(0xFF5FE3A0);
  static const Color nightFundedWash = Color(0xFF10402B);
  static const Color nightOverspent = Color(0xFFFF8C7A);
  static const Color nightOverspentWash = Color(0xFF4A1B17);
  static const Color nightUnderfunded = Color(0xFFFFC94D);
  static const Color nightUnderfundedWash = Color(0xFF43320A);

  /// The print shadow under night stickers: deeper than the page.
  static const Color nightShadow = Color(0xFF05030C);

  static const Color black = Color(0xFF000000);
  static const Color clear = Color(0x00000000);
}

/// A meaning OpenBudget gives a colour.
///
/// Every tone has a hue for figures, icons, and short labels, and a wash for
/// the field behind them. Text on a wash is always [ObPalette.ink]. Colour is
/// never the only signal: a toned element also says what it means in words.
enum ObTone {
  /// No meaning: ink on the quiet fog wash.
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
/// either palette. Day is paper sheets on newsprint in one deep ink with
/// spot-ink fills; night is the same print run on deep violet stock.
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
    required this.onHighlighter,
    required this.overprint,
    required this.printShadow,
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
    required this.spots,
  });

  /// The light theme: paper sheets on newsprint.
  const ObPalette.paper()
    : canvas = ObSwatch.newsprint,
      surface = ObSwatch.paper,
      ink = ObSwatch.ink,
      mutedInk = ObSwatch.mutedInk,
      line = ObSwatch.line,
      action = ObSwatch.pink,
      onAction = ObSwatch.ink,
      highlight = ObSwatch.fog,
      highlighter = ObSwatch.sunflower,
      onHighlighter = ObSwatch.ink,
      overprint = ObSwatch.teal,
      printShadow = ObSwatch.ink,
      brand = ObSwatch.pinkText,
      brandWash = ObSwatch.pinkWash,
      funded = ObSwatch.funded,
      fundedWash = ObSwatch.fundedWash,
      overspent = ObSwatch.overspent,
      overspentWash = ObSwatch.overspentWash,
      underfunded = ObSwatch.underfunded,
      underfundedWash = ObSwatch.underfundedWash,
      review = ObSwatch.cobalt,
      reviewWash = ObSwatch.cobaltWash,
      spots = const [
        ObSwatch.pink,
        ObSwatch.teal,
        ObSwatch.sunflower,
        ObSwatch.sky,
        ObSwatch.tangerine,
        ObSwatch.lilac,
      ];

  /// The dark theme: the same print run on night stock.
  const ObPalette.night()
    : canvas = ObSwatch.night,
      surface = ObSwatch.nightPaper,
      ink = ObSwatch.chalk,
      mutedInk = ObSwatch.nightMutedInk,
      line = ObSwatch.nightLine,
      action = ObSwatch.nightPink,
      onAction = ObSwatch.night,
      highlight = ObSwatch.nightFog,
      highlighter = ObSwatch.sunflower,
      onHighlighter = ObSwatch.night,
      overprint = ObSwatch.nightTeal,
      printShadow = ObSwatch.nightShadow,
      brand = ObSwatch.nightPinkText,
      brandWash = ObSwatch.nightPinkWash,
      funded = ObSwatch.nightFunded,
      fundedWash = ObSwatch.nightFundedWash,
      overspent = ObSwatch.nightOverspent,
      overspentWash = ObSwatch.nightOverspentWash,
      underfunded = ObSwatch.nightUnderfunded,
      underfundedWash = ObSwatch.nightUnderfundedWash,
      review = ObSwatch.nightCobalt,
      reviewWash = ObSwatch.nightCobaltWash,
      spots = const [
        ObSwatch.nightPink,
        ObSwatch.nightTeal,
        ObSwatch.sunflower,
        ObSwatch.nightCobalt,
        ObSwatch.tangerine,
        ObSwatch.lilac,
      ];

  /// The page behind everything.
  final Color canvas;

  /// Cards, sheets, fields, and bars: paper laid on the page.
  final Color surface;

  /// Text, icons, and outlines. Readable on every surface, wash and spot.
  final Color ink;

  /// Secondary text. At least 4.5:1 on [surface] and [canvas].
  final Color mutedInk;

  /// Dividers and disabled outlines. Decorative only, never text.
  final Color line;

  /// The spot-ink fill of the one deliberate next step on a page.
  final Color action;

  /// Text and icons on an [action] fill.
  final Color onAction;

  /// The quiet wash under selections, tracks, and neutral chips.
  final Color highlight;

  /// The highlighter stroke behind money that is ready to assign, and the
  /// coin and wax seal of a full envelope. Carries [onHighlighter].
  final Color highlighter;

  /// Text and icons on the [highlighter].
  final Color onHighlighter;

  /// The second spot ink, printed off-register under heroes and stickers.
  /// Decoration only, never text.
  final Color overprint;

  /// The hard offset shadow under raised stickers: buttons, heroes, dialogs.
  final Color printShadow;

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

  /// The spot inks, in order, for chart series and envelope colours. Fills
  /// only: anything drawn on them uses [onAction], and a chart also labels
  /// each series in words.
  final List<Color> spots;

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

  /// The spot ink at [index], wrapping around the set.
  Color spot(int index) => spots[index % spots.length];

  /// Whether this is the night palette.
  bool get isNight => surface.computeLuminance() < 0.3;

  /// The quiet pen around fields, chips, and secondary controls; 3:1 or
  /// better on [surface] in both modes.
  Color get quietPen => ink.withValues(alpha: isNight ? 0.66 : 0.72);

  /// The firm pen around sheets, menus, and selected markers.
  Color get firmPen => ink;

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
    Color? onHighlighter,
    Color? overprint,
    Color? printShadow,
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
    List<Color>? spots,
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
    onHighlighter: onHighlighter ?? this.onHighlighter,
    overprint: overprint ?? this.overprint,
    printShadow: printShadow ?? this.printShadow,
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
    spots: spots ?? this.spots,
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
      onHighlighter: mix(onHighlighter, other.onHighlighter),
      overprint: mix(overprint, other.overprint),
      printShadow: mix(printShadow, other.printShadow),
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
      spots: [
        for (var i = 0; i < spots.length; i++)
          mix(spots[i], other.spots[i % other.spots.length]),
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ObPalette &&
      other.canvas == canvas &&
      other.surface == surface &&
      other.ink == ink &&
      other.mutedInk == mutedInk &&
      other.line == line &&
      other.action == action &&
      other.onAction == onAction &&
      other.highlight == highlight &&
      other.highlighter == highlighter &&
      other.onHighlighter == onHighlighter &&
      other.overprint == overprint &&
      other.printShadow == printShadow &&
      other.brand == brand &&
      other.brandWash == brandWash &&
      other.funded == funded &&
      other.fundedWash == fundedWash &&
      other.overspent == overspent &&
      other.overspentWash == overspentWash &&
      other.underfunded == underfunded &&
      other.underfundedWash == underfundedWash &&
      other.review == review &&
      other.reviewWash == reviewWash &&
      _sameColours(other.spots, spots);

  @override
  int get hashCode => Object.hashAll([
    canvas,
    surface,
    ink,
    mutedInk,
    line,
    action,
    onAction,
    highlight,
    highlighter,
    onHighlighter,
    overprint,
    printShadow,
    brand,
    brandWash,
    funded,
    fundedWash,
    overspent,
    overspentWash,
    underfunded,
    underfundedWash,
    review,
    reviewWash,
    ...spots,
  ]);
}

bool _sameColours(List<Color> a, List<Color> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
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
