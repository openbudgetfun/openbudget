import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/money_guide/guidance_block.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

Entity _entity(String countryCode) => Entity(
  ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
  name: 'Test',
  kind: EntityKind.individual,
  countryCode: countryCode,
  baseCurrencyCode: countryCode == 'GB' ? 'GBP' : 'KES',
  timeZone: countryCode == 'GB' ? 'Europe/London' : 'Africa/Nairobi',
  fiscalYearEndMonth: 12,
  fiscalYearEndDay: 31,
);

void main() {
  group('buildGuidanceBlock', () {
    test('pack country with reviewed maturity is full', () {
      final block = buildGuidanceBlock(
        entity: _entity('GB'),
        maturity: 'reviewed',
      );
      expect(block['jurisdictionState'], 'full');
      expect(block['disclaimerKey'], isNotNull);
      expect(block['scopeStatement'], isNotNull);
      expect(block.containsKey('scopeSentence'), isFalse);
      expect(block.containsKey('state'), isFalse);
      expect(block.containsKey('signpostTo'), isFalse);
    });

    test('pack country with preview maturity is preview', () {
      final block = buildGuidanceBlock(
        entity: _entity('GB'),
        maturity: 'preview',
      );
      expect(block['jurisdictionState'], 'preview');
    });

    test('non-pack country is universal with null perimeter fields', () {
      final block = buildGuidanceBlock(entity: _entity('KE'));
      expect(block['jurisdictionState'], 'universal');
      expect(block['disclaimerKey'], isNull);
      expect(block['scopeStatement'], isNull);
      expect(block['professional'], isNull);
      expect(block['signposts'], isEmpty);
      expect(block['reservedTopics'], isEmpty);
      expect(block['crossBorder'], isFalse);
    });
  });
}
