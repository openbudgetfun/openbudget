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
import 'package:openbudget_client/src/protocol/billing/entitlement.dart'
    as _iyhncv6f;
import 'package:openbudget_client/src/protocol/billing/solana_plan_view.dart'
    as _ij0nbz0v;
import 'package:openbudget_client/src/protocol/budget_templates/budget_template.dart'
    as _itiojbb0;
import 'package:openbudget_client/src/protocol/budgets/budget.dart'
    as _iro9sz2e;
import 'package:openbudget_client/src/protocol/categories/category.dart'
    as _iels1fku;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal.dart'
    as _ibdhi9gv;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart'
    as _i29jf3by;
import 'package:openbudget_client/src/protocol/fx_rates/fx_latest_snapshot.dart'
    as _it7vndki;
import 'package:openbudget_client/src/protocol/institutions/institution.dart'
    as _i6ysl1a4;
import 'package:openbudget_client/src/protocol/monthly_allocations/monthly_allocation.dart'
    as _iz3b7rge;
import 'package:openbudget_client/src/protocol/payees/payee.dart' as _iaf6ifsb;
import 'package:openbudget_client/src/protocol/recurring_transactions/recurring_transaction.dart'
    as _i41tn6nr;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet.dart'
    as _i1b8tal0;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_holding.dart'
    as _i7zpyr5z;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_sync_result.dart'
    as _ip6egngy;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_tax_year_summary.dart'
    as _igj51lwa;
import 'package:openbudget_client/src/protocol/solana_wallets/solana_wallet_transaction.dart'
    as _isudwq84;
import 'package:openbudget_client/src/protocol/tax/tax_category_view.dart'
    as _ic177lol;
import 'package:openbudget_client/src/protocol/tax/tax_profile.dart'
    as _ibyrfq34;
import 'package:openbudget_client/src/protocol/tax/tax_report_view.dart'
    as _ieaa4q0n;
import 'package:openbudget_client/src/protocol/transaction_rules/transaction_rule.dart'
    as _iwxd5v0a;
import 'package:openbudget_client/src/protocol/transactions/import_row.dart'
    as _iyud7cy9;
import 'package:openbudget_client/src/protocol/transactions/split_item.dart'
    as _ilmjmphd;
import 'package:openbudget_client/src/protocol/transactions/transaction.dart'
    as _iio3v7fv;
import 'package:openbudget_client/src/protocol/wallets/wallet_connect_result.dart'
    as _iol2ym9i;
import 'package:openbudget_client/src/protocol/wallets/wallet_holding.dart'
    as _izm3e498;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import 'protocol.dart' as _il2as5qe;

