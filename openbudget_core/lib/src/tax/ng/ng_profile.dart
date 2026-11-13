import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';

/// Which gross-turnover figure decides small-company status in Nigeria.
///
/// The two 2025 Acts disagree: the Nigeria Tax Act gazette defines a small
/// company at N50,000,000 or less, while the Nigeria Tax Administration Act
/// defines a "small business" at N100,000,000 or less. Officials describe the
/// N50,000,000 figure as a gazetting error, but no enacted correction was
/// found as of 5 November 2026, so the default stays on the Act that charges
/// the tax and the user can switch.
enum NgSmallCompanyCeiling {
  /// The Nigeria Tax Act gazette: gross turnover of N50,000,000 or less.
  ntaGazette,

  /// The Nigeria Tax Administration Act: gross turnover of N100,000,000 or
  /// less.
  ntaaIntended,
}

/// The facts about a Nigerian taxpayer that change how their figures are
/// taxed.
@immutable
final class NgTaxProfile extends TaxProfile {
  const NgTaxProfile({
    required super.entityKind,
    super.salesTaxRegistered,
    super.taxResident,
    super.usPerson,
    this.annualRentMinor = 0,
    this.smallCompanyCeiling = NgSmallCompanyCeiling.ntaGazette,
    this.mneGroupMember = false,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.ng;

  /// Annual rent paid on a home, for rent relief under the Nigeria Tax Act.
  ///
  /// The 2025 regime has no rent relief; the pack ignores this for a 2025
  /// year of assessment.
  final int annualRentMinor;

  /// Which turnover figure decides small-company status for 2026.
  final NgSmallCompanyCeiling smallCompanyCeiling;

  /// Whether the books belong to a constituent entity of a multinational
  /// group, which brings the 15% minimum effective tax rate (NTA s.57) into
  /// scope regardless of turnover.
  final bool mneGroupMember;

  @override
  Map<String, Object?> toJson() => {
    ...baseJson(),
    'annualRentMinor': annualRentMinor,
    'smallCompanyCeiling': smallCompanyCeiling.name,
    'mneGroupMember': mneGroupMember,
  };
}

/// Decodes an NG profile.
NgTaxProfile ngProfileFromJson(Map<String, Object?> json) {
  final common = taxProfileCommonJson(json);
  return NgTaxProfile(
    entityKind: common.entityKind,
    salesTaxRegistered: common.salesTaxRegistered,
    taxResident: common.taxResident,
    usPerson: common.usPerson,
    annualRentMinor: taxProfileNonNegativeInt(json, 'annualRentMinor') ?? 0,
    smallCompanyCeiling:
        taxProfileEnumField(
          json,
          'smallCompanyCeiling',
          NgSmallCompanyCeiling.values,
        ) ??
        NgSmallCompanyCeiling.ntaGazette,
    mneGroupMember: taxProfileField<bool>(json, 'mneGroupMember') ?? false,
  );
}

/// The questions the NG pack asks after [commonTaxProfileQuestions], in
/// form order.
const ngTaxProfileQuestions = <TaxProfileQuestion>[
  TaxMoneyQuestion(
    key: 'annualRentMinor',
    labelKey: 'taxQNgAnnualRent',
    helpKey: 'taxQNgAnnualRentHelp',
  ),
  TaxChoiceQuestion(
    key: 'smallCompanyCeiling',
    labelKey: 'taxQNgSmallCompanyCeiling',
    helpKey: 'taxQNgSmallCompanyCeilingHelp',
    options: [
      TaxChoiceOption(
        value: 'ntaGazette',
        labelKey: 'taxQNgSmallCompanyCeilingGazette',
      ),
      TaxChoiceOption(
        value: 'ntaaIntended',
        labelKey: 'taxQNgSmallCompanyCeilingIntended',
      ),
    ],
  ),
  TaxBoolQuestion(
    key: 'mneGroupMember',
    labelKey: 'taxQNgMneGroupMember',
    helpKey: 'taxQNgMneGroupMemberHelp',
  ),
];
