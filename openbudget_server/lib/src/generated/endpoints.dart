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
import '../auth/apple_idp_endpoint.dart' as _i3;
import '../auth/email_idp_endpoint.dart' as _i4;
import '../auth/google_idp_endpoint.dart' as _i5;
import '../auth/jwt_refresh_endpoint.dart' as _i6;
import '../budget_templates/budget_template_endpoint.dart' as _i7;
import '../budgets/budget_endpoint.dart' as _i8;
import '../budgets/budget_stream.dart' as _i9;
import '../categories/category_endpoint.dart' as _i10;
import '../envelope_goals/envelope_goal_endpoint.dart' as _i11;
import '../envelopes/envelope_endpoint.dart' as _i12;
import '../fx_rates/fx_rate_endpoint.dart' as _i13;
import '../monthly_allocations/monthly_allocation_endpoint.dart' as _i14;
import '../payees/payee_endpoint.dart' as _i15;
import '../plaid/plaid_endpoint.dart' as _i16;
import '../recurring_transactions/recurring_transaction_endpoint.dart' as _i17;
import '../solana_wallets/solana_wallet_endpoint.dart' as _i18;
import '../transaction_rules/transaction_rule_endpoint.dart' as _i19;
import '../transactions/transaction_endpoint.dart' as _i20;
import '../wallets/wallet_endpoint.dart' as _i21;
import 'package:openbudget_server/src/generated/transactions/split_item.dart'
    as _i22;
