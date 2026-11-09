import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  group('OpenBudgetPalette.chartSeriesFor', () {
    for (final (name, theme) in [
      ('light', OpenBudgetTheme.light),
      ('dark', OpenBudgetTheme.dark),
    ]) {
      test('prints $name charts in the six spot inks', () {
        final series = OpenBudgetPalette.chartSeriesFor(theme);
        expect(series, theme.ob.spots);
        expect(series.toSet(), hasLength(6));
      });

      test('every $name series carries the action label at AA', () {
        for (final colour in OpenBudgetPalette.chartSeriesFor(theme)) {
          expect(
            obContrastRatio(theme.ob.onAction, colour),
            greaterThanOrEqualTo(4.5),
          );
        }
      });
    }
  });
}
