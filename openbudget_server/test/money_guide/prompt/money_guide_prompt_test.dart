import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_index.dart';
import 'package:openbudget_server/src/money_guide/money_guide_prompt.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

/// Set to `1` to rewrite the golden briefs instead of comparing against
/// them: `UPDATE_GOLDENS=1 dart test test/money_guide/prompt/`.
final bool _updateGoldens = Platform.environment['UPDATE_GOLDENS'] == '1';

/// The pinned instant every brief is built at: no test reads the real clock.
final DateTime _now = DateTime.utc(2026, 11, 14);

const String _entityName = 'Zebediah Quillfeather & Sons';
final UuidValue _entityId = UuidValue.fromString(
  '7f3c9a2e-5b1d-4e8a-9c6f-0d2b4a6e8c10',
);
final UuidValue _ownerId = UuidValue.fromString(
  'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d',
);
final UuidValue _linkedId = UuidValue.fromString(
  'c0ffee00-1234-4abc-9def-aabbccddeeff',
);

Entity _entity({
  required EntityKind kind,
  required String countryCode,
  required String currency,
  required String timeZone,
  String name = _entityName,
  int fiscalYearEndMonth = 12,
  int fiscalYearEndDay = 31,
}) => Entity(
  id: _entityId,
  ownerId: _ownerId,
  name: name,
  kind: kind,
  countryCode: countryCode,
  baseCurrencyCode: currency,
  timeZone: timeZone,
  fiscalYearEndMonth: fiscalYearEndMonth,
  fiscalYearEndDay: fiscalYearEndDay,
  linkedPersonalEntityId: _linkedId,
);

final Entity _gb = _entity(
  kind: EntityKind.soleTrader,
  countryCode: 'GB',
  currency: 'GBP',
  timeZone: 'Europe/London',
  fiscalYearEndMonth: 4,
  fiscalYearEndDay: 5,
);
final Entity _us = _entity(
  kind: EntityKind.individual,
  countryCode: 'US',
  currency: 'USD',
  timeZone: 'America/New_York',
);
final Entity _de = _entity(
  kind: EntityKind.company,
  countryCode: 'DE',
  currency: 'EUR',
  timeZone: 'Europe/Berlin',
);
final Entity _ng = _entity(
  kind: EntityKind.individual,
  countryCode: 'NG',
  currency: 'NGN',
  timeZone: 'Africa/Lagos',
);
final Entity _ke = _entity(
  kind: EntityKind.individual,
  countryCode: 'KE',
  currency: 'KES',
  timeZone: 'Africa/Nairobi',
);

final Map<String, Entity> _entities = {
  'gb': _gb,
  'us': _us,
  'de': _de,
  'ng': _ng,
  'ke': _ke,
};

String _brief(
  Entity entity, {
  bool taxResident = false,
  bool usPerson = false,
}) => MoneyGuidePrompt.brief(
  entity: entity,
  now: _now,
  taxResident: taxResident,
  usPerson: usPerson,
);

/// The wording the guardrails forbid that [text] uses.
List<String> _forbiddenIn(String text) => [
  for (final (shown, pattern) in forbiddenCardWording)
    if (RegExp(pattern, caseSensitive: false).hasMatch(text)) shown,
];

KnowledgeCard _card({
  required String id,
  required String countryCode,
  required String title,
  List<int> taxYears = const [],
  List<EntityKind> entityKinds = const [],
}) => KnowledgeCard(
  id: id,
  countryCode: countryCode,
  title: title,
  topics: const ['tax'],
  entityKinds: entityKinds,
  taxYears: taxYears,
  grade: TaxEvidenceGrade.primary,
  verifiedOn: DateTime.utc(2026, 11),
  recheckBy: DateTime.utc(2027, 4),
  perimeter: KnowledgePerimeter.taxIllustration,
  needsEvidence: false,
  announced: false,
  keywords: const [],
  sources: const [],
  body: 'Body.',
);

