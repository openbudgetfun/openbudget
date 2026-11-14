import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_rules.dart';

/// The facts about a taxpayer that change how their figures are taxed.
///
/// [TaxProfile] carries only what every jurisdiction stores; each rule
/// pack owns its own subclass in `<cc>/<cc>_profile.dart` and defines its
/// stored JSON, its decoder and its questions there, so only the questions
/// that matter in that country can be asked and stored.
@immutable
abstract base class TaxProfile {
  const TaxProfile({
    required this.entityKind,
    this.salesTaxRegistered = false,
    this.taxResident = false,
    this.usPerson = false,
  });

  final EntityKind entityKind;

  /// Whether the books are registered for VAT or sales tax.
  final bool salesTaxRegistered;

  /// Whether the taxpayer is a tax resident of [jurisdiction]. The
  /// tax-planning guardrails require the answer before any lever is
  /// suggested.
  final bool taxResident;

  /// Whether the taxpayer is a US person for the information rules that
  /// follow from it. Asked in every country, because US persons owe US
  /// filings wherever they live.
  final bool usPerson;

  TaxJurisdiction get jurisdiction;

  Map<String, Object?> toJson();

  /// The answers to this pack's questions that describe the profile, keyed
  /// by [TaxProfileQuestion.key] (a month-and-day question by its
  /// `<key>Month` and `<key>Day`), with a value for every question even
  /// where [toJson] omits a default. The generic profile form starts from
  /// these. Profiles whose questions are not one stored field each, or
  /// that store a default as nothing, override it.
  Map<String, Object?> toAnswers() => toJson();

  /// This profile with [answers] applied, decoded through the pack so the
  /// result is validated like any stored profile. Answers replace the
  /// fields they name; every other field keeps its value. Keys are those
  /// of [toAnswers].
  ///
  /// Throws [FormatException] naming the field when an answer is invalid.
  TaxProfile withAnswers(Map<String, Object?> answers) =>
      TaxRules.forJurisdiction(
        jurisdiction,
      ).profileFromJson({...toJson(), ...answers});

  /// Decodes a stored profile. The jurisdiction names the rule pack, and
  /// the pack's own decoder defines the fields, so the pack is the single
  /// source of truth for its stored shape.
  ///
  /// Throws [FormatException] naming the field for a wrong type, an
  /// unknown enum value, a negative count or a missing required one.
  static TaxProfile fromJson(Map<String, Object?> json) {
    final jurisdictionCode = taxProfileRequired<String>(json, 'jurisdiction');
    final jurisdiction = TaxJurisdiction.fromCountryCode(jurisdictionCode);
    if (jurisdiction == null) {
      throw FormatException('Unknown jurisdiction', jurisdictionCode);
    }
    return TaxRules.forJurisdiction(jurisdiction).profileFromJson(json);
  }

  /// The fields every pack stores on its profile, in stored key order:
  /// the jurisdiction, the kind of books, sales-tax registration and the
  /// two guardrail answers. Each profile spreads this first in its
  /// [toJson], so this order is the stored order. The guardrail answers
  /// joined the stored shape after the first profiles were saved, so they
  /// are omitted while false and old profiles keep their exact bytes.
  @protected
  Map<String, Object?> baseJson() => {
    'jurisdiction': jurisdiction.countryCode,
    'entityKind': entityKind.name,
    'salesTaxRegistered': salesTaxRegistered,
    'taxResident': ?(taxResident ? true : null),
    'usPerson': ?(usPerson ? true : null),
  };
}

/// The identity fields every pack reads the same way, decoded from a
/// stored profile map: which kind of books this is, sales-tax
/// registration and the two guardrail answers.
typedef TaxProfileCommonFields = ({
  EntityKind entityKind,
  bool salesTaxRegistered,
  bool taxResident,
  bool usPerson,
});

