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
import 'package:serverpod/serverpod.dart' as _i1;
import '../accounts/account_endpoint.dart' as _i2;
import '../auth/email_idp_endpoint.dart' as _i3;
import '../auth/jwt_refresh_endpoint.dart' as _i4;
import '../budgets/budget_endpoint.dart' as _i5;
import '../budgets/budget_stream.dart' as _i6;
import '../categories/category_endpoint.dart' as _i7;
import '../envelope_goals/envelope_goal_endpoint.dart' as _i8;
import '../envelopes/envelope_endpoint.dart' as _i9;
import '../monthly_allocations/monthly_allocation_endpoint.dart' as _i10;
import '../payees/payee_endpoint.dart' as _i11;
import '../recurring_transactions/recurring_transaction_endpoint.dart' as _i12;
import '../transactions/transaction_endpoint.dart' as _i13;
import 'package:openbudget_server/src/generated/transactions/split_item.dart'
    as _i14;
import 'package:openbudget_server/src/generated/transactions/import_row.dart'
    as _i15;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i16;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i17;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'account': _i2.AccountEndpoint()..initialize(server, 'account', null),
      'emailIdp': _i3.EmailIdpEndpoint()..initialize(server, 'emailIdp', null),
      'jwtRefresh': _i4.JwtRefreshEndpoint()
        ..initialize(server, 'jwtRefresh', null),
      'budget': _i5.BudgetEndpoint()..initialize(server, 'budget', null),
      'budgetStream': _i6.BudgetStreamEndpoint()
        ..initialize(server, 'budgetStream', null),
      'category': _i7.CategoryEndpoint()..initialize(server, 'category', null),
      'envelopeGoal': _i8.EnvelopeGoalEndpoint()
        ..initialize(server, 'envelopeGoal', null),
      'envelope': _i9.EnvelopeEndpoint()..initialize(server, 'envelope', null),
      'monthlyAllocation': _i10.MonthlyAllocationEndpoint()
        ..initialize(server, 'monthlyAllocation', null),
      'payee': _i11.PayeeEndpoint()..initialize(server, 'payee', null),
      'recurringTransaction': _i12.RecurringTransactionEndpoint()
        ..initialize(server, 'recurringTransaction', null),
      'transaction': _i13.TransactionEndpoint()
        ..initialize(server, 'transaction', null),
    };
    connectors['account'] = _i1.EndpointConnector(
      name: 'account',
      endpoint: endpoints['account']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'accountType': _i1.ParameterDescription(
              name: 'accountType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'balanceCents': _i1.ParameterDescription(
              name: 'balanceCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _i1.ParameterDescription(
              name: 'currencyCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'onBudget': _i1.ParameterDescription(
              name: 'onBudget',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['account'] as _i2.AccountEndpoint).create(
                session,
                params['name'],
                params['accountType'],
                params['balanceCents'],
                params['currencyCode'],
                params['budgetId'],
                onBudget: params['onBudget'],
                sortOrder: params['sortOrder'],
              ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['account'] as _i2.AccountEndpoint).list(
                session,
                params['budgetId'],
              ),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['account'] as _i2.AccountEndpoint).get(
                session,
                params['accountId'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'accountType': _i1.ParameterDescription(
              name: 'accountType',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'balanceCents': _i1.ParameterDescription(
              name: 'balanceCents',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'onBudget': _i1.ParameterDescription(
              name: 'onBudget',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'isClosed': _i1.ParameterDescription(
              name: 'isClosed',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['account'] as _i2.AccountEndpoint).update(
                session,
                params['accountId'],
                name: params['name'],
                accountType: params['accountType'],
                balanceCents: params['balanceCents'],
                onBudget: params['onBudget'],
                sortOrder: params['sortOrder'],
                isClosed: params['isClosed'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['account'] as _i2.AccountEndpoint).delete(
                session,
                params['accountId'],
              ),
        ),
      },
    );
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['emailIdp'] as _i3.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['emailIdp'] as _i3.EmailIdpEndpoint).startRegistration(
                session,
                email: params['email'],
              ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .startPasswordReset(session, email: params['email']),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['emailIdp'] as _i3.EmailIdpEndpoint).hasAccount(
                session,
              ),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['jwtRefresh'] as _i4.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['budget'] = _i1.EndpointConnector(
      name: 'budget',
      endpoint: endpoints['budget']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'currencyCode': _i1.ParameterDescription(
              name: 'currencyCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['budget'] as _i5.BudgetEndpoint).create(
                session,
                params['name'],
                params['currencyCode'],
              ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {},
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['budget'] as _i5.BudgetEndpoint).list(session),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['budget'] as _i5.BudgetEndpoint).get(
                session,
                params['budgetId'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'currencyCode': _i1.ParameterDescription(
              name: 'currencyCode',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['budget'] as _i5.BudgetEndpoint).update(
                session,
                params['budgetId'],
                name: params['name'],
                currencyCode: params['currencyCode'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['budget'] as _i5.BudgetEndpoint).delete(
                session,
                params['budgetId'],
              ),
        ),
      },
    );
    connectors['budgetStream'] = _i1.EndpointConnector(
      name: 'budgetStream',
      endpoint: endpoints['budgetStream']!,
      methodConnectors: {
        'budgetUpdates': _i1.MethodStreamConnector(
          name: 'budgetUpdates',
          params: {},
          streamParams: {
            'budgetIdStream': _i1.StreamParameterDescription<_i1.UuidValue>(
              name: 'budgetIdStream',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['budgetStream'] as _i6.BudgetStreamEndpoint)
                  .budgetUpdates(
                    session,
                    streamParams['budgetIdStream']!.cast<_i1.UuidValue>(),
                  ),
        ),
      },
    );
    connectors['category'] = _i1.EndpointConnector(
      name: 'category',
      endpoint: endpoints['category']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['category'] as _i7.CategoryEndpoint).create(
                session,
                params['name'],
                params['budgetId'],
                params['sortOrder'],
              ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['category'] as _i7.CategoryEndpoint).list(
                session,
                params['budgetId'],
              ),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['category'] as _i7.CategoryEndpoint).get(
                session,
                params['categoryId'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['category'] as _i7.CategoryEndpoint).update(
                session,
                params['categoryId'],
                name: params['name'],
                sortOrder: params['sortOrder'],
              ),
        ),
        'reorder': _i1.MethodConnector(
          name: 'reorder',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'categoryIds': _i1.ParameterDescription(
              name: 'categoryIds',
              type: _i1.getType<List<_i1.UuidValue>>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['category'] as _i7.CategoryEndpoint).reorder(
                session,
                params['budgetId'],
                params['categoryIds'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['category'] as _i7.CategoryEndpoint).delete(
                session,
                params['categoryId'],
              ),
        ),
      },
    );
    connectors['envelopeGoal'] = _i1.EndpointConnector(
      name: 'envelopeGoal',
      endpoint: endpoints['envelopeGoal']!,
      methodConnectors: {
        'upsert': _i1.MethodConnector(
          name: 'upsert',
          params: {
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'goalType': _i1.ParameterDescription(
              name: 'goalType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'targetAmountCents': _i1.ParameterDescription(
              name: 'targetAmountCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'targetDate': _i1.ParameterDescription(
              name: 'targetDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'monthlyFundingCents': _i1.ParameterDescription(
              name: 'monthlyFundingCents',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['envelopeGoal'] as _i8.EnvelopeGoalEndpoint).upsert(
                session,
                params['envelopeId'],
                params['goalType'],
                params['targetAmountCents'],
                targetDate: params['targetDate'],
                monthlyFundingCents: params['monthlyFundingCents'],
              ),
        ),
        'getForEnvelope': _i1.MethodConnector(
          name: 'getForEnvelope',
          params: {
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['envelopeGoal'] as _i8.EnvelopeGoalEndpoint)
                  .getForEnvelope(session, params['envelopeId']),
        ),
        'listForEnvelopes': _i1.MethodConnector(
          name: 'listForEnvelopes',
          params: {
            'envelopeIds': _i1.ParameterDescription(
              name: 'envelopeIds',
              type: _i1.getType<List<_i1.UuidValue>>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['envelopeGoal'] as _i8.EnvelopeGoalEndpoint)
                  .listForEnvelopes(session, params['envelopeIds']),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'goalId': _i1.ParameterDescription(
              name: 'goalId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['envelopeGoal'] as _i8.EnvelopeGoalEndpoint).delete(
                session,
                params['goalId'],
              ),
        ),
      },
    );
    connectors['envelope'] = _i1.EndpointConnector(
      name: 'envelope',
      endpoint: endpoints['envelope']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'budgetedAmountCents': _i1.ParameterDescription(
              name: 'budgetedAmountCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _i1.ParameterDescription(
              name: 'currencyCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['envelope'] as _i9.EnvelopeEndpoint).create(
                session,
                params['name'],
                params['categoryId'],
                params['budgetedAmountCents'],
                params['currencyCode'],
              ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['envelope'] as _i9.EnvelopeEndpoint).list(
                session,
                params['categoryId'],
              ),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['envelope'] as _i9.EnvelopeEndpoint).get(
                session,
                params['envelopeId'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'budgetedAmountCents': _i1.ParameterDescription(
              name: 'budgetedAmountCents',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'spentAmountCents': _i1.ParameterDescription(
              name: 'spentAmountCents',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['envelope'] as _i9.EnvelopeEndpoint).update(
                session,
                params['envelopeId'],
                name: params['name'],
                budgetedAmountCents: params['budgetedAmountCents'],
                spentAmountCents: params['spentAmountCents'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['envelope'] as _i9.EnvelopeEndpoint).delete(
                session,
                params['envelopeId'],
              ),
        ),
      },
    );
    connectors['monthlyAllocation'] = _i1.EndpointConnector(
      name: 'monthlyAllocation',
      endpoint: endpoints['monthlyAllocation']!,
      methodConnectors: {
        'upsert': _i1.MethodConnector(
          name: 'upsert',
          params: {
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'year': _i1.ParameterDescription(
              name: 'year',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'month': _i1.ParameterDescription(
              name: 'month',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'allocatedCents': _i1.ParameterDescription(
              name: 'allocatedCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'carryoverCents': _i1.ParameterDescription(
              name: 'carryoverCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['monthlyAllocation'] as _i10.MonthlyAllocationEndpoint)
                  .upsert(
                    session,
                    params['envelopeId'],
                    params['budgetId'],
                    params['year'],
                    params['month'],
                    params['allocatedCents'],
                    carryoverCents: params['carryoverCents'],
                  ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'year': _i1.ParameterDescription(
              name: 'year',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'month': _i1.ParameterDescription(
              name: 'month',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['monthlyAllocation'] as _i10.MonthlyAllocationEndpoint)
                  .list(
                    session,
                    params['budgetId'],
                    params['year'],
                    params['month'],
                  ),
        ),
        'moveMoney': _i1.MethodConnector(
          name: 'moveMoney',
          params: {
            'fromEnvelopeId': _i1.ParameterDescription(
              name: 'fromEnvelopeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'toEnvelopeId': _i1.ParameterDescription(
              name: 'toEnvelopeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'year': _i1.ParameterDescription(
              name: 'year',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'month': _i1.ParameterDescription(
              name: 'month',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'amountCents': _i1.ParameterDescription(
              name: 'amountCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['monthlyAllocation'] as _i10.MonthlyAllocationEndpoint)
                  .moveMoney(
                    session,
                    params['fromEnvelopeId'],
                    params['toEnvelopeId'],
                    params['budgetId'],
                    params['year'],
                    params['month'],
                    params['amountCents'],
                  ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'allocationId': _i1.ParameterDescription(
              name: 'allocationId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['monthlyAllocation'] as _i10.MonthlyAllocationEndpoint)
                  .delete(session, params['allocationId']),
        ),
      },
    );
    connectors['payee'] = _i1.EndpointConnector(
      name: 'payee',
      endpoint: endpoints['payee']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['payee'] as _i11.PayeeEndpoint).create(
                session,
                params['name'],
                params['budgetId'],
              ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['payee'] as _i11.PayeeEndpoint).list(
                session,
                params['budgetId'],
              ),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['payee'] as _i11.PayeeEndpoint).get(
                session,
                params['payeeId'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['payee'] as _i11.PayeeEndpoint).update(
                session,
                params['payeeId'],
                name: params['name'],
              ),
        ),
        'lastUsedEnvelopeId': _i1.MethodConnector(
          name: 'lastUsedEnvelopeId',
          params: {
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['payee'] as _i11.PayeeEndpoint).lastUsedEnvelopeId(
                session,
                params['payeeId'],
                params['budgetId'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['payee'] as _i11.PayeeEndpoint).delete(
                session,
                params['payeeId'],
              ),
        ),
      },
    );
    connectors['recurringTransaction'] = _i1.EndpointConnector(
      name: 'recurringTransaction',
      endpoint: endpoints['recurringTransaction']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'amountCents': _i1.ParameterDescription(
              name: 'amountCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _i1.ParameterDescription(
              name: 'currencyCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'frequency': _i1.ParameterDescription(
              name: 'frequency',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'nextOccurrence': _i1.ParameterDescription(
              name: 'nextOccurrence',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'endDate': _i1.ParameterDescription(
              name: 'endDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['recurringTransaction']
                      as _i12.RecurringTransactionEndpoint)
                  .create(
                    session,
                    params['description'],
                    params['amountCents'],
                    params['currencyCode'],
                    params['budgetId'],
                    params['frequency'],
                    params['nextOccurrence'],
                    envelopeId: params['envelopeId'],
                    accountId: params['accountId'],
                    payeeId: params['payeeId'],
                    endDate: params['endDate'],
                  ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'activeOnly': _i1.ParameterDescription(
              name: 'activeOnly',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['recurringTransaction']
                      as _i12.RecurringTransactionEndpoint)
                  .list(
                    session,
                    params['budgetId'],
                    activeOnly: params['activeOnly'],
                  ),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'recurringTransactionId': _i1.ParameterDescription(
              name: 'recurringTransactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['recurringTransaction']
                      as _i12.RecurringTransactionEndpoint)
                  .get(session, params['recurringTransactionId']),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'recurringTransactionId': _i1.ParameterDescription(
              name: 'recurringTransactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'amountCents': _i1.ParameterDescription(
              name: 'amountCents',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'frequency': _i1.ParameterDescription(
              name: 'frequency',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'nextOccurrence': _i1.ParameterDescription(
              name: 'nextOccurrence',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'endDate': _i1.ParameterDescription(
              name: 'endDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['recurringTransaction']
                      as _i12.RecurringTransactionEndpoint)
                  .update(
                    session,
                    params['recurringTransactionId'],
                    description: params['description'],
                    amountCents: params['amountCents'],
                    envelopeId: params['envelopeId'],
                    accountId: params['accountId'],
                    payeeId: params['payeeId'],
                    frequency: params['frequency'],
                    nextOccurrence: params['nextOccurrence'],
                    endDate: params['endDate'],
                    isActive: params['isActive'],
                  ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'recurringTransactionId': _i1.ParameterDescription(
              name: 'recurringTransactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['recurringTransaction']
                      as _i12.RecurringTransactionEndpoint)
                  .delete(session, params['recurringTransactionId']),
        ),
        'skipOccurrence': _i1.MethodConnector(
          name: 'skipOccurrence',
          params: {
            'recurringTransactionId': _i1.ParameterDescription(
              name: 'recurringTransactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['recurringTransaction']
                      as _i12.RecurringTransactionEndpoint)
                  .skipOccurrence(session, params['recurringTransactionId']),
        ),
        'postDue': _i1.MethodConnector(
          name: 'postDue',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['recurringTransaction']
                      as _i12.RecurringTransactionEndpoint)
                  .postDue(session, params['budgetId']),
        ),
        'countDue': _i1.MethodConnector(
          name: 'countDue',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['recurringTransaction']
                      as _i12.RecurringTransactionEndpoint)
                  .countDue(session, params['budgetId']),
        ),
      },
    );
    connectors['transaction'] = _i1.EndpointConnector(
      name: 'transaction',
      endpoint: endpoints['transaction']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'amountCents': _i1.ParameterDescription(
              name: 'amountCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _i1.ParameterDescription(
              name: 'currencyCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'transactionDate': _i1.ParameterDescription(
              name: 'transactionDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'memo': _i1.ParameterDescription(
              name: 'memo',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint).create(
                session,
                params['description'],
                params['amountCents'],
                params['currencyCode'],
                params['budgetId'],
                params['transactionDate'],
                envelopeId: params['envelopeId'],
                payeeId: params['payeeId'],
                memo: params['memo'],
              ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint).list(
                session,
                params['budgetId'],
              ),
        ),
        'listByMonth': _i1.MethodConnector(
          name: 'listByMonth',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'year': _i1.ParameterDescription(
              name: 'year',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'month': _i1.ParameterDescription(
              name: 'month',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint)
                  .listByMonth(
                    session,
                    params['budgetId'],
                    params['year'],
                    params['month'],
                  ),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'transactionId': _i1.ParameterDescription(
              name: 'transactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint).get(
                session,
                params['transactionId'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'transactionId': _i1.ParameterDescription(
              name: 'transactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'amountCents': _i1.ParameterDescription(
              name: 'amountCents',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'envelopeId': _i1.ParameterDescription(
              name: 'envelopeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'transactionDate': _i1.ParameterDescription(
              name: 'transactionDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'memo': _i1.ParameterDescription(
              name: 'memo',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint).update(
                session,
                params['transactionId'],
                description: params['description'],
                amountCents: params['amountCents'],
                envelopeId: params['envelopeId'],
                payeeId: params['payeeId'],
                transactionDate: params['transactionDate'],
                memo: params['memo'],
              ),
        ),
        'transfer': _i1.MethodConnector(
          name: 'transfer',
          params: {
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'amountCents': _i1.ParameterDescription(
              name: 'amountCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _i1.ParameterDescription(
              name: 'currencyCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'fromAccountId': _i1.ParameterDescription(
              name: 'fromAccountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'toAccountId': _i1.ParameterDescription(
              name: 'toAccountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'transactionDate': _i1.ParameterDescription(
              name: 'transactionDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint).transfer(
                session,
                params['description'],
                params['amountCents'],
                params['currencyCode'],
                params['budgetId'],
                params['fromAccountId'],
                params['toAccountId'],
                params['transactionDate'],
              ),
        ),
        'listByAccount': _i1.MethodConnector(
          name: 'listByAccount',
          params: {
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint)
                  .listByAccount(
                    session,
                    params['accountId'],
                    params['budgetId'],
                  ),
        ),
        'toggleCleared': _i1.MethodConnector(
          name: 'toggleCleared',
          params: {
            'transactionId': _i1.ParameterDescription(
              name: 'transactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint)
                  .toggleCleared(session, params['transactionId']),
        ),
        'reconcileAccount': _i1.MethodConnector(
          name: 'reconcileAccount',
          params: {
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint)
                  .reconcileAccount(
                    session,
                    params['accountId'],
                    params['budgetId'],
                  ),
        ),
        'ageOfMoney': _i1.MethodConnector(
          name: 'ageOfMoney',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint).ageOfMoney(
                session,
                params['budgetId'],
              ),
        ),
        'createSplit': _i1.MethodConnector(
          name: 'createSplit',
          params: {
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'totalAmountCents': _i1.ParameterDescription(
              name: 'totalAmountCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _i1.ParameterDescription(
              name: 'currencyCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'transactionDate': _i1.ParameterDescription(
              name: 'transactionDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'splits': _i1.ParameterDescription(
              name: 'splits',
              type: _i1.getType<List<_i14.SplitItem>>(),
              nullable: false,
            ),
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint)
                  .createSplit(
                    session,
                    params['description'],
                    params['totalAmountCents'],
                    params['currencyCode'],
                    params['budgetId'],
                    params['transactionDate'],
                    params['splits'],
                    payeeId: params['payeeId'],
                    accountId: params['accountId'],
                  ),
        ),
        'listSplits': _i1.MethodConnector(
          name: 'listSplits',
          params: {
            'parentTransactionId': _i1.ParameterDescription(
              name: 'parentTransactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint).listSplits(
                session,
                params['parentTransactionId'],
              ),
        ),
        'bulkImport': _i1.MethodConnector(
          name: 'bulkImport',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'currencyCode': _i1.ParameterDescription(
              name: 'currencyCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'rows': _i1.ParameterDescription(
              name: 'rows',
              type: _i1.getType<List<_i15.ImportRow>>(),
              nullable: false,
            ),
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint).bulkImport(
                session,
                params['budgetId'],
                params['currencyCode'],
                params['rows'],
                accountId: params['accountId'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'transactionId': _i1.ParameterDescription(
              name: 'transactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i13.TransactionEndpoint).delete(
                session,
                params['transactionId'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i16.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i17.Endpoints()
      ..initializeEndpoints(server);
  }
}
