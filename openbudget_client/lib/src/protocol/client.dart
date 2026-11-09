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
import 'package:openbudget_client/src/protocol/billing/entitlement.dart'
    as _iyhncv6f;
import 'package:openbudget_client/src/protocol/billing/solana_plan_view.dart'
    as _ij0nbz0v;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal.dart'
    as _ibdhi9gv;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart'
    as _i29jf3by;
import 'package:openbudget_client/src/protocol/fx_rates/fx_latest_snapshot.dart'
    as _it7vndki;
import 'package:openbudget_client/src/protocol/institutions/institution.dart'
    as _i6ysl1a4;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import 'protocol.dart' as _il2as5qe;

/// The financial assistant: chat, its history, its proposals and the user's
/// own provider settings.
///
/// Every method requires a signed-in user and checks that the budget, chat or
/// proposal belongs to them. The assistant never changes financial data; it
/// creates proposals that `applyProposal` carries out on the user's behalf.
/// {@category Endpoint}
class EndpointAgent extends _isc.EndpointRef {
  EndpointAgent(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'agent';

  /// Streams one assistant turn in budget `budgetId`.
  ///
  /// A null [conversationId] starts a conversation titled from [message].
  /// Events are `usage` after each model call, `toolCall` before a tool runs,
  /// `proposal` for each change suggested, one `textDelta` with the reply, and
  /// a final `done`.
  _ida.Stream<_isrqm714.AgentEvent> chat(
    _isc.UuidValue budgetId,
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
          'budgetId': budgetId,
          'conversationId': conversationId,
          'message': message,
        },
        {},
      );