/// Reads [TaxProfileCommonFields] from a stored profile map. Each pack's
/// decoder starts here, so the shared fields parse identically everywhere.
TaxProfileCommonFields taxProfileCommonJson(Map<String, Object?> json) => (
  entityKind: taxProfileRequiredEnum(json, 'entityKind', EntityKind.values),
  salesTaxRegistered:
      taxProfileField<bool>(json, 'salesTaxRegistered') ?? false,
  taxResident: taxProfileField<bool>(json, 'taxResident') ?? false,
  usPerson: taxProfileField<bool>(json, 'usPerson') ?? false,
);

// Strict readers for stored and client-supplied profile maps. Each one
// fails with a [FormatException] naming the field, so a malformed profile
// is reported as invalid input rather than crashing with a cast error.
// They are shared by every pack's profile decoder.

/// The value stored under [key] when it is a [T], null when absent, and a
/// [FormatException] naming [key] when it holds anything else.
T? taxProfileField<T extends Object>(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is T) return value;
  throw FormatException('Tax profile field "$key" must be a $T', value);
}

/// [taxProfileField] that rejects absence.
T taxProfileRequired<T extends Object>(Map<String, Object?> json, String key) =>
    taxProfileField<T>(json, key) ??
    (throw FormatException('Tax profile field "$key" is required'));

/// A non-negative whole number stored under [key], or null when absent.
int? taxProfileNonNegativeInt(Map<String, Object?> json, String key) {
  final value = taxProfileField<int>(json, key);
  if (value != null && value < 0) {
    throw FormatException(
      'Tax profile field "$key" must not be negative',
      value,
    );
  }
  return value;
}

/// The enum value whose name is stored under [key], or null when absent.
T? taxProfileEnumField<T extends Enum>(
  Map<String, Object?> json,
  String key,
  List<T> values,
) {
  final name = taxProfileField<String>(json, key);
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Tax profile field "$key" has an unknown value', name);
}

/// [taxProfileEnumField] that rejects absence.
T taxProfileRequiredEnum<T extends Enum>(
  Map<String, Object?> json,
  String key,
  List<T> values,
) =>
    taxProfileEnumField(json, key, values) ??
    (throw FormatException('Tax profile field "$key" is required'));

/// A question a rule pack asks to build its profile, as data.
///
/// The packs declare these so the app can render one generic form instead
/// of branching per country. Every user-visible key is an `AppLocalizations`
/// key named `taxQ<Cc><Field>` after the declaring pack, or `taxQCommon`
/// for the questions every pack shares; the answer is stored under [key].
@immutable
sealed class TaxProfileQuestion {
  const TaxProfileQuestion({
    required this.key,
    required this.labelKey,
    this.helpKey,
    this.appliesTo = const {
      EntityKind.individual,
      EntityKind.soleTrader,
      EntityKind.company,
    },
    this.visibleWhen,
  });

  /// The JSON field the answer is stored under.
  final String key;

  /// The `AppLocalizations` key of the question's label.
  final String labelKey;

  /// The `AppLocalizations` key of a longer explanation, when there is one.
  final String? helpKey;

  /// The kinds of books the question is asked of.
  final Set<EntityKind> appliesTo;

  /// Shown only when another answer has a given value.
  final TaxProfileCondition? visibleWhen;
}

/// A yes-or-no question, stored as a JSON boolean.
final class TaxBoolQuestion extends TaxProfileQuestion {
  const TaxBoolQuestion({
    required super.key,
    required super.labelKey,
    super.helpKey,
    super.appliesTo,
    super.visibleWhen,
  });
}

/// One option of a [TaxChoiceQuestion].
@immutable
final class TaxChoiceOption {
  const TaxChoiceOption({required this.value, required this.labelKey});

  /// The value stored under the question's key, usually an enum name.
  final String value;

  /// The `AppLocalizations` key of the option's label.
  final String labelKey;
}

/// A pick-one question, stored as the chosen option's [TaxChoiceOption.value].
final class TaxChoiceQuestion extends TaxProfileQuestion {
  const TaxChoiceQuestion({
    required super.key,
    required super.labelKey,
    required this.options,
    super.helpKey,
    super.appliesTo,
    super.visibleWhen,
    this.noneLabelKey,
  });

  final List<TaxChoiceOption> options;

