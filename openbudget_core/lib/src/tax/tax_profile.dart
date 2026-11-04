import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// The facts about a taxpayer that change how their figures are taxed.
///
/// Each jurisdiction has its own profile, so only the questions that matter
/// there can be asked and stored.
@immutable
sealed class TaxProfile {
  const TaxProfile({required this.entityKind});

  final TaxEntityKind entityKind;

  TaxJurisdiction get jurisdiction;

  /// Whether the books are registered for VAT or sales tax.
  bool get salesTaxRegistered;

  Map<String, Object?> toJson();

  static TaxProfile fromJson(Map<String, Object?> json) {
    final entityKind = TaxEntityKind.values.byName(
      json['entityKind']! as String,
    );
    final registered = json['salesTaxRegistered'] as bool? ?? false;
    return switch (TaxJurisdiction.fromCountryCode(
      json['jurisdiction']! as String,
    )) {
      TaxJurisdiction.gb => GbTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        scottishTaxpayer: json['scottishTaxpayer'] as bool? ?? false,
        studentLoanPlan: switch (json['studentLoanPlan']) {
          final String plan => GbStudentLoanPlan.values.byName(plan),
          _ => null,
        },
      ),
      TaxJurisdiction.us => UsTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        filingStatus: UsFilingStatus.values.byName(
          json['filingStatus'] as String? ?? UsFilingStatus.single.name,
        ),
      ),
      TaxJurisdiction.ng => NgTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        annualRentMinor: json['annualRentMinor'] as int? ?? 0,
      ),
      TaxJurisdiction.de => DeTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        jointAssessment: json['jointAssessment'] as bool? ?? false,
        churchTax: json['churchTax'] as bool? ?? false,
        smallBusinessExemption: json['smallBusinessExemption'] as bool? ?? true,
      ),
      null => throw FormatException(
        'Unknown jurisdiction',
        json['jurisdiction'],
      ),
    };
  }

  Map<String, Object?> _baseJson() => {
    'jurisdiction': jurisdiction.countryCode,
    'entityKind': entityKind.name,
    'salesTaxRegistered': salesTaxRegistered,
  };
}

/// Student loan repayment plans HMRC collects through Self Assessment.
enum GbStudentLoanPlan { plan1, plan2, plan4, plan5, postgraduate }

final class GbTaxProfile extends TaxProfile {
  const GbTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.scottishTaxpayer = false,
    this.studentLoanPlan,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.gb;

  @override
  final bool salesTaxRegistered;

  /// Scottish taxpayers pay income tax on non-savings income at Scottish
  /// rates.
  final bool scottishTaxpayer;

  final GbStudentLoanPlan? studentLoanPlan;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'scottishTaxpayer': scottishTaxpayer,
    'studentLoanPlan': ?studentLoanPlan?.name,
  };
}

enum UsFilingStatus {
  single,
  marriedFilingJointly,
  marriedFilingSeparately,
  headOfHousehold,
}

final class UsTaxProfile extends TaxProfile {
  const UsTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.filingStatus = UsFilingStatus.single,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.us;

  @override
  final bool salesTaxRegistered;

  final UsFilingStatus filingStatus;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'filingStatus': filingStatus.name,
  };
}

final class NgTaxProfile extends TaxProfile {
  const NgTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.annualRentMinor = 0,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.ng;

  @override
  final bool salesTaxRegistered;

  /// Annual rent paid on a home, for rent relief under the Nigeria Tax Act.
  final int annualRentMinor;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'annualRentMinor': annualRentMinor,
  };
}

final class DeTaxProfile extends TaxProfile {
  const DeTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.jointAssessment = false,
    this.churchTax = false,
    this.smallBusinessExemption = true,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.de;

  @override
  final bool salesTaxRegistered;

  /// Zusammenveranlagung: spouses assessed jointly under the splitting
  /// method.
  final bool jointAssessment;

  /// Kirchensteuer is due on top of income tax.
  final bool churchTax;

  /// Kleinunternehmerregelung (§19 UStG): no VAT charged or reclaimed.
  final bool smallBusinessExemption;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'jointAssessment': jointAssessment,
    'churchTax': churchTax,
    'smallBusinessExemption': smallBusinessExemption,
  };
}
