/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;

import 'package:http/http.dart' as _i85jenna;
import 'package:openbudget_client/src/protocol/accounts/account.dart'
    as _iqudaadl;
import 'package:openbudget_client/src/protocol/accounts/account_balances_view.dart'
    as _i83280l7;
import 'package:openbudget_client/src/protocol/accounts/account_valuation.dart'
    as _idms9t2z;
import 'package:openbudget_client/src/protocol/agent/agent_conversation.dart'
    as _in44ixo7;
import 'package:openbudget_client/src/protocol/agent/agent_event.dart'
    as _isrqm714;
import 'package:openbudget_client/src/protocol/agent/agent_message.dart'
    as _i8fbky0c;
import 'package:openbudget_client/src/protocol/agent/agent_proposal.dart'
    as _icv7zzda;
import 'package:openbudget_client/src/protocol/agent/agent_provider_settings_view.dart'
    as _i8qcy504;
import 'package:openbudget_client/src/protocol/agent/agent_usage_view.dart'
    as _igs7yvae;
import 'package:openbudget_client/src/protocol/agent/mcp/agent_access_token_created.dart'
    as _ie7c2xv8;
import 'package:openbudget_client/src/protocol/agent/mcp/agent_access_token_view.dart'
    as _itxn3wek;
import 'package:openbudget_client/src/protocol/audit/audit_event.dart'
    as _ioe147d0;
import 'package:openbudget_client/src/protocol/billing/entitlement.dart'
    as _iyhncv6f;
import 'package:openbudget_client/src/protocol/billing/solana_plan_view.dart'
    as _ij0nbz0v;
import 'package:openbudget_client/src/protocol/budget/allocation_input.dart'
    as _inutgv28;
import 'package:openbudget_client/src/protocol/budget/budget_month_summary.dart'
    as _i52laypj;
import 'package:openbudget_client/src/protocol/budget/budget_month_view.dart'
    as _i6xxh8m1;
import 'package:openbudget_client/src/protocol/budget_templates/budget_template.dart'
    as _itiojbb0;
import 'package:openbudget_client/src/protocol/budget_templates/budget_template_line.dart'
    as _ik2p0evm;
import 'package:openbudget_client/src/protocol/categories/category.dart'
    as _iels1fku;
import 'package:openbudget_client/src/protocol/entities/entity.dart'
    as _i2ulk6h5;
import 'package:openbudget_client/src/protocol/entities/entity_changed_event.dart'
    as _irhjjor1;
import 'package:openbudget_client/src/protocol/entities/entity_summary_view.dart'
    as _ib1vbiwb;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal.dart'
    as _ibdhi9gv;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal_kind.dart'
    as _ilw4dz54;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart'
    as _i29jf3by;
import 'package:openbudget_client/src/protocol/fx_rates/fx_latest_snapshot.dart'
    as _it7vndki;
import 'package:openbudget_client/src/protocol/fx_rates/fx_quote_view.dart'
    as _ij92xk61;
import 'package:openbudget_client/src/protocol/institutions/institution.dart'
    as _i6ysl1a4;
import 'package:openbudget_client/src/protocol/ledger/journal.dart'
    as _izuizaeu;
import 'package:openbudget_client/src/protocol/ledger/journal_line.dart'
    as _iwruw2s3;
import 'package:openbudget_client/src/protocol/ledger/journal_line_input.dart'
    as _i3j8x5or;
import 'package:openbudget_client/src/protocol/ledger/ledger_account.dart'
    as _ixq9t892;
import 'package:openbudget_client/src/protocol/ledger/ledger_period_lock.dart'
    as _i10h3ni6;
import 'package:openbudget_client/src/protocol/ledger/trial_balance_view.dart'
    as _i0gvlz5s;
import 'package:openbudget_client/src/protocol/payees/payee.dart' as _iaf6ifsb;
import 'package:openbudget_client/src/protocol/plaid/plaid_connection.dart'
    as _itydqisw;
import 'package:openbudget_client/src/protocol/recurring_transactions/recurring_transaction.dart'
    as _i41tn6nr;
import 'package:openbudget_client/src/protocol/reports/net_worth_granularity.dart'
    as _idze6lni;
import 'package:openbudget_client/src/protocol/reports/net_worth_history_view.dart'
    as _iynyr02m;
import 'package:openbudget_client/src/protocol/reports/net_worth_view.dart'
    as _ilmu26ji;
import 'package:openbudget_client/src/protocol/reports/report_grouping.dart'
    as _igx41vni;
import 'package:openbudget_client/src/protocol/reports/spending_row.dart'
    as _ia9y0al9;
import 'package:openbudget_client/src/protocol/settings/user_settings.dart'
    as _ivxpuwvx;
import 'package:openbudget_client/src/protocol/tax/tax_category_view.dart'
    as _ic177lol;
import 'package:openbudget_client/src/protocol/tax/tax_profile.dart'
    as _ibyrfq34;
import 'package:openbudget_client/src/protocol/tax/tax_report_view.dart'
    as _ieaa4q0n;
import 'package:openbudget_client/src/protocol/tax/tax_summary_view.dart'
    as _iets520s;
import 'package:openbudget_client/src/protocol/transaction_rules/transaction_rule.dart'
    as _iwxd5v0a;
import 'package:openbudget_client/src/protocol/transactions/import_result.dart'
    as _ish80d3o;
import 'package:openbudget_client/src/protocol/transactions/import_row.dart'
    as _iyud7cy9;
import 'package:openbudget_client/src/protocol/transactions/reconcile_result.dart'
    as _idhtlbwy;
import 'package:openbudget_client/src/protocol/transactions/transaction_flag.dart'
    as _idwby6z8;
import 'package:openbudget_client/src/protocol/transactions/transaction_input.dart'
    as _iufp60gr;
import 'package:openbudget_client/src/protocol/transactions/transaction_page.dart'
    as _ipoksp8f;
import 'package:openbudget_client/src/protocol/transactions/transaction_query.dart'
    as _in48a2uo;
import 'package:openbudget_client/src/protocol/transactions/transaction_status.dart'
    as _itmjglt7;
import 'package:openbudget_client/src/protocol/transactions/transaction_view.dart'
    as _irfj6dpt;
import 'package:openbudget_client/src/protocol/transactions/transfer_input.dart'
    as _i4fjyt55;
import 'package:openbudget_client/src/protocol/wallets/wallet.dart'
    as _igzh8mor;
import 'package:openbudget_client/src/protocol/wallets/wallet_holding.dart'
    as _izm3e498;
import 'package:openbudget_client/src/protocol/wallets/wallet_sync_result.dart'
    as _idhyojww;
import 'package:openbudget_client/src/protocol/wallets/wallet_tax_year_summary.dart'
    as _il62txu0;
import 'package:openbudget_client/src/protocol/wallets/wallet_transaction.dart'
    as _itxp58mr;
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import 'protocol.dart' as _il2as5qe;