  /// The `AppLocalizations` key of the extra "none of these" choice for a
  /// field that may be left unset, stored as a JSON null.
  final String? noneLabelKey;
}

/// An amount in the pack's currency, stored as integer minor units.
final class TaxMoneyQuestion extends TaxProfileQuestion {
  const TaxMoneyQuestion({
    required super.key,
    required super.labelKey,
    super.helpKey,
    super.appliesTo,
    super.visibleWhen,
  });
}

/// A whole number of things, stored as a JSON integer.
final class TaxCountQuestion extends TaxProfileQuestion {
  const TaxCountQuestion({
    required super.key,
    required super.labelKey,
    super.helpKey,
    super.appliesTo,
    super.visibleWhen,
  });
}

/// A day in the year, asked as a month and a day of month. The answer is
/// stored under the two JSON fields `<key>Month` and `<key>Day`.
final class TaxMonthDayQuestion extends TaxProfileQuestion {
  const TaxMonthDayQuestion({
    required super.key,
    required super.labelKey,
    required this.monthLabelKey,
    required this.dayLabelKey,
    super.helpKey,
    super.appliesTo,
    super.visibleWhen,
  });

  /// The `AppLocalizations` key of the month picker's label.
  final String monthLabelKey;

  /// The `AppLocalizations` key of the day picker's label.
  final String dayLabelKey;
}

/// Shows a question only when the answer stored under [key] is one of
/// [values].
@immutable
final class TaxProfileCondition {
  const TaxProfileCondition(this.key, this.values);

  /// The key of the answer the condition reads.
  final String key;

  /// The answer values that show the question, as [taxProfileAnswerText]
  /// writes them.
  final Set<String> values;

  /// Whether [answer] satisfies the condition.
  bool matches(Object? answer) =>
      answer != null && values.contains(taxProfileAnswerText(answer));
}

/// The text form of a question answer, as [TaxProfileCondition.values]
/// stores it: booleans as `true` and `false`, enums by name, everything
/// else by [Object.toString].
String taxProfileAnswerText(Object? answer) => switch (answer) {
  final bool answer => '$answer',
  final Enum answer => answer.name,
  final answer => '$answer',
};

/// The questions every pack asks, in form order: which kind of books this
/// is, VAT or sales-tax registration, and the two guardrail questions of
/// the tax-planning guardrails — residence, and whether the taxpayer is a
/// US person. Each pack's `profileQuestions` returns these before its own.
const commonTaxProfileQuestions = <TaxProfileQuestion>[
  TaxChoiceQuestion(
    key: 'entityKind',
    labelKey: 'taxQCommonEntityKind',
    options: [
      TaxChoiceOption(
        value: 'individual',
        labelKey: 'taxQCommonEntityKindIndividual',
      ),
      TaxChoiceOption(
        value: 'soleTrader',
        labelKey: 'taxQCommonEntityKindSoleTrader',
      ),
      TaxChoiceOption(
        value: 'company',
        labelKey: 'taxQCommonEntityKindCompany',
      ),
    ],
  ),
  TaxBoolQuestion(
    key: 'salesTaxRegistered',
    labelKey: 'taxQCommonSalesTaxRegistered',
    helpKey: 'taxQCommonSalesTaxRegisteredHelp',
  ),
  TaxBoolQuestion(
    key: 'taxResident',
    labelKey: 'taxQCommonTaxResident',
    helpKey: 'taxQCommonTaxResidentHelp',
  ),
  TaxBoolQuestion(
    key: 'usPerson',
    labelKey: 'taxQCommonUsPerson',
    helpKey: 'taxQCommonUsPersonHelp',
  ),
];

/// The questions [questions] ask for [kind], keeping only those whose
/// [TaxProfileQuestion.appliesTo] includes it. A pack's `profileQuestions`
/// passes its common-plus-country list here, so the app receives exactly
/// the questions that kind of books answers.
List<TaxProfileQuestion> taxProfileQuestionsFor(
  EntityKind kind,
  List<TaxProfileQuestion> questions,
) => [
  for (final question in questions)
    if (question.appliesTo.contains(kind)) question,
];
