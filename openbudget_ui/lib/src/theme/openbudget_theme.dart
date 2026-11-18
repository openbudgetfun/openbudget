import 'package:flutter/material.dart';
import 'package:openbudget_ui/src/icons/openbudget_icons.g.dart';
import 'package:openbudget_ui/src/motion/ob_ink_transition.dart';
import 'package:openbudget_ui/src/theme/color_tokens.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/ob_pen.dart';
import 'package:openbudget_ui/src/theme/ob_rough_border.dart';
import 'package:openbudget_ui/src/theme/ob_rough_decoration.dart';
import 'package:skribble/skribble.dart';

/// The chunky hand-lettered face for heroes, headlines and page titles.
const obDisplayTypeface = 'Skribble';

/// The linear sibling for body text, labels and row titles, chosen so small
/// text stays as readable as a printed statement.
const obTextTypeface = 'SkribbleLinearPlayful';

/// The face amounts are set in: the linear face with tabular figures, so a
/// column of money lines up like a ledger without looking like code.
const String obNumeralTypeface = obTextTypeface;

/// The monospaced, rubber-stamped face for postmarks and seals.
const obStampTypeface = 'SkribbleMonoPlayful';

const _fontPackage = 'packages/skribble_font_recursive';

/// [obDisplayTypeface] in Flutter's resolved `packages/<package>/<family>`
/// form, ready for [TextStyle.fontFamily].
const obDisplayFontFamily = '$_fontPackage/$obDisplayTypeface';

/// [obTextTypeface] in resolved form.
const obTextFontFamily = '$_fontPackage/$obTextTypeface';

/// [obNumeralTypeface] in resolved form. Material has no numeral role, so
/// amounts apply it through [ObTextStyles.amount].
const obNumeralFontFamily = '$_fontPackage/$obNumeralTypeface';

/// [obStampTypeface] in resolved form.
const obStampFontFamily = '$_fontPackage/$obStampTypeface';

/// Builds OpenBudget's day (light) and night (dark) themes.
///
/// Material widgets keep their APIs; the theme prints them. Primary actions
/// are spot-ink stickers with an ink outline and a hard print shadow that
/// they press into. Cards are paper sheets inked with the rough pen. Fields, chips and
/// menus take the hand-drawn pen, navigation marks its place with a
/// highlighter swipe, and every route arrives behind an ink wipe.
abstract final class OpenBudgetTheme {
  /// The day theme.
  static final ThemeData light = build();

  /// The night theme.
  static final ThemeData dark = build(brightness: Brightness.dark);

  /// Builds a theme for [brightness].
  ///
  /// [useAppTypeface] applies the Skribble faces. Golden and layout tests
  /// that need Flutter's deterministic test font pass `false`.
  static ThemeData build({
    Brightness brightness = Brightness.light,
    bool useAppTypeface = true,
  }) {
    final palette = brightness == Brightness.dark
        ? const ObPalette.night()
        : const ObPalette.paper();
    final colorScheme = _colorScheme(palette, brightness);
    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);
    final textTheme = _typeScale(
      base.textTheme,
      useAppTypeface: useAppTypeface,
    ).apply(bodyColor: palette.ink, displayColor: palette.ink);
    final actionText = textTheme.labelLarge!;

