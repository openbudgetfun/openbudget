import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/edit_account_dialog.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../../../fixtures/budget_month.dart';

const String _entityId = fixtureEntityId;

Account _makeAccount({bool isClosed = false}) => testAccount(
  name: 'Daily',
  balanceMinor: 5000000,
  closedAt: isClosed ? DateTime.utc(2026, 8) : null,
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
    required String entityId,
  }) async {
    onDelete?.call();
    if (throwOnDelete) {
      throw Exception('delete response decode error');
    }
    return _makeAccount(isClosed: true);
  }

  @override
  Future<Account> closeAccount({
    required String accountId,
    required String entityId,
  }) async => _makeAccount(isClosed: true);

  @override
  Future<Account> reopenAccount({
    required String accountId,
    required String entityId,
  }) async => _makeAccount();

  @override
  Future<Account> updateAccount({
    required String accountId,
    required String entityId,
    String? name,
    AccountKind? kind,
    bool? onBudget,
    String? institutionId,
    bool clearInstitution = false,
    String? note,
    int? sortOrder,
  }) async => _makeAccount();
}

class _RecordingAccountActions extends AccountActions {
  String? savedName;
  String? savedNote;

  @override
  FutureOr<void> build() {}

  @override
  Future<Account> updateAccount({
    required String accountId,
    required String entityId,
    String? name,
    AccountKind? kind,
    bool? onBudget,
    String? institutionId,
    bool clearInstitution = false,
    String? note,
    int? sortOrder,
  }) async {
    savedName = name;
    savedNote = note;
    return _makeAccount();
  }
}

Widget _buildSubject({
  required Account account,
  VoidCallback? onDeleted,
  VoidCallback? onDeleteAction,
  bool throwOnDelete = false,
  List<Account>? accountListOverride,
  AccountActions? actions,
}) => ProviderScope(
  overrides: [
    accountActionsProvider.overrideWith(
      () =>
          actions ??
          _FakeAccountActions(
            onDelete: onDeleteAction,
            throwOnDelete: throwOnDelete,
          ),
    ),
    if (accountListOverride != null)
      accountListProvider(
        _entityId,
      ).overrideWith((ref) async => accountListOverride),
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
                entityId: _entityId,
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

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('EditAccountDialog', () {
    testWidgets('open account shows close and delete actions', (tester) async {
      await tester.pumpWidget(_buildSubject(account: _makeAccount()));
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Account Nickname'), findsOneWidget);
      await _scrollTo(tester, find.text('Close Account'));
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

      await _scrollTo(tester, find.text('Delete Permanently'));

      expect(find.text('Delete Permanently'), findsOneWidget);
      expect(find.text('Reopen Account'), findsOneWidget);
      expect(find.text('Close Account'), findsNothing);
    });

    testWidgets('save keeps the nickname and note', (tester) async {
      final actions = _RecordingAccountActions();
      await tester.pumpWidget(
        _buildSubject(account: _makeAccount(), actions: actions),
      );
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Everyday');
      final notesFields = find.byType(TextField);
      await tester.enterText(notesFields.last, 'Paycheque lands here');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(actions.savedName, 'Everyday');
      expect(actions.savedNote, 'Paycheque lands here');
    });

    testWidgets('delete action triggers callback after successful delete', (
      tester,
    ) async {
      var deleteCalled = false;

      await tester.pumpWidget(
        _buildSubject(
          account: _makeAccount(isClosed: true),
          onDeleteAction: () => deleteCalled = true,
        ),
      );
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('Delete Permanently'));

      await tester.tap(find.text('Delete Permanently'));
      await tester.pumpAndSettle();

      expect(find.textContaining('"Daily"'), findsOneWidget);
      await tester.tap(
        find.widgetWithText(FilledButton, 'Delete Permanently').last,
      );
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
      // onDeleted was the pre-port imperative refresh hook; the realtime
      // entity events invalidate the list now, so only the delete call
      // matters here.
      expect(find.text('Edit Account'), findsNothing);
    });

    testWidgets('a failed delete shows the error toast and keeps the dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          account: _makeAccount(isClosed: true),
          throwOnDelete: true,
        ),
      );
      await tester.tap(find.text('Open Edit Dialog'));
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('Delete Permanently'));

      await tester.tap(find.text('Delete Permanently'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Delete Permanently').last,
      );
      await tester.pumpAndSettle();

      // The confirm dialog's inline error and the toast both show it.
      expect(
        find.text('Could not delete account. Please try again.'),
        findsWidgets,
      );
      expect(find.text('Delete Permanently'), findsWidgets);
    });
  });
}
