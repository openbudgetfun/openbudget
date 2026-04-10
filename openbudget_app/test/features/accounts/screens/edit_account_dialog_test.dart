// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/edit_account_dialog.dart';
import 'package:openbudget_client/openbudget_client.dart';

const _budgetId = '00000000-0000-0000-0000-000000000010';
final _budgetUuid = UuidValue.fromString(_budgetId);

Account _makeAccount({bool isClosed = false}) => Account(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000111'),
    name: 'Daily',
    accountType: 'checking',
    balanceCents: 5000000,
    currencyCode: 'USD',
    budgetId: _budgetUuid,
    onBudget: true,
    sortOrder: 0,
    isClosed: isClosed,
  );

class _FakeAccountActions extends AccountActions {
  _FakeAccountActions({this.onDelete, this.throwOnDelete = false});

  final VoidCallback? onDelete;
  final bool throwOnDelete;

  @override
  FutureOr<void> build() {}

  @override
  Future<Account> deleteAccount({
    required String accountId,
    required String budgetId,
  }) async {
    onDelete?.call();
    if (throwOnDelete) {
      throw StateError('delete response decode error');
    }
    return _makeAccount(isClosed: true);
  }

  @override
  Future<Account> updateAccount({
    required String accountId,
    required String budgetId,
    String? name,
    String? accountType,
    int? balanceCents,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
  }) async => _makeAccount(isClosed: isClosed ?? false);
}

Widget _buildSubject({
  required Account account,
  VoidCallback? onDeleted,
  VoidCallback? onDeleteAction,
  bool throwOnDelete = false,
  List<Account>? accountListOverride,
}) => ProviderScope(
    overrides: [
      accountActionsProvider.overrideWith(
        () => _FakeAccountActions(
          onDelete: onDeleteAction,
          throwOnDelete: throwOnDelete,
        ),
      ),
      if (accountListOverride != null)
        accountListProvider(_budgetId).overrideWith((ref) async => accountListOverride),
    ],
    child: MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => EditAccountDialog(
                  account: account,
                  budgetId: _budgetId,
                  onDeleted: onDeleted,
                ),
              ),
              child: const Text('Open Edit Dialog'),
            ),
          ),
        ),
      ),
    ),
  );

void main() {
  group('EditAccountDialog', () {
    testWidgets('open account shows close and delete actions', (tester) async {
      await tester.pumpWidget(_buildSubject(account: _makeAccount()));
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Account Nickname'), findsOneWidget);
      expect(find.text('Working Balance'), findsOneWidget);
      expect(find.text('Link an Account (Unavailable)'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Close Account'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Close Account'), findsOneWidget);
      expect(find.text('Delete Permanently'), findsOneWidget);
      expect(find.text('Reopen Account'), findsNothing);
    });

    testWidgets('closed account shows delete and reopen actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(account: _makeAccount(isClosed: true)),
      );
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Delete Permanently'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete Permanently'), findsOneWidget);
      expect(find.text('Reopen Account'), findsOneWidget);
      expect(find.text('Close Account'), findsNothing);
    });

    testWidgets('save stays disabled with invalid balance input', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(account: _makeAccount()));
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(2), 'abc');
      await tester.pumpAndSettle();

      final saveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('delete action triggers callback after successful delete', (
      tester,
    ) async {
      var deleteCalled = false;
      var onDeletedCalled = false;

      await tester.pumpWidget(
        _buildSubject(
          account: _makeAccount(isClosed: true),
          onDeleted: () => onDeletedCalled = true,
          onDeleteAction: () => deleteCalled = true,
        ),
      );
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Delete Permanently'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Permanently'));
      await tester.pumpAndSettle();

      expect(find.textContaining('"Daily"'), findsOneWidget);
      await tester.tap(
        find.widgetWithText(FilledButton, 'Delete Permanently').last,
      );
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
      expect(onDeletedCalled, isTrue);
      expect(find.text('Edit Account'), findsNothing);
    });

    testWidgets('delete fallback succeeds when account is already gone', (
      tester,
    ) async {
      var onDeletedCalled = false;

      await tester.pumpWidget(
        _buildSubject(
          account: _makeAccount(isClosed: true),
          throwOnDelete: true,
          onDeleted: () => onDeletedCalled = true,
          accountListOverride: const <Account>[],
        ),
      );
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Delete Permanently'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Permanently'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Delete Permanently').last,
      );
      await tester.pumpAndSettle();

      expect(onDeletedCalled, isTrue);
      expect(
        find.text('Could not delete account. Please try again.'),
        findsNothing,
      );
      expect(find.text('Edit Account'), findsNothing);
    });
  });
}
