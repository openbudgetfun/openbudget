/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: no_leading_underscores_for_local_identifiers

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'dart:io' as _idi;

import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:openbudget_server/src/generated/accounts/account.dart'
    as _i3fh9aci;
import 'package:openbudget_server/src/generated/accounts/account_balances_view.dart'
    as _icm7c3fq;
import 'package:openbudget_server/src/generated/accounts/account_valuation.dart'
    as _itqzh2rv;
import 'package:openbudget_server/src/generated/agent/agent_conversation.dart'
    as _ihq3j0fx;
import 'package:openbudget_server/src/generated/agent/agent_event.dart'
    as _ig0iahoe;
import 'package:openbudget_server/src/generated/agent/agent_message.dart'
    as _ixbh63dx;
import 'package:openbudget_server/src/generated/agent/agent_proposal.dart'
    as _iqa5uoc4;
import 'package:openbudget_server/src/generated/agent/agent_provider_settings_view.dart'
    as _ixg2m9if;
import 'package:openbudget_server/src/generated/agent/agent_usage_view.dart'
    as _iwi553xc;
import 'package:openbudget_server/src/generated/agent/mcp/agent_access_token_created.dart'
    as _ir54shi0;
import 'package:openbudget_server/src/generated/agent/mcp/agent_access_token_view.dart'
    as _i8fy0qox;
import 'package:openbudget_server/src/generated/audit/audit_event.dart'
    as _ictk02ka;
import 'package:openbudget_server/src/generated/billing/entitlement.dart'
    as _iiht0r85;
import 'package:openbudget_server/src/generated/billing/solana_plan_view.dart'
    as _i7ligxlm;
import 'package:openbudget_server/src/generated/budget/allocation_input.dart'
    as _inwbkajl;
import 'package:openbudget_server/src/generated/budget/budget_month_summary.dart'
    as _ipz3w5am;
import 'package:openbudget_server/src/generated/budget/budget_month_view.dart'
    as _iumjg9vv;
import 'package:openbudget_server/src/generated/budget_templates/budget_template.dart'
    as _ihbdj8p6;
import 'package:openbudget_server/src/generated/budget_templates/budget_template_line.dart'
    as _iz4ekkcc;
import 'package:openbudget_server/src/generated/categories/category.dart'
    as _iwlneq7u;
import 'package:openbudget_server/src/generated/entities/entity.dart'
    as _if2ry2np;
import 'package:openbudget_server/src/generated/entities/entity_changed_event.dart'
    as _i6lrvoev;
import 'package:openbudget_server/src/generated/entities/entity_summary_view.dart'
    as _im3neacv;
import 'package:openbudget_server/src/generated/envelope_goals/envelope_goal.dart'
    as _iuyjld9f;
import 'package:openbudget_server/src/generated/envelope_goals/envelope_goal_kind.dart'
    as _i16hg0wx;
import 'package:openbudget_server/src/generated/envelopes/envelope.dart'
    as _igwnqatb;
import 'package:openbudget_server/src/generated/future_calls.dart' as _iwv90kfd;
import 'package:openbudget_server/src/generated/future_calls_generated_models/fx_backfill_future_call_fetch_model.dart'
    as _i0uw56cr;
import 'package:openbudget_server/src/generated/fx_rates/fx_latest_snapshot.dart'
    as _ictw4lhv;
import 'package:openbudget_server/src/generated/fx_rates/fx_quote_view.dart'
    as _irw5ufyh;
import 'package:openbudget_server/src/generated/institutions/institution.dart'
    as _izagyfe8;
import 'package:openbudget_server/src/generated/ledger/journal.dart'
    as _ixvlhhyv;
import 'package:openbudget_server/src/generated/ledger/journal_line.dart'
    as _icjh3b69;
import 'package:openbudget_server/src/generated/ledger/journal_line_input.dart'
    as _in0sxdux;
import 'package:openbudget_server/src/generated/ledger/ledger_account.dart'
    as _iab1c098;
import 'package:openbudget_server/src/generated/ledger/ledger_period_lock.dart'
    as _i1ns2ewu;
import 'package:openbudget_server/src/generated/ledger/trial_balance_view.dart'
    as _iywmy3kt;
import 'package:openbudget_server/src/generated/payees/payee.dart' as _i2xhh3nq;
import 'package:openbudget_server/src/generated/plaid/plaid_connection.dart'
    as _iyqk0wcc;
import 'package:openbudget_server/src/generated/recurring_transactions/recurring_transaction.dart'
    as _i6lbncsb;
import 'package:openbudget_server/src/generated/reports/net_worth_granularity.dart'
    as _iwv93n42;
import 'package:openbudget_server/src/generated/reports/net_worth_history_view.dart'
    as _igxf0nr4;
import 'package:openbudget_server/src/generated/reports/net_worth_view.dart'
    as _idgd1o7p;
import 'package:openbudget_server/src/generated/reports/report_grouping.dart'
    as _i3o6dj87;
import 'package:openbudget_server/src/generated/reports/spending_row.dart'
    as _ijvd4zl8;
import 'package:openbudget_server/src/generated/settings/user_settings.dart'
    as _ijkobaqo;
import 'package:openbudget_server/src/generated/tax/tax_category_view.dart'
    as _i687t6y5;
import 'package:openbudget_server/src/generated/tax/tax_profile.dart'
    as _iqcxgux6;
import 'package:openbudget_server/src/generated/tax/tax_report_view.dart'
    as _ik01tkfb;
import 'package:openbudget_server/src/generated/tax/tax_summary_view.dart'
    as _i8zfm0mo;
import 'package:openbudget_server/src/generated/transaction_rules/transaction_rule.dart'
    as _i4wqhpw2;
import 'package:openbudget_server/src/generated/transactions/import_result.dart'
    as _iymxcqas;
import 'package:openbudget_server/src/generated/transactions/import_row.dart'
    as _iyod81ld;
import 'package:openbudget_server/src/generated/transactions/reconcile_result.dart'
    as _i7ymtsah;
import 'package:openbudget_server/src/generated/transactions/transaction_flag.dart'
    as _iilgv4bx;
import 'package:openbudget_server/src/generated/transactions/transaction_input.dart'
    as _i87mxfy4;
import 'package:openbudget_server/src/generated/transactions/transaction_page.dart'
    as _i2x9c1z2;
import 'package:openbudget_server/src/generated/transactions/transaction_query.dart'
    as _iun6b2tc;
import 'package:openbudget_server/src/generated/transactions/transaction_status.dart'
    as _i54b59qp;
import 'package:openbudget_server/src/generated/transactions/transaction_view.dart'
    as _iw07wj0h;
import 'package:openbudget_server/src/generated/transactions/transfer_input.dart'
    as _i7e3qnpf;
import 'package:openbudget_server/src/generated/wallets/wallet.dart'
    as _igcr1vxe;
import 'package:openbudget_server/src/generated/wallets/wallet_holding.dart'
    as _icu5m6lt;
import 'package:openbudget_server/src/generated/wallets/wallet_sync_result.dart'
    as _izzuzifg;
import 'package:openbudget_server/src/generated/wallets/wallet_tax_year_summary.dart'
    as _ilgsya0a;
import 'package:openbudget_server/src/generated/wallets/wallet_transaction.dart'
    as _imzwq91q;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_test/serverpod_test.dart' as _ist;
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/generated/endpoints.dart';
export 'package:serverpod_test/serverpod_test_public_exports.dart';

