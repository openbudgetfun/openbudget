import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

void main() {
  group('pumpApp', () {
    testWidgets('renders widget with theme', (tester) async {
      await tester.pumpApp(const Scaffold(body: Text('Hello OpenBudget')));

      expect(find.text('Hello OpenBudget'), findsOneWidget);
    });
  });
}
