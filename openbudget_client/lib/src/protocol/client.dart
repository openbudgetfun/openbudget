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
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:openbudget_client/src/protocol/budgets/budget.dart' as _i5;
import 'package:openbudget_client/src/protocol/categories/category.dart' as _i6;
import 'package:openbudget_client/src/protocol/envelopes/envelope.dart' as _i7;
import 'package:openbudget_client/src/protocol/transactions/transaction.dart'
    as _i8;
import 'protocol.dart' as _i9;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

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
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>('emailIdp', 'login', {
    'email': email,
    'password': password,
  });

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
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
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
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) =>
      caller.callServerEndpoint<String>('emailIdp', 'verifyRegistrationCode', {
        'accountRequestId': accountRequestId,
        'verificationCode': verificationCode,
      });

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
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {'registrationToken': registrationToken, 'password': password},
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
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
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
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) =>
      caller.callServerEndpoint<String>('emailIdp', 'verifyPasswordResetCode', {
        'passwordResetRequestId': passwordResetRequestId,
        'verificationCode': verificationCode,
      });

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
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>('emailIdp', 'finishPasswordReset', {
    'finishPasswordResetToken': finishPasswordResetToken,
    'newPassword': newPassword,
  });

  @override
  _i3.Future<bool> hasAccount() =>
      caller.callServerEndpoint<bool>('emailIdp', 'hasAccount', {});
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

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
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
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
class EndpointBudget extends _i2.EndpointRef {
  EndpointBudget(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'budget';

  /// Creates a new budget for the authenticated user.
  _i3.Future<_i5.Budget> create(String name, String currencyCode) =>
      caller.callServerEndpoint<_i5.Budget>('budget', 'create', {
        'name': name,
        'currencyCode': currencyCode,
      });

  /// Lists all budgets for the authenticated user.
  _i3.Future<List<_i5.Budget>> list() =>
      caller.callServerEndpoint<List<_i5.Budget>>('budget', 'list', {});

  /// Gets a single budget by ID, verifying ownership.
  _i3.Future<_i5.Budget> get(_i2.UuidValue budgetId) => caller
      .callServerEndpoint<_i5.Budget>('budget', 'get', {'budgetId': budgetId});

  /// Updates a budget by ID, verifying ownership.
  _i3.Future<_i5.Budget> update(
    _i2.UuidValue budgetId, {
    String? name,
    String? currencyCode,
  }) => caller.callServerEndpoint<_i5.Budget>('budget', 'update', {
    'budgetId': budgetId,
    'name': name,
    'currencyCode': currencyCode,
  });

  /// Deletes a budget by ID, verifying ownership.
  _i3.Future<_i5.Budget> delete(_i2.UuidValue budgetId) =>
      caller.callServerEndpoint<_i5.Budget>('budget', 'delete', {
        'budgetId': budgetId,
      });
}

/// Streaming endpoint for real-time budget updates.
///
/// Client sends budget IDs, server streams back the current budget state.
/// {@category Endpoint}
class EndpointBudgetStream extends _i2.EndpointRef {
  EndpointBudgetStream(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'budgetStream';

  /// Streams budget updates to the connected client.
  ///
  /// Client sends [UuidValue] budget IDs, server responds with the current
  /// [Budget] state for each requested ID. Ownership is verified on each
  /// request.
  _i3.Stream<_i5.Budget> budgetUpdates(
    _i3.Stream<_i2.UuidValue> budgetIdStream,
  ) => caller.callStreamingServerEndpoint<_i3.Stream<_i5.Budget>, _i5.Budget>(
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
class EndpointCategory extends _i2.EndpointRef {
  EndpointCategory(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'category';

  /// Creates a new category within a budget.
  _i3.Future<_i6.Category> create(
    String name,
    _i2.UuidValue budgetId,
    int sortOrder,
  ) => caller.callServerEndpoint<_i6.Category>('category', 'create', {
    'name': name,
    'budgetId': budgetId,
    'sortOrder': sortOrder,
  });

  /// Lists all categories for a budget.
  _i3.Future<List<_i6.Category>> list(_i2.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_i6.Category>>('category', 'list', {
        'budgetId': budgetId,
      });

  /// Gets a single category by ID.
  _i3.Future<_i6.Category> get(_i2.UuidValue categoryId) =>
      caller.callServerEndpoint<_i6.Category>('category', 'get', {
        'categoryId': categoryId,
      });

  /// Updates a category by ID.
  _i3.Future<_i6.Category> update(
    _i2.UuidValue categoryId, {
    String? name,
    int? sortOrder,
  }) => caller.callServerEndpoint<_i6.Category>('category', 'update', {
    'categoryId': categoryId,
    'name': name,
    'sortOrder': sortOrder,
  });

  /// Deletes a category by ID.
  _i3.Future<_i6.Category> delete(_i2.UuidValue categoryId) =>
      caller.callServerEndpoint<_i6.Category>('category', 'delete', {
        'categoryId': categoryId,
      });
}

/// API surface for envelope operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointEnvelope extends _i2.EndpointRef {
  EndpointEnvelope(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'envelope';

  /// Creates a new envelope within a category.
  _i3.Future<_i7.Envelope> create(
    String name,
    _i2.UuidValue categoryId,
    int budgetedAmountCents,
    String currencyCode,
  ) => caller.callServerEndpoint<_i7.Envelope>('envelope', 'create', {
    'name': name,
    'categoryId': categoryId,
    'budgetedAmountCents': budgetedAmountCents,
    'currencyCode': currencyCode,
  });

  /// Lists all envelopes for a category.
  _i3.Future<List<_i7.Envelope>> list(_i2.UuidValue categoryId) =>
      caller.callServerEndpoint<List<_i7.Envelope>>('envelope', 'list', {
        'categoryId': categoryId,
      });

  /// Gets a single envelope by ID.
  _i3.Future<_i7.Envelope> get(_i2.UuidValue envelopeId) =>
      caller.callServerEndpoint<_i7.Envelope>('envelope', 'get', {
        'envelopeId': envelopeId,
      });

  /// Updates an envelope by ID.
  _i3.Future<_i7.Envelope> update(
    _i2.UuidValue envelopeId, {
    String? name,
    int? budgetedAmountCents,
    int? spentAmountCents,
  }) => caller.callServerEndpoint<_i7.Envelope>('envelope', 'update', {
    'envelopeId': envelopeId,
    'name': name,
    'budgetedAmountCents': budgetedAmountCents,
    'spentAmountCents': spentAmountCents,
  });

  /// Deletes an envelope by ID.
  _i3.Future<_i7.Envelope> delete(_i2.UuidValue envelopeId) =>
      caller.callServerEndpoint<_i7.Envelope>('envelope', 'delete', {
        'envelopeId': envelopeId,
      });
}

/// API surface for transaction operations.
///
/// All methods require authentication.
/// {@category Endpoint}
class EndpointTransaction extends _i2.EndpointRef {
  EndpointTransaction(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'transaction';

  /// Creates a new transaction within a budget.
  _i3.Future<_i8.Transaction> create(
    String description,
    int amountCents,
    String currencyCode,
    _i2.UuidValue budgetId,
    DateTime transactionDate, {
    _i2.UuidValue? envelopeId,
  }) => caller.callServerEndpoint<_i8.Transaction>('transaction', 'create', {
    'description': description,
    'amountCents': amountCents,
    'currencyCode': currencyCode,
    'budgetId': budgetId,
    'transactionDate': transactionDate,
    'envelopeId': envelopeId,
  });

  /// Lists all transactions for a budget.
  _i3.Future<List<_i8.Transaction>> list(_i2.UuidValue budgetId) =>
      caller.callServerEndpoint<List<_i8.Transaction>>('transaction', 'list', {
        'budgetId': budgetId,
      });

  /// Gets a single transaction by ID.
  _i3.Future<_i8.Transaction> get(_i2.UuidValue transactionId) =>
      caller.callServerEndpoint<_i8.Transaction>('transaction', 'get', {
        'transactionId': transactionId,
      });

  /// Updates a transaction by ID.
  _i3.Future<_i8.Transaction> update(
    _i2.UuidValue transactionId, {
    String? description,
    int? amountCents,
    _i2.UuidValue? envelopeId,
    DateTime? transactionDate,
  }) => caller.callServerEndpoint<_i8.Transaction>('transaction', 'update', {
    'transactionId': transactionId,
    'description': description,
    'amountCents': amountCents,
    'envelopeId': envelopeId,
    'transactionDate': transactionDate,
  });

  /// Deletes a transaction by ID.
  _i3.Future<_i8.Transaction> delete(_i2.UuidValue transactionId) =>
      caller.callServerEndpoint<_i8.Transaction>('transaction', 'delete', {
        'transactionId': transactionId,
      });
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(_i2.MethodCallContext, Object, StackTrace)? onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i9.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    budget = EndpointBudget(this);
    budgetStream = EndpointBudgetStream(this);
    category = EndpointCategory(this);
    envelope = EndpointEnvelope(this);
    transaction = EndpointTransaction(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointBudget budget;

  late final EndpointBudgetStream budgetStream;

  late final EndpointCategory category;

  late final EndpointEnvelope envelope;

  late final EndpointTransaction transaction;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'budget': budget,
    'budgetStream': budgetStream,
    'category': category,
    'envelope': envelope,
    'transaction': transaction,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