    // Cards and fields are inked, not pencilled: the hand-drawn line is
    // the look, so it is drawn firmly enough to see at a glance.
    final cardPen = BorderSide(color: palette.firmPen, width: 2.4);
    final quietPen = BorderSide(color: palette.quietPen, width: 2);
    final firmPen = BorderSide(
      color: palette.firmPen,
      width: ObPen.strokeWidth,
    );
    final fieldBorder = ObRoughInputBorder(
      borderSide: BorderSide(color: palette.firmPen, width: 2),
      radius: 12,
    );

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.surface,
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      extensions: [palette],
      textTheme: textTheme,
      iconTheme: IconThemeData(color: palette.ink, size: 22),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ObInkPageTransitionsBuilder(),
          TargetPlatform.iOS: ObInkPageTransitionsBuilder(),
          TargetPlatform.macOS: ObInkPageTransitionsBuilder(),
          TargetPlatform.windows: ObInkPageTransitionsBuilder(),
          TargetPlatform.linux: ObInkPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ObInkPageTransitionsBuilder(),
        },
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.ink,
        selectionColor: palette.highlighter.withValues(alpha: 0.6),
        selectionHandleColor: palette.action,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        foregroundColor: palette.ink,
        surfaceTintColor: ObSwatch.clear,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: palette.ink, size: 22),
        actionsIconTheme: IconThemeData(color: palette.ink, size: 22),
      ),
      // Back, close, and menu buttons draw Skribble glyphs, so navigation
      // chrome matches every other icon.
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) =>
            const SkribbleIcon(data: OpenBudgetIcons.back),
        closeButtonIconBuilder: (context) =>
            const SkribbleIcon(data: OpenBudgetIcons.close),
        drawerButtonIconBuilder: (context) =>
            const SkribbleIcon(data: OpenBudgetIcons.menu),
        endDrawerButtonIconBuilder: (context) =>
            const SkribbleIcon(data: OpenBudgetIcons.menu),
      ),
      // Cards are paper sheets inked around with the rough pen, so a screen
      // of them reads as drawn by hand at a glance.
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: ObRoughBorder(side: cardPen, radius: RadiusTokens.lg, seed: 7),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _stickerStyle(
          palette,
          fill: palette.action,
          label: palette.onAction,
          textStyle: actionText,
          seed: 3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _stickerStyle(
          palette,
          fill: palette.surface,
          label: palette.ink,
          textStyle: actionText,
          seed: 5,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: palette.surface,
          foregroundColor: palette.ink,
          disabledForegroundColor: palette.mutedInk,
          minimumSize: const Size(64, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: const ObRoughBorder(seed: 9, radius: RadiusTokens.md),
          textStyle: actionText,
        ).copyWith(side: _penOutline(palette, enabledAlpha: 0.7)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.ink,
          disabledForegroundColor: palette.mutedInk,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(RadiusTokens.md)),
          ),
          textStyle: actionText.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: palette.action,
            decorationThickness: 2.4,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.ink,
          minimumSize: const Size(48, 48),
          shape: const CircleBorder(),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.action,
        foregroundColor: palette.onAction,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        iconSize: 26,
        shape: ObStickerBorder(
          side: BorderSide(color: palette.ink, width: ObPen.strokeWidth),
          radius: RadiusTokens.lg,
          seed: 37,
          shadowColor: palette.printShadow,
          shadowOffset: const Offset(4, 4),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            ObRoughBorder(seed: 41, radius: RadiusTokens.md),
          ),
          side: WidgetStatePropertyAll(quietPen),
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          textStyle: WidgetStatePropertyAll(actionText),
          // Selection is a highlighter swipe under ink plus a check, never
          // colour alone.
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.highlighter
                : palette.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.onHighlighter
                : palette.ink,
          ),
        ),
        selectedIcon: const SkribbleIcon(data: OpenBudgetIcons.check, size: 18),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.highlighter,
        disabledColor: palette.surface,
        checkmarkColor: palette.onHighlighter,
        side: quietPen,
        shape: ObRoughBorder(
          side: quietPen,
          radius: RadiusTokens.pill,
          seed: 13,
        ),
        labelStyle: actionText.copyWith(color: palette.ink),
        secondaryLabelStyle: actionText.copyWith(color: palette.onHighlighter),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        iconTheme: IconThemeData(color: palette.ink, size: 18),
      ),
      // A focused field draws a heavier ink pen; an invalid one draws it in
      // red pencil, and the message under it says what is wrong.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: palette.mutedInk),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(color: palette.ink),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.mutedInk),
        helperStyle: textTheme.bodySmall?.copyWith(color: palette.mutedInk),
        prefixIconColor: palette.mutedInk,
        suffixIconColor: palette.mutedInk,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        disabledBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: palette.quietPen, width: 1.8),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: palette.ink, width: 2.6),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: palette.overspent, width: 2.4),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: palette.overspent, width: 3),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: palette.overspent),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.ink,
        textColor: palette.ink,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: palette.mutedInk,
        ),
        selectedColor: palette.ink,
        selectedTileColor: palette.highlight,
        minVerticalPadding: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(RadiusTokens.md)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.onAction
              : palette.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.action
              : palette.highlight,
        ),
        trackOutlineColor: WidgetStatePropertyAll(palette.ink),
        trackOutlineWidth: const WidgetStatePropertyAll(1.8),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.action
              : palette.surface,
        ),
        checkColor: WidgetStatePropertyAll(palette.onAction),
        side: BorderSide(color: palette.ink, width: 1.8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(palette.ink),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.action,
        inactiveTrackColor: palette.highlight,
        thumbColor: palette.ink,
        overlayColor: palette.action.withValues(alpha: 0.16),
      ),
      // Dialogs, sheets and menus are stickers laid over the page: paper,
      // firm ink, and a hard print shadow instead of a soft elevation.
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        iconColor: palette.ink,
        elevation: 0,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
        shape: ObStickerBorder(
          side: firmPen,
          radius: RadiusTokens.xl,
          seed: 17,
          shadowColor: palette.printShadow,
          shadowOffset: const Offset(6, 6),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        dragHandleColor: palette.quietPen,
        dragHandleSize: const Size(44, 5),
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: palette.ink.withValues(
          alpha: palette.isNight ? 0.6 : 0.32,
        ),
        shape: ObRoughBorder(side: firmPen, radius: RadiusTokens.xl, seed: 19),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        elevation: 0,
        textStyle: actionText.copyWith(color: palette.ink),
        shape: ObStickerBorder(
          side: firmPen,
          radius: RadiusTokens.md,
          seed: 43,
          shadowColor: palette.printShadow,
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(palette.surface),
          surfaceTintColor: const WidgetStatePropertyAll(ObSwatch.clear),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            ObStickerBorder(
              side: firmPen,
              radius: RadiusTokens.md,
              seed: 43,
              shadowColor: palette.printShadow,
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyLarge,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: palette.surface,
          border: fieldBorder,
          enabledBorder: fieldBorder,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(palette.surface),
          surfaceTintColor: const WidgetStatePropertyAll(ObSwatch.clear),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            ObStickerBorder(
              side: firmPen,
              radius: RadiusTokens.md,
              seed: 47,
              shadowColor: palette.printShadow,
            ),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: ObRoughDecoration(
          color: palette.ink,
          outline: palette.ink,
          radius: RadiusTokens.sm,
          strokeWidth: 1.6,
          seed: 47,
        ),
        textStyle: actionText.copyWith(color: palette.canvas),
      ),
      // A snack bar inverts the page and is printed over a teal shadow.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: palette.canvas),
        actionTextColor: palette.highlighter,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: ObStickerBorder(
          side: BorderSide(color: palette.ink, width: 1.8),
          radius: RadiusTokens.md,
          seed: 23,
          shadowColor: palette.overprint,
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: palette.ink,
        collapsedIconColor: palette.mutedInk,
        textColor: palette.ink,
        collapsedTextColor: palette.ink,
      ),
      dividerTheme: DividerThemeData(
        color: palette.line,
        thickness: 1.2,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.ink,
        linearTrackColor: palette.highlight,
        circularTrackColor: ObSwatch.clear,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.ink,
        unselectedLabelColor: palette.mutedInk,
        labelStyle: actionText,
        unselectedLabelStyle: actionText,
        indicator: ShapeDecoration(
          color: palette.highlighter,
          shape: const ObMarkerBorder(seed: 5),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        dividerColor: palette.line,
        splashBorderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      // The selected destination is marked with a highlighter swipe, and
      // its label goes from muted to full ink.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        elevation: 0,
        height: 72,
        indicatorColor: palette.highlighter,
        indicatorShape: const ObMarkerBorder(seed: 59),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? palette.ink
                : palette.mutedInk,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? palette.onHighlighter
                : palette.mutedInk,
            size: 24,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.highlighter,
        indicatorShape: const ObMarkerBorder(seed: 59),
        selectedLabelTextStyle: textTheme.labelMedium,
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: palette.mutedInk,
        ),
        selectedIconTheme: IconThemeData(color: palette.onHighlighter),
        unselectedIconTheme: IconThemeData(color: palette.mutedInk),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        elevation: 0,
        headerBackgroundColor: palette.canvas,
        headerForegroundColor: palette.ink,
        shape: ObStickerBorder(
          side: firmPen,
          radius: RadiusTokens.xl,
          seed: 61,
          shadowColor: palette.printShadow,
          shadowOffset: const Offset(6, 6),
        ),
        todayBorder: BorderSide(color: palette.ink, width: 1.8),
        dayForegroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.onAction
              : palette.ink,
        ),
        dayBackgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? palette.action : null,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(palette.quietPen),
        radius: const Radius.circular(4),
      ),
    );
  }
}

