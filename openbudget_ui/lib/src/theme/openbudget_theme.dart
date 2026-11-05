import 'package:flutter/material.dart';
import 'package:openbudget_ui/src/icons/openbudget_icons.g.dart';
import 'package:openbudget_ui/src/theme/color_tokens.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/ob_pen.dart';
import 'package:openbudget_ui/src/theme/ob_rough_border.dart';
import 'package:openbudget_ui/src/theme/ob_rough_decoration.dart';
import 'package:skribble/skribble.dart';

/// The calm hand-lettered face for display lines, headlines, and titles.
const obDisplayTypeface = 'SkribbleGentle';

/// The linear sibling for body text and labels, chosen so small text stays
/// as readable as a printed statement.
const obTextTypeface = 'SkribbleLinearGentle';

/// The monospaced sibling for amounts: every digit has the same width, so
/// columns of money line up like a ledger.
const obNumeralTypeface = 'SkribbleMonoGentle';

const _fontPackage = 'packages/skribble_font_recursive';

/// [obDisplayTypeface] in Flutter's resolved `packages/<package>/<family>`
/// form, ready for [TextStyle.fontFamily].
const obDisplayFontFamily = '$_fontPackage/$obDisplayTypeface';

/// [obTextTypeface] in resolved form.
const obTextFontFamily = '$_fontPackage/$obTextTypeface';

/// [obNumeralTypeface] in resolved form. Material has no numeral role, so
/// amounts apply it through [ObTextStyles.amount].
const obNumeralFontFamily = '$_fontPackage/$obNumeralTypeface';

/// Builds OpenBudget's paper (light) and night (dark) themes.
///
/// Material widgets keep their APIs; the theme gives every button, card,
/// chip, field, dialog, sheet, and menu the hand-drawn OpenBudget pen, and
/// letters text in the Skribble faces.
abstract final class OpenBudgetTheme {
  /// The paper theme.
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

