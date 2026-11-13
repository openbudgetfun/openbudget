// The contract between the questions the rule packs declare in
// openbudget_core and the strings the app shows for them: every key a
// question names resolves through the generated resolver to text, the ARB
// file has that text, and the resolver knows no key a pack does not use.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/tax_question_labels.g.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// Every key [question] names: label, help, options and the month and day.
Set<String> arbKeysOf(TaxProfileQuestion question) => {
  question.labelKey,
  ?question.helpKey,
  if (question is TaxChoiceQuestion) ...[
    for (final option in question.options) option.labelKey,
    ?question.noneLabelKey,
  ],
  if (question is TaxMonthDayQuestion) ...[
    question.monthLabelKey,
    question.dayLabelKey,
  ],
};

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final arb = jsonDecode(
    File('lib/l10n/app_en.arb').readAsStringSync(),
  ) as Map<String, Object?>;

  /// Every key every pack declares, with where it is declared.
  final declared = <String, String>{};
  for (final jurisdiction in TaxJurisdiction.values) {
    final pack = TaxRules.forJurisdiction(jurisdiction);
    for (final kind in EntityKind.values) {
      for (final question in pack.profileQuestions(kind)) {
        for (final key in arbKeysOf(question)) {
          declared[key] = '${jurisdiction.countryCode} ${question.key}';
        }
      }
    }
  }

  test('the packs declare questions to resolve', () {
    expect(declared, isNotEmpty);
  });

  for (final entry in declared.entries) {
    test('${entry.key} (${entry.value}) has text in the ARB file', () {
      expect(arb[entry.key], isA<String>());
      expect((arb[entry.key]! as String).trim(), isNotEmpty);
    });

    test('${entry.key} (${entry.value}) resolves to that text', () {
      expect(taxQuestionLabel(l10n, entry.key), arb[entry.key]);
    });
  }

  test('the resolver knows exactly the declared keys', () {
    expect(taxQuestionLabelKeys.toSet(), declared.keys.toSet());
    expect(
      taxQuestionLabelKeys,
      hasLength(taxQuestionLabelKeys.toSet().length),
      reason: 'a key is listed twice',
    );
  });

  test('an undeclared key is an error, not empty text', () {
    expect(
      () => taxQuestionLabel(l10n, 'taxQNowhereAtAll'),
      throwsArgumentError,
    );
  });
}