/// Text styles Material has no role for.
abstract final class ObTextStyles {
  /// An amount of money in a list or row: the linear face with tabular
  /// figures, so columns align, at the size of [base].
  static TextStyle amount(TextStyle? base) =>
      (base ?? const TextStyle()).copyWith(
        fontFamily: obNumeralFontFamily,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: 0,
      );

  /// A hero amount: the chunky display face, set big. Its digits are
  /// proportional, the way a figure is lettered by hand.
  static TextStyle heroAmount(TextStyle? base) =>
      (base ?? const TextStyle()).copyWith(
        fontFamily: obDisplayFontFamily,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        height: 1,
      );

  /// The small spaced label above a hero figure or a section.
  static TextStyle eyebrow(TextStyle? base) =>
      (base ?? const TextStyle()).copyWith(
        fontFamily: obTextFontFamily,
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        height: 1.2,
      );

  /// The rubber-stamp lettering of postmarks and seals.
  static TextStyle stamp(TextStyle? base) =>
      (base ?? const TextStyle()).copyWith(
        fontFamily: obStampFontFamily,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        height: 1,
      );
}

/// The type scale from `docs/branding.md`.
///
/// Display, headline and page titles are lettered in the chunky Skribble
/// face; row titles, body and labels use the linear sibling at comfortable
/// sizes (never below 12.5) so dense money screens stay easy to read.
TextTheme _typeScale(TextTheme base, {required bool useAppTypeface}) {
  TextStyle? role(
    TextStyle? style, {
    required String family,
    required double size,
    required double height,
    required FontWeight weight,
    double letterSpacing = 0,
  }) => style?.copyWith(
    fontFamily: useAppTypeface ? family : null,
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: letterSpacing,
  );

  TextStyle? display(TextStyle? style, double size) => role(
    style,
    family: obDisplayFontFamily,
    size: size,
    height: 1.05,
    weight: FontWeight.w900,
    letterSpacing: -0.5,
  );
  TextStyle? headline(TextStyle? style, double size) => role(
    style,
    family: obDisplayFontFamily,
    size: size,
    height: 1.12,
    weight: FontWeight.w900,
  );
  TextStyle? pageTitle(TextStyle? style, double size) => role(
    style,
    family: obDisplayFontFamily,
    size: size,
    height: 1.2,
    weight: FontWeight.w800,
  );
  TextStyle? title(TextStyle? style, double size) => role(
    style,
    family: obTextFontFamily,
    size: size,
    height: 1.3,
    weight: FontWeight.w700,
  );
  TextStyle? body(TextStyle? style, double size, FontWeight weight) => role(
    style,
    family: obTextFontFamily,
    size: size,
    height: 1.45,
    weight: weight,
  );
  TextStyle? label(TextStyle? style, double size) => role(
    style,
    family: obTextFontFamily,
    size: size,
    height: 1.25,
    weight: FontWeight.w700,
    letterSpacing: 0.1,
  );

  return base.copyWith(
    displayLarge: display(base.displayLarge, 54),
    displayMedium: display(base.displayMedium, 46),
    displaySmall: display(base.displaySmall, 38),
    headlineLarge: headline(base.headlineLarge, 32),
    headlineMedium: headline(base.headlineMedium, 28),
    headlineSmall: headline(base.headlineSmall, 23),
    titleLarge: pageTitle(base.titleLarge, 21),
    titleMedium: title(base.titleMedium, 17),
    titleSmall: title(base.titleSmall, 15.5),
    bodyLarge: body(base.bodyLarge, 16, FontWeight.w400),
    bodyMedium: body(base.bodyMedium, 15, FontWeight.w500),
    bodySmall: body(base.bodySmall, 13.5, FontWeight.w500),
    labelLarge: label(base.labelLarge, 15.5),
    labelMedium: label(base.labelMedium, 14),
    labelSmall: label(base.labelSmall, 12.5),
  );
}

