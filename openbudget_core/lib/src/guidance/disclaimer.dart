import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// One country's disclaimer, keyed for localisation.
///
/// The key travels in tool-result payloads (`disclaimerKey`); the app
/// localises the text through `AppLocalizations`, and the [addition] here
/// is the canonical English sentence the server puts in payloads an MCP
/// client renders without the app's strings.
@immutable
final class GuidanceDisclaimer {
  const GuidanceDisclaimer({required this.key, required this.addition});

  /// `gb`, `us`, `de` or `ng`.
  final String key;

  /// The sentence this country adds to the standard disclaimer.
  final String addition;

  /// The standard disclaimer plus this country's addition.
  String get fullText => '$standardDisclaimerText $addition';
}

/// The standard disclaimer every country's text starts with.
const standardDisclaimerText =
    'Information only, based on the figures you entered and the rules we '
    'checked. This is not tax, legal or investment advice and does not know '
    'your full circumstances. Rules change. A qualified professional should '
    'confirm anything you act on.';

/// Each pack country's disclaimer key and addition, from the
/// `tax-planning-guardrails` skill's product-rules reference, section 2.
final Map<TaxJurisdiction, GuidanceDisclaimer> guidanceDisclaimers =
    Map.unmodifiable({
      TaxJurisdiction.gb: const GuidanceDisclaimer(
        key: 'gb',
        addition:
            'This does not recommend any investment, pension or ISA product.',
      ),
      TaxJurisdiction.us: const GuidanceDisclaimer(
        key: 'us',
        addition:
            'General educational calculation. Not a written federal tax '
            'opinion and not investment advice.',
      ),
      TaxJurisdiction.de: const GuidanceDisclaimer(
        key: 'de',
        addition:
            'Allgemeine Information, keine Steuerberatung im Einzelfall. Für '
            'Ihren Fall wenden Sie sich an einen Steuerberater oder '
            'Lohnsteuerhilfeverein.',
      ),
      TaxJurisdiction.ng: const GuidanceDisclaimer(
        key: 'ng',
        addition:
            'Confirm with a registered tax practitioner and the tax '
            'authority before relying on this.',
      ),
    });

/// The disclaimer of [jurisdiction], or null when no pack serves it.
GuidanceDisclaimer? guidanceDisclaimerFor(TaxJurisdiction jurisdiction) =>
    guidanceDisclaimers[jurisdiction];