  /// Lists the user's conversations in one budget, newest first.
  _ida.Future<List<_in44ixo7.AgentConversation>> listConversations(
    _isc.UuidValue budgetId,
  ) => caller.callServerEndpoint<List<_in44ixo7.AgentConversation>>(
    'agent',
    'listConversations',
    {'budgetId': budgetId},
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

  /// Lists the changes the assistant proposed for one budget.
  _ida.Future<List<_icv7zzda.AgentProposal>> listProposals(
    _isc.UuidValue budgetId, {
    required bool pendingOnly,
  }) => caller.callServerEndpoint<List<_icv7zzda.AgentProposal>>(
    'agent',
    'listProposals',
    {
      'budgetId': budgetId,
      'pendingOnly': pendingOnly,
    },
  );

  /// Applies a pending proposal through the normal budget and tax services.
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

/// API surface for envelope goal operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointEnvelopeGoal extends _isc.EndpointRef {
  EndpointEnvelopeGoal(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'envelopeGoal';

  /// Creates or updates a goal for an envelope.
  _ida.Future<_ibdhi9gv.EnvelopeGoal> upsert(
    _isc.UuidValue envelopeId,
    String goalType,
    int targetAmountCents, {
    DateTime? targetDate,
    int? monthlyFundingCents,
  }) => caller.callServerEndpoint<_ibdhi9gv.EnvelopeGoal>(
    'envelopeGoal',
    'upsert',
    {
      'envelopeId': envelopeId,
      'goalType': goalType,
      'targetAmountCents': targetAmountCents,
      'targetDate': targetDate,
      'monthlyFundingCents': monthlyFundingCents,
    },
  );

  /// Gets the goal for an envelope.
  _ida.Future<_ibdhi9gv.EnvelopeGoal?> getForEnvelope(
    _isc.UuidValue envelopeId,
  ) => caller.callServerEndpoint<_ibdhi9gv.EnvelopeGoal?>(
    'envelopeGoal',
    'getForEnvelope',
    {'envelopeId': envelopeId},
  );

  /// Lists all goals for a set of envelope IDs.
  _ida.Future<List<_ibdhi9gv.EnvelopeGoal>> listForEnvelopes(
    List<_isc.UuidValue> envelopeIds,
  ) => caller.callServerEndpoint<List<_ibdhi9gv.EnvelopeGoal>>(
    'envelopeGoal',
    'listForEnvelopes',
    {'envelopeIds': envelopeIds},
  );

  /// Deletes a goal by ID.
  _ida.Future<_ibdhi9gv.EnvelopeGoal> delete(_isc.UuidValue goalId) =>
      caller.callServerEndpoint<_ibdhi9gv.EnvelopeGoal>(
        'envelopeGoal',
        'delete',
        {'goalId': goalId},
      );
}

/// API surface for envelope operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointEnvelope extends _isc.EndpointRef {
  EndpointEnvelope(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'envelope';

  /// Creates a new envelope within a category.
  _ida.Future<_i29jf3by.Envelope> create(
    String name,
    _isc.UuidValue categoryId,
    int budgetedAmountCents,
    String currencyCode,
  ) => caller.callServerEndpoint<_i29jf3by.Envelope>(
    'envelope',
    'create',
    {
      'name': name,
      'categoryId': categoryId,
      'budgetedAmountCents': budgetedAmountCents,
      'currencyCode': currencyCode,
    },
  );

  /// Lists all envelopes for a category.
  _ida.Future<List<_i29jf3by.Envelope>> list(_isc.UuidValue categoryId) =>
      caller.callServerEndpoint<List<_i29jf3by.Envelope>>(
        'envelope',
        'list',
        {'categoryId': categoryId},
      );

  /// Gets a single envelope by ID.
  _ida.Future<_i29jf3by.Envelope> get(_isc.UuidValue envelopeId) =>
      caller.callServerEndpoint<_i29jf3by.Envelope>(
        'envelope',
        'get',
        {'envelopeId': envelopeId},
      );

  /// Updates an envelope by ID.
  _ida.Future<_i29jf3by.Envelope> update(
    _isc.UuidValue envelopeId, {
    String? name,
    int? budgetedAmountCents,
    int? spentAmountCents,
    String? note,
    bool? isHidden,
  }) => caller.callServerEndpoint<_i29jf3by.Envelope>(
    'envelope',
    'update',
    {
      'envelopeId': envelopeId,
      'name': name,
      'budgetedAmountCents': budgetedAmountCents,
      'spentAmountCents': spentAmountCents,
      'note': note,
      'isHidden': isHidden,
    },
  );

  /// Reorders envelopes within a category.
  _ida.Future<List<_i29jf3by.Envelope>> reorder(
    _isc.UuidValue categoryId,
    List<String> envelopeIds,
  ) => caller.callServerEndpoint<List<_i29jf3by.Envelope>>(
    'envelope',
    'reorder',
    {
      'categoryId': categoryId,
      'envelopeIds': envelopeIds,
    },
  );

  /// Deletes an envelope by ID.
  _ida.Future<_i29jf3by.Envelope> delete(_isc.UuidValue envelopeId) =>
      caller.callServerEndpoint<_i29jf3by.Envelope>(
        'envelope',
        'delete',
        {'envelopeId': envelopeId},
      );
}

/// API surface for exchange rates used by display-currency conversion.
/// {@category Endpoint}
class EndpointFxRate extends _isc.EndpointRef {
  EndpointFxRate(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'fxRate';

  /// Returns the latest FX snapshot persisted by the backend.
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

/// API surface for Plaid-linked account integration.
/// {@category Endpoint}
class EndpointPlaid extends _isc.EndpointRef {
  EndpointPlaid(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'plaid';

  /// Creates a short-lived link token for starting Plaid Link in the client.
  _ida.Future<String> createLinkToken(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<String>(
        'plaid',
        'createLinkToken',
        {'budgetId': budgetId},
      );

  /// Exchanges a public token and imports linked bank accounts into OpenBudget.
  _ida.Future<List<_iqudaadl.Account>> exchangePublicToken(
    _isc.UuidValue budgetId,
    String publicToken,
  ) => caller.callServerEndpoint<List<_iqudaadl.Account>>(
    'plaid',
    'exchangePublicToken',
    {
      'budgetId': budgetId,
      'publicToken': publicToken,
    },
  );

  /// Refreshes an existing Plaid item connection and updates imported accounts.
  _ida.Future<List<_iqudaadl.Account>> syncConnection(
    _isc.UuidValue budgetId,
    _isc.UuidValue connectionId,
  ) => caller.callServerEndpoint<List<_iqudaadl.Account>>(
    'plaid',
    'syncConnection',
    {
      'budgetId': budgetId,
      'connectionId': connectionId,
    },
  );

  /// Creates a Plaid sandbox item and imports accounts without client-side Link.
  _ida.Future<List<_iqudaadl.Account>> importSandboxAccounts(
    _isc.UuidValue budgetId, {
    String? plaidInstitutionId,
  }) => caller.callServerEndpoint<List<_iqudaadl.Account>>(
    'plaid',
    'importSandboxAccounts',
    {
      'budgetId': budgetId,
      'plaidInstitutionId': plaidInstitutionId,
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
    agent = EndpointAgent(this);
    agentToken = EndpointAgentToken(this);
    appleIdp = EndpointAppleIdp(this);
    emailIdp = EndpointEmailIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    billing = EndpointBilling(this);
    envelopeGoal = EndpointEnvelopeGoal(this);
    envelope = EndpointEnvelope(this);
    fxRate = EndpointFxRate(this);
    institution = EndpointInstitution(this);
    plaid = EndpointPlaid(this);
    modules = Modules(this);
  }

  late final EndpointAgent agent;

  late final EndpointAgentToken agentToken;

  late final EndpointAppleIdp appleIdp;

  late final EndpointEmailIdp emailIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointBilling billing;

  late final EndpointEnvelopeGoal envelopeGoal;

  late final EndpointEnvelope envelope;

  late final EndpointFxRate fxRate;

  late final EndpointInstitution institution;

  late final EndpointPlaid plaid;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'agent': agent,
    'agentToken': agentToken,
    'appleIdp': appleIdp,
    'emailIdp': emailIdp,
    'googleIdp': googleIdp,
    'jwtRefresh': jwtRefresh,
    'billing': billing,
    'envelopeGoal': envelopeGoal,
    'envelope': envelope,
    'fxRate': fxRate,
    'institution': institution,
    'plaid': plaid,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