/// Material's colour roles, mapped one by one from [palette]. Nothing is
/// derived by `ColorScheme.fromSeed`, which would invent greys and tints the
/// design never prints.
ColorScheme _colorScheme(ObPalette palette, Brightness brightness) {
  final inverse = brightness == Brightness.dark
      ? const ObPalette.paper()
      : const ObPalette.night();
  return ColorScheme(
    brightness: brightness,
    primary: palette.action,
    onPrimary: palette.onAction,
    primaryContainer: palette.brandWash,
    onPrimaryContainer: palette.ink,
    secondary: palette.brand,
    onSecondary: palette.surface,
    secondaryContainer: palette.highlight,
    onSecondaryContainer: palette.ink,
    tertiary: palette.funded,
    onTertiary: palette.surface,
    tertiaryContainer: palette.fundedWash,
    onTertiaryContainer: palette.ink,
    error: palette.overspent,
    onError: palette.surface,
    errorContainer: palette.overspentWash,
    onErrorContainer: palette.ink,
    surface: palette.surface,
    onSurface: palette.ink,
    onSurfaceVariant: palette.mutedInk,
    surfaceDim: palette.canvas,
    surfaceBright: palette.surface,
    surfaceContainerLowest: palette.surface,
    surfaceContainerLow: palette.surface,
    surfaceContainer: palette.surface,
    surfaceContainerHigh: palette.surface,
    surfaceContainerHighest: palette.highlight,
    outline: palette.mutedInk,
    outlineVariant: palette.line,
    shadow: palette.printShadow,
    scrim: ObSwatch.black,
    inverseSurface: inverse.surface,
    onInverseSurface: inverse.ink,
    inversePrimary: inverse.action,
    surfaceTint: ObSwatch.clear,
  );
}

