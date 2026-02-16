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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:openbudget_client/src/protocol/accounts/account.dart' as _i3;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i4;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i5;
import 'package:openbudget_client/src/protocol/budgets/budget.dart' as _i6;
import 'package:openbudget_client/src/protocol/categories/category.dart' as _i7;
import 'package:openbudget_client/src/protocol/envelope_goals/envelope_goal.dart'
    as _i8;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart' as _i9;
import 'package:openbudget_client/src/protocol/monthly_allocations/monthly_allocation.dart'
    as _i10;
import 'package:openbudget_client/src/protocol/payees/payee.dart' as _i11;
import 'package:openbudget_client/src/protocol/transactions/transaction.dart'
    as _i12;
import 'protocol.dart' as _i13;

/// API surface for account operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointAccount extends _i1.EndpointRef {
  EndpointAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'account';

  /// Creates a new account within a budget.
  _i2.Future<_i3.Account> create(
    String name,
    String accountType,
    int balanceCents,
    String currencyCode,
    _i1.UuidValue budgetId, {
    required bool onBudget,
    required int sortOrder,
  }) => caller.callServerEndpoint<_i3.Account>(
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
    },
  );

  /// Lists all accounts for a budget.
  _i2.Future<List<_i3.Account>> list(_i1.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_i3.Account>>(
        'account',
        'list',
        {'budgetId': budgetId},
      );

  /// Gets a single account by ID.
  _i2.Future<_i3.Account> get(_i1.UuidValue accountId) =>
      caller.callServerEndpoint<_i3.Account>(
        'account',
        'get',
        {'accountId': accountId},
      );

  /// Updates an account by ID.
  _i2.Future<_i3.Account> update(
    _i1.UuidValue accountId, {
    String? name,
    String? accountType,
    int? balanceCents,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
  }) => caller.callServerEndpoint<_i3.Account>(
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
  _i2.Future<_i3.Account> delete(_i1.UuidValue accountId) =>
      caller.callServerEndpoint<_i3.Account>(
        'account',
        'delete',
        {'accountId': accountId},
      );
}

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i4.EndpointEmailIdpBase {
  EndpointEmailIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<_i5.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i5.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i2.Future<_i1.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i2.Future<_i5.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i5.AuthSuccess>(
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
  _i2.Future<_i1.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
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
  _i2.Future<String> verifyPasswordResetCode({
    required _i1.UuidValue passwordResetRequestId,
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
  _i2.Future<void> finishPasswordReset({
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
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i5.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
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
  _i2.Future<_i5.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i5.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// API surface for budget operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointBudget extends _i1.EndpointRef {
  EndpointBudget(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'budget';

  /// Creates a new budget for the authenticated user.
  _i2.Future<_i6.Budget> create(
    String name,
    String currencyCode,
  ) => caller.callServerEndpoint<_i6.Budget>(
    'budget',
    'create',
    {
      'name': name,
      'currencyCode': currencyCode,
    },
  );

  /// Lists all budgets for the authenticated user.
  _i2.Future<List<_i6.Budget>> list() =>
      caller.callServerEndpoint<List<_i6.Budget>>(
        'budget',
        'list',
        {},
      );

  /// Gets a single budget by ID, verifying ownership.
  _i2.Future<_i6.Budget> get(_i1.UuidValue budgetId) =>
      caller.callServerEndpoint<_i6.Budget>(
        'budget',
        'get',
        {'budgetId': budgetId},
      );

  /// Updates a budget by ID, verifying ownership.
  _i2.Future<_i6.Budget> update(
    _i1.UuidValue budgetId, {
    String? name,
    String? currencyCode,
  }) => caller.callServerEndpoint<_i6.Budget>(
    'budget',
    'update',
    {
      'budgetId': budgetId,
      'name': name,
      'currencyCode': currencyCode,
    },
  );

  /// Deletes a budget by ID, verifying ownership.
  _i2.Future<_i6.Budget> delete(_i1.UuidValue budgetId) =>
      caller.callServerEndpoint<_i6.Budget>(
        'budget',
        'delete',
        {'budgetId': budgetId},
      );
}

/// Streaming endpoint for real-time budget updates.
///
/// Client sends budget IDs, server streams back the current budget state.
/// {@category Endpoint}
class EndpointBudgetStream extends _i1.EndpointRef {
  EndpointBudgetStream(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'budgetStream';

  /// Streams budget updates to the connected client.
  ///
  /// Client sends [UuidValue] budget IDs, server responds with the current
  /// [Budget] state for each requested ID. Ownership is verified on each
  /// request.
  _i2.Stream<_i6.Budget> budgetUpdates(
    _i2.Stream<_i1.UuidValue> budgetIdStream,
  ) => caller.callStreamingServerEndpoint<_i2.Stream<_i6.Budget>, _i6.Budget>(
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
class EndpointCategory extends _i1.EndpointRef {
  EndpointCategory(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'category';

  /// Creates a new category within a budget.
  _i2.Future<_i7.Category> create(
    String name,
    _i1.UuidValue budgetId,
    int sortOrder,
  ) => caller.callServerEndpoint<_i7.Category>(
    'category',
    'create',
    {
      'name': name,
      'budgetId': budgetId,
      'sortOrder': sortOrder,
    },
  );

  /// Lists all categories for a budget.
  _i2.Future<List<_i7.Category>> list(_i1.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_i7.Category>>(
        'category',
        'list',
        {'budgetId': budgetId},
      );

  /// Gets a single category by ID.
  _i2.Future<_i7.Category> get(_i1.UuidValue categoryId) =>
      caller.callServerEndpoint<_i7.Category>(
        'category',
        'get',
        {'categoryId': categoryId},
      );

  /// Updates a category by ID.
  _i2.Future<_i7.Category> update(
    _i1.UuidValue categoryId, {
    String? name,
    int? sortOrder,
  }) => caller.callServerEndpoint<_i7.Category>(
    'category',
    'update',
    {
      'categoryId': categoryId,
      'name': name,
      'sortOrder': sortOrder,
    },
  );

  /// Deletes a category by ID.
  _i2.Future<_i7.Category> delete(_i1.UuidValue categoryId) =>
      caller.callServerEndpoint<_i7.Category>(
        'category',
        'delete',
        {'categoryId': categoryId},
      );
}

/// API surface for envelope goal operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointEnvelopeGoal extends _i1.EndpointRef {
  EndpointEnvelopeGoal(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'envelopeGoal';

  /// Creates or updates a goal for an envelope.
  _i2.Future<_i8.EnvelopeGoal> upsert(
    _i1.UuidValue envelopeId,
    String goalType,
    int targetAmountCents, {
    DateTime? targetDate,
    int? monthlyFundingCents,
  }) => caller.callServerEndpoint<_i8.EnvelopeGoal>(
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
  _i2.Future<_i8.EnvelopeGoal?> getForEnvelope(_i1.UuidValue envelopeId) =>
      caller.callServerEndpoint<_i8.EnvelopeGoal?>(
        'envelopeGoal',
        'getForEnvelope',
        {'envelopeId': envelopeId},
      );

  /// Lists all goals for a set of envelope IDs.
  _i2.Future<List<_i8.EnvelopeGoal>> listForEnvelopes(
    List<_i1.UuidValue> envelopeIds,
  ) => caller.callServerEndpoint<List<_i8.EnvelopeGoal>>(
    'envelopeGoal',
    'listForEnvelopes',
    {'envelopeIds': envelopeIds},
  );

  /// Deletes a goal by ID.
  _i2.Future<_i8.EnvelopeGoal> delete(_i1.UuidValue goalId) =>
      caller.callServerEndpoint<_i8.EnvelopeGoal>(
        'envelopeGoal',
        'delete',
        {'goalId': goalId},
      );
}

/// API surface for envelope operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointEnvelope extends _i1.EndpointRef {
  EndpointEnvelope(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'envelope';

  /// Creates a new envelope within a category.
  _i2.Future<_i9.Envelope> create(
    String name,
    _i1.UuidValue categoryId,
    int budgetedAmountCents,
    String currencyCode,
  ) => caller.callServerEndpoint<_i9.Envelope>(
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
  _i2.Future<List<_i9.Envelope>> list(_i1.UuidValue categoryId) =>
      caller.callServerEndpoint<List<_i9.Envelope>>(
        'envelope',
        'list',
        {'categoryId': categoryId},
      );

  /// Gets a single envelope by ID.
  _i2.Future<_i9.Envelope> get(_i1.UuidValue envelopeId) =>
      caller.callServerEndpoint<_i9.Envelope>(
        'envelope',
        'get',
        {'envelopeId': envelopeId},
      );

  /// Updates an envelope by ID.
  _i2.Future<_i9.Envelope> update(
    _i1.UuidValue envelopeId, {
    String? name,
    int? budgetedAmountCents,
    int? spentAmountCents,
  }) => caller.callServerEndpoint<_i9.Envelope>(
    'envelope',
    'update',
    {
      'envelopeId': envelopeId,
      'name': name,
      'budgetedAmountCents': budgetedAmountCents,
      'spentAmountCents': spentAmountCents,
    },
  );

  /// Deletes an envelope by ID.
  _i2.Future<_i9.Envelope> delete(_i1.UuidValue envelopeId) =>
      caller.callServerEndpoint<_i9.Envelope>(
        'envelope',
        'delete',
        {'envelopeId': envelopeId},
      );
}

/// API surface for monthly allocation operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointMonthlyAllocation extends _i1.EndpointRef {
  EndpointMonthlyAllocation(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'monthlyAllocation';

  /// Creates or updates an allocation for an envelope in a given month.
  _i2.Future<_i10.MonthlyAllocation> upsert(
    _i1.UuidValue envelopeId,
    _i1.UuidValue budgetId,
    int year,
    int month,
    int allocatedCents, {
    required int carryoverCents,
  }) => caller.callServerEndpoint<_i10.MonthlyAllocation>(
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
  _i2.Future<List<_i10.MonthlyAllocation>> list(
    _i1.UuidValue budgetId,
    int year,
    int month,
  ) => caller.callServerEndpoint<List<_i10.MonthlyAllocation>>(
    'monthlyAllocation',
    'list',
    {
      'budgetId': budgetId,
      'year': year,
      'month': month,
    },
  );

  /// Deletes a monthly allocation by ID.
  _i2.Future<_i10.MonthlyAllocation> delete(_i1.UuidValue allocationId) =>
      caller.callServerEndpoint<_i10.MonthlyAllocation>(
        'monthlyAllocation',
        'delete',
        {'allocationId': allocationId},
      );
}

/// API surface for payee operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointPayee extends _i1.EndpointRef {
  EndpointPayee(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'payee';

  /// Creates a new payee within a budget.
  _i2.Future<_i11.Payee> create(
    String name,
    _i1.UuidValue budgetId,
  ) => caller.callServerEndpoint<_i11.Payee>(
    'payee',
    'create',
    {
      'name': name,
      'budgetId': budgetId,
    },
  );

  /// Lists all payees for a budget.
  _i2.Future<List<_i11.Payee>> list(_i1.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_i11.Payee>>(
        'payee',
        'list',
        {'budgetId': budgetId},
      );

  /// Gets a single payee by ID.
  _i2.Future<_i11.Payee> get(_i1.UuidValue payeeId) =>
      caller.callServerEndpoint<_i11.Payee>(
        'payee',
        'get',
        {'payeeId': payeeId},
      );

  /// Updates a payee by ID.
  _i2.Future<_i11.Payee> update(
    _i1.UuidValue payeeId, {
    String? name,
  }) => caller.callServerEndpoint<_i11.Payee>(
    'payee',
    'update',
    {
      'payeeId': payeeId,
      'name': name,
    },
  );

  /// Deletes a payee by ID.
  _i2.Future<_i11.Payee> delete(_i1.UuidValue payeeId) =>
      caller.callServerEndpoint<_i11.Payee>(
        'payee',
        'delete',
        {'payeeId': payeeId},
      );
}

/// API surface for transaction operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointTransaction extends _i1.EndpointRef {
  EndpointTransaction(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'transaction';

  /// Creates a new transaction within a budget.
  _i2.Future<_i12.Transaction> create(
    String description,
    int amountCents,
    String currencyCode,
    _i1.UuidValue budgetId,
    DateTime transactionDate, {
    _i1.UuidValue? envelopeId,
    _i1.UuidValue? payeeId,
  }) => caller.callServerEndpoint<_i12.Transaction>(
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
    },
  );

  /// Lists all transactions for a budget.
  _i2.Future<List<_i12.Transaction>> list(_i1.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_i12.Transaction>>(
        'transaction',
        'list',
        {'budgetId': budgetId},
      );

  /// Lists transactions for a budget within a specific month.
  _i2.Future<List<_i12.Transaction>> listByMonth(
    _i1.UuidValue budgetId,
    int year,
    int month,
  ) => caller.callServerEndpoint<List<_i12.Transaction>>(
    'transaction',
    'listByMonth',
    {
      'budgetId': budgetId,
      'year': year,
      'month': month,
    },
  );

  /// Gets a single transaction by ID.
  _i2.Future<_i12.Transaction> get(_i1.UuidValue transactionId) =>
      caller.callServerEndpoint<_i12.Transaction>(
        'transaction',
        'get',
        {'transactionId': transactionId},
      );

  /// Updates a transaction by ID.
  _i2.Future<_i12.Transaction> update(
    _i1.UuidValue transactionId, {
    String? description,
    int? amountCents,
    _i1.UuidValue? envelopeId,
    _i1.UuidValue? payeeId,
    DateTime? transactionDate,
  }) => caller.callServerEndpoint<_i12.Transaction>(
    'transaction',
    'update',
    {
      'transactionId': transactionId,
      'description': description,
      'amountCents': amountCents,
      'envelopeId': envelopeId,
      'payeeId': payeeId,
      'transactionDate': transactionDate,
    },
  );

  /// Deletes a transaction by ID.
  _i2.Future<_i12.Transaction> delete(_i1.UuidValue transactionId) =>
      caller.callServerEndpoint<_i12.Transaction>(
        'transaction',
        'delete',
        {'transactionId': transactionId},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i4.Caller(client);
    serverpod_auth_core = _i5.Caller(client);
  }

  late final _i4.Caller serverpod_auth_idp;

  late final _i5.Caller serverpod_auth_core;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i13.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    account = EndpointAccount(this);
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    budget = EndpointBudget(this);
    budgetStream = EndpointBudgetStream(this);
    category = EndpointCategory(this);
    envelopeGoal = EndpointEnvelopeGoal(this);
    envelope = EndpointEnvelope(this);
    monthlyAllocation = EndpointMonthlyAllocation(this);
    payee = EndpointPayee(this);
    transaction = EndpointTransaction(this);
    modules = Modules(this);
  }

  late final EndpointAccount account;

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointBudget budget;

  late final EndpointBudgetStream budgetStream;

  late final EndpointCategory category;

  late final EndpointEnvelopeGoal envelopeGoal;

  late final EndpointEnvelope envelope;

  late final EndpointMonthlyAllocation monthlyAllocation;

  late final EndpointPayee payee;

  late final EndpointTransaction transaction;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'account': account,
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'budget': budget,
    'budgetStream': budgetStream,
    'category': category,
    'envelopeGoal': envelopeGoal,
    'envelope': envelope,
    'monthlyAllocation': monthlyAllocation,
    'payee': payee,
    'transaction': transaction,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