    final cardPen = BorderSide(color: palette.ink, width: ObPen.strokeWidth);
    final quietPen = BorderSide(color: palette.quietPen, width: 1.8);
    final firmPen = BorderSide(
      color: palette.firmPen,
      width: ObPen.strokeWidth,
    );
    final fieldBorder = ObRoughInputBorder(borderSide: quietPen);

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.surface,
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      extensions: [palette],
      textTheme: textTheme,
      iconTheme: IconThemeData(color: palette.ink, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        foregroundColor: palette.ink,
        surfaceTintColor: ObSwatch.clear,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
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
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: ObRoughBorder(side: cardPen, radius: RadiusTokens.md, seed: 7),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.action,
          foregroundColor: palette.onAction,
          disabledBackgroundColor: palette.highlight,
          disabledForegroundColor: palette.mutedInk,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const ObRoughBorder(),
          textStyle: actionText,
        ).copyWith(side: _penOutline(palette, enabledAlpha: 1)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.surface,
          foregroundColor: palette.ink,
          elevation: 0,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const ObRoughBorder(seed: 5),
          textStyle: actionText,
        ).copyWith(side: _penOutline(palette, enabledAlpha: 0.82)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: palette.surface,
          foregroundColor: palette.ink,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const ObRoughBorder(seed: 9),
          textStyle: actionText,
        ).copyWith(side: _penOutline(palette, enabledAlpha: 0.56)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.ink,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const ObRoughBorder(seed: 29),
          textStyle: actionText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.ink,
          minimumSize: const Size(48, 48),
          shape: const ObRoughBorder(seed: 31),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.action,
        foregroundColor: palette.onAction,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: ObRoughBorder(side: firmPen, radius: RadiusTokens.md, seed: 37),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(ObRoughBorder(seed: 41)),
          side: WidgetStatePropertyAll(quietPen),
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          textStyle: WidgetStatePropertyAll(actionText),
          // Selection is a wash under ink plus a check, never colour alone.
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.highlight
                : palette.surface,
          ),
          foregroundColor: WidgetStatePropertyAll(palette.ink),
        ),
        selectedIcon: const SkribbleIcon(data: OpenBudgetIcons.check, size: 18),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.highlight,
        disabledColor: palette.surface,
        checkmarkColor: palette.ink,
        side: quietPen,
        shape: ObRoughBorder(side: quietPen, radius: RadiusTokens.lg, seed: 13),
        labelStyle: actionText.copyWith(color: palette.ink),
        secondaryLabelStyle: actionText.copyWith(color: palette.ink),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        iconTheme: IconThemeData(color: palette.ink, size: 18),
      ),
      // A focused or invalid field draws a heavier pen; the message under it
      // says what is wrong.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
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
          borderSide: BorderSide(color: palette.line, width: 1.8),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: palette.ink, width: 2.6),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: palette.overspent, width: 2.6),
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
        shape: const ObRoughBorder(radius: RadiusTokens.md),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.onAction
              : palette.ink,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.action
              : palette.surface,
        ),
        trackOutlineColor: WidgetStatePropertyAll(palette.ink),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.action
              : palette.surface,
        ),
        checkColor: WidgetStatePropertyAll(palette.onAction),
        side: BorderSide(color: palette.ink, width: 1.8),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(palette.ink),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.ink,
        inactiveTrackColor: palette.highlight,
        thumbColor: palette.ink,
        overlayColor: palette.ink.withValues(alpha: 0.08),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        iconColor: palette.ink,
        elevation: 0,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
        shape: ObRoughBorder(side: firmPen, radius: RadiusTokens.xl, seed: 17),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        dragHandleColor: palette.quietPen,
        elevation: 0,
        modalElevation: 0,
        shape: ObRoughBorder(side: firmPen, radius: RadiusTokens.xl, seed: 19),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        elevation: 0,
        textStyle: actionText.copyWith(color: palette.ink),
        shape: ObRoughBorder(side: firmPen, radius: RadiusTokens.md, seed: 43),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(palette.surface),
          surfaceTintColor: const WidgetStatePropertyAll(ObSwatch.clear),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            ObRoughBorder(side: firmPen, radius: RadiusTokens.md, seed: 43),
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
            ObRoughBorder(side: firmPen, radius: RadiusTokens.md, seed: 47),
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
      // A snack bar inverts the page: paper on night, night on paper.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: palette.canvas),
        actionTextColor: palette.canvas,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: ObRoughBorder(
          side: BorderSide(
            color: palette.canvas.withValues(alpha: 0.7),
            width: 1.8,
          ),
          radius: RadiusTokens.md,
          seed: 23,
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
        thickness: 1,
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
        indicatorColor: palette.ink,
        dividerColor: palette.line,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        elevation: 0,
        indicatorColor: palette.highlighter,
        indicatorShape: ObRoughBorder(
          side: BorderSide(color: palette.ink, width: 1.8),
          radius: RadiusTokens.lg,
          seed: 59,
        ),
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
                ? palette.ink
                : palette.mutedInk,
            size: 24,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.highlighter,
        indicatorShape: ObRoughBorder(
          side: BorderSide(color: palette.ink, width: 1.8),
          radius: RadiusTokens.lg,
          seed: 59,
        ),
        selectedLabelTextStyle: textTheme.labelMedium,
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: palette.mutedInk,
        ),
        selectedIconTheme: IconThemeData(color: palette.ink),
        unselectedIconTheme: IconThemeData(color: palette.mutedInk),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: ObSwatch.clear,
        elevation: 0,
        headerBackgroundColor: palette.canvas,
        headerForegroundColor: palette.ink,
        shape: ObRoughBorder(side: firmPen, radius: RadiusTokens.xl, seed: 61),
        todayBorder: BorderSide(color: palette.ink, width: 1.8),
      ),
    );
  }
}

