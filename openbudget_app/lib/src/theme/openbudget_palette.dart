import 'package:flutter/material.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Semantic colour roles for OpenBudget surfaces, text, states, and charts.
///
/// Every role resolves through the theme's [ObPalette], so screens follow
/// light and dark mode and never hold a raw colour. New code should read
/// `Theme.of(context).ob` directly; these getters keep older call sites
/// working while screens move to the shared `openbudget_ui` components.
abstract final class OpenBudgetPalette {
  /// Transparent colour for overlays and pass-through backgrounds.
  static Color transparentFor(ThemeData theme) => ObSwatch.clear;

  /// The page behind full-screen scaffolds.
  static Color bgPrimaryFor(ThemeData theme) => theme.ob.canvas;

  /// Cards, tiles, and content blocks: the same paper, outlined in pen.
  static Color bgSecondaryFor(ThemeData theme) => theme.ob.surface;

  /// Muted containers: the quiet highlight wash.
  static Color bgTertiaryFor(ThemeData theme) => theme.ob.highlight;

  /// Dividers and decorative borders.
  static Color borderSubtleFor(ThemeData theme) => theme.ob.line;

  /// High-emphasis text and icons.
  static Color fgPrimaryFor(ThemeData theme) => theme.ob.ink;

  /// High-emphasis text with a touch less weight.
  static Color fgPrimaryEmphasisFor(ThemeData theme) => theme.ob.ink;

  /// Supporting text and icons; 4.5:1 or better on every surface.
  static Color fgSecondaryFor(ThemeData theme) => theme.ob.mutedInk;

  /// Text and icons on the action fill.
  static Color fgOnBrandFor(ThemeData theme) => theme.ob.onAction;

  /// The one deliberate next step: ink fill.
  static Color bgBrandFor(ThemeData theme) => theme.ob.action;

  /// Selected and highlighted states: the brand wash.
  static Color bgAccentFor(ThemeData theme) => theme.ob.brandWash;

  /// Funded badges and chips.
  static Color bgSuccessFor(ThemeData theme) => theme.ob.fundedWash;

  /// Funded figures and positive trends.
  static Color fgSuccessFor(ThemeData theme) => theme.ob.funded;

  /// Overspent figures, errors, and destructive actions.
  static Color fgErrorFor(ThemeData theme) => theme.ob.overspent;

  /// Scrim behind modals and sheets.
  static Color overlayScrimFor(ThemeData theme) =>
      theme.ob.ink.withValues(alpha: theme.ob.isNight ? 0.7 : 0.45);

  /// Sign-in and onboarding background.
  static Color bgAuthFor(ThemeData theme) => theme.ob.canvas;

  /// Hero titles.
  static Color fgHeroTitleFor(ThemeData theme) => theme.ob.ink;

  /// Hero supporting text.
  static Color fgHeroBodyFor(ThemeData theme) => theme.ob.mutedInk;

  /// Former hero gradient start; heroes are flat paper now.
  static Color bgHeroGradientStartFor(ThemeData theme) => theme.ob.brandWash;

  /// Former hero gradient end; heroes are flat paper now.
  static Color bgHeroGradientEndFor(ThemeData theme) => theme.ob.brandWash;

  /// Decorative hero shape, primary.
  static Color bgHeroBlobPrimaryFor(ThemeData theme) => theme.ob.brandWash;

  /// Decorative hero shape, secondary.
  static Color bgHeroBlobSecondaryFor(ThemeData theme) => theme.ob.reviewWash;

  /// Decorative hero shape, accent.
  static Color bgHeroBlobAccentFor(ThemeData theme) => theme.ob.fundedWash;

  /// Emphasised positive text.
  static Color fgSuccessStrongFor(ThemeData theme) => theme.ob.funded;

  /// Neutral callouts.
  static Color bgInfoFor(ThemeData theme) => theme.ob.brandWash;

  /// Destructive callouts.
  static Color bgErrorFor(ThemeData theme) => theme.ob.overspentWash;

  /// Account and entity chips.
  static Color bgBadgeFor(ThemeData theme) => theme.ob.highlight;

  /// Selected rows and containers.
  static Color bgSelectedFor(ThemeData theme) => theme.ob.brandWash;

  /// Cautionary badges and indicators.
  static Color bgWarningFor(ThemeData theme) => theme.ob.underfundedWash;

  /// Error tag field.
  static Color bgTagErrorFor(ThemeData theme) => theme.ob.overspentWash;

  /// Error tag text; reads at AA on its wash.
  static Color fgTagErrorFor(ThemeData theme) => theme.ob.overspent;

  /// Warning tag text; reads at AA on its wash.
  static Color fgTagWarningFor(ThemeData theme) => theme.ob.underfunded;

  /// Success tag field.
  static Color bgTagSuccessFor(ThemeData theme) => theme.ob.fundedWash;

  /// Success tag text; reads at AA on its wash.
  static Color fgTagSuccessFor(ThemeData theme) => theme.ob.funded;

  /// Icons that must stand out.
  static Color fgIconStrongFor(ThemeData theme) => theme.ob.ink;

  /// Critical flag.
  static Color bgFlagCriticalFor(ThemeData theme) => theme.ob.overspent;

  /// High-priority flag.
  static Color bgFlagHighFor(ThemeData theme) => theme.ob.underfunded;

  /// Medium-priority flag.
  static Color bgFlagMediumFor(ThemeData theme) => theme.ob.highlighter;

  /// Positive flag.
  static Color bgFlagPositiveFor(ThemeData theme) => theme.ob.funded;

  /// Informational flag.
  static Color bgFlagInfoFor(ThemeData theme) => theme.ob.brand;

  /// Custom flag.
  static Color bgFlagAccentFor(ThemeData theme) => theme.ob.review;

  /// Ordered chart series. Charts also label each series in words.
  static List<Color> chartSeriesFor(ThemeData theme) {
    final palette = theme.ob;
    return [
      palette.brand,
      palette.funded,
      palette.underfunded,
      palette.overspent,
      palette.review,
      palette.mutedInk,
    ];
  }
}