import 'package:openbudget_server/src/generated/transactions/import_row.dart'
    as _i23;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i24;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i25;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'account': _i2.AccountEndpoint()
        ..initialize(
          server,
          'account',
          null,
        ),
      'appleIdp': _i3.AppleIdpEndpoint()
        ..initialize(
          server,
          'appleIdp',
          null,
        ),
      'emailIdp': _i4.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'googleIdp': _i5.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'jwtRefresh': _i6.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'budgetTemplate': _i7.BudgetTemplateEndpoint()
        ..initialize(
          server,
          'budgetTemplate',
          null,
        ),
      'budget': _i8.BudgetEndpoint()
        ..initialize(
          server,
          'budget',
          null,
        ),
      'budgetStream': _i9.BudgetStreamEndpoint()
        ..initialize(
          server,
          'budgetStream',
          null,
        ),
      'category': _i10.CategoryEndpoint()
        ..initialize(
          server,
          'category',
          null,
        ),
      'envelopeGoal': _i11.EnvelopeGoalEndpoint()
        ..initialize(
          server,
          'envelopeGoal',
          null,
        ),
      'envelope': _i12.EnvelopeEndpoint()
        ..initialize(
          server,
          'envelope',
          null,
        ),
      'fxRate': _i13.FxRateEndpoint()
        ..initialize(
          server,
          'fxRate',
          null,
        ),
      'monthlyAllocation': _i14.MonthlyAllocationEndpoint()
        ..initialize(
          server,
          'monthlyAllocation',
          null,
        ),
      'payee': _i15.PayeeEndpoint()
        ..initialize(
          server,
          'payee',
          null,
        ),
      'plaid': _i16.PlaidEndpoint()
        ..initialize(
          server,
          'plaid',
          null,
        ),
      'recurringTransaction': _i17.RecurringTransactionEndpoint()
        ..initialize(
          server,
          'recurringTransaction',
          null,
        ),
      'solanaWallet': _i18.SolanaWalletEndpoint()
        ..initialize(
          server,
          'solanaWallet',
          null,
        ),
      'transactionRule': _i19.TransactionRuleEndpoint()
        ..initialize(
          server,
          'transactionRule',
          null,
        ),
      'transaction': _i20.TransactionEndpoint()
        ..initialize(
          server,
          'transaction',
          null,
        ),
      'wallet': _i21.WalletEndpoint()
        ..initialize(
          server,
          'wallet',
          null,
        ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _i2.AccountEndpoint).create(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _i2.AccountEndpoint).list(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _i2.AccountEndpoint).get(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _i2.AccountEndpoint).update(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _i2.AccountEndpoint).delete(
                session,
                params['accountId'],
              ),
        ),
      },
    );
    connectors['appleIdp'] = _i1.EndpointConnector(
      name: 'appleIdp',
      endpoint: endpoints['appleIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'identityToken': _i1.ParameterDescription(
              name: 'identityToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'authorizationCode': _i1.ParameterDescription(
              name: 'authorizationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isNativeApplePlatformSignIn': _i1.ParameterDescription(
              name: 'isNativeApplePlatformSignIn',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'firstName': _i1.ParameterDescription(
              name: 'firstName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'lastName': _i1.ParameterDescription(
              name: 'lastName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appleIdp'] as _i3.AppleIdpEndpoint).login(
                session,
                identityToken: params['identityToken'],
                authorizationCode: params['authorizationCode'],
                isNativeApplePlatformSignIn:
                    params['isNativeApplePlatformSignIn'],
                firstName: params['firstName'],
                lastName: params['lastName'],
              ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appleIdp'] as _i3.AppleIdpEndpoint)
                  .hasAccount(session),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i4.EmailIdpEndpoint).login(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i4.EmailIdpEndpoint)
                  .startRegistration(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i4.EmailIdpEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i4.EmailIdpEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i4.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i4.EmailIdpEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i4.EmailIdpEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i4.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['googleIdp'] = _i1.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'idToken': _i1.ParameterDescription(
              name: 'idToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'accessToken': _i1.ParameterDescription(
              name: 'accessToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['googleIdp'] as _i5.GoogleIdpEndpoint).login(
                    session,
                    idToken: params['idToken'],
                    accessToken: params['accessToken'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i5.GoogleIdpEndpoint)
                  .hasAccount(session),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i6.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['budgetTemplate'] = _i1.EndpointConnector(
      name: 'budgetTemplate',
      endpoint: endpoints['budgetTemplate']!,
      methodConnectors: {
        'saveFromMonth': _i1.MethodConnector(
          name: 'saveFromMonth',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budgetTemplate'] as _i7.BudgetTemplateEndpoint)
                      .saveFromMonth(
                        session,
                        params['budgetId'],
                        params['name'],
                        params['year'],
                        params['month'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budgetTemplate'] as _i7.BudgetTemplateEndpoint)
                      .list(
                        session,
                        params['budgetId'],
                      ),
        ),
        'applyToMonth': _i1.MethodConnector(
          name: 'applyToMonth',
          params: {
            'templateId': _i1.ParameterDescription(
              name: 'templateId',
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budgetTemplate'] as _i7.BudgetTemplateEndpoint)
                      .applyToMonth(
                        session,
                        params['templateId'],
                        params['budgetId'],
                        params['year'],
                        params['month'],
                      ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'templateId': _i1.ParameterDescription(
              name: 'templateId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budgetTemplate'] as _i7.BudgetTemplateEndpoint)
                      .delete(
                        session,
                        params['templateId'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['budget'] as _i8.BudgetEndpoint).create(
                session,
                params['name'],
                params['currencyCode'],
              ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budget'] as _i8.BudgetEndpoint).list(session),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['budget'] as _i8.BudgetEndpoint).get(
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
            'displayCurrencyCode': _i1.ParameterDescription(
              name: 'displayCurrencyCode',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'clearDisplayCurrencyCode': _i1.ParameterDescription(
              name: 'clearDisplayCurrencyCode',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['budget'] as _i8.BudgetEndpoint).update(
                session,
                params['budgetId'],
                name: params['name'],
                currencyCode: params['currencyCode'],
                displayCurrencyCode: params['displayCurrencyCode'],
                clearDisplayCurrencyCode: params['clearDisplayCurrencyCode'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['budget'] as _i8.BudgetEndpoint).delete(
                session,
                params['budgetId'],
              ),
        ),
        'exportData': _i1.MethodConnector(
          name: 'exportData',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['budget'] as _i8.BudgetEndpoint).exportData(
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
              ) => (endpoints['budgetStream'] as _i9.BudgetStreamEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _i10.CategoryEndpoint).create(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i10.CategoryEndpoint).list(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i10.CategoryEndpoint).get(
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
            'isHidden': _i1.ParameterDescription(
              name: 'isHidden',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _i10.CategoryEndpoint).update(
                    session,
                    params['categoryId'],
                    name: params['name'],
                    sortOrder: params['sortOrder'],
                    isHidden: params['isHidden'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _i10.CategoryEndpoint).reorder(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _i10.CategoryEndpoint).delete(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelopeGoal'] as _i11.EnvelopeGoalEndpoint)
                      .upsert(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelopeGoal'] as _i11.EnvelopeGoalEndpoint)
                      .getForEnvelope(
                        session,
                        params['envelopeId'],
                      ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelopeGoal'] as _i11.EnvelopeGoalEndpoint)
                      .listForEnvelopes(
                        session,
                        params['envelopeIds'],
                      ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelopeGoal'] as _i11.EnvelopeGoalEndpoint)
                      .delete(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _i12.EnvelopeEndpoint).create(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['envelope'] as _i12.EnvelopeEndpoint).list(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['envelope'] as _i12.EnvelopeEndpoint).get(
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
            'note': _i1.ParameterDescription(
              name: 'note',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'isHidden': _i1.ParameterDescription(
              name: 'isHidden',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _i12.EnvelopeEndpoint).update(
                    session,
                    params['envelopeId'],
                    name: params['name'],
                    budgetedAmountCents: params['budgetedAmountCents'],
                    spentAmountCents: params['spentAmountCents'],
                    note: params['note'],
                    isHidden: params['isHidden'],
                  ),
        ),
        'reorder': _i1.MethodConnector(
          name: 'reorder',
          params: {
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'envelopeIds': _i1.ParameterDescription(
              name: 'envelopeIds',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _i12.EnvelopeEndpoint).reorder(
                    session,
                    params['categoryId'],
                    params['envelopeIds'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _i12.EnvelopeEndpoint).delete(
                    session,
                    params['envelopeId'],
                  ),
        ),
      },
    );
    connectors['fxRate'] = _i1.EndpointConnector(
      name: 'fxRate',
      endpoint: endpoints['fxRate']!,
      methodConnectors: {
        'latest': _i1.MethodConnector(
          name: 'latest',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['fxRate'] as _i13.FxRateEndpoint).latest(session),
        ),
        'refresh': _i1.MethodConnector(
          name: 'refresh',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['fxRate'] as _i13.FxRateEndpoint).refresh(session),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _i14.MonthlyAllocationEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _i14.MonthlyAllocationEndpoint)
                      .list(
                        session,
                        params['budgetId'],
                        params['year'],
                        params['month'],
                      ),
        ),
        'copyMonth': _i1.MethodConnector(
          name: 'copyMonth',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'sourceYear': _i1.ParameterDescription(
              name: 'sourceYear',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'sourceMonth': _i1.ParameterDescription(
              name: 'sourceMonth',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'targetYear': _i1.ParameterDescription(
              name: 'targetYear',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'targetMonth': _i1.ParameterDescription(
              name: 'targetMonth',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _i14.MonthlyAllocationEndpoint)
                      .copyMonth(
                        session,
                        params['budgetId'],
                        params['sourceYear'],
                        params['sourceMonth'],
                        params['targetYear'],
                        params['targetMonth'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _i14.MonthlyAllocationEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _i14.MonthlyAllocationEndpoint)
                      .delete(
                        session,
                        params['allocationId'],
                      ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i15.PayeeEndpoint).create(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i15.PayeeEndpoint).list(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i15.PayeeEndpoint).get(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i15.PayeeEndpoint).update(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['payee'] as _i15.PayeeEndpoint).lastUsedEnvelopeId(
                    session,
                    params['payeeId'],
                    params['budgetId'],
                  ),
        ),
        'merge': _i1.MethodConnector(
          name: 'merge',
          params: {
            'sourcePayeeId': _i1.ParameterDescription(
              name: 'sourcePayeeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'targetPayeeId': _i1.ParameterDescription(
              name: 'targetPayeeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i15.PayeeEndpoint).merge(
                session,
                params['sourcePayeeId'],
                params['targetPayeeId'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i15.PayeeEndpoint).delete(
                session,
                params['payeeId'],
              ),
        ),
      },
    );
    connectors['plaid'] = _i1.EndpointConnector(
      name: 'plaid',
      endpoint: endpoints['plaid']!,
      methodConnectors: {
        'createLinkToken': _i1.MethodConnector(
          name: 'createLinkToken',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['plaid'] as _i16.PlaidEndpoint).createLinkToken(
                    session,
                    params['budgetId'],
                  ),
        ),
        'exchangePublicToken': _i1.MethodConnector(
          name: 'exchangePublicToken',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'publicToken': _i1.ParameterDescription(
              name: 'publicToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['plaid'] as _i16.PlaidEndpoint)
                  .exchangePublicToken(
                    session,
                    params['budgetId'],
                    params['publicToken'],
                  ),
        ),
        'syncConnection': _i1.MethodConnector(
          name: 'syncConnection',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'connectionId': _i1.ParameterDescription(
              name: 'connectionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['plaid'] as _i16.PlaidEndpoint).syncConnection(
                    session,
                    params['budgetId'],
                    params['connectionId'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _i17.RecurringTransactionEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _i17.RecurringTransactionEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _i17.RecurringTransactionEndpoint)
                      .get(
                        session,
                        params['recurringTransactionId'],
                      ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _i17.RecurringTransactionEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _i17.RecurringTransactionEndpoint)
                      .delete(
                        session,
                        params['recurringTransactionId'],
                      ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _i17.RecurringTransactionEndpoint)
                      .skipOccurrence(
                        session,
                        params['recurringTransactionId'],
                      ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _i17.RecurringTransactionEndpoint)
                      .postDue(
                        session,
                        params['budgetId'],
                      ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _i17.RecurringTransactionEndpoint)
                      .countDue(
                        session,
                        params['budgetId'],
                      ),
        ),
      },
    );
    connectors['solanaWallet'] = _i1.EndpointConnector(
      name: 'solanaWallet',
      endpoint: endpoints['solanaWallet']!,
      methodConnectors: {
        'attach': _i1.MethodConnector(
          name: 'attach',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'address': _i1.ParameterDescription(
              name: 'address',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'cluster': _i1.ParameterDescription(
              name: 'cluster',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _i18.SolanaWalletEndpoint)
                      .attach(
                        session,
                        params['budgetId'],
                        params['accountId'],
                        params['address'],
                        label: params['label'],
                        cluster: params['cluster'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _i18.SolanaWalletEndpoint).list(
                    session,
                    params['budgetId'],
                  ),
        ),
        'getForAccount': _i1.MethodConnector(
          name: 'getForAccount',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _i18.SolanaWalletEndpoint)
                      .getForAccount(
                        session,
                        params['budgetId'],
                        params['accountId'],
                      ),
        ),
        'sync': _i1.MethodConnector(
          name: 'sync',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'walletId': _i1.ParameterDescription(
              name: 'walletId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _i18.SolanaWalletEndpoint).sync(
                    session,
                    params['budgetId'],
                    params['walletId'],
                    limit: params['limit'],
                  ),
        ),
        'listTransactions': _i1.MethodConnector(
          name: 'listTransactions',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'walletId': _i1.ParameterDescription(
              name: 'walletId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _i18.SolanaWalletEndpoint)
                      .listTransactions(
                        session,
                        params['budgetId'],
                        params['walletId'],
                        limit: params['limit'],
                      ),
        ),
        'listHoldings': _i1.MethodConnector(
          name: 'listHoldings',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'walletId': _i1.ParameterDescription(
              name: 'walletId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _i18.SolanaWalletEndpoint)
                      .listHoldings(
                        session,
                        params['budgetId'],
                        params['walletId'],
                      ),
        ),
        'updateTransactionMetadata': _i1.MethodConnector(
          name: 'updateTransactionMetadata',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'transactionId': _i1.ParameterDescription(
              name: 'transactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'category': _i1.ParameterDescription(
              name: 'category',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'tagsCsv': _i1.ParameterDescription(
              name: 'tagsCsv',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'memo': _i1.ParameterDescription(
              name: 'memo',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _i18.SolanaWalletEndpoint)
                      .updateTransactionMetadata(
                        session,
                        params['budgetId'],
                        params['transactionId'],
                        category: params['category'],
                        tagsCsv: params['tagsCsv'],
                        memo: params['memo'],
                      ),
        ),
      },
    );
    connectors['transactionRule'] = _i1.EndpointConnector(
      name: 'transactionRule',
      endpoint: endpoints['transactionRule']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'targetEnvelopeId': _i1.ParameterDescription(
              name: 'targetEnvelopeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule'] as _i19.TransactionRuleEndpoint)
                      .create(
                        session,
                        params['budgetId'],
                        params['payeeId'],
                        params['targetEnvelopeId'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule'] as _i19.TransactionRuleEndpoint)
                      .list(
                        session,
                        params['budgetId'],
                      ),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'ruleId': _i1.ParameterDescription(
              name: 'ruleId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule'] as _i19.TransactionRuleEndpoint)
                      .get(
                        session,
                        params['ruleId'],
                      ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'ruleId': _i1.ParameterDescription(
              name: 'ruleId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'targetEnvelopeId': _i1.ParameterDescription(
              name: 'targetEnvelopeId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'enabled': _i1.ParameterDescription(
              name: 'enabled',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule'] as _i19.TransactionRuleEndpoint)
                      .update(
                        session,
                        params['ruleId'],
                        targetEnvelopeId: params['targetEnvelopeId'],
                        enabled: params['enabled'],
                      ),
        ),
        'findMatchingEnvelope': _i1.MethodConnector(
          name: 'findMatchingEnvelope',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'payeeId': _i1.ParameterDescription(
              name: 'payeeId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule'] as _i19.TransactionRuleEndpoint)
                      .findMatchingEnvelope(
                        session,
                        params['budgetId'],
                        params['payeeId'],
                      ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'ruleId': _i1.ParameterDescription(
              name: 'ruleId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule'] as _i19.TransactionRuleEndpoint)
                      .delete(
                        session,
                        params['ruleId'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _i20.TransactionEndpoint).create(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _i20.TransactionEndpoint).list(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _i20.TransactionEndpoint).get(
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
            'flagColor': _i1.ParameterDescription(
              name: 'flagColor',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _i20.TransactionEndpoint).update(
                    session,
                    params['transactionId'],
                    description: params['description'],
                    amountCents: params['amountCents'],
                    envelopeId: params['envelopeId'],
                    payeeId: params['payeeId'],
                    transactionDate: params['transactionDate'],
                    memo: params['memo'],
                    flagColor: params['flagColor'],
                  ),
        ),
        'setFlag': _i1.MethodConnector(
          name: 'setFlag',
          params: {
            'transactionId': _i1.ParameterDescription(
              name: 'transactionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'flagColor': _i1.ParameterDescription(
              name: 'flagColor',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
                  .setFlag(
                    session,
                    params['transactionId'],
                    flagColor: params['flagColor'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
                  .transfer(
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
                  .toggleCleared(
                    session,
                    params['transactionId'],
                  ),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
                  .reconcileAccount(
                    session,
                    params['accountId'],
                    params['budgetId'],
                  ),
        ),
        'reconcileWithBalance': _i1.MethodConnector(
          name: 'reconcileWithBalance',
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
            'statementBalanceCents': _i1.ParameterDescription(
              name: 'statementBalanceCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
                  .reconcileWithBalance(
                    session,
                    params['accountId'],
                    params['budgetId'],
                    params['statementBalanceCents'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
                  .ageOfMoney(
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
              type: _i1.getType<List<_i22.SplitItem>>(),
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
                  .listSplits(
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
              type: _i1.getType<List<_i23.ImportRow>>(),
              nullable: false,
            ),
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
                  .bulkImport(
                    session,
                    params['budgetId'],
                    params['currencyCode'],
                    params['rows'],
                    accountId: params['accountId'],
                  ),
        ),
        'findDuplicates': _i1.MethodConnector(
          name: 'findDuplicates',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'amountCents': _i1.ParameterDescription(
              name: 'amountCents',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'transactionDate': _i1.ParameterDescription(
              name: 'transactionDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['transaction'] as _i20.TransactionEndpoint)
                  .findDuplicates(
                    session,
                    params['budgetId'],
                    params['amountCents'],
                    params['transactionDate'],
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
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _i20.TransactionEndpoint).delete(
                    session,
                    params['transactionId'],
                  ),
        ),
      },
    );
    connectors['wallet'] = _i1.EndpointConnector(
      name: 'wallet',
      endpoint: endpoints['wallet']!,
      methodConnectors: {
        'connectSolanaWallet': _i1.MethodConnector(
          name: 'connectSolanaWallet',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'address': _i1.ParameterDescription(
              name: 'address',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'onBudget': _i1.ParameterDescription(
              name: 'onBudget',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['wallet'] as _i21.WalletEndpoint)
                  .connectSolanaWallet(
                    session,
                    params['budgetId'],
                    params['address'],
                    label: params['label'],
                    onBudget: params['onBudget'],
                  ),
        ),
        'refreshSolanaWallet': _i1.MethodConnector(
          name: 'refreshSolanaWallet',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'connectionId': _i1.ParameterDescription(
              name: 'connectionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['wallet'] as _i21.WalletEndpoint)
                  .refreshSolanaWallet(
                    session,
                    params['budgetId'],
                    params['connectionId'],
                  ),
        ),
        'listWalletHoldings': _i1.MethodConnector(
          name: 'listWalletHoldings',
          params: {
            'budgetId': _i1.ParameterDescription(
              name: 'budgetId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'connectionId': _i1.ParameterDescription(
              name: 'connectionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['wallet'] as _i21.WalletEndpoint)
                  .listWalletHoldings(
                    session,
                    params['budgetId'],
                    params['connectionId'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i24.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i25.Endpoints()
      ..initializeEndpoints(server);
  }
}