/// A sticker button: a spot-ink [fill] edged in ink over a hard print shadow,
/// which presses flat when tapped. Disabled, it lies flat in pencil.
ButtonStyle _stickerStyle(
  ObPalette palette, {
  required Color fill,
  required Color label,
  required TextStyle textStyle,
  required int seed,
}) {
  ObStickerBorder sticker({required double lift, required Color outline}) =>
      ObStickerBorder(
        side: BorderSide(color: outline, width: ObPen.strokeWidth),
        radius: RadiusTokens.md,
        seed: seed,
        shadowColor: palette.printShadow,
        lift: lift,
      );

  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.disabled) ? palette.highlight : fill,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.disabled) ? palette.mutedInk : label,
    ),
    overlayColor: WidgetStatePropertyAll(label.withValues(alpha: 0.08)),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: WidgetStatePropertyAll(textStyle),
    minimumSize: const WidgetStatePropertyAll(Size(64, 54)),
    animationDuration: const Duration(milliseconds: 90),
    padding: WidgetStateProperty.resolveWith(
      // A pressed sticker sinks into its shadow, and its label sinks too.
      (states) => states.contains(WidgetState.pressed)
          ? const EdgeInsets.fromLTRB(23, 17, 17, 11)
          : const EdgeInsets.fromLTRB(20, 14, 20, 14),
    ),
    shape: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return ObStickerBorder(
          side: BorderSide(color: palette.line, width: ObPen.strokeWidth),
          radius: RadiusTokens.md,
          seed: seed,
          lift: 0,
        );
      }
      return sticker(
        lift: states.contains(WidgetState.pressed) ? 0 : 1,
        outline: palette.ink,
      );
    }),
  );
}

/// The pen outline for themed buttons. A disabled control keeps its shape
/// but drops to the quiet line colour.
WidgetStateProperty<BorderSide> _penOutline(
  ObPalette palette, {
  required double enabledAlpha,
}) => WidgetStateProperty.resolveWith(
  (states) => BorderSide(
    color: states.contains(WidgetState.disabled)
        ? palette.line
        : palette.ink.withValues(alpha: enabledAlpha),
    width: ObPen.strokeWidth,
  ),
);
