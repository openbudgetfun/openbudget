import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';

/// Validates a catalogue tax code against the entity's country and kind.
///
/// The catalogue, not this class, decides which codes exist. A universal
/// code is accepted in every country, so books without a rule pack can
/// still be tagged ([UniversalTaxCategories]). Any other code is accepted
/// only when the jurisdiction has a tax pack and that pack lists it for
/// the entity kind, so an envelope never stores a code a report cannot
/// recognise.
abstract final class TaxCatalogueValidation {
  /// Trims a client-supplied code and treats an empty value as absent.
  static String? normalise(String? raw) {
    final code = raw?.trim();
    return code == null || code.isEmpty ? null : code;
  }

  /// Rejects an unknown or inapplicable [code]; a null code stays null.
  static void requireCode(Entity entity, String? code) {
    final normalised = normalise(code);
    if (normalised == null) return;

    if (UniversalTaxCategories.isUniversalCode(normalised)) {
      final universal = UniversalTaxCategories.category(normalised);
      if (universal == null || !universal.entityKinds.contains(entity.kind)) {
        throw ValidationException(
          message:
              'Unknown universal tax category "$normalised" '
              'for ${entity.kind.name} books',
        );
      }
      return;
    }

    final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
    if (jurisdiction == null) {
      throw ValidationException(
        message: 'No tax catalog exists for ${entity.countryCode}',
      );
    }

    final category = TaxRules.forJurisdiction(jurisdiction)
        .category(normalised);
    if (category == null || !category.entityKinds.contains(entity.kind)) {
      throw ValidationException(
        message:
            'Unknown ${jurisdiction.countryCode} tax category "$normalised" '
            'for ${entity.kind.name} books',
      );
    }
  }
}