/// Creates a new test group that takes a callback that can be used to write tests.
/// The callback has two parameters: `sessionBuilder` and `endpoints`.
/// `sessionBuilder` is used to build a `Session` object that represents the server state during an endpoint call and is used to set up scenarios.
/// `endpoints` contains all your Serverpod endpoints and lets you call them:
/// ```dart
/// withServerpod('Given Example endpoint', (sessionBuilder, endpoints) {
///   test('when calling `hello` then should return greeting', () async {
///     final greeting = await endpoints.example.hello(sessionBuilder, 'Michael');
///     expect(greeting, 'Hello Michael');
///   });
/// });
/// ```
///
/// **Configuration options**
///
/// [applyMigrations] Whether pending migrations should be applied when starting Serverpod. Defaults to `true`
///
/// [enableSessionLogging] Whether session logging should be enabled. Defaults to `false`
///
/// [ephemeralDatabase] Whether this group gets its own empty database, created when the group starts and dropped when it finishes. Defaults to `true`.
/// Set this to `false` to use the database configured for [runMode], including a previously seeded database. [configOverride] can still replace that database. The configured database is not created or dropped, so groups that share it cannot run in parallel. [rollbackDatabase] still controls whether writes inside the group are rolled back.
///
/// [rollbackDatabase] Options for when to rollback the database during the test lifecycle.
/// By default `withServerpod` does all database operations inside a transaction that is rolled back after each `test` case.
/// Just like the following enum describes, the behavior of the automatic rollbacks can be configured:
/// ```dart
/// /// Options for when to rollback the database during the test lifecycle.
/// enum RollbackDatabase {
///   /// After each test. This is the default.
///   afterEach,
///
///   /// After all tests.
///   afterAll,
///
///   /// Disable rolling back the database.
///   disabled,
/// }
/// ```
///
/// [runMode] The run mode that Serverpod should be running in. Defaults to `test`.
///
/// [serverpodLoggingMode] The logging mode used when creating Serverpod. Defaults to `ServerpodLoggingMode.normal`
///
/// [serverpodStartTimeout] The timeout to use when starting Serverpod, which connects to the database among other things. Defaults to `Duration(seconds: 120)`.
///
/// [testServerOutputMode] Options for controlling test server output during test execution. Defaults to `TestServerOutputMode.normal`.
/// ```dart
/// /// Options for controlling test server output during test execution.
/// enum TestServerOutputMode {
///   /// Default mode - only stderr is printed (stdout suppressed).
///   /// This hides normal startup/shutdown logs while preserving error messages.
///   normal,
///
///   /// All logging - both stdout and stderr are printed.
///   /// Useful for debugging when you need to see all server output.
///   verbose,
///
///   /// No logging - both stdout and stderr are suppressed.
///   /// Completely silent mode, useful when you don't want any server output.
///   silent,
/// }
/// ```
///
/// [configOverride] A function to override the server configuration. This function is called with
/// the default server configuration after it is loaded from the config/ directory
/// and before it is used to start the server. Use this to override particular
/// settings in the server configuration.
///
/// [databaseInterceptor] Optional interceptor that replaces the default database for each session.
/// See [Serverpod.databaseInterceptor] for more information.
///
/// [testGroupTagsOverride] By default Serverpod test tools tags the `withServerpod` test group with `"integration"`.
/// This is to provide a simple way to only run unit or integration tests.
/// This property allows this tag to be overridden to something else. Defaults to `['integration']`.
///
/// [experimentalFeatures] Optionally specify experimental features. See [Serverpod] for more information.
///
/// [serverDirectory] The server package directory `config/<runMode>.yaml`, `config/passwords.yaml`,
/// and `migrations/<module>/...` are resolved against. Defaults to
/// [Directory.current] at the time the test boots. Pass this when the test
/// isolate's cwd is not the server package root (e.g. running tests from a
/// workspace parent directory) so config and migrations are still loaded
/// from the right place.
@_ist.isTestGroup
void withServerpod(
  String testGroupName,
  _ist.TestClosure<TestEndpoints> testClosure, {
  bool? applyMigrations,
  _is.ServerpodConfig Function(_is.ServerpodConfig)? configOverride,
  _is.DatabaseInterceptor? databaseInterceptor,
  bool? enableSessionLogging,
  bool? ephemeralDatabase,
  _is.ExperimentalFeatures? experimentalFeatures,
  _ist.RollbackDatabase? rollbackDatabase,
  String? runMode,
  _is.RuntimeParametersListBuilder? runtimeParametersBuilder,
  _idi.Directory? serverDirectory,
  _is.ServerpodLoggingMode? serverpodLoggingMode,
  Duration? serverpodStartTimeout,
  List<String>? testGroupTagsOverride,
  _ist.TestServerOutputMode? testServerOutputMode,
}) {
  _ist.buildWithServerpod<_InternalTestEndpoints>(
    testGroupName,
    _ist.TestServerpod(
      testEndpoints: _InternalTestEndpoints(),
      endpoints: Endpoints(),
      serializationManager: Protocol(),
      runMode: runMode,
      applyMigrations: applyMigrations,
      ephemeralDatabase: ephemeralDatabase,
      isDatabaseEnabled: true,
      serverpodLoggingMode: serverpodLoggingMode,
      testServerOutputMode: testServerOutputMode,
      serverDirectory: serverDirectory,
      experimentalFeatures: experimentalFeatures,
      configOverride: configOverride,
      runtimeParametersBuilder: runtimeParametersBuilder,
      databaseInterceptor: databaseInterceptor,
    ),
    maybeRollbackDatabase: rollbackDatabase,
    maybeEnableSessionLogging: enableSessionLogging,
    maybeTestGroupTagsOverride: testGroupTagsOverride,
    maybeServerpodStartTimeout: serverpodStartTimeout,
    maybeTestServerOutputMode: testServerOutputMode,
  )(testClosure);
}

class TestEndpoints {
  late final futureCalls = _FutureCalls();

  late final _AccountEndpoint account;

  late final _AgentEndpoint agent;

  late final _AgentTokenEndpoint agentToken;

  late final _AppleIdpEndpoint appleIdp;

  late final _EmailIdpEndpoint emailIdp;

  late final _GoogleIdpEndpoint googleIdp;

  late final _JwtRefreshEndpoint jwtRefresh;

  late final _BillingEndpoint billing;

  late final _BudgetEndpoint budget;

  late final _CategoryEndpoint category;

  late final _EntityEndpoint entity;

  late final _EntityStreamEndpoint entityStream;

  late final _EnvelopeGoalEndpoint envelopeGoal;

  late final _EnvelopeEndpoint envelope;

  late final _FxRateEndpoint fxRate;

  late final _InstitutionEndpoint institution;

  late final _LedgerEndpoint ledger;

  late final _PayeeEndpoint payee;

  late final _PlaidEndpoint plaid;

  late final _RecurringTransactionEndpoint recurringTransaction;

  late final _ReportEndpoint report;

  late final _SettingsEndpoint settings;

  late final _TaxEndpoint tax;

  late final _TransactionRuleEndpoint transactionRule;

  late final _TransactionEndpoint transaction;

  late final _WalletEndpoint wallet;
}

class _InternalTestEndpoints extends TestEndpoints
    implements _ist.InternalTestEndpoints {
  @override
  void initialize(
    _is.SerializationManager serializationManager,
    _is.EndpointDispatch endpoints,
  ) {
    account = _AccountEndpoint(
      endpoints,
      serializationManager,
    );
    agent = _AgentEndpoint(
      endpoints,
      serializationManager,
    );
    agentToken = _AgentTokenEndpoint(
      endpoints,
      serializationManager,
    );
    appleIdp = _AppleIdpEndpoint(
      endpoints,
      serializationManager,
    );
    emailIdp = _EmailIdpEndpoint(
      endpoints,
      serializationManager,
    );
    googleIdp = _GoogleIdpEndpoint(
      endpoints,
      serializationManager,
    );
    jwtRefresh = _JwtRefreshEndpoint(
      endpoints,
      serializationManager,
    );
    billing = _BillingEndpoint(
      endpoints,
      serializationManager,
    );
    budget = _BudgetEndpoint(
      endpoints,
      serializationManager,
    );
    category = _CategoryEndpoint(
      endpoints,
      serializationManager,
    );
    entity = _EntityEndpoint(
      endpoints,
      serializationManager,
    );
    entityStream = _EntityStreamEndpoint(
      endpoints,
      serializationManager,
    );
    envelopeGoal = _EnvelopeGoalEndpoint(
      endpoints,
      serializationManager,
    );
    envelope = _EnvelopeEndpoint(
      endpoints,
      serializationManager,
    );
    fxRate = _FxRateEndpoint(
      endpoints,
      serializationManager,
    );
    institution = _InstitutionEndpoint(
      endpoints,
      serializationManager,
    );
    ledger = _LedgerEndpoint(
      endpoints,
      serializationManager,
    );
    payee = _PayeeEndpoint(
      endpoints,
      serializationManager,
    );
    plaid = _PlaidEndpoint(
      endpoints,
      serializationManager,
    );
    recurringTransaction = _RecurringTransactionEndpoint(
      endpoints,
      serializationManager,
    );
    report = _ReportEndpoint(
      endpoints,
      serializationManager,
    );
    settings = _SettingsEndpoint(
      endpoints,
      serializationManager,
    );
    tax = _TaxEndpoint(
      endpoints,
      serializationManager,
    );
    transactionRule = _TransactionRuleEndpoint(
      endpoints,
      serializationManager,
    );
    transaction = _TransactionEndpoint(
      endpoints,
      serializationManager,
    );
    wallet = _WalletEndpoint(
      endpoints,
      serializationManager,
    );
  }
}