/// API surface for account operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointAccount extends _isc.EndpointRef {
  EndpointAccount(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'account';

  /// Creates a new account within a budget.
  _ida.Future<_iqudaadl.Account> create(
    String name,
    String accountType,
    int balanceCents,
    String currencyCode,
    _isc.UuidValue budgetId, {
    required bool onBudget,
    required int sortOrder,
    _isc.UuidValue? institutionId,
  }) => caller.callServerEndpoint<_iqudaadl.Account>(
    'account',
    'create',
    {
      'name': name,
      'accountType': accountType,
      'balanceCents': balanceCents,
      'currencyCode': currencyCode,
      'budgetId': budgetId,
      'onBudget': onBudget,
      'sortOrder': sortOrder,
      'institutionId': institutionId,
    },
  );

  /// Lists all accounts for a budget.
  _ida.Future<List<_iqudaadl.Account>> list(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_iqudaadl.Account>>(
        'account',
        'list',
        {'budgetId': budgetId},
      );

  /// Lists creator-owned reusable accounts that can be added to another budget.
  _ida.Future<List<_iqudaadl.Account>> listMine({
    _isc.UuidValue? excludeBudgetId,
  }) => caller.callServerEndpoint<List<_iqudaadl.Account>>(
    'account',
    'listMine',
    {'excludeBudgetId': excludeBudgetId},
  );

  /// Adds one of the creator's existing accounts to another owned budget.
  _ida.Future<_iqudaadl.Account> addMineToBudget(
    _isc.UuidValue sourceAccountId,
    _isc.UuidValue budgetId,
  ) => caller.callServerEndpoint<_iqudaadl.Account>(
    'account',
    'addMineToBudget',
    {
      'sourceAccountId': sourceAccountId,
      'budgetId': budgetId,
    },
  );

  /// Gets a single account by ID.
  _ida.Future<_iqudaadl.Account> get(_isc.UuidValue accountId) =>
      caller.callServerEndpoint<_iqudaadl.Account>(
        'account',
        'get',
        {'accountId': accountId},
      );

  /// Updates an account by ID.
  _ida.Future<_iqudaadl.Account> update(
    _isc.UuidValue accountId, {
    String? name,
    String? accountType,
    int? balanceCents,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
  }) => caller.callServerEndpoint<_iqudaadl.Account>(
    'account',
    'update',
    {
      'accountId': accountId,
      'name': name,
      'accountType': accountType,
      'balanceCents': balanceCents,
      'onBudget': onBudget,
      'sortOrder': sortOrder,
      'isClosed': isClosed,
    },
  );

  /// Deletes an account by ID.
  _ida.Future<_iqudaadl.Account> delete(_isc.UuidValue accountId) =>
      caller.callServerEndpoint<_iqudaadl.Account>(
        'account',
        'delete',
        {'accountId': accountId},
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

/// API surface for budget template operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointBudgetTemplate extends _isc.EndpointRef {
  EndpointBudgetTemplate(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'budgetTemplate';

  /// Saves a new template from the allocations of a given month.
  _ida.Future<_itiojbb0.BudgetTemplate> saveFromMonth(
    _isc.UuidValue budgetId,
    String name,
    int year,
    int month,
  ) => caller.callServerEndpoint<_itiojbb0.BudgetTemplate>(
    'budgetTemplate',
    'saveFromMonth',
    {
      'budgetId': budgetId,
      'name': name,
      'year': year,
      'month': month,
    },
  );

  /// Lists all templates for a budget.
  _ida.Future<List<_itiojbb0.BudgetTemplate>> list(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_itiojbb0.BudgetTemplate>>(
        'budgetTemplate',
        'list',
        {'budgetId': budgetId},
      );

  /// Applies a template to a target month.
  _ida.Future<List<_iz3b7rge.MonthlyAllocation>> applyToMonth(
    _isc.UuidValue templateId,
    _isc.UuidValue budgetId,
    int year,
    int month,
  ) => caller.callServerEndpoint<List<_iz3b7rge.MonthlyAllocation>>(
    'budgetTemplate',
    'applyToMonth',
    {
      'templateId': templateId,
      'budgetId': budgetId,
      'year': year,
      'month': month,
    },
  );

  /// Deletes a template by ID.
  _ida.Future<_itiojbb0.BudgetTemplate> delete(_isc.UuidValue templateId) =>
      caller.callServerEndpoint<_itiojbb0.BudgetTemplate>(
        'budgetTemplate',
        'delete',
        {'templateId': templateId},
      );
}

/// API surface for budget operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointBudget extends _isc.EndpointRef {
  EndpointBudget(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'budget';

  /// Creates a new budget for the authenticated user.
  _ida.Future<_iro9sz2e.Budget> create(
    String name,
    String currencyCode,
  ) => caller.callServerEndpoint<_iro9sz2e.Budget>(
    'budget',
    'create',
    {
      'name': name,
      'currencyCode': currencyCode,
    },
  );

  /// Lists all budgets for the authenticated user.
  _ida.Future<List<_iro9sz2e.Budget>> list() =>
      caller.callServerEndpoint<List<_iro9sz2e.Budget>>(
        'budget',
        'list',
        {},
      );

  /// Gets a single budget by ID, verifying ownership.
  _ida.Future<_iro9sz2e.Budget> get(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<_iro9sz2e.Budget>(
        'budget',
        'get',
        {'budgetId': budgetId},
      );

  /// Updates a budget by ID, verifying ownership.
  _ida.Future<_iro9sz2e.Budget> update(
    _isc.UuidValue budgetId, {
    String? name,
    String? currencyCode,
    String? displayCurrencyCode,
    bool? clearDisplayCurrencyCode,
  }) => caller.callServerEndpoint<_iro9sz2e.Budget>(
    'budget',
    'update',
    {
      'budgetId': budgetId,
      'name': name,
      'currencyCode': currencyCode,
      'displayCurrencyCode': displayCurrencyCode,
      'clearDisplayCurrencyCode': clearDisplayCurrencyCode,
    },
  );

  /// Deletes a budget by ID, verifying ownership.
  _ida.Future<_iro9sz2e.Budget> delete(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<_iro9sz2e.Budget>(
        'budget',
        'delete',
        {'budgetId': budgetId},
      );

  /// Exports all budget data as a JSON string for data portability.
  _ida.Future<String> exportData(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<String>(
        'budget',
        'exportData',
        {'budgetId': budgetId},
      );
}

/// Streaming endpoint for real-time budget updates.
///
/// Client sends a budget ID once, server streams live budget snapshots.
/// {@category Endpoint}
class EndpointBudgetStream extends _isc.EndpointRef {
  EndpointBudgetStream(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'budgetStream';

  /// Streams budget updates to the connected client.
  ///
  /// Client sends a [UuidValue] budget ID. The stream yields an initial
  /// [Budget] snapshot and then emits fresh snapshots whenever that budget
  /// changes.
  _ida.Stream<_iro9sz2e.Budget> budgetUpdates(
    _ida.Stream<_isc.UuidValue> budgetIdStream,
  ) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_iro9sz2e.Budget>,
        _iro9sz2e.Budget
      >(
        'budgetStream',
        'budgetUpdates',
        {},
        {'budgetIdStream': budgetIdStream},
      );
}

/// API surface for category operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointCategory extends _isc.EndpointRef {
  EndpointCategory(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'category';

  /// Creates a new category within a budget.
  _ida.Future<_iels1fku.Category> create(
    String name,
    _isc.UuidValue budgetId,
    int sortOrder,
  ) => caller.callServerEndpoint<_iels1fku.Category>(
    'category',
    'create',
    {
      'name': name,
      'budgetId': budgetId,
      'sortOrder': sortOrder,
    },
  );

  /// Lists all categories for a budget.
  _ida.Future<List<_iels1fku.Category>> list(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_iels1fku.Category>>(
        'category',
        'list',
        {'budgetId': budgetId},
      );

  /// Gets a single category by ID.
  _ida.Future<_iels1fku.Category> get(_isc.UuidValue categoryId) =>
      caller.callServerEndpoint<_iels1fku.Category>(
        'category',
        'get',
        {'categoryId': categoryId},
      );

  /// Updates a category by ID.
  _ida.Future<_iels1fku.Category> update(
    _isc.UuidValue categoryId, {
    String? name,
    int? sortOrder,
    bool? isHidden,
  }) => caller.callServerEndpoint<_iels1fku.Category>(
    'category',
    'update',
    {
      'categoryId': categoryId,
      'name': name,
      'sortOrder': sortOrder,
      'isHidden': isHidden,
    },
  );

  /// Batch-reorders categories by their new position.
  ///
  /// The [categoryIds] list defines the new sort order: the first ID gets
  /// sort order 0, the second gets 1, etc.
  _ida.Future<List<_iels1fku.Category>> reorder(
    _isc.UuidValue budgetId,
    List<_isc.UuidValue> categoryIds,
  ) => caller.callServerEndpoint<List<_iels1fku.Category>>(
    'category',
    'reorder',
    {
      'budgetId': budgetId,
      'categoryIds': categoryIds,
    },
  );

  /// Deletes a category by ID.
  _ida.Future<_iels1fku.Category> delete(_isc.UuidValue categoryId) =>
      caller.callServerEndpoint<_iels1fku.Category>(
        'category',
        'delete',
        {'categoryId': categoryId},
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

/// API surface for monthly allocation operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointMonthlyAllocation extends _isc.EndpointRef {
  EndpointMonthlyAllocation(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'monthlyAllocation';

  /// Creates or updates an allocation for an envelope in a given month.
  _ida.Future<_iz3b7rge.MonthlyAllocation> upsert(
    _isc.UuidValue envelopeId,
    _isc.UuidValue budgetId,
    int year,
    int month,
    int allocatedCents, {
    required int carryoverCents,
  }) => caller.callServerEndpoint<_iz3b7rge.MonthlyAllocation>(
    'monthlyAllocation',
    'upsert',
    {
      'envelopeId': envelopeId,
      'budgetId': budgetId,
      'year': year,
      'month': month,
      'allocatedCents': allocatedCents,
      'carryoverCents': carryoverCents,
    },
  );

  /// Lists all allocations for a budget in a given month.
  _ida.Future<List<_iz3b7rge.MonthlyAllocation>> list(
    _isc.UuidValue budgetId,
    int year,
    int month,
  ) => caller.callServerEndpoint<List<_iz3b7rge.MonthlyAllocation>>(
    'monthlyAllocation',
    'list',
    {
      'budgetId': budgetId,
      'year': year,
      'month': month,
    },
  );

  /// Copies all allocations from a source month to a target month.
  _ida.Future<List<_iz3b7rge.MonthlyAllocation>> copyMonth(
    _isc.UuidValue budgetId,
    int sourceYear,
    int sourceMonth,
    int targetYear,
    int targetMonth,
  ) => caller.callServerEndpoint<List<_iz3b7rge.MonthlyAllocation>>(
    'monthlyAllocation',
    'copyMonth',
    {
      'budgetId': budgetId,
      'sourceYear': sourceYear,
      'sourceMonth': sourceMonth,
      'targetYear': targetYear,
      'targetMonth': targetMonth,
    },
  );

  /// Moves money between two envelopes in the same budget and month.
  _ida.Future<List<_iz3b7rge.MonthlyAllocation>> moveMoney(
    _isc.UuidValue fromEnvelopeId,
    _isc.UuidValue toEnvelopeId,
    _isc.UuidValue budgetId,
    int year,
    int month,
    int amountCents,
  ) => caller.callServerEndpoint<List<_iz3b7rge.MonthlyAllocation>>(
    'monthlyAllocation',
    'moveMoney',
    {
      'fromEnvelopeId': fromEnvelopeId,
      'toEnvelopeId': toEnvelopeId,
      'budgetId': budgetId,
      'year': year,
      'month': month,
      'amountCents': amountCents,
    },
  );

  /// Deletes a monthly allocation by ID.
  _ida.Future<_iz3b7rge.MonthlyAllocation> delete(
    _isc.UuidValue allocationId,
  ) => caller.callServerEndpoint<_iz3b7rge.MonthlyAllocation>(
    'monthlyAllocation',
    'delete',
    {'allocationId': allocationId},
  );
}

/// API surface for payee operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointPayee extends _isc.EndpointRef {
  EndpointPayee(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'payee';

  /// Creates a new payee within a budget.
  _ida.Future<_iaf6ifsb.Payee> create(
    String name,
    _isc.UuidValue budgetId,
  ) => caller.callServerEndpoint<_iaf6ifsb.Payee>(
    'payee',
    'create',
    {
      'name': name,
      'budgetId': budgetId,
    },
  );

  /// Lists all payees for a budget.
  _ida.Future<List<_iaf6ifsb.Payee>> list(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_iaf6ifsb.Payee>>(
        'payee',
        'list',
        {'budgetId': budgetId},
      );

  /// Gets a single payee by ID.
  _ida.Future<_iaf6ifsb.Payee> get(_isc.UuidValue payeeId) =>
      caller.callServerEndpoint<_iaf6ifsb.Payee>(
        'payee',
        'get',
        {'payeeId': payeeId},
      );

  /// Updates a payee by ID.
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

  /// Returns the envelope ID from the most recent transaction for a payee.
  _ida.Future<_isc.UuidValue?> lastUsedEnvelopeId(
    _isc.UuidValue payeeId,
    _isc.UuidValue budgetId,
  ) => caller.callServerEndpoint<_isc.UuidValue?>(
    'payee',
    'lastUsedEnvelopeId',
    {
      'payeeId': payeeId,
      'budgetId': budgetId,
    },
  );

  /// Merges the source payee into the target payee.
  ///
  /// All transactions and rules from the source are reassigned to the target.
  /// The source payee is deleted after merging.
  /// Returns the number of transactions reassigned.
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

  /// Deletes a payee by ID.
  _ida.Future<_iaf6ifsb.Payee> delete(_isc.UuidValue payeeId) =>
      caller.callServerEndpoint<_iaf6ifsb.Payee>(
        'payee',
        'delete',
        {'payeeId': payeeId},
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

/// API surface for recurring transaction operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointRecurringTransaction extends _isc.EndpointRef {
  EndpointRecurringTransaction(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'recurringTransaction';

  /// Creates a new recurring transaction.
  _ida.Future<_i41tn6nr.RecurringTransaction> create(
    String description,
    int amountCents,
    String currencyCode,
    _isc.UuidValue budgetId,
    String frequency,
    DateTime nextOccurrence, {
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? payeeId,
    DateTime? endDate,
  }) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'create',
    {
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      'budgetId': budgetId,
      'frequency': frequency,
      'nextOccurrence': nextOccurrence,
      'envelopeId': envelopeId,
      'accountId': accountId,
      'payeeId': payeeId,
      'endDate': endDate,
    },
  );

  /// Lists recurring transactions for a budget.
  _ida.Future<List<_i41tn6nr.RecurringTransaction>> list(
    _isc.UuidValue budgetId, {
    bool? activeOnly,
  }) => caller.callServerEndpoint<List<_i41tn6nr.RecurringTransaction>>(
    'recurringTransaction',
    'list',
    {
      'budgetId': budgetId,
      'activeOnly': activeOnly,
    },
  );

  /// Gets a recurring transaction by ID.
  _ida.Future<_i41tn6nr.RecurringTransaction> get(
    _isc.UuidValue recurringTransactionId,
  ) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'get',
    {'recurringTransactionId': recurringTransactionId},
  );

  /// Updates a recurring transaction.
  _ida.Future<_i41tn6nr.RecurringTransaction> update(
    _isc.UuidValue recurringTransactionId, {
    String? description,
    int? amountCents,
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? payeeId,
    String? frequency,
    DateTime? nextOccurrence,
    DateTime? endDate,
    bool? isActive,
  }) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'update',
    {
      'recurringTransactionId': recurringTransactionId,
      'description': description,
      'amountCents': amountCents,
      'envelopeId': envelopeId,
      'accountId': accountId,
      'payeeId': payeeId,
      'frequency': frequency,
      'nextOccurrence': nextOccurrence,
      'endDate': endDate,
      'isActive': isActive,
    },
  );

  /// Deletes a recurring transaction.
  _ida.Future<_i41tn6nr.RecurringTransaction> delete(
    _isc.UuidValue recurringTransactionId,
  ) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'delete',
    {'recurringTransactionId': recurringTransactionId},
  );

  /// Skips the next occurrence of a recurring transaction by advancing the
  /// schedule without creating a transaction.
  _ida.Future<_i41tn6nr.RecurringTransaction> skipOccurrence(
    _isc.UuidValue recurringTransactionId,
  ) => caller.callServerEndpoint<_i41tn6nr.RecurringTransaction>(
    'recurringTransaction',
    'skipOccurrence',
    {'recurringTransactionId': recurringTransactionId},
  );

  /// Posts all due recurring transactions for a budget, creating actual
  /// transactions and advancing the schedule. Returns the count of created
  /// transactions.
  _ida.Future<int> postDue(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<int>(
        'recurringTransaction',
        'postDue',
        {'budgetId': budgetId},
      );

  /// Returns the count of active recurring transactions that are currently due.
  _ida.Future<int> countDue(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<int>(
        'recurringTransaction',
        'countDue',
        {'budgetId': budgetId},
      );
}

/// API surface for Solana wallet operations.
/// {@category Endpoint}
class EndpointSolanaWallet extends _isc.EndpointRef {
  EndpointSolanaWallet(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'solanaWallet';

  /// Attaches (or updates) a Solana wallet to an account.
  _ida.Future<_i1b8tal0.SolanaWallet> attach(
    _isc.UuidValue budgetId,
    _isc.UuidValue accountId,
    String address, {
    String? label,
    required String cluster,
  }) => caller.callServerEndpoint<_i1b8tal0.SolanaWallet>(
    'solanaWallet',
    'attach',
    {
      'budgetId': budgetId,
      'accountId': accountId,
      'address': address,
      'label': label,
      'cluster': cluster,
    },
  );

  /// Returns all Solana wallets for a budget.
  _ida.Future<List<_i1b8tal0.SolanaWallet>> list(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_i1b8tal0.SolanaWallet>>(
        'solanaWallet',
        'list',
        {'budgetId': budgetId},
      );

  /// Returns wallet metadata for an account.
  _ida.Future<_i1b8tal0.SolanaWallet?> getForAccount(
    _isc.UuidValue budgetId,
    _isc.UuidValue accountId,
  ) => caller.callServerEndpoint<_i1b8tal0.SolanaWallet?>(
    'solanaWallet',
    'getForAccount',
    {
      'budgetId': budgetId,
      'accountId': accountId,
    },
  );

  /// Syncs recent chain activity and holdings for the wallet.
  _ida.Future<_ip6egngy.SolanaWalletSyncResult> sync(
    _isc.UuidValue budgetId,
    _isc.UuidValue walletId, {
    required int limit,
  }) => caller.callServerEndpoint<_ip6egngy.SolanaWalletSyncResult>(
    'solanaWallet',
    'sync',
    {
      'budgetId': budgetId,
      'walletId': walletId,
      'limit': limit,
    },
  );

  /// Lists parsed wallet transactions.
  _ida.Future<List<_isudwq84.SolanaWalletTransaction>> listTransactions(
    _isc.UuidValue budgetId,
    _isc.UuidValue walletId, {
    required int limit,
  }) => caller.callServerEndpoint<List<_isudwq84.SolanaWalletTransaction>>(
    'solanaWallet',
    'listTransactions',
    {
      'budgetId': budgetId,
      'walletId': walletId,
      'limit': limit,
    },
  );

  /// Lists current wallet holdings.
  _ida.Future<List<_i7zpyr5z.SolanaWalletHolding>> listHoldings(
    _isc.UuidValue budgetId,
    _isc.UuidValue walletId,
  ) => caller.callServerEndpoint<List<_i7zpyr5z.SolanaWalletHolding>>(
    'solanaWallet',
    'listHoldings',
    {
      'budgetId': budgetId,
      'walletId': walletId,
    },
  );

  /// Returns estimated realized wallet P&L grouped by tax year.
  _ida.Future<List<_igj51lwa.SolanaWalletTaxYearSummary>> listTaxYearSummaries(
    _isc.UuidValue budgetId,
    _isc.UuidValue walletId,
  ) => caller.callServerEndpoint<List<_igj51lwa.SolanaWalletTaxYearSummary>>(
    'solanaWallet',
    'listTaxYearSummaries',
    {
      'budgetId': budgetId,
      'walletId': walletId,
    },
  );

  /// Updates category/tags/memo for a wallet transaction.
  _ida.Future<_isudwq84.SolanaWalletTransaction> updateTransactionMetadata(
    _isc.UuidValue budgetId,
    _isc.UuidValue transactionId, {
    String? category,
    String? tagsCsv,
    String? memo,
  }) => caller.callServerEndpoint<_isudwq84.SolanaWalletTransaction>(
    'solanaWallet',
    'updateTransactionMetadata',
    {
      'budgetId': budgetId,
      'transactionId': transactionId,
      'category': category,
      'tagsCsv': tagsCsv,
      'memo': memo,
    },
  );
}

/// API surface for tax profiles, categorisation, and reports.
///
/// All methods require authentication and check budget ownership.
/// {@category Endpoint}
class EndpointTax extends _isc.EndpointRef {
  EndpointTax(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'tax';

  /// Returns the budget's tax profile, or null when none is set.
  _ida.Future<_ibyrfq34.TaxProfileRecord?> getProfile(
    _isc.UuidValue budgetId,
  ) => caller.callServerEndpoint<_ibyrfq34.TaxProfileRecord?>(
    'tax',
    'getProfile',
    {'budgetId': budgetId},
  );

  /// Creates or replaces the budget's tax profile.
  _ida.Future<_ibyrfq34.TaxProfileRecord> saveProfile(
    _isc.UuidValue budgetId,
    String jurisdiction,
    String entityKind,
    String profileJson, {
    _isc.UuidValue? linkedBudgetId,
  }) => caller.callServerEndpoint<_ibyrfq34.TaxProfileRecord>(
    'tax',
    'saveProfile',
    {
      'budgetId': budgetId,
      'jurisdiction': jurisdiction,
      'entityKind': entityKind,
      'profileJson': profileJson,
      'linkedBudgetId': linkedBudgetId,
    },
  );

  /// Lists the tax categories available to the budget's entity kind.
  _ida.Future<List<_ic177lol.TaxCategoryView>> listCategories(
    _isc.UuidValue budgetId,
  ) => caller.callServerEndpoint<List<_ic177lol.TaxCategoryView>>(
    'tax',
    'listCategories',
    {'budgetId': budgetId},
  );

  /// Sets or clears the default tax category on an envelope.
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

  /// Sets or clears a transaction's tax treatment.
  _ida.Future<_iio3v7fv.Transaction> setTransactionTax(
    _isc.UuidValue transactionId, {
    String? code,
    int? businessUsePercent,
    int? salesTaxCents,
  }) => caller.callServerEndpoint<_iio3v7fv.Transaction>(
    'tax',
    'setTransactionTax',
    {
      'transactionId': transactionId,
      'code': code,
      'businessUsePercent': businessUsePercent,
      'salesTaxCents': salesTaxCents,
    },
  );

  /// Computes the budget's tax report for the year starting in [startYear].
  ///
  /// When [startYear] is null the tax year containing today is used.
  _ida.Future<_ieaa4q0n.TaxReportView> getReport(
    _isc.UuidValue budgetId, {
    int? startYear,
  }) => caller.callServerEndpoint<_ieaa4q0n.TaxReportView>(
    'tax',
    'getReport',
    {
      'budgetId': budgetId,
      'startYear': startYear,
    },
  );
}

/// API surface for transaction rule operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointTransactionRule extends _isc.EndpointRef {
  EndpointTransactionRule(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'transactionRule';

  /// Creates a new transaction rule for a payee in a budget.
  _ida.Future<_iwxd5v0a.TransactionRule> create(
    _isc.UuidValue budgetId,
    _isc.UuidValue payeeId,
    _isc.UuidValue targetEnvelopeId,
  ) => caller.callServerEndpoint<_iwxd5v0a.TransactionRule>(
    'transactionRule',
    'create',
    {
      'budgetId': budgetId,
      'payeeId': payeeId,
      'targetEnvelopeId': targetEnvelopeId,
    },
  );

  /// Lists all transaction rules for a budget.
  _ida.Future<List<_iwxd5v0a.TransactionRule>> list(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_iwxd5v0a.TransactionRule>>(
        'transactionRule',
        'list',
        {'budgetId': budgetId},
      );

  /// Gets a single transaction rule by ID.
  _ida.Future<_iwxd5v0a.TransactionRule> get(_isc.UuidValue ruleId) =>
      caller.callServerEndpoint<_iwxd5v0a.TransactionRule>(
        'transactionRule',
        'get',
        {'ruleId': ruleId},
      );

  /// Updates a transaction rule.
  _ida.Future<_iwxd5v0a.TransactionRule> update(
    _isc.UuidValue ruleId, {
    _isc.UuidValue? targetEnvelopeId,
    bool? enabled,
  }) => caller.callServerEndpoint<_iwxd5v0a.TransactionRule>(
    'transactionRule',
    'update',
    {
      'ruleId': ruleId,
      'targetEnvelopeId': targetEnvelopeId,
      'enabled': enabled,
    },
  );

  /// Finds the matching envelope for a payee (used for client-side preview).
  _ida.Future<_isc.UuidValue?> findMatchingEnvelope(
    _isc.UuidValue budgetId,
    _isc.UuidValue payeeId,
  ) => caller.callServerEndpoint<_isc.UuidValue?>(
    'transactionRule',
    'findMatchingEnvelope',
    {
      'budgetId': budgetId,
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
/// All methods require authentication.
/// {@category Endpoint}
class EndpointTransaction extends _isc.EndpointRef {
  EndpointTransaction(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'transaction';

  /// Creates a new transaction within a budget.
  _ida.Future<_iio3v7fv.Transaction> create(
    String description,
    int amountCents,
    String currencyCode,
    _isc.UuidValue budgetId,
    DateTime transactionDate, {
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? payeeId,
    String? memo,
  }) => caller.callServerEndpoint<_iio3v7fv.Transaction>(
    'transaction',
    'create',
    {
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      'budgetId': budgetId,
      'transactionDate': transactionDate,
      'envelopeId': envelopeId,
      'payeeId': payeeId,
      'memo': memo,
    },
  );

  /// Lists all transactions for a budget.
  _ida.Future<List<_iio3v7fv.Transaction>> list(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_iio3v7fv.Transaction>>(
        'transaction',
        'list',
        {'budgetId': budgetId},
      );

  /// Lists transactions for a budget within a specific month.
  _ida.Future<List<_iio3v7fv.Transaction>> listByMonth(
    _isc.UuidValue budgetId,
    int year,
    int month,
  ) => caller.callServerEndpoint<List<_iio3v7fv.Transaction>>(
    'transaction',
    'listByMonth',
    {
      'budgetId': budgetId,
      'year': year,
      'month': month,
    },
  );

  /// Gets a single transaction by ID.
  _ida.Future<_iio3v7fv.Transaction> get(_isc.UuidValue transactionId) =>
      caller.callServerEndpoint<_iio3v7fv.Transaction>(
        'transaction',
        'get',
        {'transactionId': transactionId},
      );

  /// Updates a transaction by ID.
  _ida.Future<_iio3v7fv.Transaction> update(
    _isc.UuidValue transactionId, {
    String? description,
    int? amountCents,
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? payeeId,
    DateTime? transactionDate,
    String? memo,
    String? flagColor,
  }) => caller.callServerEndpoint<_iio3v7fv.Transaction>(
    'transaction',
    'update',
    {
      'transactionId': transactionId,
      'description': description,
      'amountCents': amountCents,
      'envelopeId': envelopeId,
      'payeeId': payeeId,
      'transactionDate': transactionDate,
      'memo': memo,
      'flagColor': flagColor,
    },
  );

  /// Sets or clears the flag color on a transaction.
  _ida.Future<_iio3v7fv.Transaction> setFlag(
    _isc.UuidValue transactionId, {
    String? flagColor,
  }) => caller.callServerEndpoint<_iio3v7fv.Transaction>(
    'transaction',
    'setFlag',
    {
      'transactionId': transactionId,
      'flagColor': flagColor,
    },
  );

  /// Creates a transfer between two accounts.
  _ida.Future<List<_iio3v7fv.Transaction>> transfer(
    String description,
    int amountCents,
    String currencyCode,
    _isc.UuidValue budgetId,
    _isc.UuidValue fromAccountId,
    _isc.UuidValue toAccountId,
    DateTime transactionDate,
  ) => caller.callServerEndpoint<List<_iio3v7fv.Transaction>>(
    'transaction',
    'transfer',
    {
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      'budgetId': budgetId,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'transactionDate': transactionDate,
    },
  );

  /// Lists transactions for a specific account.
  _ida.Future<List<_iio3v7fv.Transaction>> listByAccount(
    _isc.UuidValue accountId,
    _isc.UuidValue budgetId,
  ) => caller.callServerEndpoint<List<_iio3v7fv.Transaction>>(
    'transaction',
    'listByAccount',
    {
      'accountId': accountId,
      'budgetId': budgetId,
    },
  );

  /// Toggles the cleared status of a transaction.
  _ida.Future<_iio3v7fv.Transaction> toggleCleared(
    _isc.UuidValue transactionId,
  ) => caller.callServerEndpoint<_iio3v7fv.Transaction>(
    'transaction',
    'toggleCleared',
    {'transactionId': transactionId},
  );

  /// Reconciles all cleared transactions for an account.
  _ida.Future<int> reconcileAccount(
    _isc.UuidValue accountId,
    _isc.UuidValue budgetId,
  ) => caller.callServerEndpoint<int>(
    'transaction',
    'reconcileAccount',
    {
      'accountId': accountId,
      'budgetId': budgetId,
    },
  );

  /// Reconciles an account with a statement balance.
  ///
  /// If the cleared balance differs from the statement balance, creates an
  /// adjustment transaction. Returns [reconciledCount, adjustmentCents].
  _ida.Future<List<int>> reconcileWithBalance(
    _isc.UuidValue accountId,
    _isc.UuidValue budgetId,
    int statementBalanceCents,
  ) => caller.callServerEndpoint<List<int>>(
    'transaction',
    'reconcileWithBalance',
    {
      'accountId': accountId,
      'budgetId': budgetId,
      'statementBalanceCents': statementBalanceCents,
    },
  );

  /// Calculates the "Age of Money" for a budget.
  ///
  /// Returns the average days between income and spending, or null if
  /// there is insufficient data.
  _ida.Future<int?> ageOfMoney(_isc.UuidValue budgetId) =>
      caller.callServerEndpoint<int?>(
        'transaction',
        'ageOfMoney',
        {'budgetId': budgetId},
      );

  /// Creates a split transaction with multiple envelope assignments.
  _ida.Future<List<_iio3v7fv.Transaction>> createSplit(
    String description,
    int totalAmountCents,
    String currencyCode,
    _isc.UuidValue budgetId,
    DateTime transactionDate,
    List<_ilmjmphd.SplitItem> splits, {
    _isc.UuidValue? payeeId,
    _isc.UuidValue? accountId,
  }) => caller.callServerEndpoint<List<_iio3v7fv.Transaction>>(
    'transaction',
    'createSplit',
    {
      'description': description,
      'totalAmountCents': totalAmountCents,
      'currencyCode': currencyCode,
      'budgetId': budgetId,
      'transactionDate': transactionDate,
      'splits': splits,
      'payeeId': payeeId,
      'accountId': accountId,
    },
  );

  /// Lists the sub-transactions (splits) for a parent transaction.
  _ida.Future<List<_iio3v7fv.Transaction>> listSplits(
    _isc.UuidValue parentTransactionId,
  ) => caller.callServerEndpoint<List<_iio3v7fv.Transaction>>(
    'transaction',
    'listSplits',
    {'parentTransactionId': parentTransactionId},
  );

  /// Bulk creates transactions from imported data.
  ///
  /// Returns the count of successfully created transactions.
  _ida.Future<int> bulkImport(
    _isc.UuidValue budgetId,
    String currencyCode,
    List<_iyud7cy9.ImportRow> rows, {
    _isc.UuidValue? accountId,
  }) => caller.callServerEndpoint<int>(
    'transaction',
    'bulkImport',
    {
      'budgetId': budgetId,
      'currencyCode': currencyCode,
      'rows': rows,
      'accountId': accountId,
    },
  );

  /// Finds potential duplicate transactions with the same amount near a date.
  _ida.Future<List<_iio3v7fv.Transaction>> findDuplicates(
    _isc.UuidValue budgetId,
    int amountCents,
    DateTime transactionDate,
  ) => caller.callServerEndpoint<List<_iio3v7fv.Transaction>>(
    'transaction',
    'findDuplicates',
    {
      'budgetId': budgetId,
      'amountCents': amountCents,
      'transactionDate': transactionDate,
    },
  );

  /// Deletes a transaction by ID.
  _ida.Future<_iio3v7fv.Transaction> delete(_isc.UuidValue transactionId) =>
      caller.callServerEndpoint<_iio3v7fv.Transaction>(
        'transaction',
        'delete',
        {'transactionId': transactionId},
      );
}

/// API surface for read-only blockchain wallet account integration.
/// {@category Endpoint}
class EndpointWallet extends _isc.EndpointRef {
  EndpointWallet(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'wallet';

  /// Connects a Solana wallet and imports holdings as a synced account.
  _ida.Future<_iol2ym9i.WalletConnectResult> connectSolanaWallet(
    _isc.UuidValue budgetId,
    String address, {
    String? label,
    required bool onBudget,
  }) => caller.callServerEndpoint<_iol2ym9i.WalletConnectResult>(
    'wallet',
    'connectSolanaWallet',
    {
      'budgetId': budgetId,
      'address': address,
      'label': label,
      'onBudget': onBudget,
    },
  );

  /// Refreshes holdings and account balance for a wallet connection.
  _ida.Future<_iol2ym9i.WalletConnectResult> refreshSolanaWallet(
    _isc.UuidValue budgetId,
    _isc.UuidValue connectionId,
  ) => caller.callServerEndpoint<_iol2ym9i.WalletConnectResult>(
    'wallet',
    'refreshSolanaWallet',
    {
      'budgetId': budgetId,
      'connectionId': connectionId,
    },
  );

  /// Returns the latest persisted holdings for a wallet connection.
  _ida.Future<List<_izm3e498.WalletHolding>> listWalletHoldings(
    _isc.UuidValue budgetId,
    _isc.UuidValue connectionId,
  ) => caller.callServerEndpoint<List<_izm3e498.WalletHolding>>(
    'wallet',
    'listWalletHoldings',
    {
      'budgetId': budgetId,
      'connectionId': connectionId,
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
    appleIdp = EndpointAppleIdp(this);
    emailIdp = EndpointEmailIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    billing = EndpointBilling(this);
    budgetTemplate = EndpointBudgetTemplate(this);
    budget = EndpointBudget(this);
    budgetStream = EndpointBudgetStream(this);
    category = EndpointCategory(this);
    envelopeGoal = EndpointEnvelopeGoal(this);
    envelope = EndpointEnvelope(this);
    fxRate = EndpointFxRate(this);
    institution = EndpointInstitution(this);
    monthlyAllocation = EndpointMonthlyAllocation(this);
    payee = EndpointPayee(this);
    plaid = EndpointPlaid(this);
    recurringTransaction = EndpointRecurringTransaction(this);
    solanaWallet = EndpointSolanaWallet(this);
    tax = EndpointTax(this);
    transactionRule = EndpointTransactionRule(this);
    transaction = EndpointTransaction(this);
    wallet = EndpointWallet(this);
    modules = Modules(this);
  }

  late final EndpointAccount account;

  late final EndpointAppleIdp appleIdp;

  late final EndpointEmailIdp emailIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointBilling billing;

  late final EndpointBudgetTemplate budgetTemplate;

  late final EndpointBudget budget;

  late final EndpointBudgetStream budgetStream;

  late final EndpointCategory category;

  late final EndpointEnvelopeGoal envelopeGoal;

  late final EndpointEnvelope envelope;

  late final EndpointFxRate fxRate;

  late final EndpointInstitution institution;

  late final EndpointMonthlyAllocation monthlyAllocation;

  late final EndpointPayee payee;

  late final EndpointPlaid plaid;

  late final EndpointRecurringTransaction recurringTransaction;

  late final EndpointSolanaWallet solanaWallet;

  late final EndpointTax tax;

  late final EndpointTransactionRule transactionRule;

  late final EndpointTransaction transaction;

  late final EndpointWallet wallet;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'account': account,
    'appleIdp': appleIdp,
    'emailIdp': emailIdp,
    'googleIdp': googleIdp,
    'jwtRefresh': jwtRefresh,
    'billing': billing,
    'budgetTemplate': budgetTemplate,
    'budget': budget,
    'budgetStream': budgetStream,
    'category': category,
    'envelopeGoal': envelopeGoal,
    'envelope': envelope,
    'fxRate': fxRate,
    'institution': institution,
    'monthlyAllocation': monthlyAllocation,
    'payee': payee,
    'plaid': plaid,
    'recurringTransaction': recurringTransaction,
    'solanaWallet': solanaWallet,
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