void main() {
  group('golden briefs', () {
    for (final MapEntry(key: name, value: entity) in _entities.entries) {
      test('the $name brief matches its golden snapshot', () {
        final brief = _brief(entity);
        final golden = File('test/money_guide/prompt/goldens/$name.txt');
        if (_updateGoldens) {
          golden.writeAsStringSync('$brief\n');
        }
        expect(
          golden.existsSync(),
          isTrue,
          reason: 'Missing golden; run with UPDATE_GOLDENS=1.',
        );
        expect(
          brief,
          golden.readAsStringSync().trimRight(),
          reason: 'Brief changed; rerun with UPDATE_GOLDENS=1 if intended.',
        );
      });
    }
  });

  group('static rules', () {
    test('are byte-identical for every entity and come first', () {
      final messages = [
        for (final entity in _entities.values)
          MoneyGuidePrompt.systemMessages(_brief(entity)),
      ];
      for (final system in messages) {
        expect(system, hasLength(2));
        expect(system.first['content'], MoneyGuidePrompt.staticRules);
        expect(system.first['role'], 'system');
        expect(system.last['role'], 'system');
      }
      final statics = {for (final system in messages) system.first['content']};
      expect(statics, hasLength(1));
      final briefs = {for (final system in messages) system.last['content']};
      expect(briefs, hasLength(messages.length));
    });

    test('keep the guidance framing and never name an adviser', () {
      const rules = MoneyGuidePrompt.staticRules;
      expect(rules, contains('guidance, not regulated financial, tax'));
      expect(rules, contains('Do not call yourself an adviser'));
      expect(rules.toLowerCase(), isNot(contains('financial advisor')));
      expect(rules.toLowerCase(), isNot(contains('financial adviser')));
      expect(rules, isNot(contains('assistant')));
      expect(rules, contains('[^key]'));
      expect(rules, contains('announced, not yet law'));
      expect(rules, contains('Never claim a change was made'));
    });

    test('name every item of the never-suggest list', () {
      const keywords = <String, String>{
        'marketeted-avoidance': 'avoidance schemes',
        'income-splitting': 'income splitting',
        'disguised-employment': 'disguised employment',
        'below-market-owner-pay': 'below-market pay',
        'wash-sales': 'wash sales',
        'concealment': 'hiding income',
        'residence-of-convenience': 'only for a tax result',
        'personal-costs-as-business': 'personal costs recorded as business',
        'director-loan-bed-and-breakfast': 'repeated company loans',
        'backdating': 'backdated records',
      };
      expect(
        neverSuggestList.map((item) => item.id).toSet(),
        keywords.keys.toSet(),
        reason: 'A never-suggest item changed; update the prompt and this map.',
      );
      final rules = MoneyGuidePrompt.staticRules.replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      for (final MapEntry(key: id, value: keyword) in keywords.entries) {
        expect(rules, contains(keyword), reason: 'No short form of $id');
      }
    });

    test('state the product, allocation and "people like them" bans', () {
      final rules = MoneyGuidePrompt.staticRules.replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      expect(rules, contains('Never pick, rank or name products'));
      expect(rules, contains('allocation, trade timing'));
      expect(rules, contains('what people like them usually do'));
      expect(rules, contains('tax resident and whether they are a US person'));
    });

    test('fit the 2,500-token budget of docs/money-guide.md section 5.4', () {
      expect(
        estimateTokens(MoneyGuidePrompt.staticRules),
        lessThanOrEqualTo(2500),
      );
    });
  });

  group('brief size', () {
    for (final MapEntry(key: name, value: entity) in _entities.entries) {
      test('the $name brief stays under 2,000 estimated tokens', () {
        final tokens = estimateTokens(_brief(entity));
        expect(tokens, lessThan(2000), reason: '$name brief: $tokens tokens');
      });
    }

    test('estimateTokens is characters divided by four, rounded up', () {
      expect(estimateTokens(''), 0);
      expect(estimateTokens('abcd'), 1);
      expect(estimateTokens('abcde'), 2);
    });
  });

  group('privacy', () {
    test('no brief carries the entity name or any identifier', () {
      final secrets = [
        _entityName,
        'Zebediah',
        'Quillfeather',
        _entityId.uuid,
        _ownerId.uuid,
        _linkedId.uuid,
      ];
      for (final MapEntry(key: name, value: entity) in _entities.entries) {
        final brief = _brief(entity).toLowerCase();
        for (final secret in secrets) {
          expect(
            brief,
            isNot(contains(secret.toLowerCase())),
            reason: 'The $name brief leaks "$secret".',
          );
        }
      }
    });

    test('two entities that differ only by name and ids get one brief', () {
      final other = Entity(
        id: UuidValue.fromString('11111111-2222-4333-8444-555555555555'),
        ownerId: UuidValue.fromString('99999999-8888-4777-8666-555555555555'),
        name: 'A different name entirely',
        kind: _gb.kind,
        countryCode: _gb.countryCode,
        baseCurrencyCode: _gb.baseCurrencyCode,
        timeZone: _gb.timeZone,
        fiscalYearEndMonth: _gb.fiscalYearEndMonth,
        fiscalYearEndDay: _gb.fiscalYearEndDay,
      );
      expect(_brief(other), _brief(_gb));
    });
  });

  group('jurisdiction states', () {
    test('a preview pack reports preview, with its rules version', () {
      final brief = _brief(_gb);
      expect(brief, contains('Jurisdiction: preview, rules '));
      expect(brief, contains('personal income tax preview'));
      expect(brief, contains('company tax preview'));
      expect(brief, contains('digital assets universal'));
      expect(brief, contains('payroll universal'));
      expect(brief, isNot(contains(' full')));
    });

    test('a section that does not exist for the country is not applicable', () {
      expect(_brief(_us), contains('VAT or sales tax not applicable'));
    });

    test('a country with no pack is universal in every section', () {
      final brief = _brief(_ke);
      expect(brief, contains('Jurisdiction: universal, no rule pack for KE.'));
      expect(brief, contains('Sections: every section universal.'));
      expect(brief, contains('Disclaimer key: none.'));
      expect(
        brief,
        contains('Signpost to: a qualified local tax professional.'),
      );
      expect(brief, contains('Perimeter: general guidance only.'));
    });

    test('a universal country states only its indirect tax, graded', () {
      final brief = _brief(_ke);
      expect(brief, contains('Tax authority: Kenya Revenue Authority (KRA).'));
      expect(
        brief,
        contains('Indirect tax now: VAT standard 16% (grade secondary).'),
      );
      // Rows that ended before the pinned date are not in force.
      expect(brief, isNot(contains('14%')));
      expect(brief, isNot(contains('petroleum')));
    });

    test('a pack country names its perimeter, professional and disclaimer', () {
      final brief = _brief(_gb);
      expect(brief, contains('Perimeter: tax illustration.'));
      expect(brief, contains('Personal recommendations on investments'));
      expect(
        brief,
        contains(
          'Signpost to: an authorised financial adviser or MoneyHelper.',
        ),
      );
      expect(brief, contains('Disclaimer key: gb.'));
      expect(_brief(_de), contains('Disclaimer key: de.'));
      expect(_brief(_de), contains('Signpost to: ein Steuerberater'));
    });
  });

  group('tax year and profile', () {
    test('the GB tax year starts on 6 April', () {
      expect(
        _brief(_gb),
        contains('Tax year now: 2026/27, 2026-04-06 to 2027-04-05.'),
      );
      final beforeBoundary = MoneyGuidePrompt.brief(
        entity: _gb,
        now: DateTime.utc(2026, 4, 5, 12),
      );
      expect(
        beforeBoundary,
        contains('Tax year now: 2025/26, 2025-04-06 to 2026-04-05.'),
      );
    });

    test('a calendar-year country shows its calendar year', () {
      expect(
        _brief(_ke),
        contains('Tax year now: 2026, 2026-01-01 to 2026-12-31.'),
      );
    });

    test('the profile answers show as recorded or not recorded', () {
      expect(
        _brief(_gb),
        contains(
          'Profile: tax resident of GB not recorded; US person not recorded.',
        ),
      );
      expect(
        _brief(_gb, taxResident: true, usPerson: true),
        contains('Profile: tax resident of GB yes; US person yes.'),
      );
    });
  });

  group('card index', () {
    test(
      'lists the entity country and universal cards for the year and kind',
      () {
        final index = KnowledgeIndex([
          _card(id: 'gb-b', countryCode: 'GB', title: 'Second GB card'),
          _card(
            id: 'gb-a',
            countryCode: 'GB',
            title: 'First GB card',
            taxYears: [2026],
          ),
          _card(
            id: 'gb-old',
            countryCode: 'GB',
            title: 'Old year',
            taxYears: [2025],
          ),
          _card(
            id: 'gb-company',
            countryCode: 'GB',
            title: 'Company only',
            entityKinds: [EntityKind.company],
          ),
          _card(id: 'us-a', countryCode: 'US', title: 'US card'),
          _card(
            id: 'universal-a',
            countryCode: 'universal',
            title: 'Universal card',
          ),
        ]);
        final brief = MoneyGuidePrompt.brief(
          entity: _gb,
          now: _now,
          index: index,
        );
        expect(
          brief,
          contains(
            'Cards for GB (id: title):\n'
            '- gb-a: First GB card\n'
            '- gb-b: Second GB card\n'
            'Universal cards (id: title):\n'
            '- universal-a: Universal card',
          ),
        );
        for (final absent in ['gb-old', 'gb-company', 'us-a']) {
          expect(brief, isNot(contains(absent)));
        }
      },
    );

    test('says so when a country has no cards', () {
      final brief = _brief(_ke);
      expect(brief, contains('Cards for KE: none.'));
      expect(brief, contains('Universal cards (id: title):'));
    });

    test('lists the shipped universal cards', () {
      expect(
        _brief(_ke),
        contains('- universal-budgeting-zero-based-envelopes: '),
      );
    });
  });

  group('wording', () {
    test('no brief uses wording the guardrails forbid', () {
      for (final MapEntry(key: name, value: entity) in _entities.entries) {
        expect(_forbiddenIn(_brief(entity)), isEmpty, reason: 'brief $name');
      }
    });
  });
}