/// API surface for account operations.
///
/// All methods require authentication and cross [AccountService] for the
/// entity-ownership check.
/// {@category Endpoint}
class EndpointAccount extends _isc.EndpointRef {
  EndpointAccount(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'account';

  /// Creates an account and its opening balance or first valuation.
  _ida.Future<_iqudaadl.Account> create(
    _isc.UuidValue entityId,
    String name,
    _ifz8weqz.AccountKind kind,
    String currencyCode, {
    _ifz8weqz.AccountBalanceSource? balanceSource,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
    _isc.UuidValue? institutionId,
    String? note,
  }) => caller.callServerEndpoint<_iqudaadl.Account>(
    'account',
    'create',
    {
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
    },
  );

  /// Lists every account of one owned entity.
  _ida.Future<List<_iqudaadl.Account>> list(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<List<_iqudaadl.Account>>(
        'account',
        'list',
        {'entityId': entityId},
      );

  /// Lists every account in every entity the caller owns.
  _ida.Future<List<_iqudaadl.Account>> listAll() =>
      caller.callServerEndpoint<List<_iqudaadl.Account>>(
        'account',
        'listAll',
        {},
      );

  /// Loads one owned account.
  _ida.Future<_iqudaadl.Account> get(_isc.UuidValue accountId) =>
      caller.callServerEndpoint<_iqudaadl.Account>(
        'account',
        'get',
        {'accountId': accountId},
      );

  /// Updates mutable account metadata.
  _ida.Future<_iqudaadl.Account> update(
    _isc.UuidValue accountId, {
    String? name,
    _ifz8weqz.AccountKind? kind,
    bool? onBudget,
    _isc.UuidValue? institutionId,
    bool? clearInstitution,
    String? note,
    int? sortOrder,
  }) => caller.callServerEndpoint<_iqudaadl.Account>(
    'account',
    'update',
    {
      'accountId': accountId,
      'name': name,
      'kind': kind,
      'onBudget': onBudget,
      'institutionId': institutionId,
      'clearInstitution': clearInstitution,
      'note': note,
      'sortOrder': sortOrder,
    },
  );

  /// Replaces the account order of one owned entity.
  _ida.Future<List<_iqudaadl.Account>> reorder(
    _isc.UuidValue entityId,
    List<_isc.UuidValue> accountIds,
  ) => caller.callServerEndpoint<List<_iqudaadl.Account>>(
    'account',
    'reorder',
    {
      'entityId': entityId,
      'accountIds': accountIds,
    },
  );

  /// Closes an account whose balance is zero.
  _ida.Future<_iqudaadl.Account> close(_isc.UuidValue accountId) =>
      caller.callServerEndpoint<_iqudaadl.Account>(
        'account',
        'close',
        {'accountId': accountId},
      );

  /// Reopens a closed account.
  _ida.Future<_iqudaadl.Account> reopen(_isc.UuidValue accountId) =>
      caller.callServerEndpoint<_iqudaadl.Account>(
        'account',
        'reopen',
        {'accountId': accountId},
      );

  /// Deletes the account, its transactions and its valuations.
  _ida.Future<void> delete(_isc.UuidValue accountId) =>
      caller.callServerEndpoint<void>(
        'account',
        'delete',
        {'accountId': accountId},
      );

  /// Returns the cached and cleared balances of one account.
  _ida.Future<_i83280l7.AccountBalancesView> getBalances(
    _isc.UuidValue accountId,
  ) => caller.callServerEndpoint<_i83280l7.AccountBalancesView>(
    'account',
    'getBalances',
    {'accountId': accountId},
  );

  /// Lists one account's valuations newest-first.
  _ida.Future<List<_idms9t2z.AccountValuation>> listValuations(
    _isc.UuidValue accountId,
  ) => caller.callServerEndpoint<List<_idms9t2z.AccountValuation>>(
    'account',
    'listValuations',
    {'accountId': accountId},
  );

  /// Upserts one manual valuation.
  _ida.Future<_idms9t2z.AccountValuation> setValuation(
    _isc.UuidValue accountId,
    DateTime valuationDate,
    int valueMinor, {
    String? note,
  }) => caller.callServerEndpoint<_idms9t2z.AccountValuation>(
    'account',
    'setValuation',
    {
      'accountId': accountId,
      'valuationDate': valuationDate,
      'valueMinor': valueMinor,
      'note': note,
    },
  );

  /// Deletes one valuation and recomputes the account balance.
  _ida.Future<void> deleteValuation(_isc.UuidValue valuationId) =>
      caller.callServerEndpoint<void>(
        'account',
        'deleteValuation',
        {'valuationId': valuationId},
      );
}

/// The financial assistant: chat, its history, its proposals and the user's
/// own provider settings.
///
/// Every method requires a signed-in user and checks that the entity, chat or
/// proposal belongs to them. The assistant never changes financial data; it
/// creates proposals that `applyProposal` carries out on the user's behalf.
/// {@category Endpoint}
class EndpointAgent extends _isc.EndpointRef {
  EndpointAgent(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'agent';

  /// Streams one assistant turn in entity `entityId`.
  ///
  /// A null [conversationId] starts a conversation titled from [message].
  /// Events are `usage` after each model call, `toolCall` before a tool runs,
  /// `proposal` for each change suggested, one `textDelta` with the reply, and
  /// a final `done`.
  _ida.Stream<_isrqm714.AgentEvent> chat(
    _isc.UuidValue entityId,
    _isc.UuidValue? conversationId,
    String message,
  ) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_isrqm714.AgentEvent>,
        _isrqm714.AgentEvent
      >(
        'agent',
        'chat',
        {
          'entityId': entityId,
          'conversationId': conversationId,
          'message': message,
        },
        {},
      );

  /// Lists the user's conversations in one entity, newest first.
  _ida.Future<List<_in44ixo7.AgentConversation>> listConversations(
    _isc.UuidValue entityId,
  ) => caller.callServerEndpoint<List<_in44ixo7.AgentConversation>>(
    'agent',
    'listConversations',
    {'entityId': entityId},
  );

  /// Returns the visible user and assistant messages of a conversation.
  _ida.Future<List<_i8fbky0c.AgentMessage>> getMessages(
    _isc.UuidValue conversationId,
  ) => caller.callServerEndpoint<List<_i8fbky0c.AgentMessage>>(
    'agent',
    'getMessages',
    {'conversationId': conversationId},
  );

  /// Deletes a conversation and its messages, keeping its proposals.
  _ida.Future<void> deleteConversation(_isc.UuidValue conversationId) =>
      caller.callServerEndpoint<void>(
        'agent',
        'deleteConversation',
        {'conversationId': conversationId},
      );

  /// Returns how much of the included agent allowance is left.
  _ida.Future<_igs7yvae.AgentUsageView> getUsage() =>
      caller.callServerEndpoint<_igs7yvae.AgentUsageView>(
        'agent',
        'getUsage',
        {},
      );

  /// Saves the user's own OpenAI-compatible provider and returns it without
  /// the API key.
  _ida.Future<_i8qcy504.AgentProviderSettingsView> saveProviderSettings(
    String baseUrl,
    String model,
    String apiKey,
  ) => caller.callServerEndpoint<_i8qcy504.AgentProviderSettingsView>(
    'agent',
    'saveProviderSettings',
    {
      'baseUrl': baseUrl,
      'model': model,
      'apiKey': apiKey,
    },
  );

  /// Returns the user's provider settings, or null when they use the
  /// built-in provider.
  _ida.Future<_i8qcy504.AgentProviderSettingsView?> getProviderSettings() =>
      caller.callServerEndpoint<_i8qcy504.AgentProviderSettingsView?>(
        'agent',
        'getProviderSettings',
        {},
      );

  /// Removes the user's provider settings so the built-in provider is used.
  _ida.Future<void> clearProviderSettings() => caller.callServerEndpoint<void>(
    'agent',
    'clearProviderSettings',
    {},
  );

  /// Lists the changes the assistant proposed for one entity.
  _ida.Future<List<_icv7zzda.AgentProposal>> listProposals(
    _isc.UuidValue entityId, {
    required bool pendingOnly,
  }) => caller.callServerEndpoint<List<_icv7zzda.AgentProposal>>(
    'agent',
    'listProposals',
    {
      'entityId': entityId,
      'pendingOnly': pendingOnly,
    },
  );

  /// Applies a pending proposal through the normal plan and tax services.
  _ida.Future<_icv7zzda.AgentProposal> applyProposal(
    _isc.UuidValue proposalId,
  ) => caller.callServerEndpoint<_icv7zzda.AgentProposal>(
    'agent',
    'applyProposal',
    {'proposalId': proposalId},
  );

  /// Dismisses a pending proposal without changing any data.
  _ida.Future<_icv7zzda.AgentProposal> dismissProposal(
    _isc.UuidValue proposalId,
  ) => caller.callServerEndpoint<_icv7zzda.AgentProposal>(
    'agent',
    'dismissProposal',
    {'proposalId': proposalId},
  );
}

/// Personal access tokens for external agents connecting over MCP.
///
/// Creating a token returns its secret exactly once. The server stores only a
/// hash, so a lost token is revoked and replaced, never recovered.
/// {@category Endpoint}
class EndpointAgentToken extends _isc.EndpointRef {
  EndpointAgentToken(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'agentToken';

  /// Creates a token and returns its secret, which is never shown again.
  _ida.Future<_ie7c2xv8.AgentAccessTokenCreated> createAccessToken(
    String name,
    bool canPropose,
  ) => caller.callServerEndpoint<_ie7c2xv8.AgentAccessTokenCreated>(
    'agentToken',
    'createAccessToken',
    {
      'name': name,
      'canPropose': canPropose,
    },
  );

  /// Lists the user's tokens without their secret.
  _ida.Future<List<_itxn3wek.AgentAccessTokenView>> listAccessTokens() =>
      caller.callServerEndpoint<List<_itxn3wek.AgentAccessTokenView>>(
        'agentToken',
        'listAccessTokens',
        {},
      );

  /// Revokes one of the user's tokens. Revoking twice is harmless.
  _ida.Future<_itxn3wek.AgentAccessTokenView> revokeAccessToken(
    _isc.UuidValue id,
  ) => caller.callServerEndpoint<_itxn3wek.AgentAccessTokenView>(
    'agentToken',
    'revokeAccessToken',
    {'id': id},
  );
}

/// By extending [AppleIdpBaseEndpoint], the Apple identity provider endpoint
/// is made available on the server and enables the corresponding sign-in flow
/// on the client.
/// {@category Endpoint}
class EndpointAppleIdp extends _iaic.EndpointAppleIdpBase {
  EndpointAppleIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'appleIdp';

  /// Signs in a user with their Apple account.
  ///
  /// If no user exists yet linked to the Apple-provided identifier, a new one
  /// will be created (without any `Scope`s). Further their provided name and
  /// email (if any) will be used for the `UserProfile` which will be linked to
  /// their `AuthUser`.
  ///
  /// Returns a session for the user upon successful login.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String identityToken,
    required String authorizationCode,
    required bool isNativeApplePlatformSignIn,
    String? firstName,
    String? lastName,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'appleIdp',
    'login',
    {
      'identityToken': identityToken,
      'authorizationCode': authorizationCode,
      'isNativeApplePlatformSignIn': isNativeApplePlatformSignIn,
      'firstName': firstName,
      'lastName': lastName,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'appleIdp',
    'hasAccount',
    {},
  );
}

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [GoogleIdpBaseEndpoint], the Google identity provider endpoint
/// is made available on the server and enables the corresponding sign-in flow
/// on the client.
/// {@category Endpoint}
class EndpointGoogleIdp extends _iaic.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  /// Validates a Google ID token and either logs in the associated user or
  /// creates a new user account if the Google account ID is not yet known.
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'login',
    {
      'idToken': idToken,
      'accessToken': accessToken,
    },
  );

  /// Validates a Google authorization code from the web OAuth2 PKCE flow and
  /// either logs in the associated user or creates a new account.
  ///
  /// This is the web counterpart of [login], which accepts an ID token directly
  /// (used on native platforms via the `google_sign_in` package).
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> loginWithCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'loginWithCode',
    {
      'code': code,
      'codeVerifier': codeVerifier,
      'redirectUri': redirectUri,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'googleIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// Subscription state for the signed-in user.
/// {@category Endpoint}
class EndpointBilling extends _isc.EndpointRef {
  EndpointBilling(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'billing';

  /// Returns the entitlement that currently grants OpenBudget Plus, or null
  /// when the user is on the free plan.
  _ida.Future<_iyhncv6f.Entitlement?> getEntitlement() =>
      caller.callServerEndpoint<_iyhncv6f.Entitlement?>(
        'billing',
        'getEntitlement',
        {},
      );

  /// Creates a Stripe Checkout session and returns its hosted URL.
  _ida.Future<String> createStripeCheckout(
    String successUrl,
    String cancelUrl,
  ) => caller.callServerEndpoint<String>(
    'billing',
    'createStripeCheckout',
    {
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
    },
  );

  /// Creates a Stripe billing portal session and returns its hosted URL.
  _ida.Future<String> createStripePortal(String returnUrl) =>
      caller.callServerEndpoint<String>(
        'billing',
        'createStripePortal',
        {'returnUrl': returnUrl},
      );

  /// Returns the Solana plan terms the app needs to subscribe on chain.
  _ida.Future<_ij0nbz0v.SolanaPlanView> getSolanaPlan() =>
      caller.callServerEndpoint<_ij0nbz0v.SolanaPlanView>(
        'billing',
        'getSolanaPlan',
        {},
      );

  /// Returns a one-time message the subscriber signs with their wallet.
  _ida.Future<String> solanaSubscriptionChallenge() =>
      caller.callServerEndpoint<String>(
        'billing',
        'solanaSubscriptionChallenge',
        {},
      );

  /// Verifies the signed challenge and records the on-chain subscription.
  _ida.Future<_iyhncv6f.Entitlement> confirmSolanaSubscription(
    String subscriberAddress,
    String message,
    String signatureBase58,
  ) => caller.callServerEndpoint<_iyhncv6f.Entitlement>(
    'billing',
    'confirmSolanaSubscription',
    {
      'subscriberAddress': subscriberAddress,
      'message': message,
      'signatureBase58': signatureBase58,
    },
  );
}

/// API surface for the envelope plan.
///
/// Every method requires authentication. The services own entity ownership,
/// archived-entity rejection and the transaction boundaries; this endpoint
/// only exposes the contract.
/// {@category Endpoint}
class EndpointBudget extends _isc.EndpointRef {
  EndpointBudget(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'budget';

  /// Reads one month of the Plan screen in a single database snapshot.
  _ida.Future<_i6xxh8m1.BudgetMonthView> getMonth(
    _isc.UuidValue entityId,
    int month,
  ) => caller.callServerEndpoint<_i6xxh8m1.BudgetMonthView>(
    'budget',
    'getMonth',
    {
      'entityId': entityId,
      'month': month,
    },
  );

  /// Replaces the named envelopes' allocations for one month.
  _ida.Future<_i6xxh8m1.BudgetMonthView> setAllocations(
    _isc.UuidValue entityId,
    int month,
    List<_inutgv28.AllocationInput> allocations,
  ) => caller.callServerEndpoint<_i6xxh8m1.BudgetMonthView>(
    'budget',
    'setAllocations',
    {
      'entityId': entityId,
      'month': month,
      'allocations': allocations,
    },
  );

  /// Moves a positive amount between envelopes or Ready to Assign.
  _ida.Future<_i6xxh8m1.BudgetMonthView> moveMoney(
    _isc.UuidValue entityId,
    int month,
    _isc.UuidValue? fromEnvelopeId,
    _isc.UuidValue? toEnvelopeId,
    int amountMinor,
  ) => caller.callServerEndpoint<_i6xxh8m1.BudgetMonthView>(
    'budget',
    'moveMoney',
    {
      'entityId': entityId,
      'month': month,
      'fromEnvelopeId': fromEnvelopeId,
      'toEnvelopeId': toEnvelopeId,
      'amountMinor': amountMinor,
    },
  );

  /// Replaces the target month's allocations with the source month's.
  _ida.Future<_i6xxh8m1.BudgetMonthView> copyMonth(
    _isc.UuidValue entityId,
    int fromMonth,
    int toMonth,
  ) => caller.callServerEndpoint<_i6xxh8m1.BudgetMonthView>(
    'budget',
    'copyMonth',
    {
      'entityId': entityId,
      'fromMonth': fromMonth,
      'toMonth': toMonth,
    },
  );

  /// Saves one month's exact sparse allocations as a named template.
  _ida.Future<_itiojbb0.BudgetTemplate> saveTemplate(
    _isc.UuidValue entityId,
    int month,
    String name,
  ) => caller.callServerEndpoint<_itiojbb0.BudgetTemplate>(
    'budget',
    'saveTemplate',
    {
      'entityId': entityId,
      'month': month,
      'name': name,
    },
  );

  /// Lists every template of an owned entity.
  _ida.Future<List<_itiojbb0.BudgetTemplate>> listTemplates(
    _isc.UuidValue entityId,
  ) => caller.callServerEndpoint<List<_itiojbb0.BudgetTemplate>>(
    'budget',
    'listTemplates',
    {'entityId': entityId},
  );

  /// Loads one template's lines.
  _ida.Future<List<_ik2p0evm.BudgetTemplateLine>> getTemplateLines(
    _isc.UuidValue templateId,
  ) => caller.callServerEndpoint<List<_ik2p0evm.BudgetTemplateLine>>(
    'budget',
    'getTemplateLines',
    {'templateId': templateId},
  );

  /// Replaces one month's allocations with a template's lines.
  _ida.Future<_i6xxh8m1.BudgetMonthView> applyTemplate(
    _isc.UuidValue templateId,
    int month,
  ) => caller.callServerEndpoint<_i6xxh8m1.BudgetMonthView>(
    'budget',
    'applyTemplate',
    {
      'templateId': templateId,
      'month': month,
    },
  );

  /// Deletes one template.
  _ida.Future<void> deleteTemplate(_isc.UuidValue templateId) =>
      caller.callServerEndpoint<void>(
        'budget',
        'deleteTemplate',
        {'templateId': templateId},
      );
}

/// API surface for category operations.
///
/// All methods require authentication and delegate to [CategoryService],
/// which owns the entity boundary.
/// {@category Endpoint}
class EndpointCategory extends _isc.EndpointRef {
  EndpointCategory(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'category';

  /// Creates a category at the end of the entity's list.
  _ida.Future<_iels1fku.Category> create(
    _isc.UuidValue entityId,
    String name,
  ) => caller.callServerEndpoint<_iels1fku.Category>(
    'category',
    'create',
    {
      'entityId': entityId,
      'name': name,
    },
  );

  /// Lists every category of an entity, hidden ones included.
  _ida.Future<List<_iels1fku.Category>> list(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<List<_iels1fku.Category>>(
        'category',
        'list',
        {'entityId': entityId},
      );

  /// Loads one category by id.
  _ida.Future<_iels1fku.Category> get(_isc.UuidValue categoryId) =>
      caller.callServerEndpoint<_iels1fku.Category>(
        'category',
        'get',
        {'categoryId': categoryId},
      );

  /// Renames or hides a category.
  _ida.Future<_iels1fku.Category> update(
    _isc.UuidValue categoryId, {
    String? name,
    bool? isHidden,
  }) => caller.callServerEndpoint<_iels1fku.Category>(
    'category',
    'update',
    {
      'categoryId': categoryId,
      'name': name,
      'isHidden': isHidden,
    },
  );

  /// Rewrites the entity's category order from an exact id list.
  _ida.Future<List<_iels1fku.Category>> reorder(
    _isc.UuidValue entityId,
    List<_isc.UuidValue> categoryIds,
  ) => caller.callServerEndpoint<List<_iels1fku.Category>>(
    'category',
    'reorder',
    {
      'entityId': entityId,
      'categoryIds': categoryIds,
    },
  );

  /// Deletes an empty category.
  _ida.Future<void> delete(_isc.UuidValue categoryId) =>
      caller.callServerEndpoint<void>(
        'category',
        'delete',
        {'categoryId': categoryId},
      );
}

/// Entity lifecycle for the signed-in owner.
/// {@category Endpoint}
class EndpointEntity extends _isc.EndpointRef {
  EndpointEntity(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'entity';

  /// Creates an entity with country fiscal defaults.
  _ida.Future<_i2ulk6h5.Entity> create(
    String name,
    _ifz8weqz.EntityKind kind,
    String countryCode,
    String baseCurrencyCode,
    String timeZone, {
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    _isc.UuidValue? linkedPersonalEntityId,
  }) => caller.callServerEndpoint<_i2ulk6h5.Entity>(
    'entity',
    'create',
    {
      'name': name,
      'kind': kind,
      'countryCode': countryCode,
      'baseCurrencyCode': baseCurrencyCode,
      'timeZone': timeZone,
      'fiscalYearEndMonth': fiscalYearEndMonth,
      'fiscalYearEndDay': fiscalYearEndDay,
      'linkedPersonalEntityId': linkedPersonalEntityId,
    },
  );

  /// Lists entities owned by the caller.
  _ida.Future<List<_i2ulk6h5.Entity>> list({bool? includeArchived}) =>
      caller.callServerEndpoint<List<_i2ulk6h5.Entity>>(
        'entity',
        'list',
        {'includeArchived': includeArchived},
      );

  /// One headline row per active entity the caller owns.
  _ida.Future<List<_ib1vbiwb.EntitySummaryView>> listSummaries() =>
      caller.callServerEndpoint<List<_ib1vbiwb.EntitySummaryView>>(
        'entity',
        'listSummaries',
        {},
      );

  /// Loads one owned entity.
  _ida.Future<_i2ulk6h5.Entity> get(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<_i2ulk6h5.Entity>(
        'entity',
        'get',
        {'entityId': entityId},
      );

  /// Updates mutable entity properties.
  _ida.Future<_i2ulk6h5.Entity> update(
    _isc.UuidValue entityId, {
    String? name,
    String? baseCurrencyCode,
    String? timeZone,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    bool? includeInNetWorth,
    _isc.UuidValue? linkedPersonalEntityId,
    bool? clearLinkedPersonalEntity,
    int? sortOrder,
  }) => caller.callServerEndpoint<_i2ulk6h5.Entity>(
    'entity',
    'update',
    {
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
    },
  );

  /// Hides an entity from active lists.
  _ida.Future<_i2ulk6h5.Entity> archive(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<_i2ulk6h5.Entity>(
        'entity',
        'archive',
        {'entityId': entityId},
      );

  /// Restores an entity to active lists.
  _ida.Future<_i2ulk6h5.Entity> unarchive(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<_i2ulk6h5.Entity>(
        'entity',
        'unarchive',
        {'entityId': entityId},
      );

  /// Requires an exact name confirmation for every entity, including ledger mode.
  _ida.Future<void> delete(
    _isc.UuidValue entityId,
    String confirmName,
  ) => caller.callServerEndpoint<void>(
    'entity',
    'delete',
    {
      'entityId': entityId,
      'confirmName': confirmName,
    },
  );

  /// Exports every record of the entity as one portable JSON document.
  _ida.Future<String> exportData(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<String>(
        'entity',
        'exportData',
        {'entityId': entityId},
      );
}

/// Streams scoped changes to the entity's owner.
/// {@category Endpoint}
class EndpointEntityStream extends _isc.EndpointRef {
  EndpointEntityStream(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'entityStream';

  /// Ownership is checked before subscribing to the global channel.
  _ida.Stream<_irhjjor1.EntityChangedEvent> watch(_isc.UuidValue entityId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_irhjjor1.EntityChangedEvent>,
        _irhjjor1.EntityChangedEvent
      >(
        'entityStream',
        'watch',
        {'entityId': entityId},
        {},
      );
}

/// API surface for envelope goal operations.
///
/// All methods require authentication and delegate to [EnvelopeGoalService],
/// which owns the entity boundary.
/// {@category Endpoint}
class EndpointEnvelopeGoal extends _isc.EndpointRef {
  EndpointEnvelopeGoal(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'envelopeGoal';

  /// Creates or replaces the goal for one envelope.
  _ida.Future<_ibdhi9gv.EnvelopeGoal> upsert(
    _isc.UuidValue envelopeId,
    _ilw4dz54.EnvelopeGoalKind kind,
    int amountMinor, {
    DateTime? targetDate,
  }) => caller.callServerEndpoint<_ibdhi9gv.EnvelopeGoal>(
    'envelopeGoal',
    'upsert',
    {
      'envelopeId': envelopeId,
      'kind': kind,
      'amountMinor': amountMinor,
      'targetDate': targetDate,
    },
  );

  /// Lists every goal of an entity.
  _ida.Future<List<_ibdhi9gv.EnvelopeGoal>> list(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<List<_ibdhi9gv.EnvelopeGoal>>(
        'envelopeGoal',
        'list',
        {'entityId': entityId},
      );

  /// Deletes one goal by id.
  _ida.Future<void> delete(_isc.UuidValue goalId) =>
      caller.callServerEndpoint<void>(
        'envelopeGoal',
        'delete',
        {'goalId': goalId},
      );
}

/// API surface for envelope operations.
///
/// All methods require authentication and delegate to [EnvelopeService],
/// which owns the entity boundary and the reassignment transaction.
/// {@category Endpoint}
class EndpointEnvelope extends _isc.EndpointRef {
  EndpointEnvelope(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'envelope';

  /// Creates an envelope at the end of its category's list.
  _ida.Future<_i29jf3by.Envelope> create(
    _isc.UuidValue categoryId,
    String name, {
    String? note,
    String? taxCategoryCode,
  }) => caller.callServerEndpoint<_i29jf3by.Envelope>(
    'envelope',
    'create',
    {
      'categoryId': categoryId,
      'name': name,
      'note': note,
      'taxCategoryCode': taxCategoryCode,
    },
  );

  /// Lists every envelope of an entity.
  _ida.Future<List<_i29jf3by.Envelope>> list(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<List<_i29jf3by.Envelope>>(
        'envelope',
        'list',
        {'entityId': entityId},
      );

  /// Loads one envelope by id.
  _ida.Future<_i29jf3by.Envelope> get(_isc.UuidValue envelopeId) =>
      caller.callServerEndpoint<_i29jf3by.Envelope>(
        'envelope',
        'get',
        {'envelopeId': envelopeId},
      );

  /// Updates one envelope, including nullable clear flags.
  _ida.Future<_i29jf3by.Envelope> update(
    _isc.UuidValue envelopeId, {
    String? name,
    _isc.UuidValue? categoryId,
    String? note,
    bool? isHidden,
    String? taxCategoryCode,
    bool? clearTaxCategoryCode,
    _isc.UuidValue? defaultLedgerAccountId,
    bool? clearDefaultLedgerAccount,
  }) => caller.callServerEndpoint<_i29jf3by.Envelope>(
    'envelope',
    'update',
    {
      'envelopeId': envelopeId,
      'name': name,
      'categoryId': categoryId,
      'note': note,
      'isHidden': isHidden,
      'taxCategoryCode': taxCategoryCode,
      'clearTaxCategoryCode': clearTaxCategoryCode,
      'defaultLedgerAccountId': defaultLedgerAccountId,
      'clearDefaultLedgerAccount': clearDefaultLedgerAccount,
    },
  );

  /// Rewrites one category's envelope order from an exact id list.
  _ida.Future<List<_i29jf3by.Envelope>> reorder(
    _isc.UuidValue categoryId,
    List<_isc.UuidValue> envelopeIds,
  ) => caller.callServerEndpoint<List<_i29jf3by.Envelope>>(
    'envelope',
    'reorder',
    {
      'categoryId': categoryId,
      'envelopeIds': envelopeIds,
    },
  );

  /// Deletes an envelope, optionally moving every reference first.
  _ida.Future<void> delete(
    _isc.UuidValue envelopeId, {
    _isc.UuidValue? reassignToEnvelopeId,
  }) => caller.callServerEndpoint<void>(
    'envelope',
    'delete',
    {
      'envelopeId': envelopeId,
      'reassignToEnvelopeId': reassignToEnvelopeId,
    },
  );
}

/// API surface for exchange rates used by display-currency conversion.
/// {@category Endpoint}
class EndpointFxRate extends _isc.EndpointRef {
  EndpointFxRate(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'fxRate';

  /// Returns the latest daily FX rows persisted by the backend.
  _ida.Future<_it7vndki.FxLatestSnapshot> latest() =>
      caller.callServerEndpoint<_it7vndki.FxLatestSnapshot>(
        'fxRate',
        'latest',
        {},
      );

  /// Forces an immediate refresh from the upstream FX provider and persists it.
  _ida.Future<_it7vndki.FxLatestSnapshot> refresh() =>
      caller.callServerEndpoint<_it7vndki.FxLatestSnapshot>(
        'fxRate',
        'refresh',
        {},
      );

  /// Resolves the rate the server would use on [date].
  ///
  /// Throws [FxRateUnavailableException] when no rate exists; it never answers
  /// with an identity rate for two different currencies.
  _ida.Future<_ij92xk61.FxQuoteView> quote(
    String fromCurrencyCode,
    String toCurrencyCode,
    DateTime date,
  ) => caller.callServerEndpoint<_ij92xk61.FxQuoteView>(
    'fxRate',
    'quote',
    {
      'fromCurrencyCode': fromCurrencyCode,
      'toCurrencyCode': toCurrencyCode,
      'date': date,
    },
  );
}

/// API surface for institution catalog discovery.
/// {@category Endpoint}
class EndpointInstitution extends _isc.EndpointRef {
  EndpointInstitution(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'institution';

  /// Returns the seeded institution catalog sorted for a user's location.
  _ida.Future<List<_i6ysl1a4.Institution>> list({String? locationCode}) =>
      caller.callServerEndpoint<List<_i6ysl1a4.Institution>>(
        'institution',
        'list',
        {'locationCode': locationCode},
      );
}

/// API surface for an entity's double-entry books.
///
/// All methods require authentication and cross [LedgerService], which checks
/// entity ownership. Posted journals have no update or delete path anywhere
/// in this API: corrections go through [reverseJournal]. Revaluation is not
/// exposed until the revaluation unit exists.
/// {@category Endpoint}
class EndpointLedger extends _isc.EndpointRef {
  EndpointLedger(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'ledger';

  /// Enables ledger accounting on a sole-trader or company entity: seeds the
  /// country chart, links one ledger account per money account, and switches
  /// the entity to ledger mode atomically.
  _ida.Future<_i2ulk6h5.Entity> enableLedger(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<_i2ulk6h5.Entity>(
        'ledger',
        'enableLedger',
        {'entityId': entityId},
      );

  /// Lists the entity's ledger accounts.
  _ida.Future<List<_ixq9t892.LedgerAccount>> listAccounts(
    _isc.UuidValue entityId, {
    required bool includeArchived,
  }) => caller.callServerEndpoint<List<_ixq9t892.LedgerAccount>>(
    'ledger',
    'listAccounts',
    {
      'entityId': entityId,
      'includeArchived': includeArchived,
    },
  );

  /// Adds an account to the entity's chart of accounts.
  _ida.Future<_ixq9t892.LedgerAccount> createAccount(
    _isc.UuidValue entityId,
    String code,
    String name,
    _ifz8weqz.LedgerAccountType type, {
    _ifz8weqz.LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  }) => caller.callServerEndpoint<_ixq9t892.LedgerAccount>(
    'ledger',
    'createAccount',
    {
      'entityId': entityId,
      'code': code,
      'name': name,
      'type': type,
      'systemRole': systemRole,
      'currencyCode': currencyCode,
      'taxCategoryCode': taxCategoryCode,
    },
  );

  /// Archives a non-structural account so it stops accepting postings.
  _ida.Future<_ixq9t892.LedgerAccount> archiveAccount(
    _isc.UuidValue accountId,
  ) => caller.callServerEndpoint<_ixq9t892.LedgerAccount>(
    'ledger',
    'archiveAccount',
    {'accountId': accountId},
  );

  /// Saves a draft journal: creates one, or replaces the lines of an existing
  /// draft when [journalId] is given.
  _ida.Future<_izuizaeu.Journal> saveDraftJournal(
    _isc.UuidValue entityId,
    DateTime date,
    List<_i3j8x5or.JournalLineInput> lines, {
    _isc.UuidValue? journalId,
    required String reference,
    String? narration,
    required _ifz8weqz.JournalSource source,
  }) => caller.callServerEndpoint<_izuizaeu.Journal>(
    'ledger',
    'saveDraftJournal',
    {
      'entityId': entityId,
      'date': date,
      'lines': lines,
      'journalId': journalId,
      'reference': reference,
      'narration': narration,
      'source': source,
    },
  );

  /// Deletes a draft journal. Posted journals cannot be deleted.
  _ida.Future<void> deleteDraftJournal(_isc.UuidValue journalId) =>
      caller.callServerEndpoint<void>(
        'ledger',
        'deleteDraftJournal',
        {'journalId': journalId},
      );

  /// Posts a draft journal, making it immutable.
  _ida.Future<_izuizaeu.Journal> postJournal(_isc.UuidValue journalId) =>
      caller.callServerEndpoint<_izuizaeu.Journal>(
        'ledger',
        'postJournal',
        {'journalId': journalId},
      );

  /// Reverses a posted journal on [date] with a mirror journal.
  _ida.Future<_izuizaeu.Journal> reverseJournal(
    _isc.UuidValue journalId,
    DateTime date,
  ) => caller.callServerEndpoint<_izuizaeu.Journal>(
    'ledger',
    'reverseJournal',
    {
      'journalId': journalId,
      'date': date,
    },
  );

  /// Lists one bounded page of the entity's journals, newest first.
  _ida.Future<List<_izuizaeu.Journal>> listJournals(
    _isc.UuidValue entityId, {
    DateTime? fromDate,
    DateTime? toDate,
    required int limit,
    String? cursor,
  }) => caller.callServerEndpoint<List<_izuizaeu.Journal>>(
    'ledger',
    'listJournals',
    {
      'entityId': entityId,
      'fromDate': fromDate,
      'toDate': toDate,
      'limit': limit,
      'cursor': cursor,
    },
  );

  /// Lists one journal's lines, oldest first.
  _ida.Future<List<_iwruw2s3.JournalLine>> listJournalLines(
    _isc.UuidValue journalId,
  ) => caller.callServerEndpoint<List<_iwruw2s3.JournalLine>>(
    'ledger',
    'listJournalLines',
    {'journalId': journalId},
  );

  /// The entity's period lock, or null when no lock date has been set.
  _ida.Future<_i10h3ni6.LedgerPeriodLock?> getLockDate(
    _isc.UuidValue entityId,
  ) => caller.callServerEndpoint<_i10h3ni6.LedgerPeriodLock?>(
    'ledger',
    'getLockDate',
    {'entityId': entityId},
  );

  /// Sets or moves the entity's period lock date.
  _ida.Future<_i10h3ni6.LedgerPeriodLock> setLockDate(
    _isc.UuidValue entityId,
    DateTime lockDate,
  ) => caller.callServerEndpoint<_i10h3ni6.LedgerPeriodLock>(
    'ledger',
    'setLockDate',
    {
      'entityId': entityId,
      'lockDate': lockDate,
    },
  );

  /// Computes the trial balance through [asOf] over posted journals.
  _ida.Future<_i0gvlz5s.TrialBalanceView> trialBalance(
    _isc.UuidValue entityId,
    DateTime asOf,
  ) => caller.callServerEndpoint<_i0gvlz5s.TrialBalanceView>(
    'ledger',
    'trialBalance',
    {
      'entityId': entityId,
      'asOf': asOf,
    },
  );

  /// Lists one bounded page of the entity's audit trail, newest first.
  _ida.Future<List<_ioe147d0.AuditEvent>> listAuditEvents(
    _isc.UuidValue entityId, {
    DateTime? before,
    int? limit,
  }) => caller.callServerEndpoint<List<_ioe147d0.AuditEvent>>(
    'ledger',
    'listAuditEvents',
    {
      'entityId': entityId,
      'before': before,
      'limit': limit,
    },
  );
}

/// API surface for payee operations.
///
/// All methods require authentication and delegate to [PayeeService], which
/// owns the entity boundary and publishes committed change events.
/// {@category Endpoint}
class EndpointPayee extends _isc.EndpointRef {
  EndpointPayee(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'payee';

  /// Creates a payee, or reuses the entity's payee with the same name.
  _ida.Future<_iaf6ifsb.Payee> create(
    String name,
    _isc.UuidValue entityId,
  ) => caller.callServerEndpoint<_iaf6ifsb.Payee>(
    'payee',
    'create',
    {
      'name': name,
      'entityId': entityId,
    },
  );

  /// Lists every payee of an entity, ordered by name and id.
  _ida.Future<List<_iaf6ifsb.Payee>> list(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<List<_iaf6ifsb.Payee>>(
        'payee',
        'list',
        {'entityId': entityId},
      );

  /// Gets a single payee by ID.
  _ida.Future<_iaf6ifsb.Payee> get(_isc.UuidValue payeeId) =>
      caller.callServerEndpoint<_iaf6ifsb.Payee>(
        'payee',
        'get',
        {'payeeId': payeeId},
      );

  /// Renames a payee by ID.
  _ida.Future<_iaf6ifsb.Payee> update(
    _isc.UuidValue payeeId, {
    String? name,
  }) => caller.callServerEndpoint<_iaf6ifsb.Payee>(
    'payee',
    'update',
    {
      'payeeId': payeeId,
      'name': name,
    },
  );

  /// Returns the envelope used by the payee's most recent coded transaction.
  _ida.Future<_isc.UuidValue?> lastUsedEnvelopeId(
    _isc.UuidValue payeeId,
    _isc.UuidValue entityId,
  ) => caller.callServerEndpoint<_isc.UuidValue?>(
    'payee',
    'lastUsedEnvelopeId',
    {
      'payeeId': payeeId,
      'entityId': entityId,
    },
  );

  /// Merges the source payee into the target payee.
  ///
  /// Returns the number of transactions reassigned. The source payee is
  /// deleted after its transactions, recurring schedules and rules move.
  _ida.Future<int> merge(
    _isc.UuidValue sourcePayeeId,
    _isc.UuidValue targetPayeeId,
  ) => caller.callServerEndpoint<int>(
    'payee',
    'merge',
    {
      'sourcePayeeId': sourcePayeeId,
      'targetPayeeId': targetPayeeId,
    },
  );

  /// Deletes a payee and clears every reference to it.
  _ida.Future<_iaf6ifsb.Payee> delete(_isc.UuidValue payeeId) =>
      caller.callServerEndpoint<_iaf6ifsb.Payee>(
        'payee',
        'delete',
        {'payeeId': payeeId},
      );
}

/// API surface for Plaid-linked bank connections.
///
/// Every method is entity-scoped. The connection rows carry no secrets for
/// the client: the token and cursor fields are `scope=serverOnly`, so the
/// generated class cannot leak them.
/// {@category Endpoint}
class EndpointPlaid extends _isc.EndpointRef {
  EndpointPlaid(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'plaid';

  /// Creates a short-lived link token for starting Plaid Link in the client.
  _ida.Future<String> createLinkToken(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<String>(
        'plaid',
        'createLinkToken',
        {'entityId': entityId},
      );

  /// Exchanges a public token, imports the item's accounts with their
  /// opening balances, and syncs the posted movements once.
  _ida.Future<_itydqisw.PlaidConnection> exchangePublicToken(
    _isc.UuidValue entityId,
    String publicToken,
  ) => caller.callServerEndpoint<_itydqisw.PlaidConnection>(
    'plaid',
    'exchangePublicToken',
    {
      'entityId': entityId,
      'publicToken': publicToken,
    },
  );

  /// Refreshes one connection: reported balances, valuations and movements.
  _ida.Future<_itydqisw.PlaidConnection> syncConnection(
    _isc.UuidValue connectionId,
  ) => caller.callServerEndpoint<_itydqisw.PlaidConnection>(
    'plaid',
    'syncConnection',
    {'connectionId': connectionId},
  );

  /// Lists the entity's connections, secrets never included.
  _ida.Future<List<_itydqisw.PlaidConnection>> listConnections(
    _isc.UuidValue entityId,
  ) => caller.callServerEndpoint<List<_itydqisw.PlaidConnection>>(
    'plaid',
    'listConnections',
    {'entityId': entityId},
  );

  /// Removes a connection, revokes the item at Plaid, and keeps the
  /// accounts' imported history.
  _ida.Future<void> removeConnection(_isc.UuidValue connectionId) =>
      caller.callServerEndpoint<void>(
        'plaid',
        'removeConnection',
        {'connectionId': connectionId},
      );

  /// Creates a Plaid sandbox item and links it without client-side Link.
  _ida.Future<_itydqisw.PlaidConnection> importSandboxAccounts(
    _isc.UuidValue entityId, {
    String? plaidInstitutionId,
  }) => caller.callServerEndpoint<_itydqisw.PlaidConnection>(
    'plaid',
    'importSandboxAccounts',
    {
      'entityId': entityId,
      'plaidInstitutionId': plaidInstitutionId,
    },
  );
}

/// API surface for recurring transaction operations.
///
/// All methods require authentication and delegate to
/// [RecurringTransactionService], which owns the entity boundary and publishes
/// committed change events.
/// {@category Endpoint}
class EndpointRecurringTransaction extends _isc.EndpointRef {
  EndpointRecurringTransaction(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'recurringTransaction';

  /// Creates a schedule for one transactions-sourced account.
  _ida.Future<_i41tn6nr.RecurringTransaction> create(
    _isc.UuidValue accountId,
    String description,
    int amountMinor,
    _ifz8weqz.RecurrenceFrequency frequency,
    DateTime nextDate, {
    _isc.UuidValue? payeeId,
    _isc.UuidValue? envelopeId,
    String? memo,
    DateTime? endDate,
  }) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'create',
    {
      'accountId': accountId,
      'description': description,
      'amountMinor': amountMinor,
      'frequency': frequency,
      'nextDate': nextDate,
      'payeeId': payeeId,
      'envelopeId': envelopeId,
      'memo': memo,
      'endDate': endDate,
    },
  );

  /// Lists every schedule of an owned entity in due-date order.
  _ida.Future<List<_i41tn6nr.RecurringTransaction>> list(
    _isc.UuidValue entityId,
  ) => caller.callServerEndpoint<List<_i41tn6nr.RecurringTransaction>>(
    'recurringTransaction',
    'list',
    {'entityId': entityId},
  );

  /// Gets one schedule by ID.
  _ida.Future<_i41tn6nr.RecurringTransaction> get(
    _isc.UuidValue recurringTransactionId,
  ) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'get',
    {'recurringTransactionId': recurringTransactionId},
  );

  /// Updates the named fields and clear flags from the §7.1 contract.
  _ida.Future<_i41tn6nr.RecurringTransaction> update(
    _isc.UuidValue recurringTransactionId, {
    _isc.UuidValue? accountId,
    String? description,
    int? amountMinor,
    _ifz8weqz.RecurrenceFrequency? frequency,
    DateTime? nextDate,
    _isc.UuidValue? payeeId,
    bool? clearPayee,
    _isc.UuidValue? envelopeId,
    bool? clearEnvelope,
    String? memo,
    DateTime? endDate,
    bool? clearEndDate,
    bool? isActive,
  }) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'update',
    {
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
    },
  );

  /// Deletes one schedule without deleting its posted transactions.
  _ida.Future<_i41tn6nr.RecurringTransaction> delete(
    _isc.UuidValue recurringTransactionId,
  ) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'delete',
    {'recurringTransactionId': recurringTransactionId},
  );

  /// Advances the schedule by one occurrence without posting it.
  _ida.Future<_i41tn6nr.RecurringTransaction> skipOccurrence(
    _isc.UuidValue recurringTransactionId,
  ) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'skipOccurrence',
    {'recurringTransactionId': recurringTransactionId},
  );

  /// Posts every due occurrence for one entity and returns the actual count.
  _ida.Future<int> postDue(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<int>(
        'recurringTransaction',
        'postDue',
        {'entityId': entityId},
      );

  /// Counts active schedules that are due on the entity's local today.
  _ida.Future<int> countDue(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<int>(
        'recurringTransaction',
        'countDue',
        {'entityId': entityId},
      );
}

/// Read-only reporting surface for net worth, spending, month summaries and
/// age of money. Every method requires a signed-in caller and delegates the
/// ownership boundary to its service.
/// {@category Endpoint}
class EndpointReport extends _isc.EndpointRef {
  EndpointReport(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'report';

  /// Combined net worth for the caller's entities on one date.
  _ida.Future<_ilmu26ji.NetWorthView> netWorth({
    List<_isc.UuidValue>? entityIds,
    String? currencyCode,
    DateTime? asOf,
  }) => caller.callServerEndpoint<_ilmu26ji.NetWorthView>(
    'report',
    'netWorth',
    {
      'entityIds': entityIds,
      'currencyCode': currencyCode,
      'asOf': asOf,
    },
  );

  /// Net worth at the last day of each period in a range.
  _ida.Future<_iynyr02m.NetWorthHistoryView> netWorthHistory(
    DateTime fromDate,
    DateTime toDate,
    _idze6lni.NetWorthGranularity granularity, {
    List<_isc.UuidValue>? entityIds,
    String? currencyCode,
  }) => caller.callServerEndpoint<_iynyr02m.NetWorthHistoryView>(
    'report',
    'netWorthHistory',
    {
      'fromDate': fromDate,
      'toDate': toDate,
      'granularity': granularity,
      'entityIds': entityIds,
      'currencyCode': currencyCode,
    },
  );

  /// One group's spending and income over a month range.
  _ida.Future<List<_ia9y0al9.SpendingRow>> spending(
    _isc.UuidValue entityId,
    int fromMonth,
    int toMonth,
    _igx41vni.ReportGrouping grouping,
    bool byMonth,
  ) => caller.callServerEndpoint<List<_ia9y0al9.SpendingRow>>(
    'report',
    'spending',
    {
      'entityId': entityId,
      'fromMonth': fromMonth,
      'toMonth': toMonth,
      'grouping': grouping,
      'byMonth': byMonth,
    },
  );

  /// The section 6.4 summary for every month from [fromMonth] to [toMonth].
  _ida.Future<List<_i52laypj.BudgetMonthSummary>> monthSummaries(
    _isc.UuidValue entityId,
    int fromMonth,
    int toMonth,
  ) => caller.callServerEndpoint<List<_i52laypj.BudgetMonthSummary>>(
    'report',
    'monthSummaries',
    {
      'entityId': entityId,
      'fromMonth': fromMonth,
      'toMonth': toMonth,
    },
  );

  /// The mean age in days of the last ten outflows' money, or null.
  _ida.Future<int?> ageOfMoney(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<int?>(
        'report',
        'ageOfMoney',
        {'entityId': entityId},
      );
}

/// User preferences independent of the selected entity.
/// {@category Endpoint}
class EndpointSettings extends _isc.EndpointRef {
  EndpointSettings(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'settings';

  /// Loads or creates the caller's settings.
  _ida.Future<_ivxpuwvx.UserSettings> get() =>
      caller.callServerEndpoint<_ivxpuwvx.UserSettings>(
        'settings',
        'get',
        {},
      );

  /// Sets a supported ISO reporting currency.
  _ida.Future<_ivxpuwvx.UserSettings> setReportingCurrency(
    String currencyCode,
  ) => caller.callServerEndpoint<_ivxpuwvx.UserSettings>(
    'settings',
    'setReportingCurrency',
    {'currencyCode': currencyCode},
  );
}

/// API surface for tax profiles, line coding, envelope defaults, reports
/// and tax-ready summaries.
///
/// Every method requires authentication and delegates to [TaxService], which
/// owns the entity boundary and the write rules.
/// {@category Endpoint}
class EndpointTax extends _isc.EndpointRef {
  EndpointTax(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'tax';

  /// Returns the entity's canonical tax profile, or null when none is set.
  _ida.Future<_ibyrfq34.TaxProfileRecord?> getProfile(
    _isc.UuidValue entityId,
  ) => caller.callServerEndpoint<_ibyrfq34.TaxProfileRecord?>(
    'tax',
    'getProfile',
    {'entityId': entityId},
  );

  /// Creates or replaces the entity's tax profile.
  ///
  /// [jurisdiction] and [entityKind] are kept for the documented §7.1 surface,
  /// but they are redundant assertions: the entity's country and kind are the
  /// source of truth and always rewrite the stored profile, and a conflicting
  /// value rejects. The personal-business link is set on the entity, not here.
  _ida.Future<_ibyrfq34.TaxProfileRecord> saveProfile(
    _isc.UuidValue entityId,
    String jurisdiction,
    String entityKind,
    String profileJson,
  ) => caller.callServerEndpoint<_ibyrfq34.TaxProfileRecord>(
    'tax',
    'saveProfile',
    {
      'entityId': entityId,
      'jurisdiction': jurisdiction,
      'entityKind': entityKind,
      'profileJson': profileJson,
    },
  );

  /// Lists the tax categories available to the entity's kind.
  _ida.Future<List<_ic177lol.TaxCategoryView>> listCategories(
    _isc.UuidValue entityId,
  ) => caller.callServerEndpoint<List<_ic177lol.TaxCategoryView>>(
    'tax',
    'listCategories',
    {'entityId': entityId},
  );

  /// Sets or clears the default tax category on an envelope.
  ///
  /// A null or blank [code] clears the default, matching the existing surface.
  _ida.Future<_i29jf3by.Envelope> setEnvelopeTaxCategory(
    _isc.UuidValue envelopeId, {
    String? code,
  }) => caller.callServerEndpoint<_i29jf3by.Envelope>(
    'tax',
    'setEnvelopeTaxCategory',
    {
      'envelopeId': envelopeId,
      'code': code,
    },
  );

  /// Sets or clears one transaction line's tax treatment.
  ///
  /// Null leaves a field unchanged; [clearTaxCategoryCode] clears only the
  /// category. The write uses the transaction writer's rules, so reconciled
  /// rows, period locks, transfers and ledger revisions behave exactly as an
  /// ordinary line edit.
  _ida.Future<_irfj6dpt.TransactionView> setLineTax(
    _isc.UuidValue transactionLineId, {
    String? taxCategoryCode,
    bool? clearTaxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
  }) => caller.callServerEndpoint<_irfj6dpt.TransactionView>(
    'tax',
    'setLineTax',
    {
      'transactionLineId': transactionLineId,
      'taxCategoryCode': taxCategoryCode,
      'clearTaxCategoryCode': clearTaxCategoryCode,
      'businessUsePercent': businessUsePercent,
      'salesTaxMinor': salesTaxMinor,
    },
  );

  /// Computes the entity's tax report for the year starting in [startYear].
  ///
  /// When [startYear] is null the tax year containing the entity's local today
  /// is used.
  _ida.Future<_ieaa4q0n.TaxReportView> getReport(
    _isc.UuidValue entityId, {
    int? startYear,
  }) => caller.callServerEndpoint<_ieaa4q0n.TaxReportView>(
    'tax',
    'getReport',
    {
      'entityId': entityId,
      'startYear': startYear,
    },
  );

  /// Builds the entity's tax-ready summary for the year starting in
  /// [startYear].
  ///
  /// When [startYear] is null the year containing the entity's local today
  /// is used. Every country is served: a pack country uses its pack's tax
  /// year, any other country its universal tax year, and a company its own
  /// financial year.
  _ida.Future<_iets520s.TaxSummaryView> getSummary(
    _isc.UuidValue entityId, {
    int? startYear,
  }) => caller.callServerEndpoint<_iets520s.TaxSummaryView>(
    'tax',
    'getSummary',
    {
      'entityId': entityId,
      'startYear': startYear,
    },
  );
}

/// API surface for transaction rule operations.
///
/// All methods require authentication and delegate to
/// [TransactionRuleService], which owns the entity boundary and publishes
/// committed change events.
/// {@category Endpoint}
class EndpointTransactionRule extends _isc.EndpointRef {
  EndpointTransactionRule(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'transactionRule';

  /// Creates the entity's rule for a payee.
  _ida.Future<_iwxd5v0a.TransactionRule> create(
    _isc.UuidValue entityId,
    _isc.UuidValue payeeId,
    _isc.UuidValue envelopeId,
  ) => caller.callServerEndpoint<_iwxd5v0a.TransactionRule>(
    'transactionRule',
    'create',
    {
      'entityId': entityId,
      'payeeId': payeeId,
      'envelopeId': envelopeId,
    },
  );

  /// Lists every rule of an entity.
  _ida.Future<List<_iwxd5v0a.TransactionRule>> list(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<List<_iwxd5v0a.TransactionRule>>(
        'transactionRule',
        'list',
        {'entityId': entityId},
      );

  /// Gets a single transaction rule by ID.
  _ida.Future<_iwxd5v0a.TransactionRule> get(_isc.UuidValue ruleId) =>
      caller.callServerEndpoint<_iwxd5v0a.TransactionRule>(
        'transactionRule',
        'get',
        {'ruleId': ruleId},
      );

  /// Changes a rule's envelope, its enabled state, or both.
  _ida.Future<_iwxd5v0a.TransactionRule> update(
    _isc.UuidValue ruleId, {
    _isc.UuidValue? envelopeId,
    bool? enabled,
  }) => caller.callServerEndpoint<_iwxd5v0a.TransactionRule>(
    'transactionRule',
    'update',
    {
      'ruleId': ruleId,
      'envelopeId': envelopeId,
      'enabled': enabled,
    },
  );

  /// Returns the envelope an enabled rule supplies for a payee.
  _ida.Future<_isc.UuidValue?> findMatchingEnvelope(
    _isc.UuidValue entityId,
    _isc.UuidValue payeeId,
  ) => caller.callServerEndpoint<_isc.UuidValue?>(
    'transactionRule',
    'findMatchingEnvelope',
    {
      'entityId': entityId,
      'payeeId': payeeId,
    },
  );

  /// Deletes a transaction rule.
  _ida.Future<_iwxd5v0a.TransactionRule> delete(_isc.UuidValue ruleId) =>
      caller.callServerEndpoint<_iwxd5v0a.TransactionRule>(
        'transactionRule',
        'delete',
        {'ruleId': ruleId},
      );
}

/// API surface for transaction operations.
///
/// Every method requires authentication and delegates to
/// [TransactionService], which owns ownership checks and the write boundary.
/// {@category Endpoint}
class EndpointTransaction extends _isc.EndpointRef {
  EndpointTransaction(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'transaction';

  /// Creates a transaction header and its lines.
  _ida.Future<_irfj6dpt.TransactionView> create(
    _iufp60gr.TransactionInput input,
  ) => caller.callServerEndpoint<_irfj6dpt.TransactionView>(
    'transaction',
    'create',
    {'input': input},
  );

  /// Loads one owned transaction with its lines and transfer peer.
  _ida.Future<_irfj6dpt.TransactionView> get(_isc.UuidValue transactionId) =>
      caller.callServerEndpoint<_irfj6dpt.TransactionView>(
        'transaction',
        'get',
        {'transactionId': transactionId},
      );

  /// Lists one keyset page of an owned entity's transactions.
  _ida.Future<_ipoksp8f.TransactionPage> list(
    _in48a2uo.TransactionQuery query,
  ) => caller.callServerEndpoint<_ipoksp8f.TransactionPage>(
    'transaction',
    'list',
    {'query': query},
  );

  /// Replaces a transaction and its lines.
  _ida.Future<_irfj6dpt.TransactionView> update(
    _isc.UuidValue transactionId,
    _iufp60gr.TransactionInput input,
  ) => caller.callServerEndpoint<_irfj6dpt.TransactionView>(
    'transaction',
    'update',
    {
      'transactionId': transactionId,
      'input': input,
    },
  );

  /// Deletes a transaction, both legs of a transfer, and their balances.
  _ida.Future<void> delete(_isc.UuidValue transactionId) =>
      caller.callServerEndpoint<void>(
        'transaction',
        'delete',
        {'transactionId': transactionId},
      );

  /// Sets one status on a page of owned transactions.
  ///
  /// `reconciled` is rejected here; clearing a reconciled row unlocks it.
  _ida.Future<int> setStatus(
    List<_isc.UuidValue> transactionIds,
    _itmjglt7.TransactionStatus status,
  ) => caller.callServerEndpoint<int>(
    'transaction',
    'setStatus',
    {
      'transactionIds': transactionIds,
      'status': status,
    },
  );

  /// Sets or clears one flag on a page of owned transactions.
  _ida.Future<int> setFlag(
    List<_isc.UuidValue> transactionIds,
    _idwby6z8.TransactionFlag? flag,
  ) => caller.callServerEndpoint<int>(
    'transaction',
    'setFlag',
    {
      'transactionIds': transactionIds,
      'flag': flag,
    },
  );

  /// Creates both legs of a transfer and their link.
  _ida.Future<List<_irfj6dpt.TransactionView>> createTransfer(
    _i4fjyt55.TransferInput input,
  ) => caller.callServerEndpoint<List<_irfj6dpt.TransactionView>>(
    'transaction',
    'createTransfer',
    {'input': input},
  );

  /// Replaces both legs of an existing transfer.
  _ida.Future<List<_irfj6dpt.TransactionView>> updateTransfer(
    _isc.UuidValue transferId,
    _i4fjyt55.TransferInput input,
  ) => caller.callServerEndpoint<List<_irfj6dpt.TransactionView>>(
    'transaction',
    'updateTransfer',
    {
      'transferId': transferId,
      'input': input,
    },
  );

  /// Reconciles one owned transactions account against a statement balance.
  _ida.Future<_idhtlbwy.ReconcileResult> reconcile(
    _isc.UuidValue accountId,
    DateTime statementDate,
    int statementBalanceMinor,
    bool createAdjustment,
  ) => caller.callServerEndpoint<_idhtlbwy.ReconcileResult>(
    'transaction',
    'reconcile',
    {
      'accountId': accountId,
      'statementDate': statementDate,
      'statementBalanceMinor': statementBalanceMinor,
      'createAdjustment': createAdjustment,
    },
  );

  /// Imports rows into one owned transactions account idempotently.
  ///
  /// `externalId` dedupes the file, so retrying the same rows inserts only
  /// the new ones. Row-level validation failures come back with their
  /// 0-based index in [ImportResult.errors].
  _ida.Future<_ish80d3o.ImportResult> importRows(
    _isc.UuidValue accountId,
    List<_iyud7cy9.ImportRow> rows,
  ) => caller.callServerEndpoint<_ish80d3o.ImportResult>(
    'transaction',
    'importRows',
    {
      'accountId': accountId,
      'rows': rows,
    },
  );

  /// Finds same-account, same-amount transactions within three days.
  _ida.Future<List<_irfj6dpt.TransactionView>> findDuplicates(
    _isc.UuidValue accountId,
    DateTime date,
    int amountMinor,
  ) => caller.callServerEndpoint<List<_irfj6dpt.TransactionView>>(
    'transaction',
    'findDuplicates',
    {
      'accountId': accountId,
      'date': date,
      'amountMinor': amountMinor,
    },
  );
}

/// API surface for read-only blockchain wallets.
///
/// Every method requires a signed-in caller and lets [WalletService] cross
/// [EntityAccess] before touching a wallet, account or transaction.
/// {@category Endpoint}
class EndpointWallet extends _isc.EndpointRef {
  EndpointWallet(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'wallet';

  /// Creates the wallet and its crypto account in one transaction, then syncs.
  _ida.Future<_igzh8mor.Wallet> connect(
    _isc.UuidValue entityId,
    _ifz8weqz.WalletNetwork network,
    String address, {
    String? label,
    String? accountName,
  }) => caller.callServerEndpoint<_igzh8mor.Wallet>(
    'wallet',
    'connect',
    {
      'entityId': entityId,
      'network': network,
      'address': address,
      'label': label,
      'accountName': accountName,
    },
  );

  /// Lists the wallets of one owned entity.
  _ida.Future<List<_igzh8mor.Wallet>> list(_isc.UuidValue entityId) =>
      caller.callServerEndpoint<List<_igzh8mor.Wallet>>(
        'wallet',
        'list',
        {'entityId': entityId},
      );

  /// Loads the wallet that values one owned account, if any.
  _ida.Future<_igzh8mor.Wallet?> getForAccount(_isc.UuidValue accountId) =>
      caller.callServerEndpoint<_igzh8mor.Wallet?>(
        'wallet',
        'getForAccount',
        {'accountId': accountId},
      );

  /// Fetches the chain and commits holdings, transactions and the valuation.
  _ida.Future<_idhyojww.WalletSyncResult> sync(_isc.UuidValue walletId) =>
      caller.callServerEndpoint<_idhyojww.WalletSyncResult>(
        'wallet',
        'sync',
        {'walletId': walletId},
      );

  /// Lists the wallet's persisted holdings.
  _ida.Future<List<_izm3e498.WalletHolding>> listHoldings(
    _isc.UuidValue walletId,
  ) => caller.callServerEndpoint<List<_izm3e498.WalletHolding>>(
    'wallet',
    'listHoldings',
    {'walletId': walletId},
  );

  /// Lists the wallet's transactions, newest first.
  _ida.Future<List<_itxp58mr.WalletTransaction>> listTransactions(
    _isc.UuidValue walletId, {
    DateTime? before,
    int? limit,
  }) => caller.callServerEndpoint<List<_itxp58mr.WalletTransaction>>(
    'wallet',
    'listTransactions',
    {
      'walletId': walletId,
      'before': before,
      'limit': limit,
    },
  );

  /// Groups estimated realised P&L by fiscal year and currency.
  _ida.Future<List<_il62txu0.WalletTaxYearSummary>> listTaxYearSummaries(
    _isc.UuidValue walletId,
  ) => caller.callServerEndpoint<List<_il62txu0.WalletTaxYearSummary>>(
    'wallet',
    'listTaxYearSummaries',
    {'walletId': walletId},
  );

  /// Replaces category, tags and memo on one wallet transaction.
  _ida.Future<_itxp58mr.WalletTransaction> updateTransactionMetadata(
    _isc.UuidValue walletTransactionId, {
    String? category,
    List<String>? tags,
    String? memo,
  }) => caller.callServerEndpoint<_itxp58mr.WalletTransaction>(
    'wallet',
    'updateTransactionMetadata',
    {
      'walletTransactionId': walletTransactionId,
      'category': category,
      'tags': tags,
      'memo': memo,
    },
  );

  /// Deletes the wallet; deleteAccount also deletes the crypto account and its
  /// protections apply.
  _ida.Future<void> disconnect(
    _isc.UuidValue walletId, {
    bool? deleteAccount,
  }) => caller.callServerEndpoint<void>(
    'wallet',
    'disconnect',
    {
      'walletId': walletId,
      'deleteAccount': deleteAccount,
    },
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    account = EndpointAccount(this);
    agent = EndpointAgent(this);
    agentToken = EndpointAgentToken(this);
    appleIdp = EndpointAppleIdp(this);
    emailIdp = EndpointEmailIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    billing = EndpointBilling(this);
    budget = EndpointBudget(this);
    category = EndpointCategory(this);
    entity = EndpointEntity(this);
    entityStream = EndpointEntityStream(this);
    envelopeGoal = EndpointEnvelopeGoal(this);
    envelope = EndpointEnvelope(this);
    fxRate = EndpointFxRate(this);
    institution = EndpointInstitution(this);
    ledger = EndpointLedger(this);
    payee = EndpointPayee(this);
    plaid = EndpointPlaid(this);
    recurringTransaction = EndpointRecurringTransaction(this);
    report = EndpointReport(this);
    settings = EndpointSettings(this);
    tax = EndpointTax(this);
    transactionRule = EndpointTransactionRule(this);
    transaction = EndpointTransaction(this);
    wallet = EndpointWallet(this);
    modules = Modules(this);
  }

  late final EndpointAccount account;

  late final EndpointAgent agent;

  late final EndpointAgentToken agentToken;

  late final EndpointAppleIdp appleIdp;

  late final EndpointEmailIdp emailIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointBilling billing;

  late final EndpointBudget budget;

  late final EndpointCategory category;

  late final EndpointEntity entity;

  late final EndpointEntityStream entityStream;

  late final EndpointEnvelopeGoal envelopeGoal;

  late final EndpointEnvelope envelope;

  late final EndpointFxRate fxRate;

  late final EndpointInstitution institution;

  late final EndpointLedger ledger;

  late final EndpointPayee payee;

  late final EndpointPlaid plaid;

  late final EndpointRecurringTransaction recurringTransaction;

  late final EndpointReport report;

  late final EndpointSettings settings;

  late final EndpointTax tax;

  late final EndpointTransactionRule transactionRule;

  late final EndpointTransaction transaction;

  late final EndpointWallet wallet;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'account': account,
    'agent': agent,
    'agentToken': agentToken,
    'appleIdp': appleIdp,
    'emailIdp': emailIdp,
    'googleIdp': googleIdp,
    'jwtRefresh': jwtRefresh,
    'billing': billing,
    'budget': budget,
    'category': category,
    'entity': entity,
    'entityStream': entityStream,
    'envelopeGoal': envelopeGoal,
    'envelope': envelope,
    'fxRate': fxRate,
    'institution': institution,
    'ledger': ledger,
    'payee': payee,
    'plaid': plaid,
    'recurringTransaction': recurringTransaction,
    'report': report,
    'settings': settings,
    'tax': tax,
    'transactionRule': transactionRule,
    'transaction': transaction,
    'wallet': wallet,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
