import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// The ARB key derived from a universal code:
/// `universal.income.employment` → `universalCategoryIncomeEmployment`.
String _expectedLabelKey(String code) {
  final words = code
      .split('.')
      .skip(1)
      .expand((part) => part.split('_'))
      .map((word) => word[0].toUpperCase() + word.substring(1));
  return ['universalCategory', ...words].join();
}

void main() {
  group('the universal tax category catalogue', () {
    test('codes carry the universal prefix and are unique', () {
      final codes = universalCategories.map((category) => category.code);
      for (final code in codes) {
        expect(
          isUniversalCategoryCode(code),
          isTrue,
          reason: '$code must carry the universal prefix',
        );
      }
      expect(codes.toSet(), hasLength(universalCategories.length));
    });

    test('covers the section 8.6 groups', () {
      final codes = universalCategories.map((category) => category.code);
      expect(
        codes.where((code) => code.startsWith('universal.income.')),
        hasLength(12),
        reason:
            'section 8.6 lists ten income kinds; gains and digital-asset '
            'disposals split into proceeds and cost',
      );
      expect(
        codes.where((code) => code.startsWith('universal.expense.')),
        hasLength(17),
      );
      expect(
        codes.where((code) => code.startsWith('universal.relief.')),
        hasLength(7),
      );
      expect(
        codes.where((code) => code.startsWith('universal.tax.')),
        hasLength(4),
      );
      expect(
        codes.where((code) => code.startsWith('universal.out_of_scope.')),
        hasLength(4),
      );
    });

    test('every category names its kinds, label and ARB key', () {
      final labelKeys = <String>{};
      for (final category in universalCategories) {
        final reason = category.code;
        expect(category.entityKinds, isNotEmpty, reason: reason);
        expect(category.label, isNotEmpty, reason: reason);
        expect(category.labelKey, isNotNull, reason: reason);
        expect(
          category.labelKey,
          _expectedLabelKey(category.code),
          reason: '$reason must derive its ARB key from its code',
        );
        expect(labelKeys.add(category.labelKey!), isTrue, reason: reason);
        expect(
          category.labelKey!.startsWith('universalCategory'),
          isTrue,
          reason: reason,
        );
      }
    });

    test('kinds follow the catalogue group', () {
      for (final category in universalCategories) {
        switch (category.code.split('.')[1]) {
          case 'income':
            expect(
              category.kind,
              anyOf(
                TaxCategoryKind.income,
                TaxCategoryKind.disposalProceeds,
                TaxCategoryKind.disposalCost,
              ),
              reason: category.code,
            );
          case 'expense':
            expect(
              category.kind,
              TaxCategoryKind.expense,
              reason: category.code,
            );
          case 'relief':
            expect(
              category.kind,
              TaxCategoryKind.relief,
              reason: category.code,
            );
          case 'tax':
            expect(
              category.kind,
              anyOf(
                TaxCategoryKind.taxPaid,
                TaxCategoryKind.salesTaxPaid,
                TaxCategoryKind.salesTaxCollected,
              ),
              reason: category.code,
            );
          case 'out_of_scope':
            expect(
              category.kind,
              TaxCategoryKind.outOfScope,
              reason: category.code,
            );
        }
      }
    });

    test('categoriesFor filters by entity kind', () {
      for (final kind in EntityKind.values) {
        for (final category in UniversalTaxCategories.categoriesFor(kind)) {
          expect(
            category.entityKinds.contains(kind),
            isTrue,
            reason: '${category.code} must allow ${kind.name}',
          );
        }
      }
      // A sole trader cannot tag employment income; an individual cannot
      // tag business expenses.
      expect(
        UniversalTaxCategories.categoriesFor(
          EntityKind.soleTrader,
        ).map((category) => category.code),
        isNot(contains('universal.income.employment')),
      );
      expect(
        UniversalTaxCategories.categoriesFor(
          EntityKind.individual,
        ).map((category) => category.code),
        isNot(contains('universal.expense.software')),
      );
    });

    test('lookup knows its own codes and nothing else', () {
      expect(
        UniversalTaxCategories.category('universal.expense.software'),
        isNotNull,
      );
      expect(UniversalTaxCategories.category('gb.se.turnover'), isNull);
      expect(
        UniversalTaxCategories.category('universal.expense.unknown'),
        isNull,
      );
      expect(isUniversalCategoryCode('gb.se.turnover'), isFalse);
      expect(
        UniversalTaxCategories.isUniversalCode('universal.income.rent'),
        isTrue,
      );
    });
  });
}
