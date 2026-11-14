import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('guidance perimeters', () {
    test('every pack jurisdiction has a perimeter', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        final perimeter = guidancePerimeterFor(jurisdiction);
        expect(perimeter, isNotNull, reason: '$jurisdiction has no perimeter');
        expect(perimeter!.jurisdiction, jurisdiction);
      }
    });

    test('each perimeter names its disclaimer key, scope and professional', () {
      final byKey = {
        for (final perimeter in TaxJurisdiction.values.map(
          guidancePerimeterFor,
        ))
          perimeter!.disclaimerKey: perimeter,
      };
      expect(byKey.keys, containsAll(['gb', 'us', 'de', 'ng']));
      for (final perimeter in byKey.values) {
        expect(perimeter.scopeStatement, isNotEmpty);
        expect(perimeter.professional, isNotEmpty);
        expect(
          perimeter.scopeStatement.toLowerCase(),
          isNot(contains('recommend')),
        );
      }
    });

    test('the perimeter key matches the disclaimer of its country', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        final perimeter = guidancePerimeterFor(jurisdiction)!;
        final disclaimer = guidanceDisclaimerFor(jurisdiction)!;
        expect(perimeter.disclaimerKey, disclaimer.key);
      }
    });

    test('every reserved topic carries a boundary and a reason', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        final perimeter = guidancePerimeterFor(jurisdiction)!;
        expect(perimeter.reservedTopics, isNotEmpty);
        for (final topic in perimeter.reservedTopics) {
          expect(
            topic.id,
            startsWith('${jurisdiction.countryCode.toLowerCase()}.'),
          );
          expect(topic.title, isNotEmpty);
          expect(topic.note, isNotEmpty);
        }
      }
    });

    test('the German perimeter marks GmbH owner-pay comparisons '
        'signpost-only', () {
      final topic = dePerimeter.topic('de.gmbh-owner-structures')!;
      expect(topic.boundary, GuidanceBoundary.signpostOnly);
      expect(dePerimeter.signpostOnlyTopics, contains(topic));
    });

    test('the UK perimeter marks product picks and targeted support '
        'signpost-only', () {
      expect(
        gbPerimeter.topic('gb.investment-recommendation')!.boundary,
        GuidanceBoundary.signpostOnly,
      );
      expect(
        gbPerimeter.topic('gb.targeted-support')!.boundary,
        GuidanceBoundary.signpostOnly,
      );
    });

    test('topics are looked up by id and unknown ids return null', () {
      expect(usPerimeter.topic('us.investment-selection'), isNotNull);
      expect(usPerimeter.topic('gb.investment-recommendation'), isNull);
    });
  });

  group('disclaimers', () {
    test('every pack jurisdiction has a disclaimer with text', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        final disclaimer = guidanceDisclaimerFor(jurisdiction);
        expect(disclaimer, isNotNull);
        expect(disclaimer!.key, jurisdiction.countryCode.toLowerCase());
        expect(disclaimer.addition, isNotEmpty);
        expect(
          disclaimer.fullText,
          startsWith(standardDisclaimerText.substring(0, 20)),
        );
        expect(disclaimer.fullText, contains(disclaimer.addition));
      }
    });

    test(
      'the German disclaimer is German and names the right professionals',
      () {
        final de = guidanceDisclaimerFor(TaxJurisdiction.de)!;
        expect(de.addition, contains('Steuerberatung'));
        expect(de.addition, contains('Lohnsteuerhilfeverein'));
      },
    );
  });

  group('signpost triggers', () {
    test('the guardrail triggers are present and unique', () {
      final ids = signpostTriggers.map((trigger) => trigger.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(
        ids,
        containsAll([
          'residence-unclear',
          'us-person-abroad',
          'owner-managed-structures',
          'should-i-investment',
          'large-saving',
          'authority-contact',
          'trusts-and-family',
          'missing-facts',
          'unverified-rule',
        ]),
      );
      for (final trigger in signpostTriggers) {
        expect(trigger.condition, isNotEmpty);
      }
    });

    test('triggers are looked up by id', () {
      expect(signpostTrigger('residence-unclear'), isNotNull);
      expect(signpostTrigger('nope'), isNull);
      expect(signpostWording, contains('qualified adviser'));
    });
  });

  group('never-suggest list', () {
    test('carries the ten guardrail patterns', () {
      expect(neverSuggestList, hasLength(10));
      final ids = neverSuggestList.map((item) => item.id).toSet();
      expect(ids, hasLength(10));
      for (final item in neverSuggestList) {
        expect(item.pattern, isNotEmpty);
        expect(item.why, isNotEmpty);
      }
    });

    test('items are looked up by id', () {
      expect(neverSuggestItem('concealment')!.pattern, contains('income'));
      expect(neverSuggestItem('nope'), isNull);
    });

    test('every pack jurisdiction has anti-avoidance rules', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        final rules = antiAvoidanceRulesFor(jurisdiction).toList();
        expect(rules, isNotEmpty, reason: '$jurisdiction has no rules');
        for (final rule in rules) {
          expect(
            rule.id,
            startsWith('${jurisdiction.countryCode.toLowerCase()}.'),
          );
        }
      }
    });
  });

  group('wording lint', () {
    test('accepts the neutral pass cases', () {
      expect(
        findWordingIssues(
          title: 'Pension annual allowance',
          explanation: 'The allowance is £60,000 this year.',
        ),
        isEmpty,
      );
      expect(
        findWordingIssues(
          title: 'Rent relief',
          explanation: 'The rent relief is 20% of rent paid, up to ₦500,000.',
        ),
        isEmpty,
      );
      expect(
        findWordingIssues(
          title: 'Standard deduction compared with itemised',
          explanation: 'The standard deduction is larger.',
        ),
        isEmpty,
      );
    });

    test('rejects every banned phrase', () {
      final banned = <(String, String)>[
        ('You should pay £5,000', 'you should'),
        ('You must register', 'you must'),
        ('We recommend the ISA', 'we recommend'),
        ('The best option', 'best'),
        ('The optimal salary', 'optimal'),
        ('This guarantees a saving', 'guarantee'),
        ('A guaranteed loophole', 'loophole'),
        ('Sie sollten einzahlen', 'Sie sollten'),
        ('Wir empfehlen', 'wir empfehlen'),
        ('Eine Handlungsempfehlung', 'Handlungsempfehlung'),
      ];
      for (final (text, phrase) in banned) {
        expect(
          findWordingIssues(title: text, explanation: ''),
          isNotEmpty,
          reason: '"$text" should match "$phrase"',
        );
      }
    });

    test('rejects banned phrases in explanations too', () {
      expect(
        findWordingIssues(
          title: 'Pension annual allowance',
          explanation: 'You should pay into a pension.',
        ),
        isNotEmpty,
      );
    });

    test('rejects imperative titles in English and German', () {
      for (final title in [
        'Use your pension annual allowance',
        'Claim rent relief',
        'Pay quarterly estimated tax',
        'Take the standard deduction',
        'Harvest capital losses',
        'Shelter savings in an ISA',
        'Itemize deductions',
        'Maximize your deductions',
        'Register for VAT',
        'File your annual return',
        'Compare salary with dividends',
        'Watch the VAT threshold',
        'Budget for the deadline',
        'Restore your personal allowance',
        'Basisrente bis zum Höchstbetrag einzahlen',
        'Freistellungsauftrag nutzen',
        'Homeoffice-Pauschale ausschöpfen',
        'Günstigerprüfung beantragen',
        'Investitionsabzugsbetrag bilden',
        'Kleinunternehmerregelung prüfen',
      ]) {
        expect(
          findWordingIssues(title: title, explanation: ''),
          isNotEmpty,
          reason: '"$title" is an imperative title',
        );
      }
    });
  });
}
