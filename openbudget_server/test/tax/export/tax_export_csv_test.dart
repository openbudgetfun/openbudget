import 'package:openbudget_server/src/tax/export/tax_export_csv.dart';
import 'package:test/test.dart';

void main() {
  group('csvField', () {
    test('quotes commas, quotes and line breaks', () {
      expect(csvField('a,b'), '"a,b"');
      expect(csvField('say "hi"'), '"say ""hi"""');
      expect(csvField('two\nlines'), '"two\nlines"');
    });

    test('neutralises text a spreadsheet would run as a formula', () {
      expect(csvField('=HYPERLINK("x")'), '"\'=HYPERLINK(""x"")"');
      expect(csvField('+1 shop'), "'+1 shop");
      expect(csvField('-cmd'), "'-cmd");
      expect(csvField('@SUM(A1)'), "'@SUM(A1)");
    });

    test('leaves plain numbers untouched so amounts still add up', () {
      expect(csvField('-12.34'), '-12.34');
      expect(csvField('-1200'), '-1200');
      expect(csvField(42), '42');
    });
  });
}