class _FutureCalls {
  late final balanceVerify = _BalanceVerifyFutureCall();

  late final solanaBillingCollector = _SolanaBillingCollectorFutureCall();

  late final fxBackfill = _FxBackfillFutureCall();

  late final fxRefresh = _FxRefreshFutureCall();

  late final recurringPost = _RecurringPostFutureCall();
}

class _AccountEndpoint {
  _AccountEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_i3fh9aci.Account> create(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    String name,
    _ifz8weqz.AccountKind kind,
    String currencyCode, {
    _ifz8weqz.AccountBalanceSource? balanceSource,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
    _is.UuidValue? institutionId,
    String? note,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'create',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'name': name,
            'kind': kind,
            'currencyCode': currencyCode,
            'balanceSource': balanceSource,
            'onBudget': onBudget,
            'openingBalanceMinor': openingBalanceMinor,
            'openingDate': openingDate,
            'institutionId': institutionId,
            'note': note,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i3fh9aci.Account>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i3fh9aci.Account>> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_i3fh9aci.Account>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i3fh9aci.Account>> listAll(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'listAll',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'listAll',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_i3fh9aci.Account>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i3fh9aci.Account> get(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'get',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'get',
          parameters: _ist.testObjectToJson({'accountId': accountId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i3fh9aci.Account>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i3fh9aci.Account> update(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId, {
    String? name,
    _ifz8weqz.AccountKind? kind,
    bool? onBudget,
    _is.UuidValue? institutionId,
    bool? clearInstitution,
    String? note,
    int? sortOrder,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'update',
          parameters: _ist.testObjectToJson({
            'accountId': accountId,
            'name': name,
            'kind': kind,
            'onBudget': onBudget,
            'institutionId': institutionId,
            'clearInstitution': clearInstitution,
            'note': note,
            'sortOrder': sortOrder,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i3fh9aci.Account>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i3fh9aci.Account>> reorder(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    List<_is.UuidValue> accountIds,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'reorder',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'reorder',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'accountIds': accountIds,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_i3fh9aci.Account>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i3fh9aci.Account> close(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'close',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'close',
          parameters: _ist.testObjectToJson({'accountId': accountId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i3fh9aci.Account>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i3fh9aci.Account> reopen(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'reopen',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'reopen',
          parameters: _ist.testObjectToJson({'accountId': accountId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i3fh9aci.Account>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({'accountId': accountId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_icm7c3fq.AccountBalancesView> getBalances(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'getBalances',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'getBalances',
          parameters: _ist.testObjectToJson({'accountId': accountId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_icm7c3fq.AccountBalancesView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_itqzh2rv.AccountValuation>> listValuations(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'listValuations',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'listValuations',
          parameters: _ist.testObjectToJson({'accountId': accountId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_itqzh2rv.AccountValuation>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_itqzh2rv.AccountValuation> setValuation(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
    DateTime valuationDate,
    int valueMinor, {
    String? note,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'setValuation',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'setValuation',
          parameters: _ist.testObjectToJson({
            'accountId': accountId,
            'valuationDate': valuationDate,
            'valueMinor': valueMinor,
            'note': note,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_itqzh2rv.AccountValuation>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> deleteValuation(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue valuationId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'deleteValuation',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'deleteValuation',
          parameters: _ist.testObjectToJson({'valuationId': valuationId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _AgentEndpoint {
  _AgentEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Stream<_ig0iahoe.AgentEvent> chat(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    _is.UuidValue? conversationId,
    String message,
  ) {
    var _localTestStreamManager =
        _ist.TestStreamManager<_ig0iahoe.AgentEvent>();
    _ist.callStreamFunctionAndHandleExceptions(
      () async {
        var _localUniqueSession =
            (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
              endpoint: 'agent',
              method: 'chat',
            );
        var _localCallContext = await _endpointDispatch
            .getMethodStreamCallContext(
              createSessionCallback: (_) => _localUniqueSession,
              endpointPath: 'agent',
              methodName: 'chat',
              arguments: {
                'entityId': entityId,
                'conversationId': conversationId,
                'message': message,
              },
              requestedInputStreams: [],
              serializationManager: _serializationManager,
            );
        await _localTestStreamManager.callStreamMethod(
          _localCallContext,
          _localUniqueSession,
          {},
        );
      },
      _localTestStreamManager.outputStreamController,
    );
    return _localTestStreamManager.outputStreamController.stream;
  }

  _ida.Future<List<_ihq3j0fx.AgentConversation>> listConversations(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'listConversations',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'listConversations',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_ihq3j0fx.AgentConversation>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_ixbh63dx.AgentMessage>> getMessages(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue conversationId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'getMessages',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'getMessages',
          parameters: _ist.testObjectToJson({'conversationId': conversationId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_ixbh63dx.AgentMessage>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> deleteConversation(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue conversationId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'deleteConversation',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'deleteConversation',
          parameters: _ist.testObjectToJson({'conversationId': conversationId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwi553xc.AgentUsageView> getUsage(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'getUsage',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'getUsage',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iwi553xc.AgentUsageView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ixg2m9if.AgentProviderSettingsView> saveProviderSettings(
    _ist.TestSessionBuilder sessionBuilder,
    String baseUrl,
    String model,
    String apiKey,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'saveProviderSettings',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'saveProviderSettings',
          parameters: _ist.testObjectToJson({
            'baseUrl': baseUrl,
            'model': model,
            'apiKey': apiKey,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ixg2m9if.AgentProviderSettingsView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ixg2m9if.AgentProviderSettingsView?> getProviderSettings(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'getProviderSettings',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'getProviderSettings',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ixg2m9if.AgentProviderSettingsView?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> clearProviderSettings(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'clearProviderSettings',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'clearProviderSettings',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iqa5uoc4.AgentProposal>> listProposals(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId, {
    required bool pendingOnly,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'listProposals',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'listProposals',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'pendingOnly': pendingOnly,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iqa5uoc4.AgentProposal>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iqa5uoc4.AgentProposal> applyProposal(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue proposalId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'applyProposal',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'applyProposal',
          parameters: _ist.testObjectToJson({'proposalId': proposalId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iqa5uoc4.AgentProposal>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iqa5uoc4.AgentProposal> dismissProposal(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue proposalId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agent',
            method: 'dismissProposal',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agent',
          methodName: 'dismissProposal',
          parameters: _ist.testObjectToJson({'proposalId': proposalId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iqa5uoc4.AgentProposal>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _AgentTokenEndpoint {
  _AgentTokenEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_ir54shi0.AgentAccessTokenCreated> createAccessToken(
    _ist.TestSessionBuilder sessionBuilder,
    String name,
    bool canPropose,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agentToken',
            method: 'createAccessToken',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agentToken',
          methodName: 'createAccessToken',
          parameters: _ist.testObjectToJson({
            'name': name,
            'canPropose': canPropose,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ir54shi0.AgentAccessTokenCreated>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i8fy0qox.AgentAccessTokenView>> listAccessTokens(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agentToken',
            method: 'listAccessTokens',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agentToken',
          methodName: 'listAccessTokens',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_i8fy0qox.AgentAccessTokenView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i8fy0qox.AgentAccessTokenView> revokeAccessToken(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue id,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'agentToken',
            method: 'revokeAccessToken',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'agentToken',
          methodName: 'revokeAccessToken',
          parameters: _ist.testObjectToJson({'id': id}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i8fy0qox.AgentAccessTokenView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _AppleIdpEndpoint {
  _AppleIdpEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iacs.AuthSuccess> login(
    _ist.TestSessionBuilder sessionBuilder, {
    required String identityToken,
    required String authorizationCode,
    required bool isNativeApplePlatformSignIn,
    String? firstName,
    String? lastName,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'appleIdp',
            method: 'login',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'appleIdp',
          methodName: 'login',
          parameters: _ist.testObjectToJson({
            'identityToken': identityToken,
            'authorizationCode': authorizationCode,
            'isNativeApplePlatformSignIn': isNativeApplePlatformSignIn,
            'firstName': firstName,
            'lastName': lastName,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iacs.AuthSuccess>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<bool> hasAccount(_ist.TestSessionBuilder sessionBuilder) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'appleIdp',
            method: 'hasAccount',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'appleIdp',
          methodName: 'hasAccount',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _EmailIdpEndpoint {
  _EmailIdpEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iacs.AuthSuccess> login(
    _ist.TestSessionBuilder sessionBuilder, {
    required String email,
    required String password,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'login',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'login',
          parameters: _ist.testObjectToJson({
            'email': email,
            'password': password,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iacs.AuthSuccess>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_is.UuidValue> startRegistration(
    _ist.TestSessionBuilder sessionBuilder, {
    required String email,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'startRegistration',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'startRegistration',
          parameters: _ist.testObjectToJson({'email': email}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_is.UuidValue>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> verifyRegistrationCode(
    _ist.TestSessionBuilder sessionBuilder, {
    required _is.UuidValue accountRequestId,
    required String verificationCode,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'verifyRegistrationCode',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'verifyRegistrationCode',
          parameters: _ist.testObjectToJson({
            'accountRequestId': accountRequestId,
            'verificationCode': verificationCode,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iacs.AuthSuccess> finishRegistration(
    _ist.TestSessionBuilder sessionBuilder, {
    required String registrationToken,
    required String password,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'finishRegistration',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'finishRegistration',
          parameters: _ist.testObjectToJson({
            'registrationToken': registrationToken,
            'password': password,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iacs.AuthSuccess>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_is.UuidValue> startPasswordReset(
    _ist.TestSessionBuilder sessionBuilder, {
    required String email,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'startPasswordReset',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'startPasswordReset',
          parameters: _ist.testObjectToJson({'email': email}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_is.UuidValue>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> verifyPasswordResetCode(
    _ist.TestSessionBuilder sessionBuilder, {
    required _is.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'verifyPasswordResetCode',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'verifyPasswordResetCode',
          parameters: _ist.testObjectToJson({
            'passwordResetRequestId': passwordResetRequestId,
            'verificationCode': verificationCode,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> finishPasswordReset(
    _ist.TestSessionBuilder sessionBuilder, {
    required String finishPasswordResetToken,
    required String newPassword,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'finishPasswordReset',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'finishPasswordReset',
          parameters: _ist.testObjectToJson({
            'finishPasswordResetToken': finishPasswordResetToken,
            'newPassword': newPassword,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<bool> hasAccount(_ist.TestSessionBuilder sessionBuilder) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'emailIdp',
            method: 'hasAccount',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'emailIdp',
          methodName: 'hasAccount',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _GoogleIdpEndpoint {
  _GoogleIdpEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iacs.AuthSuccess> login(
    _ist.TestSessionBuilder sessionBuilder, {
    required String idToken,
    required String? accessToken,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'googleIdp',
            method: 'login',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'googleIdp',
          methodName: 'login',
          parameters: _ist.testObjectToJson({
            'idToken': idToken,
            'accessToken': accessToken,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iacs.AuthSuccess>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iacs.AuthSuccess> loginWithCode(
    _ist.TestSessionBuilder sessionBuilder, {
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'googleIdp',
            method: 'loginWithCode',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'googleIdp',
          methodName: 'loginWithCode',
          parameters: _ist.testObjectToJson({
            'code': code,
            'codeVerifier': codeVerifier,
            'redirectUri': redirectUri,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iacs.AuthSuccess>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<bool> hasAccount(_ist.TestSessionBuilder sessionBuilder) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'googleIdp',
            method: 'hasAccount',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'googleIdp',
          methodName: 'hasAccount',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _JwtRefreshEndpoint {
  _JwtRefreshEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iacs.AuthSuccess> refreshAccessToken(
    _ist.TestSessionBuilder sessionBuilder, {
    String? refreshToken,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'jwtRefresh',
            method: 'refreshAccessToken',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'jwtRefresh',
          methodName: 'refreshAccessToken',
          parameters: _ist.testObjectToJson({'refreshToken': refreshToken}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iacs.AuthSuccess>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _BillingEndpoint {
  _BillingEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iiht0r85.Entitlement?> getEntitlement(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'billing',
            method: 'getEntitlement',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'billing',
          methodName: 'getEntitlement',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iiht0r85.Entitlement?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> createStripeCheckout(
    _ist.TestSessionBuilder sessionBuilder,
    String successUrl,
    String cancelUrl,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'billing',
            method: 'createStripeCheckout',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'billing',
          methodName: 'createStripeCheckout',
          parameters: _ist.testObjectToJson({
            'successUrl': successUrl,
            'cancelUrl': cancelUrl,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> createStripePortal(
    _ist.TestSessionBuilder sessionBuilder,
    String returnUrl,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'billing',
            method: 'createStripePortal',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'billing',
          methodName: 'createStripePortal',
          parameters: _ist.testObjectToJson({'returnUrl': returnUrl}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i7ligxlm.SolanaPlanView> getSolanaPlan(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'billing',
            method: 'getSolanaPlan',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'billing',
          methodName: 'getSolanaPlan',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i7ligxlm.SolanaPlanView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> solanaSubscriptionChallenge(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'billing',
            method: 'solanaSubscriptionChallenge',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'billing',
          methodName: 'solanaSubscriptionChallenge',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iiht0r85.Entitlement> confirmSolanaSubscription(
    _ist.TestSessionBuilder sessionBuilder,
    String subscriberAddress,
    String message,
    String signatureBase58,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'billing',
            method: 'confirmSolanaSubscription',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'billing',
          methodName: 'confirmSolanaSubscription',
          parameters: _ist.testObjectToJson({
            'subscriberAddress': subscriberAddress,
            'message': message,
            'signatureBase58': signatureBase58,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iiht0r85.Entitlement>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _BudgetEndpoint {
  _BudgetEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iumjg9vv.BudgetMonthView> getMonth(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    int month,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'budget',
            method: 'getMonth',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'budget',
          methodName: 'getMonth',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'month': month,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iumjg9vv.BudgetMonthView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iumjg9vv.BudgetMonthView> setAllocations(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    int month,
    List<_inwbkajl.AllocationInput> allocations,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'budget',
            method: 'setAllocations',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'budget',
          methodName: 'setAllocations',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'month': month,
            'allocations': allocations,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iumjg9vv.BudgetMonthView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iumjg9vv.BudgetMonthView> moveMoney(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    int month,
    _is.UuidValue? fromEnvelopeId,
    _is.UuidValue? toEnvelopeId,
    int amountMinor,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'budget',
            method: 'moveMoney',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'budget',
          methodName: 'moveMoney',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'month': month,
            'fromEnvelopeId': fromEnvelopeId,
            'toEnvelopeId': toEnvelopeId,
            'amountMinor': amountMinor,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iumjg9vv.BudgetMonthView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iumjg9vv.BudgetMonthView> copyMonth(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    int fromMonth,
    int toMonth,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'budget',
            method: 'copyMonth',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'budget',
          methodName: 'copyMonth',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'fromMonth': fromMonth,
            'toMonth': toMonth,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iumjg9vv.BudgetMonthView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ihbdj8p6.BudgetTemplate> saveTemplate(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    int month,
    String name,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'budget',
            method: 'saveTemplate',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'budget',
          methodName: 'saveTemplate',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'month': month,
            'name': name,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ihbdj8p6.BudgetTemplate>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_ihbdj8p6.BudgetTemplate>> listTemplates(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'budget',
            method: 'listTemplates',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'budget',
          methodName: 'listTemplates',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_ihbdj8p6.BudgetTemplate>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iz4ekkcc.BudgetTemplateLine>> getTemplateLines(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue templateId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'budget',
            method: 'getTemplateLines',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'budget',
          methodName: 'getTemplateLines',
          parameters: _ist.testObjectToJson({'templateId': templateId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iz4ekkcc.BudgetTemplateLine>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iumjg9vv.BudgetMonthView> applyTemplate(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue templateId,
    int month,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'budget',
            method: 'applyTemplate',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'budget',
          methodName: 'applyTemplate',
          parameters: _ist.testObjectToJson({
            'templateId': templateId,
            'month': month,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iumjg9vv.BudgetMonthView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> deleteTemplate(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue templateId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'budget',
            method: 'deleteTemplate',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'budget',
          methodName: 'deleteTemplate',
          parameters: _ist.testObjectToJson({'templateId': templateId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _CategoryEndpoint {
  _CategoryEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iwlneq7u.Category> create(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    String name,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'category',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'category',
          methodName: 'create',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'name': name,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iwlneq7u.Category>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iwlneq7u.Category>> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'category',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'category',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iwlneq7u.Category>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwlneq7u.Category> get(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue categoryId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'category',
            method: 'get',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'category',
          methodName: 'get',
          parameters: _ist.testObjectToJson({'categoryId': categoryId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iwlneq7u.Category>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwlneq7u.Category> update(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue categoryId, {
    String? name,
    bool? isHidden,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'category',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'category',
          methodName: 'update',
          parameters: _ist.testObjectToJson({
            'categoryId': categoryId,
            'name': name,
            'isHidden': isHidden,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iwlneq7u.Category>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iwlneq7u.Category>> reorder(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    List<_is.UuidValue> categoryIds,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'category',
            method: 'reorder',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'category',
          methodName: 'reorder',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'categoryIds': categoryIds,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iwlneq7u.Category>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue categoryId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'category',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'category',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({'categoryId': categoryId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _EntityEndpoint {
  _EntityEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_if2ry2np.Entity> create(
    _ist.TestSessionBuilder sessionBuilder,
    String name,
    _ifz8weqz.EntityKind kind,
    String countryCode,
    String baseCurrencyCode,
    String timeZone, {
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    _is.UuidValue? linkedPersonalEntityId,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entity',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entity',
          methodName: 'create',
          parameters: _ist.testObjectToJson({
            'name': name,
            'kind': kind,
            'countryCode': countryCode,
            'baseCurrencyCode': baseCurrencyCode,
            'timeZone': timeZone,
            'fiscalYearEndMonth': fiscalYearEndMonth,
            'fiscalYearEndDay': fiscalYearEndDay,
            'linkedPersonalEntityId': linkedPersonalEntityId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_if2ry2np.Entity>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_if2ry2np.Entity>> list(
    _ist.TestSessionBuilder sessionBuilder, {
    bool? includeArchived,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entity',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entity',
          methodName: 'list',
          parameters: _ist.testObjectToJson({
            'includeArchived': includeArchived,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_if2ry2np.Entity>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_im3neacv.EntitySummaryView>> listSummaries(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entity',
            method: 'listSummaries',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entity',
          methodName: 'listSummaries',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_im3neacv.EntitySummaryView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_if2ry2np.Entity> get(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entity',
            method: 'get',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entity',
          methodName: 'get',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_if2ry2np.Entity>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_if2ry2np.Entity> update(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId, {
    String? name,
    String? baseCurrencyCode,
    String? timeZone,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    bool? includeInNetWorth,
    _is.UuidValue? linkedPersonalEntityId,
    bool? clearLinkedPersonalEntity,
    int? sortOrder,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entity',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entity',
          methodName: 'update',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'name': name,
            'baseCurrencyCode': baseCurrencyCode,
            'timeZone': timeZone,
            'fiscalYearEndMonth': fiscalYearEndMonth,
            'fiscalYearEndDay': fiscalYearEndDay,
            'includeInNetWorth': includeInNetWorth,
            'linkedPersonalEntityId': linkedPersonalEntityId,
            'clearLinkedPersonalEntity': clearLinkedPersonalEntity,
            'sortOrder': sortOrder,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_if2ry2np.Entity>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_if2ry2np.Entity> archive(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entity',
            method: 'archive',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entity',
          methodName: 'archive',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_if2ry2np.Entity>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_if2ry2np.Entity> unarchive(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entity',
            method: 'unarchive',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entity',
          methodName: 'unarchive',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_if2ry2np.Entity>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    String confirmName,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entity',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entity',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'confirmName': confirmName,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<String> exportData(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entity',
            method: 'exportData',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entity',
          methodName: 'exportData',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _EntityStreamEndpoint {
  _EntityStreamEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Stream<_i6lrvoev.EntityChangedEvent> watch(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) {
    var _localTestStreamManager =
        _ist.TestStreamManager<_i6lrvoev.EntityChangedEvent>();
    _ist.callStreamFunctionAndHandleExceptions(
      () async {
        var _localUniqueSession =
            (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
              endpoint: 'entityStream',
              method: 'watch',
            );
        var _localCallContext = await _endpointDispatch
            .getMethodStreamCallContext(
              createSessionCallback: (_) => _localUniqueSession,
              endpointPath: 'entityStream',
              methodName: 'watch',
              arguments: {'entityId': entityId},
              requestedInputStreams: [],
              serializationManager: _serializationManager,
            );
        await _localTestStreamManager.callStreamMethod(
          _localCallContext,
          _localUniqueSession,
          {},
        );
      },
      _localTestStreamManager.outputStreamController,
    );
    return _localTestStreamManager.outputStreamController.stream;
  }
}

class _EnvelopeGoalEndpoint {
  _EnvelopeGoalEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iuyjld9f.EnvelopeGoal> upsert(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue envelopeId,
    _i16hg0wx.EnvelopeGoalKind kind,
    int amountMinor, {
    DateTime? targetDate,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'envelopeGoal',
            method: 'upsert',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'envelopeGoal',
          methodName: 'upsert',
          parameters: _ist.testObjectToJson({
            'envelopeId': envelopeId,
            'kind': kind,
            'amountMinor': amountMinor,
            'targetDate': targetDate,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iuyjld9f.EnvelopeGoal>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iuyjld9f.EnvelopeGoal>> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'envelopeGoal',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'envelopeGoal',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iuyjld9f.EnvelopeGoal>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue goalId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'envelopeGoal',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'envelopeGoal',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({'goalId': goalId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _EnvelopeEndpoint {
  _EnvelopeEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_igwnqatb.Envelope> create(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue categoryId,
    String name, {
    String? note,
    String? taxCategoryCode,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'envelope',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'envelope',
          methodName: 'create',
          parameters: _ist.testObjectToJson({
            'categoryId': categoryId,
            'name': name,
            'note': note,
            'taxCategoryCode': taxCategoryCode,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_igwnqatb.Envelope>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_igwnqatb.Envelope>> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'envelope',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'envelope',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_igwnqatb.Envelope>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_igwnqatb.Envelope> get(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue envelopeId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'envelope',
            method: 'get',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'envelope',
          methodName: 'get',
          parameters: _ist.testObjectToJson({'envelopeId': envelopeId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_igwnqatb.Envelope>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_igwnqatb.Envelope> update(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue envelopeId, {
    String? name,
    _is.UuidValue? categoryId,
    String? note,
    bool? isHidden,
    String? taxCategoryCode,
    bool? clearTaxCategoryCode,
    _is.UuidValue? defaultLedgerAccountId,
    bool? clearDefaultLedgerAccount,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'envelope',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'envelope',
          methodName: 'update',
          parameters: _ist.testObjectToJson({
            'envelopeId': envelopeId,
            'name': name,
            'categoryId': categoryId,
            'note': note,
            'isHidden': isHidden,
            'taxCategoryCode': taxCategoryCode,
            'clearTaxCategoryCode': clearTaxCategoryCode,
            'defaultLedgerAccountId': defaultLedgerAccountId,
            'clearDefaultLedgerAccount': clearDefaultLedgerAccount,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_igwnqatb.Envelope>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_igwnqatb.Envelope>> reorder(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue categoryId,
    List<_is.UuidValue> envelopeIds,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'envelope',
            method: 'reorder',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'envelope',
          methodName: 'reorder',
          parameters: _ist.testObjectToJson({
            'categoryId': categoryId,
            'envelopeIds': envelopeIds,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_igwnqatb.Envelope>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue envelopeId, {
    _is.UuidValue? reassignToEnvelopeId,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'envelope',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'envelope',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({
            'envelopeId': envelopeId,
            'reassignToEnvelopeId': reassignToEnvelopeId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _FxRateEndpoint {
  _FxRateEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_ictw4lhv.FxLatestSnapshot> latest(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fxRate',
            method: 'latest',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fxRate',
          methodName: 'latest',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ictw4lhv.FxLatestSnapshot>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ictw4lhv.FxLatestSnapshot> refresh(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fxRate',
            method: 'refresh',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fxRate',
          methodName: 'refresh',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ictw4lhv.FxLatestSnapshot>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_irw5ufyh.FxQuoteView> quote(
    _ist.TestSessionBuilder sessionBuilder,
    String fromCurrencyCode,
    String toCurrencyCode,
    DateTime date,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'fxRate',
            method: 'quote',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fxRate',
          methodName: 'quote',
          parameters: _ist.testObjectToJson({
            'fromCurrencyCode': fromCurrencyCode,
            'toCurrencyCode': toCurrencyCode,
            'date': date,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_irw5ufyh.FxQuoteView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _InstitutionEndpoint {
  _InstitutionEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<List<_izagyfe8.Institution>> list(
    _ist.TestSessionBuilder sessionBuilder, {
    String? locationCode,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'institution',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'institution',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'locationCode': locationCode}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_izagyfe8.Institution>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _LedgerEndpoint {
  _LedgerEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_if2ry2np.Entity> enableLedger(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'enableLedger',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'enableLedger',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_if2ry2np.Entity>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iab1c098.LedgerAccount>> listAccounts(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId, {
    required bool includeArchived,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'listAccounts',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'listAccounts',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'includeArchived': includeArchived,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iab1c098.LedgerAccount>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iab1c098.LedgerAccount> createAccount(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    String code,
    String name,
    _ifz8weqz.LedgerAccountType type, {
    _ifz8weqz.LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'createAccount',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'createAccount',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'code': code,
            'name': name,
            'type': type,
            'systemRole': systemRole,
            'currencyCode': currencyCode,
            'taxCategoryCode': taxCategoryCode,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iab1c098.LedgerAccount>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iab1c098.LedgerAccount> archiveAccount(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'archiveAccount',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'archiveAccount',
          parameters: _ist.testObjectToJson({'accountId': accountId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iab1c098.LedgerAccount>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ixvlhhyv.Journal> saveDraftJournal(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    DateTime date,
    List<_in0sxdux.JournalLineInput> lines, {
    _is.UuidValue? journalId,
    required String reference,
    String? narration,
    required _ifz8weqz.JournalSource source,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'saveDraftJournal',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'saveDraftJournal',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'date': date,
            'lines': lines,
            'journalId': journalId,
            'reference': reference,
            'narration': narration,
            'source': source,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ixvlhhyv.Journal>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> deleteDraftJournal(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue journalId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'deleteDraftJournal',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'deleteDraftJournal',
          parameters: _ist.testObjectToJson({'journalId': journalId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ixvlhhyv.Journal> postJournal(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue journalId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'postJournal',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'postJournal',
          parameters: _ist.testObjectToJson({'journalId': journalId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ixvlhhyv.Journal>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ixvlhhyv.Journal> reverseJournal(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue journalId,
    DateTime date,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'reverseJournal',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'reverseJournal',
          parameters: _ist.testObjectToJson({
            'journalId': journalId,
            'date': date,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ixvlhhyv.Journal>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_ixvlhhyv.Journal>> listJournals(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId, {
    DateTime? fromDate,
    DateTime? toDate,
    required int limit,
    String? cursor,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'listJournals',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'listJournals',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'fromDate': fromDate,
            'toDate': toDate,
            'limit': limit,
            'cursor': cursor,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_ixvlhhyv.Journal>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_icjh3b69.JournalLine>> listJournalLines(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue journalId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'listJournalLines',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'listJournalLines',
          parameters: _ist.testObjectToJson({'journalId': journalId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_icjh3b69.JournalLine>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i1ns2ewu.LedgerPeriodLock?> getLockDate(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'getLockDate',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'getLockDate',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i1ns2ewu.LedgerPeriodLock?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i1ns2ewu.LedgerPeriodLock> setLockDate(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    DateTime lockDate,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'setLockDate',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'setLockDate',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'lockDate': lockDate,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i1ns2ewu.LedgerPeriodLock>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iywmy3kt.TrialBalanceView> trialBalance(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    DateTime asOf,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'trialBalance',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'trialBalance',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'asOf': asOf,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iywmy3kt.TrialBalanceView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_ictk02ka.AuditEvent>> listAuditEvents(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId, {
    DateTime? before,
    int? limit,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'ledger',
            method: 'listAuditEvents',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'ledger',
          methodName: 'listAuditEvents',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'before': before,
            'limit': limit,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_ictk02ka.AuditEvent>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _PayeeEndpoint {
  _PayeeEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_i2xhh3nq.Payee> create(
    _ist.TestSessionBuilder sessionBuilder,
    String name,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payee',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payee',
          methodName: 'create',
          parameters: _ist.testObjectToJson({
            'name': name,
            'entityId': entityId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i2xhh3nq.Payee>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i2xhh3nq.Payee>> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payee',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payee',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_i2xhh3nq.Payee>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i2xhh3nq.Payee> get(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue payeeId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payee',
            method: 'get',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payee',
          methodName: 'get',
          parameters: _ist.testObjectToJson({'payeeId': payeeId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i2xhh3nq.Payee>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i2xhh3nq.Payee> update(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue payeeId, {
    String? name,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payee',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payee',
          methodName: 'update',
          parameters: _ist.testObjectToJson({
            'payeeId': payeeId,
            'name': name,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i2xhh3nq.Payee>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_is.UuidValue?> lastUsedEnvelopeId(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue payeeId,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payee',
            method: 'lastUsedEnvelopeId',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payee',
          methodName: 'lastUsedEnvelopeId',
          parameters: _ist.testObjectToJson({
            'payeeId': payeeId,
            'entityId': entityId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_is.UuidValue?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<int> merge(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue sourcePayeeId,
    _is.UuidValue targetPayeeId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payee',
            method: 'merge',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payee',
          methodName: 'merge',
          parameters: _ist.testObjectToJson({
            'sourcePayeeId': sourcePayeeId,
            'targetPayeeId': targetPayeeId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<int>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i2xhh3nq.Payee> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue payeeId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payee',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payee',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({'payeeId': payeeId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i2xhh3nq.Payee>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _PlaidEndpoint {
  _PlaidEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<String> createLinkToken(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'plaid',
            method: 'createLinkToken',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'plaid',
          methodName: 'createLinkToken',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iyqk0wcc.PlaidConnection> exchangePublicToken(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    String publicToken,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'plaid',
            method: 'exchangePublicToken',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'plaid',
          methodName: 'exchangePublicToken',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'publicToken': publicToken,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iyqk0wcc.PlaidConnection>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iyqk0wcc.PlaidConnection> syncConnection(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue connectionId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'plaid',
            method: 'syncConnection',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'plaid',
          methodName: 'syncConnection',
          parameters: _ist.testObjectToJson({'connectionId': connectionId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iyqk0wcc.PlaidConnection>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iyqk0wcc.PlaidConnection>> listConnections(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'plaid',
            method: 'listConnections',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'plaid',
          methodName: 'listConnections',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iyqk0wcc.PlaidConnection>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> removeConnection(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue connectionId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'plaid',
            method: 'removeConnection',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'plaid',
          methodName: 'removeConnection',
          parameters: _ist.testObjectToJson({'connectionId': connectionId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iyqk0wcc.PlaidConnection> importSandboxAccounts(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId, {
    String? plaidInstitutionId,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'plaid',
            method: 'importSandboxAccounts',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'plaid',
          methodName: 'importSandboxAccounts',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'plaidInstitutionId': plaidInstitutionId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iyqk0wcc.PlaidConnection>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _RecurringTransactionEndpoint {
  _RecurringTransactionEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_i6lbncsb.RecurringTransaction> create(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
    String description,
    int amountMinor,
    _ifz8weqz.RecurrenceFrequency frequency,
    DateTime nextDate, {
    _is.UuidValue? payeeId,
    _is.UuidValue? envelopeId,
    String? memo,
    DateTime? endDate,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'recurringTransaction',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'recurringTransaction',
          methodName: 'create',
          parameters: _ist.testObjectToJson({
            'accountId': accountId,
            'description': description,
            'amountMinor': amountMinor,
            'frequency': frequency,
            'nextDate': nextDate,
            'payeeId': payeeId,
            'envelopeId': envelopeId,
            'memo': memo,
            'endDate': endDate,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i6lbncsb.RecurringTransaction>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i6lbncsb.RecurringTransaction>> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'recurringTransaction',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'recurringTransaction',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_i6lbncsb.RecurringTransaction>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6lbncsb.RecurringTransaction> get(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue recurringTransactionId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'recurringTransaction',
            method: 'get',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'recurringTransaction',
          methodName: 'get',
          parameters: _ist.testObjectToJson({
            'recurringTransactionId': recurringTransactionId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i6lbncsb.RecurringTransaction>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6lbncsb.RecurringTransaction> update(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue recurringTransactionId, {
    _is.UuidValue? accountId,
    String? description,
    int? amountMinor,
    _ifz8weqz.RecurrenceFrequency? frequency,
    DateTime? nextDate,
    _is.UuidValue? payeeId,
    bool? clearPayee,
    _is.UuidValue? envelopeId,
    bool? clearEnvelope,
    String? memo,
    DateTime? endDate,
    bool? clearEndDate,
    bool? isActive,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'recurringTransaction',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'recurringTransaction',
          methodName: 'update',
          parameters: _ist.testObjectToJson({
            'recurringTransactionId': recurringTransactionId,
            'accountId': accountId,
            'description': description,
            'amountMinor': amountMinor,
            'frequency': frequency,
            'nextDate': nextDate,
            'payeeId': payeeId,
            'clearPayee': clearPayee,
            'envelopeId': envelopeId,
            'clearEnvelope': clearEnvelope,
            'memo': memo,
            'endDate': endDate,
            'clearEndDate': clearEndDate,
            'isActive': isActive,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i6lbncsb.RecurringTransaction>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6lbncsb.RecurringTransaction> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue recurringTransactionId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'recurringTransaction',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'recurringTransaction',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({
            'recurringTransactionId': recurringTransactionId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i6lbncsb.RecurringTransaction>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6lbncsb.RecurringTransaction> skipOccurrence(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue recurringTransactionId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'recurringTransaction',
            method: 'skipOccurrence',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'recurringTransaction',
          methodName: 'skipOccurrence',
          parameters: _ist.testObjectToJson({
            'recurringTransactionId': recurringTransactionId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i6lbncsb.RecurringTransaction>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<int> postDue(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'recurringTransaction',
            method: 'postDue',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'recurringTransaction',
          methodName: 'postDue',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<int>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<int> countDue(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'recurringTransaction',
            method: 'countDue',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'recurringTransaction',
          methodName: 'countDue',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<int>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _ReportEndpoint {
  _ReportEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_idgd1o7p.NetWorthView> netWorth(
    _ist.TestSessionBuilder sessionBuilder, {
    List<_is.UuidValue>? entityIds,
    String? currencyCode,
    DateTime? asOf,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'report',
            method: 'netWorth',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'report',
          methodName: 'netWorth',
          parameters: _ist.testObjectToJson({
            'entityIds': entityIds,
            'currencyCode': currencyCode,
            'asOf': asOf,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_idgd1o7p.NetWorthView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_igxf0nr4.NetWorthHistoryView> netWorthHistory(
    _ist.TestSessionBuilder sessionBuilder,
    DateTime fromDate,
    DateTime toDate,
    _iwv93n42.NetWorthGranularity granularity, {
    List<_is.UuidValue>? entityIds,
    String? currencyCode,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'report',
            method: 'netWorthHistory',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'report',
          methodName: 'netWorthHistory',
          parameters: _ist.testObjectToJson({
            'fromDate': fromDate,
            'toDate': toDate,
            'granularity': granularity,
            'entityIds': entityIds,
            'currencyCode': currencyCode,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_igxf0nr4.NetWorthHistoryView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_ijvd4zl8.SpendingRow>> spending(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    int fromMonth,
    int toMonth,
    _i3o6dj87.ReportGrouping grouping,
    bool byMonth,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'report',
            method: 'spending',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'report',
          methodName: 'spending',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'fromMonth': fromMonth,
            'toMonth': toMonth,
            'grouping': grouping,
            'byMonth': byMonth,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_ijvd4zl8.SpendingRow>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_ipz3w5am.BudgetMonthSummary>> monthSummaries(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    int fromMonth,
    int toMonth,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'report',
            method: 'monthSummaries',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'report',
          methodName: 'monthSummaries',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'fromMonth': fromMonth,
            'toMonth': toMonth,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_ipz3w5am.BudgetMonthSummary>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<int?> ageOfMoney(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'report',
            method: 'ageOfMoney',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'report',
          methodName: 'ageOfMoney',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<int?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _SettingsEndpoint {
  _SettingsEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_ijkobaqo.UserSettings> get(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'settings',
            method: 'get',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'settings',
          methodName: 'get',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ijkobaqo.UserSettings>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ijkobaqo.UserSettings> setReportingCurrency(
    _ist.TestSessionBuilder sessionBuilder,
    String currencyCode,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'settings',
            method: 'setReportingCurrency',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'settings',
          methodName: 'setReportingCurrency',
          parameters: _ist.testObjectToJson({'currencyCode': currencyCode}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ijkobaqo.UserSettings>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _TaxEndpoint {
  _TaxEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iqcxgux6.TaxProfileRecord?> getProfile(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'tax',
            method: 'getProfile',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'tax',
          methodName: 'getProfile',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iqcxgux6.TaxProfileRecord?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iqcxgux6.TaxProfileRecord> saveProfile(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    String jurisdiction,
    String entityKind,
    String profileJson,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'tax',
            method: 'saveProfile',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'tax',
          methodName: 'saveProfile',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'jurisdiction': jurisdiction,
            'entityKind': entityKind,
            'profileJson': profileJson,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iqcxgux6.TaxProfileRecord>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i687t6y5.TaxCategoryView>> listCategories(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'tax',
            method: 'listCategories',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'tax',
          methodName: 'listCategories',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_i687t6y5.TaxCategoryView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_igwnqatb.Envelope> setEnvelopeTaxCategory(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue envelopeId, {
    String? code,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'tax',
            method: 'setEnvelopeTaxCategory',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'tax',
          methodName: 'setEnvelopeTaxCategory',
          parameters: _ist.testObjectToJson({
            'envelopeId': envelopeId,
            'code': code,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_igwnqatb.Envelope>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iw07wj0h.TransactionView> setLineTax(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue transactionLineId, {
    String? taxCategoryCode,
    bool? clearTaxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'tax',
            method: 'setLineTax',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'tax',
          methodName: 'setLineTax',
          parameters: _ist.testObjectToJson({
            'transactionLineId': transactionLineId,
            'taxCategoryCode': taxCategoryCode,
            'clearTaxCategoryCode': clearTaxCategoryCode,
            'businessUsePercent': businessUsePercent,
            'salesTaxMinor': salesTaxMinor,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iw07wj0h.TransactionView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ik01tkfb.TaxReportView> getReport(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId, {
    int? startYear,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'tax',
            method: 'getReport',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'tax',
          methodName: 'getReport',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'startYear': startYear,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_ik01tkfb.TaxReportView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i8zfm0mo.TaxSummaryView> getSummary(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId, {
    int? startYear,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'tax',
            method: 'getSummary',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'tax',
          methodName: 'getSummary',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'startYear': startYear,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i8zfm0mo.TaxSummaryView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _TransactionRuleEndpoint {
  _TransactionRuleEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_i4wqhpw2.TransactionRule> create(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    _is.UuidValue payeeId,
    _is.UuidValue envelopeId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transactionRule',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transactionRule',
          methodName: 'create',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'payeeId': payeeId,
            'envelopeId': envelopeId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i4wqhpw2.TransactionRule>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i4wqhpw2.TransactionRule>> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transactionRule',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transactionRule',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_i4wqhpw2.TransactionRule>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i4wqhpw2.TransactionRule> get(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue ruleId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transactionRule',
            method: 'get',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transactionRule',
          methodName: 'get',
          parameters: _ist.testObjectToJson({'ruleId': ruleId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i4wqhpw2.TransactionRule>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i4wqhpw2.TransactionRule> update(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue ruleId, {
    _is.UuidValue? envelopeId,
    bool? enabled,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transactionRule',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transactionRule',
          methodName: 'update',
          parameters: _ist.testObjectToJson({
            'ruleId': ruleId,
            'envelopeId': envelopeId,
            'enabled': enabled,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i4wqhpw2.TransactionRule>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_is.UuidValue?> findMatchingEnvelope(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    _is.UuidValue payeeId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transactionRule',
            method: 'findMatchingEnvelope',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transactionRule',
          methodName: 'findMatchingEnvelope',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'payeeId': payeeId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_is.UuidValue?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i4wqhpw2.TransactionRule> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue ruleId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transactionRule',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transactionRule',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({'ruleId': ruleId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i4wqhpw2.TransactionRule>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _TransactionEndpoint {
  _TransactionEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iw07wj0h.TransactionView> create(
    _ist.TestSessionBuilder sessionBuilder,
    _i87mxfy4.TransactionInput input,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'create',
          parameters: _ist.testObjectToJson({'input': input}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iw07wj0h.TransactionView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iw07wj0h.TransactionView> get(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue transactionId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'get',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'get',
          parameters: _ist.testObjectToJson({'transactionId': transactionId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iw07wj0h.TransactionView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i2x9c1z2.TransactionPage> list(
    _ist.TestSessionBuilder sessionBuilder,
    _iun6b2tc.TransactionQuery query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i2x9c1z2.TransactionPage>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iw07wj0h.TransactionView> update(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue transactionId,
    _i87mxfy4.TransactionInput input,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'update',
          parameters: _ist.testObjectToJson({
            'transactionId': transactionId,
            'input': input,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iw07wj0h.TransactionView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue transactionId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({'transactionId': transactionId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<int> setStatus(
    _ist.TestSessionBuilder sessionBuilder,
    List<_is.UuidValue> transactionIds,
    _i54b59qp.TransactionStatus status,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'setStatus',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'setStatus',
          parameters: _ist.testObjectToJson({
            'transactionIds': transactionIds,
            'status': status,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<int>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<int> setFlag(
    _ist.TestSessionBuilder sessionBuilder,
    List<_is.UuidValue> transactionIds,
    _iilgv4bx.TransactionFlag? flag,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'setFlag',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'setFlag',
          parameters: _ist.testObjectToJson({
            'transactionIds': transactionIds,
            'flag': flag,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<int>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iw07wj0h.TransactionView>> createTransfer(
    _ist.TestSessionBuilder sessionBuilder,
    _i7e3qnpf.TransferInput input,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'createTransfer',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'createTransfer',
          parameters: _ist.testObjectToJson({'input': input}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iw07wj0h.TransactionView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iw07wj0h.TransactionView>> updateTransfer(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue transferId,
    _i7e3qnpf.TransferInput input,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'updateTransfer',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'updateTransfer',
          parameters: _ist.testObjectToJson({
            'transferId': transferId,
            'input': input,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iw07wj0h.TransactionView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i7ymtsah.ReconcileResult> reconcile(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
    DateTime statementDate,
    int statementBalanceMinor,
    bool createAdjustment,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'reconcile',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'reconcile',
          parameters: _ist.testObjectToJson({
            'accountId': accountId,
            'statementDate': statementDate,
            'statementBalanceMinor': statementBalanceMinor,
            'createAdjustment': createAdjustment,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_i7ymtsah.ReconcileResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iymxcqas.ImportResult> importRows(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
    List<_iyod81ld.ImportRow> rows,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'importRows',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'importRows',
          parameters: _ist.testObjectToJson({
            'accountId': accountId,
            'rows': rows,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_iymxcqas.ImportResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iw07wj0h.TransactionView>> findDuplicates(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
    DateTime date,
    int amountMinor,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'transaction',
            method: 'findDuplicates',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'transaction',
          methodName: 'findDuplicates',
          parameters: _ist.testObjectToJson({
            'accountId': accountId,
            'date': date,
            'amountMinor': amountMinor,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_iw07wj0h.TransactionView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _WalletEndpoint {
  _WalletEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_igcr1vxe.Wallet> connect(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
    _ifz8weqz.WalletNetwork network,
    String address, {
    String? label,
    String? accountName,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'wallet',
            method: 'connect',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'wallet',
          methodName: 'connect',
          parameters: _ist.testObjectToJson({
            'entityId': entityId,
            'network': network,
            'address': address,
            'label': label,
            'accountName': accountName,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_igcr1vxe.Wallet>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_igcr1vxe.Wallet>> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue entityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'wallet',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'wallet',
          methodName: 'list',
          parameters: _ist.testObjectToJson({'entityId': entityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_igcr1vxe.Wallet>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_igcr1vxe.Wallet?> getForAccount(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue accountId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'wallet',
            method: 'getForAccount',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'wallet',
          methodName: 'getForAccount',
          parameters: _ist.testObjectToJson({'accountId': accountId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_igcr1vxe.Wallet?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_izzuzifg.WalletSyncResult> sync(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue walletId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'wallet',
            method: 'sync',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'wallet',
          methodName: 'sync',
          parameters: _ist.testObjectToJson({'walletId': walletId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_izzuzifg.WalletSyncResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_icu5m6lt.WalletHolding>> listHoldings(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue walletId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'wallet',
            method: 'listHoldings',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'wallet',
          methodName: 'listHoldings',
          parameters: _ist.testObjectToJson({'walletId': walletId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_icu5m6lt.WalletHolding>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_imzwq91q.WalletTransaction>> listTransactions(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue walletId, {
    DateTime? before,
    int? limit,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'wallet',
            method: 'listTransactions',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'wallet',
          methodName: 'listTransactions',
          parameters: _ist.testObjectToJson({
            'walletId': walletId,
            'before': before,
            'limit': limit,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_imzwq91q.WalletTransaction>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_ilgsya0a.WalletTaxYearSummary>> listTaxYearSummaries(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue walletId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'wallet',
            method: 'listTaxYearSummaries',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'wallet',
          methodName: 'listTaxYearSummaries',
          parameters: _ist.testObjectToJson({'walletId': walletId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<List<_ilgsya0a.WalletTaxYearSummary>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_imzwq91q.WalletTransaction> updateTransactionMetadata(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue walletTransactionId, {
    String? category,
    List<String>? tags,
    String? memo,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'wallet',
            method: 'updateTransactionMetadata',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'wallet',
          methodName: 'updateTransactionMetadata',
          parameters: _ist.testObjectToJson({
            'walletTransactionId': walletTransactionId,
            'category': category,
            'tags': tags,
            'memo': memo,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<_imzwq91q.WalletTransaction>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> disconnect(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue walletId, {
    bool? deleteAccount,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'wallet',
            method: 'disconnect',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'wallet',
          methodName: 'disconnect',
          parameters: _ist.testObjectToJson({
            'walletId': walletId,
            'deleteAccount': deleteAccount,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _BalanceVerifyFutureCall {
  Future<void> verify(_ist.TestSessionBuilder sessionBuilder) async {
    var _localUniqueSession =
        (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild();
    try {
      await _iwv90kfd.BalanceVerifyVerifyFutureCall().invoke(
        _localUniqueSession,
        null,
      );
    } finally {
      await _localUniqueSession.close();
    }
  }
}

class _SolanaBillingCollectorFutureCall {
  Future<void> collect(_ist.TestSessionBuilder sessionBuilder) async {
    var _localUniqueSession =
        (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild();
    try {
      await _iwv90kfd.SolanaBillingCollectorCollectFutureCall().invoke(
        _localUniqueSession,
        null,
      );
    } finally {
      await _localUniqueSession.close();
    }
  }
}

class _FxBackfillFutureCall {
  Future<void> fetch(
    _ist.TestSessionBuilder sessionBuilder,
    DateTime date,
  ) async {
    var object = _i0uw56cr.FxBackfillFutureCallFetchModel(date: date);
    var _localUniqueSession =
        (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild();
    try {
      await _iwv90kfd.FxBackfillFetchFutureCall().invoke(
        _localUniqueSession,
        object,
      );
    } finally {
      await _localUniqueSession.close();
    }
  }
}

class _FxRefreshFutureCall {
  Future<void> refresh(_ist.TestSessionBuilder sessionBuilder) async {
    var _localUniqueSession =
        (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild();
    try {
      await _iwv90kfd.FxRefreshRefreshFutureCall().invoke(
        _localUniqueSession,
        null,
      );
    } finally {
      await _localUniqueSession.close();
    }
  }
}

class _RecurringPostFutureCall {
  Future<void> postDue(_ist.TestSessionBuilder sessionBuilder) async {
    var _localUniqueSession =
        (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild();
    try {
      await _iwv90kfd.RecurringPostPostDueFutureCall().invoke(
        _localUniqueSession,
        null,
      );
    } finally {
      await _localUniqueSession.close();
    }
  }
}
