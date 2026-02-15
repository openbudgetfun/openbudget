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
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../budgets/budget_endpoint.dart' as _i4;
import '../budgets/budget_stream.dart' as _i5;
import '../categories/category_endpoint.dart' as _i6;
import '../envelopes/envelope_endpoint.dart' as _i7;
import '../transactions/transaction_endpoint.dart' as _i8;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i9;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i10;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()..initialize(server, 'emailIdp', null),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(server, 'jwtRefresh', null),
      'budget': _i4.BudgetEndpoint()..initialize(server, 'budget', null),
      'budgetStream': _i5.BudgetStreamEndpoint()
        ..initialize(server, 'budgetStream', null),
      'category': _i6.CategoryEndpoint()..initialize(server, 'category', null),
      'envelope': _i7.EnvelopeEndpoint()..initialize(server, 'envelope', null),
      'transaction': _i8.TransactionEndpoint()
        ..initialize(server, 'transaction', null),
    };
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
              (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
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
              (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).startRegistration(
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
              (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
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
              (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
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
              (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
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
              (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
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
              (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
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
              (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).hasAccount(
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
              (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
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
              (endpoints['budget'] as _i4.BudgetEndpoint).create(
                session,
                params['name'],
                params['currencyCode'],
              ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {},
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['budget'] as _i4.BudgetEndpoint).list(session),
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
              (endpoints['budget'] as _i4.BudgetEndpoint).get(
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
              (endpoints['budget'] as _i4.BudgetEndpoint).update(
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
              (endpoints['budget'] as _i4.BudgetEndpoint).delete(
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
              ) => (endpoints['budgetStream'] as _i5.BudgetStreamEndpoint)
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
              (endpoints['category'] as _i6.CategoryEndpoint).create(
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
              (endpoints['category'] as _i6.CategoryEndpoint).list(
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
              (endpoints['category'] as _i6.CategoryEndpoint).get(
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
              (endpoints['category'] as _i6.CategoryEndpoint).update(
                session,
                params['categoryId'],
                name: params['name'],
                sortOrder: params['sortOrder'],
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
              (endpoints['category'] as _i6.CategoryEndpoint).delete(
                session,
                params['categoryId'],
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
              (endpoints['envelope'] as _i7.EnvelopeEndpoint).create(
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
              (endpoints['envelope'] as _i7.EnvelopeEndpoint).list(
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
              (endpoints['envelope'] as _i7.EnvelopeEndpoint).get(
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
              (endpoints['envelope'] as _i7.EnvelopeEndpoint).update(
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
              (endpoints['envelope'] as _i7.EnvelopeEndpoint).delete(
                session,
                params['envelopeId'],
              ),
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
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i8.TransactionEndpoint).create(
                session,
                params['description'],
                params['amountCents'],
                params['currencyCode'],
                params['budgetId'],
                params['transactionDate'],
                envelopeId: params['envelopeId'],
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
              (endpoints['transaction'] as _i8.TransactionEndpoint).list(
                session,
                params['budgetId'],
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
              (endpoints['transaction'] as _i8.TransactionEndpoint).get(
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
            'transactionDate': _i1.ParameterDescription(
              name: 'transactionDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call: (_i1.Session session, Map<String, dynamic> params) async =>
              (endpoints['transaction'] as _i8.TransactionEndpoint).update(
                session,
                params['transactionId'],
                description: params['description'],
                amountCents: params['amountCents'],
                envelopeId: params['envelopeId'],
                transactionDate: params['transactionDate'],
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
              (endpoints['transaction'] as _i8.TransactionEndpoint).delete(
                session,
                params['transactionId'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i9.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i10.Endpoints()
      ..initializeEndpoints(server);
  }
}
