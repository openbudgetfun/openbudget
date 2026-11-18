import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/tax/tax_profile_form_values.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  final pack = TaxRules.forJurisdiction(TaxJurisdiction.de);
  final questions = pack.profileQuestions(EntityKind.individual);

  TaxFormValues valuesFor(
    TaxProfile profile, {
    TaxFormValues edits = const {},
  }) => taxFormValues(
    questions: questions,
    stored: profile.toAnswers(),
    edits: edits,
    decimals: 2,
  );

  group('taxFormValues', () {
    test('shows a zero count or amount as empty text', () {
      final values = valuesFor(
        const DeTaxProfile(entityKind: EntityKind.individual),
      );

      expect(values['children'], '');
      expect(values['statutoryPensionMinor'], '');
    });

    test('shows stored counts and amounts as editable text', () {
      final values = valuesFor(
        const DeTaxProfile(
          entityKind: EntityKind.individual,
          children: 2,
          statutoryPensionMinor: 480025,
        ),
      );

      expect(values['children'], '2');
      expect(values['statutoryPensionMinor'], '4800.25');
    });

    test('lets an edit win over the stored answer, even to nothing', () {
      final values = valuesFor(
        const DeTaxProfile(entityKind: EntityKind.individual, churchTax: true),
        edits: {'churchTax': false, 'children': ''},
      );

      expect(values['churchTax'], isFalse);
      expect(values['children'], '');
    });

    test('an unset choice with a "none" option is null', () {
      final values = valuesFor(
        const DeTaxProfile(entityKind: EntityKind.individual, churchTax: true),
      );

      expect(values['churchTaxState'], isNull);
    });

    test('a stored choice the question does not offer falls back', () {
      final values = valuesFor(
        const DeTaxProfile(entityKind: EntityKind.individual),
        edits: {'entityKind': 'trust'},
      );

      expect(values['entityKind'], 'individual');
    });
  });

  group('taxQuestionVisible', () {
    final spouse = questions.singleWhere(
      (question) => question.key == 'spouseEmployed',
    );

    test('hides a question until its condition holds', () {
      expect(taxQuestionVisible(spouse, {'jointAssessment': false}), isFalse);
      expect(taxQuestionVisible(spouse, {'jointAssessment': true}), isTrue);
    });

    test('shows a question with no condition', () {
      final children = questions.singleWhere(
        (question) => question.key == 'children',
      );

      expect(taxQuestionVisible(children, const {}), isTrue);
    });
  });

  group('taxFormAnswers', () {
    TaxFormValues blank() => valuesFor(
      const DeTaxProfile(entityKind: EntityKind.individual),
    );

    test('turns empty text into zero', () {
      final result = taxFormAnswers(
        questions: questions,
        values: blank(),
        decimals: 2,
      );

      expect(result.errors, isEmpty);
      expect(result.answers['children'], 0);
      expect(result.answers['statutoryPensionMinor'], 0);
    });

    test('parses counts and amounts, ignoring thousands separators', () {
      final result = taxFormAnswers(
        questions: questions,
        values: {
          ...blank(),
          'children': ' 3 ',
          'statutoryPensionMinor': '1,200.5',
        },
        decimals: 2,
      );

      expect(result.answers['children'], 3);
      expect(result.answers['statutoryPensionMinor'], 120050);
    });

    test('flags text that is not a count or an amount', () {
      final result = taxFormAnswers(
        questions: questions,
        values: {
          ...blank(),
          'children': '-1',
          'commuteKmOneWay': '2.5',
          'statutoryPensionMinor': '12.345',
        },
        decimals: 2,
      );

      expect(result.errors, {
        'children': TaxFieldError.count,
        'commuteKmOneWay': TaxFieldError.count,
        'statutoryPensionMinor': TaxFieldError.amount,
      });
      expect(result.answers, isNot(contains('children')));
    });

    test('lets bad text in a hidden question keep the stored answer', () {
      final hidden = taxFormAnswers(
        questions: [
          const TaxCountQuestion(
            key: 'children',
            labelKey: 'taxQDeChildren',
            visibleWhen: TaxProfileCondition('jointAssessment', {'true'}),
          ),
        ],
        values: {'jointAssessment': false, 'children': 'two'},
        decimals: 2,
      );

      expect(hidden.errors, isEmpty);
      expect(hidden.answers, isNot(contains('children')));
    });
  });

  test('a month has the days it can end on, counting 29 February', () {
    expect(taxDaysInMonth(2), 29);
    expect(taxDaysInMonth(4), 30);
    expect(taxDaysInMonth(12), 31);
  });
}