/// Text styles Material has no role for.
abstract final class ObTextStyles {
  /// An amount of money in the ledger face: equal-width digits so columns
  /// align, at the size and weight of [base].
  static TextStyle amount(TextStyle? base) =>
      (base ?? const TextStyle()).copyWith(
        fontFamily: obNumeralFontFamily,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: 0,
      );
}

/// The type scale from `DESIGN.md`.
///
/// Display, headline, and title are hand-lettered in the gentle face; body
/// and labels use the linear sibling at comfortable sizes (never below 13)
/// so dense money screens stay easy to read.
TextTheme _typeScale(TextTheme base, {required bool useAppTypeface}) {
  TextStyle? role(
    TextStyle? style, {
    required String family,
    required double size,
    required double height,
    required FontWeight weight,
  }) => style?.copyWith(
    fontFamily: useAppTypeface ? family : null,
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: 0,
  );

  TextStyle? display(TextStyle? style, double size) => role(
    style,
    family: obDisplayFontFamily,
    size: size,
    height: 1.1,
    weight: FontWeight.w800,
  );
  TextStyle? headline(TextStyle? style, double size) => role(
    style,
    family: obDisplayFontFamily,
    size: size,
    height: 1.15,
    weight: FontWeight.w700,
  );
  TextStyle? title(TextStyle? style, double size) => role(
    style,
    family: obDisplayFontFamily,
    size: size,
    height: 1.25,
    weight: FontWeight.w700,
  );
  TextStyle? body(TextStyle? style, double size) => role(
    style,
    family: obTextFontFamily,
    size: size,
    height: 1.45,
    weight: FontWeight.w500,
  );
  TextStyle? label(TextStyle? style, double size) => role(
    style,
    family: obTextFontFamily,
    size: size,
    height: 1.25,
    weight: FontWeight.w700,
  );

  return base.copyWith(
    displayLarge: display(base.displayLarge, 48),
    displayMedium: display(base.displayMedium, 42),
    displaySmall: display(base.displaySmall, 36),
    headlineLarge: headline(base.headlineLarge, 30),
    headlineMedium: headline(base.headlineMedium, 26),
    headlineSmall: headline(base.headlineSmall, 22),
    titleLarge: title(base.titleLarge, 20),
    titleMedium: title(base.titleMedium, 18),
    titleSmall: title(base.titleSmall, 16),
    bodyLarge: body(base.bodyLarge, 16),
    bodyMedium: body(base.bodyMedium, 15),
    bodySmall: body(base.bodySmall, 13.5),
    labelLarge: label(base.labelLarge, 15),
    labelMedium: label(base.labelMedium, 14),
    labelSmall: label(base.labelSmall, 13),
  );
}

/// Material's colour roles, mapped one by one from [palette]. Nothing is
/// derived by `ColorScheme.fromSeed`, which would invent greys and tints the
/// design never draws.
ColorScheme _colorScheme(ObPalette palette, Brightness brightness) {
  final inverse = brightness == Brightness.dark
      ? const ObPalette.paper()
      : const ObPalette.night();
  return ColorScheme(
    brightness: brightness,
    primary: palette.action,
    onPrimary: palette.onAction,
    primaryContainer: palette.highlight,
    onPrimaryContainer: palette.ink,
    secondary: palette.brand,
    onSecondary: palette.surface,
    secondaryContainer: palette.brandWash,
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
    surfaceDim: palette.surface,
    surfaceBright: palette.surface,
    surfaceContainerLowest: palette.canvas,
    surfaceContainerLow: palette.surface,
    surfaceContainer: palette.surface,
    surfaceContainerHigh: palette.surface,
    surfaceContainerHighest: palette.highlight,
    outline: palette.mutedInk,
    outlineVariant: palette.line,
    shadow: ObSwatch.black,
    scrim: ObSwatch.black,
    inverseSurface: inverse.surface,
    onInverseSurface: inverse.ink,
    inversePrimary: inverse.action,
    surfaceTint: ObSwatch.clear,
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
