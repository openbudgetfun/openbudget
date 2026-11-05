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
import 'package:openbudget_server/src/generated/transactions/import_row.dart'
    as _iyod81ld;
import 'package:openbudget_server/src/generated/transactions/split_item.dart'
    as _ii8zyh2l;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;

import '../accounts/account_endpoint.dart' as _izzfgwyn;
import '../auth/apple_idp_endpoint.dart' as _ilq63su8;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/google_idp_endpoint.dart' as _i71axiz0;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../budget_templates/budget_template_endpoint.dart' as _i3p5ie4r;
import '../budgets/budget_endpoint.dart' as _in8w6wxx;
import '../budgets/budget_stream.dart' as _i5nzdilh;
import '../categories/category_endpoint.dart' as _irthghnb;
import '../envelope_goals/envelope_goal_endpoint.dart' as _i76paldx;
import '../envelopes/envelope_endpoint.dart' as _in6dn9dl;
import '../fx_rates/fx_rate_endpoint.dart' as _i7xoygut;
import '../institutions/institution_endpoint.dart' as _i9rhv37i;
import '../monthly_allocations/monthly_allocation_endpoint.dart' as _ilfvovcz;
import '../payees/payee_endpoint.dart' as _i5rb0bcw;
import '../plaid/plaid_endpoint.dart' as _i9pkxqxw;
import '../recurring_transactions/recurring_transaction_endpoint.dart'
    as _ipwgw1dv;
import '../solana_wallets/solana_wallet_endpoint.dart' as _in77fwrc;
import '../transaction_rules/transaction_rule_endpoint.dart' as _i70s5v1k;
import '../transactions/transaction_endpoint.dart' as _if8xv4dr;
import '../wallets/wallet_endpoint.dart' as _i1ub0otr;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'account': _izzfgwyn.AccountEndpoint()
        ..initialize(
          server,
          'account',
          null,
        ),
      'appleIdp': _ilq63su8.AppleIdpEndpoint()
        ..initialize(
          server,
          'appleIdp',
          null,
        ),
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'googleIdp': _i71axiz0.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'budgetTemplate': _i3p5ie4r.BudgetTemplateEndpoint()
        ..initialize(
          server,
          'budgetTemplate',
          null,
        ),
      'budget': _in8w6wxx.BudgetEndpoint()
        ..initialize(
          server,
          'budget',
          null,
        ),
      'budgetStream': _i5nzdilh.BudgetStreamEndpoint()
        ..initialize(
          server,
          'budgetStream',
          null,
        ),
      'category': _irthghnb.CategoryEndpoint()
        ..initialize(
          server,
          'category',
          null,
        ),
      'envelopeGoal': _i76paldx.EnvelopeGoalEndpoint()
        ..initialize(
          server,
          'envelopeGoal',
          null,
        ),
      'envelope': _in6dn9dl.EnvelopeEndpoint()
        ..initialize(
          server,
          'envelope',
          null,
        ),
      'fxRate': _i7xoygut.FxRateEndpoint()
        ..initialize(
          server,
          'fxRate',
          null,
        ),
      'institution': _i9rhv37i.InstitutionEndpoint()
        ..initialize(
          server,
          'institution',
          null,
        ),
      'monthlyAllocation': _ilfvovcz.MonthlyAllocationEndpoint()
        ..initialize(
          server,
          'monthlyAllocation',
          null,
        ),
      'payee': _i5rb0bcw.PayeeEndpoint()
        ..initialize(
          server,
          'payee',
          null,
        ),
      'plaid': _i9pkxqxw.PlaidEndpoint()
        ..initialize(
          server,
          'plaid',
          null,
        ),
      'recurringTransaction': _ipwgw1dv.RecurringTransactionEndpoint()
        ..initialize(
          server,
          'recurringTransaction',
          null,
        ),
      'solanaWallet': _in77fwrc.SolanaWalletEndpoint()
        ..initialize(
          server,
          'solanaWallet',
          null,
        ),
      'transactionRule': _i70s5v1k.TransactionRuleEndpoint()
        ..initialize(
          server,
          'transactionRule',
          null,
        ),
      'transaction': _if8xv4dr.TransactionEndpoint()
        ..initialize(
          server,
          'transaction',
          null,
        ),
      'wallet': _i1ub0otr.WalletEndpoint()
        ..initialize(
          server,
          'wallet',
          null,
        ),
    };
    connectors['account'] = _is.EndpointConnector(
      name: 'account',
      endpoint: endpoints['account']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'accountType': _is.ParameterDescription(
              name: 'accountType',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'balanceCents': _is.ParameterDescription(
              name: 'balanceCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'onBudget': _is.ParameterDescription(
              name: 'onBudget',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'sortOrder': _is.ParameterDescription(
              name: 'sortOrder',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'institutionId': _is.ParameterDescription(
              name: 'institutionId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).create(
                    session,
                    params['name'],
                    params['accountType'],
                    params['balanceCents'],
                    params['currencyCode'],
                    params['budgetId'],
                    onBudget: params['onBudget'],
                    sortOrder: params['sortOrder'],
                    institutionId: params['institutionId'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).list(
                    session,
                    params['budgetId'],
                  ),
        ),
        'listMine': _is.MethodConnector(
          name: 'listMine',
          params: {
            'excludeBudgetId': _is.ParameterDescription(
              name: 'excludeBudgetId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).listMine(
                    session,
                    excludeBudgetId: params['excludeBudgetId'],
                  ),
        ),
        'addMineToBudget': _is.MethodConnector(
          name: 'addMineToBudget',
          params: {
            'sourceAccountId': _is.ParameterDescription(
              name: 'sourceAccountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _izzfgwyn.AccountEndpoint)
                  .addMineToBudget(
                    session,
                    params['sourceAccountId'],
                    params['budgetId'],
                  ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).get(
                    session,
                    params['accountId'],
                  ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'accountType': _is.ParameterDescription(
              name: 'accountType',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'balanceCents': _is.ParameterDescription(
              name: 'balanceCents',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'onBudget': _is.ParameterDescription(
              name: 'onBudget',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'sortOrder': _is.ParameterDescription(
              name: 'sortOrder',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'isClosed': _is.ParameterDescription(
              name: 'isClosed',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).update(
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
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).delete(
                    session,
                    params['accountId'],
                  ),
        ),
      },
    );
    connectors['appleIdp'] = _is.EndpointConnector(
      name: 'appleIdp',
      endpoint: endpoints['appleIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'identityToken': _is.ParameterDescription(
              name: 'identityToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'authorizationCode': _is.ParameterDescription(
              name: 'authorizationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'isNativeApplePlatformSignIn': _is.ParameterDescription(
              name: 'isNativeApplePlatformSignIn',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'firstName': _is.ParameterDescription(
              name: 'firstName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'lastName': _is.ParameterDescription(
              name: 'lastName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['appleIdp'] as _ilq63su8.AppleIdpEndpoint).login(
                    session,
                    identityToken: params['identityToken'],
                    authorizationCode: params['authorizationCode'],
                    isNativeApplePlatformSignIn:
                        params['isNativeApplePlatformSignIn'],
                    firstName: params['firstName'],
                    lastName: params['lastName'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appleIdp'] as _ilq63su8.AppleIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['googleIdp'] = _is.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'idToken': _is.ParameterDescription(
              name: 'idToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'accessToken': _is.ParameterDescription(
              name: 'accessToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['googleIdp'] as _i71axiz0.GoogleIdpEndpoint).login(
                    session,
                    idToken: params['idToken'],
                    accessToken: params['accessToken'],
                  ),
        ),
        'loginWithCode': _is.MethodConnector(
          name: 'loginWithCode',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'codeVerifier': _is.ParameterDescription(
              name: 'codeVerifier',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'redirectUri': _is.ParameterDescription(
              name: 'redirectUri',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i71axiz0.GoogleIdpEndpoint)
                  .loginWithCode(
                    session,
                    code: params['code'],
                    codeVerifier: params['codeVerifier'],
                    redirectUri: params['redirectUri'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i71axiz0.GoogleIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['budgetTemplate'] = _is.EndpointConnector(
      name: 'budgetTemplate',
      endpoint: endpoints['budgetTemplate']!,
      methodConnectors: {
        'saveFromMonth': _is.MethodConnector(
          name: 'saveFromMonth',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'year': _is.ParameterDescription(
              name: 'year',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budgetTemplate']
                          as _i3p5ie4r.BudgetTemplateEndpoint)
                      .saveFromMonth(
                        session,
                        params['budgetId'],
                        params['name'],
                        params['year'],
                        params['month'],
                      ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budgetTemplate']
                          as _i3p5ie4r.BudgetTemplateEndpoint)
                      .list(
                        session,
                        params['budgetId'],
                      ),
        ),
        'applyToMonth': _is.MethodConnector(
          name: 'applyToMonth',
          params: {
            'templateId': _is.ParameterDescription(
              name: 'templateId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'year': _is.ParameterDescription(
              name: 'year',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budgetTemplate']
                          as _i3p5ie4r.BudgetTemplateEndpoint)
                      .applyToMonth(
                        session,
                        params['templateId'],
                        params['budgetId'],
                        params['year'],
                        params['month'],
                      ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'templateId': _is.ParameterDescription(
              name: 'templateId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budgetTemplate']
                          as _i3p5ie4r.BudgetTemplateEndpoint)
                      .delete(
                        session,
                        params['templateId'],
                      ),
        ),
      },
    );
    connectors['budget'] = _is.EndpointConnector(
      name: 'budget',
      endpoint: endpoints['budget']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budget'] as _in8w6wxx.BudgetEndpoint).create(
                    session,
                    params['name'],
                    params['currencyCode'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['budget'] as _in8w6wxx.BudgetEndpoint).list(
                session,
              ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['budget'] as _in8w6wxx.BudgetEndpoint).get(
                session,
                params['budgetId'],
              ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'displayCurrencyCode': _is.ParameterDescription(
              name: 'displayCurrencyCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'clearDisplayCurrencyCode': _is.ParameterDescription(
              name: 'clearDisplayCurrencyCode',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budget'] as _in8w6wxx.BudgetEndpoint).update(
                    session,
                    params['budgetId'],
                    name: params['name'],
                    currencyCode: params['currencyCode'],
                    displayCurrencyCode: params['displayCurrencyCode'],
                    clearDisplayCurrencyCode:
                        params['clearDisplayCurrencyCode'],
                  ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budget'] as _in8w6wxx.BudgetEndpoint).delete(
                    session,
                    params['budgetId'],
                  ),
        ),
        'exportData': _is.MethodConnector(
          name: 'exportData',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budget'] as _in8w6wxx.BudgetEndpoint).exportData(
                    session,
                    params['budgetId'],
                  ),
        ),
      },
    );
    connectors['budgetStream'] = _is.EndpointConnector(
      name: 'budgetStream',
      endpoint: endpoints['budgetStream']!,
      methodConnectors: {
        'budgetUpdates': _is.MethodStreamConnector(
          name: 'budgetUpdates',
          params: {},
          streamParams: {
            'budgetIdStream': _is.StreamParameterDescription<_is.UuidValue>(
              name: 'budgetIdStream',
              nullable: false,
            ),
          },
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['budgetStream'] as _i5nzdilh.BudgetStreamEndpoint)
                  .budgetUpdates(
                    session,
                    streamParams['budgetIdStream']!.cast<_is.UuidValue>(),
                  ),
        ),
      },
    );
    connectors['category'] = _is.EndpointConnector(
      name: 'category',
      endpoint: endpoints['category']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'sortOrder': _is.ParameterDescription(
              name: 'sortOrder',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _irthghnb.CategoryEndpoint).create(
                    session,
                    params['name'],
                    params['budgetId'],
                    params['sortOrder'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _irthghnb.CategoryEndpoint).list(
                    session,
                    params['budgetId'],
                  ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'categoryId': _is.ParameterDescription(
              name: 'categoryId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _irthghnb.CategoryEndpoint).get(
                    session,
                    params['categoryId'],
                  ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'categoryId': _is.ParameterDescription(
              name: 'categoryId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'sortOrder': _is.ParameterDescription(
              name: 'sortOrder',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'isHidden': _is.ParameterDescription(
              name: 'isHidden',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _irthghnb.CategoryEndpoint).update(
                    session,
                    params['categoryId'],
                    name: params['name'],
                    sortOrder: params['sortOrder'],
                    isHidden: params['isHidden'],
                  ),
        ),
        'reorder': _is.MethodConnector(
          name: 'reorder',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'categoryIds': _is.ParameterDescription(
              name: 'categoryIds',
              type: _is.getType<List<_is.UuidValue>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _irthghnb.CategoryEndpoint).reorder(
                    session,
                    params['budgetId'],
                    params['categoryIds'],
                  ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'categoryId': _is.ParameterDescription(
              name: 'categoryId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _irthghnb.CategoryEndpoint).delete(
                    session,
                    params['categoryId'],
                  ),
        ),
      },
    );
    connectors['envelopeGoal'] = _is.EndpointConnector(
      name: 'envelopeGoal',
      endpoint: endpoints['envelopeGoal']!,
      methodConnectors: {
        'upsert': _is.MethodConnector(
          name: 'upsert',
          params: {
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'goalType': _is.ParameterDescription(
              name: 'goalType',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'targetAmountCents': _is.ParameterDescription(
              name: 'targetAmountCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'targetDate': _is.ParameterDescription(
              name: 'targetDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'monthlyFundingCents': _is.ParameterDescription(
              name: 'monthlyFundingCents',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelopeGoal'] as _i76paldx.EnvelopeGoalEndpoint)
                      .upsert(
                        session,
                        params['envelopeId'],
                        params['goalType'],
                        params['targetAmountCents'],
                        targetDate: params['targetDate'],
                        monthlyFundingCents: params['monthlyFundingCents'],
                      ),
        ),
        'getForEnvelope': _is.MethodConnector(
          name: 'getForEnvelope',
          params: {
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelopeGoal'] as _i76paldx.EnvelopeGoalEndpoint)
                      .getForEnvelope(
                        session,
                        params['envelopeId'],
                      ),
        ),
        'listForEnvelopes': _is.MethodConnector(
          name: 'listForEnvelopes',
          params: {
            'envelopeIds': _is.ParameterDescription(
              name: 'envelopeIds',
              type: _is.getType<List<_is.UuidValue>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelopeGoal'] as _i76paldx.EnvelopeGoalEndpoint)
                      .listForEnvelopes(
                        session,
                        params['envelopeIds'],
                      ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'goalId': _is.ParameterDescription(
              name: 'goalId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelopeGoal'] as _i76paldx.EnvelopeGoalEndpoint)
                      .delete(
                        session,
                        params['goalId'],
                      ),
        ),
      },
    );
    connectors['envelope'] = _is.EndpointConnector(
      name: 'envelope',
      endpoint: endpoints['envelope']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'categoryId': _is.ParameterDescription(
              name: 'categoryId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'budgetedAmountCents': _is.ParameterDescription(
              name: 'budgetedAmountCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _in6dn9dl.EnvelopeEndpoint).create(
                    session,
                    params['name'],
                    params['categoryId'],
                    params['budgetedAmountCents'],
                    params['currencyCode'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'categoryId': _is.ParameterDescription(
              name: 'categoryId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _in6dn9dl.EnvelopeEndpoint).list(
                    session,
                    params['categoryId'],
                  ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _in6dn9dl.EnvelopeEndpoint).get(
                    session,
                    params['envelopeId'],
                  ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'budgetedAmountCents': _is.ParameterDescription(
              name: 'budgetedAmountCents',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'spentAmountCents': _is.ParameterDescription(
              name: 'spentAmountCents',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'isHidden': _is.ParameterDescription(
              name: 'isHidden',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _in6dn9dl.EnvelopeEndpoint).update(
                    session,
                    params['envelopeId'],
                    name: params['name'],
                    budgetedAmountCents: params['budgetedAmountCents'],
                    spentAmountCents: params['spentAmountCents'],
                    note: params['note'],
                    isHidden: params['isHidden'],
                  ),
        ),
        'reorder': _is.MethodConnector(
          name: 'reorder',
          params: {
            'categoryId': _is.ParameterDescription(
              name: 'categoryId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'envelopeIds': _is.ParameterDescription(
              name: 'envelopeIds',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _in6dn9dl.EnvelopeEndpoint).reorder(
                    session,
                    params['categoryId'],
                    params['envelopeIds'],
                  ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _in6dn9dl.EnvelopeEndpoint).delete(
                    session,
                    params['envelopeId'],
                  ),
        ),
      },
    );
    connectors['fxRate'] = _is.EndpointConnector(
      name: 'fxRate',
      endpoint: endpoints['fxRate']!,
      methodConnectors: {
        'latest': _is.MethodConnector(
          name: 'latest',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fxRate'] as _i7xoygut.FxRateEndpoint)
                  .latest(session),
        ),
        'refresh': _is.MethodConnector(
          name: 'refresh',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fxRate'] as _i7xoygut.FxRateEndpoint)
                  .refresh(session),
        ),
      },
    );
    connectors['institution'] = _is.EndpointConnector(
      name: 'institution',
      endpoint: endpoints['institution']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'locationCode': _is.ParameterDescription(
              name: 'locationCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['institution'] as _i9rhv37i.InstitutionEndpoint)
                      .list(
                        session,
                        locationCode: params['locationCode'],
                      ),
        ),
      },
    );
    connectors['monthlyAllocation'] = _is.EndpointConnector(
      name: 'monthlyAllocation',
      endpoint: endpoints['monthlyAllocation']!,
      methodConnectors: {
        'upsert': _is.MethodConnector(
          name: 'upsert',
          params: {
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'year': _is.ParameterDescription(
              name: 'year',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'allocatedCents': _is.ParameterDescription(
              name: 'allocatedCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'carryoverCents': _is.ParameterDescription(
              name: 'carryoverCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _ilfvovcz.MonthlyAllocationEndpoint)
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
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'year': _is.ParameterDescription(
              name: 'year',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _ilfvovcz.MonthlyAllocationEndpoint)
                      .list(
                        session,
                        params['budgetId'],
                        params['year'],
                        params['month'],
                      ),
        ),
        'copyMonth': _is.MethodConnector(
          name: 'copyMonth',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'sourceYear': _is.ParameterDescription(
              name: 'sourceYear',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'sourceMonth': _is.ParameterDescription(
              name: 'sourceMonth',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'targetYear': _is.ParameterDescription(
              name: 'targetYear',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'targetMonth': _is.ParameterDescription(
              name: 'targetMonth',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _ilfvovcz.MonthlyAllocationEndpoint)
                      .copyMonth(
                        session,
                        params['budgetId'],
                        params['sourceYear'],
                        params['sourceMonth'],
                        params['targetYear'],
                        params['targetMonth'],
                      ),
        ),
        'moveMoney': _is.MethodConnector(
          name: 'moveMoney',
          params: {
            'fromEnvelopeId': _is.ParameterDescription(
              name: 'fromEnvelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'toEnvelopeId': _is.ParameterDescription(
              name: 'toEnvelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'year': _is.ParameterDescription(
              name: 'year',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'amountCents': _is.ParameterDescription(
              name: 'amountCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _ilfvovcz.MonthlyAllocationEndpoint)
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
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'allocationId': _is.ParameterDescription(
              name: 'allocationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['monthlyAllocation']
                          as _ilfvovcz.MonthlyAllocationEndpoint)
                      .delete(
                        session,
                        params['allocationId'],
                      ),
        ),
      },
    );
    connectors['payee'] = _is.EndpointConnector(
      name: 'payee',
      endpoint: endpoints['payee']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint).create(
                session,
                params['name'],
                params['budgetId'],
              ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint).list(
                session,
                params['budgetId'],
              ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint).get(
                session,
                params['payeeId'],
              ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint).update(
                session,
                params['payeeId'],
                name: params['name'],
              ),
        ),
        'lastUsedEnvelopeId': _is.MethodConnector(
          name: 'lastUsedEnvelopeId',
          params: {
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint)
                  .lastUsedEnvelopeId(
                    session,
                    params['payeeId'],
                    params['budgetId'],
                  ),
        ),
        'merge': _is.MethodConnector(
          name: 'merge',
          params: {
            'sourcePayeeId': _is.ParameterDescription(
              name: 'sourcePayeeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'targetPayeeId': _is.ParameterDescription(
              name: 'targetPayeeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint).merge(
                session,
                params['sourcePayeeId'],
                params['targetPayeeId'],
              ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint).delete(
                session,
                params['payeeId'],
              ),
        ),
      },
    );
    connectors['plaid'] = _is.EndpointConnector(
      name: 'plaid',
      endpoint: endpoints['plaid']!,
      methodConnectors: {
        'createLinkToken': _is.MethodConnector(
          name: 'createLinkToken',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['plaid'] as _i9pkxqxw.PlaidEndpoint)
                  .createLinkToken(
                    session,
                    params['budgetId'],
                  ),
        ),
        'exchangePublicToken': _is.MethodConnector(
          name: 'exchangePublicToken',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'publicToken': _is.ParameterDescription(
              name: 'publicToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['plaid'] as _i9pkxqxw.PlaidEndpoint)
                  .exchangePublicToken(
                    session,
                    params['budgetId'],
                    params['publicToken'],
                  ),
        ),
        'syncConnection': _is.MethodConnector(
          name: 'syncConnection',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'connectionId': _is.ParameterDescription(
              name: 'connectionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['plaid'] as _i9pkxqxw.PlaidEndpoint)
                  .syncConnection(
                    session,
                    params['budgetId'],
                    params['connectionId'],
                  ),
        ),
        'importSandboxAccounts': _is.MethodConnector(
          name: 'importSandboxAccounts',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'plaidInstitutionId': _is.ParameterDescription(
              name: 'plaidInstitutionId',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['plaid'] as _i9pkxqxw.PlaidEndpoint)
                  .importSandboxAccounts(
                    session,
                    params['budgetId'],
                    plaidInstitutionId: params['plaidInstitutionId'],
                  ),
        ),
      },
    );
    connectors['recurringTransaction'] = _is.EndpointConnector(
      name: 'recurringTransaction',
      endpoint: endpoints['recurringTransaction']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'amountCents': _is.ParameterDescription(
              name: 'amountCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'frequency': _is.ParameterDescription(
              name: 'frequency',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'nextOccurrence': _is.ParameterDescription(
              name: 'nextOccurrence',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'endDate': _is.ParameterDescription(
              name: 'endDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
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
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'activeOnly': _is.ParameterDescription(
              name: 'activeOnly',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
                      .list(
                        session,
                        params['budgetId'],
                        activeOnly: params['activeOnly'],
                      ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'recurringTransactionId': _is.ParameterDescription(
              name: 'recurringTransactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
                      .get(
                        session,
                        params['recurringTransactionId'],
                      ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'recurringTransactionId': _is.ParameterDescription(
              name: 'recurringTransactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'amountCents': _is.ParameterDescription(
              name: 'amountCents',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'frequency': _is.ParameterDescription(
              name: 'frequency',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'nextOccurrence': _is.ParameterDescription(
              name: 'nextOccurrence',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'endDate': _is.ParameterDescription(
              name: 'endDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'isActive': _is.ParameterDescription(
              name: 'isActive',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
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
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'recurringTransactionId': _is.ParameterDescription(
              name: 'recurringTransactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
                      .delete(
                        session,
                        params['recurringTransactionId'],
                      ),
        ),
        'skipOccurrence': _is.MethodConnector(
          name: 'skipOccurrence',
          params: {
            'recurringTransactionId': _is.ParameterDescription(
              name: 'recurringTransactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
                      .skipOccurrence(
                        session,
                        params['recurringTransactionId'],
                      ),
        ),
        'postDue': _is.MethodConnector(
          name: 'postDue',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
                      .postDue(
                        session,
                        params['budgetId'],
                      ),
        ),
        'countDue': _is.MethodConnector(
          name: 'countDue',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
                      .countDue(
                        session,
                        params['budgetId'],
                      ),
        ),
      },
    );
    connectors['solanaWallet'] = _is.EndpointConnector(
      name: 'solanaWallet',
      endpoint: endpoints['solanaWallet']!,
      methodConnectors: {
        'attach': _is.MethodConnector(
          name: 'attach',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'address': _is.ParameterDescription(
              name: 'address',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'label': _is.ParameterDescription(
              name: 'label',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'cluster': _is.ParameterDescription(
              name: 'cluster',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _in77fwrc.SolanaWalletEndpoint)
                      .attach(
                        session,
                        params['budgetId'],
                        params['accountId'],
                        params['address'],
                        label: params['label'],
                        cluster: params['cluster'],
                      ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _in77fwrc.SolanaWalletEndpoint)
                      .list(
                        session,
                        params['budgetId'],
                      ),
        ),
        'getForAccount': _is.MethodConnector(
          name: 'getForAccount',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _in77fwrc.SolanaWalletEndpoint)
                      .getForAccount(
                        session,
                        params['budgetId'],
                        params['accountId'],
                      ),
        ),
        'sync': _is.MethodConnector(
          name: 'sync',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'walletId': _is.ParameterDescription(
              name: 'walletId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _in77fwrc.SolanaWalletEndpoint)
                      .sync(
                        session,
                        params['budgetId'],
                        params['walletId'],
                        limit: params['limit'],
                      ),
        ),
        'listTransactions': _is.MethodConnector(
          name: 'listTransactions',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'walletId': _is.ParameterDescription(
              name: 'walletId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _in77fwrc.SolanaWalletEndpoint)
                      .listTransactions(
                        session,
                        params['budgetId'],
                        params['walletId'],
                        limit: params['limit'],
                      ),
        ),
        'listHoldings': _is.MethodConnector(
          name: 'listHoldings',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'walletId': _is.ParameterDescription(
              name: 'walletId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _in77fwrc.SolanaWalletEndpoint)
                      .listHoldings(
                        session,
                        params['budgetId'],
                        params['walletId'],
                      ),
        ),
        'listTaxYearSummaries': _is.MethodConnector(
          name: 'listTaxYearSummaries',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'walletId': _is.ParameterDescription(
              name: 'walletId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _in77fwrc.SolanaWalletEndpoint)
                      .listTaxYearSummaries(
                        session,
                        params['budgetId'],
                        params['walletId'],
                      ),
        ),
        'updateTransactionMetadata': _is.MethodConnector(
          name: 'updateTransactionMetadata',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'transactionId': _is.ParameterDescription(
              name: 'transactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'category': _is.ParameterDescription(
              name: 'category',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'tagsCsv': _is.ParameterDescription(
              name: 'tagsCsv',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'memo': _is.ParameterDescription(
              name: 'memo',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['solanaWallet'] as _in77fwrc.SolanaWalletEndpoint)
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
    connectors['transactionRule'] = _is.EndpointConnector(
      name: 'transactionRule',
      endpoint: endpoints['transactionRule']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'targetEnvelopeId': _is.ParameterDescription(
              name: 'targetEnvelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule']
                          as _i70s5v1k.TransactionRuleEndpoint)
                      .create(
                        session,
                        params['budgetId'],
                        params['payeeId'],
                        params['targetEnvelopeId'],
                      ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule']
                          as _i70s5v1k.TransactionRuleEndpoint)
                      .list(
                        session,
                        params['budgetId'],
                      ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'ruleId': _is.ParameterDescription(
              name: 'ruleId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule']
                          as _i70s5v1k.TransactionRuleEndpoint)
                      .get(
                        session,
                        params['ruleId'],
                      ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'ruleId': _is.ParameterDescription(
              name: 'ruleId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'targetEnvelopeId': _is.ParameterDescription(
              name: 'targetEnvelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'enabled': _is.ParameterDescription(
              name: 'enabled',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule']
                          as _i70s5v1k.TransactionRuleEndpoint)
                      .update(
                        session,
                        params['ruleId'],
                        targetEnvelopeId: params['targetEnvelopeId'],
                        enabled: params['enabled'],
                      ),
        ),
        'findMatchingEnvelope': _is.MethodConnector(
          name: 'findMatchingEnvelope',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule']
                          as _i70s5v1k.TransactionRuleEndpoint)
                      .findMatchingEnvelope(
                        session,
                        params['budgetId'],
                        params['payeeId'],
                      ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'ruleId': _is.ParameterDescription(
              name: 'ruleId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transactionRule']
                          as _i70s5v1k.TransactionRuleEndpoint)
                      .delete(
                        session,
                        params['ruleId'],
                      ),
        ),
      },
    );
    connectors['transaction'] = _is.EndpointConnector(
      name: 'transaction',
      endpoint: endpoints['transaction']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'amountCents': _is.ParameterDescription(
              name: 'amountCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'transactionDate': _is.ParameterDescription(
              name: 'transactionDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'memo': _is.ParameterDescription(
              name: 'memo',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .create(
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
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .list(
                        session,
                        params['budgetId'],
                      ),
        ),
        'listByMonth': _is.MethodConnector(
          name: 'listByMonth',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'year': _is.ParameterDescription(
              name: 'year',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .listByMonth(
                        session,
                        params['budgetId'],
                        params['year'],
                        params['month'],
                      ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'transactionId': _is.ParameterDescription(
              name: 'transactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .get(
                        session,
                        params['transactionId'],
                      ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'transactionId': _is.ParameterDescription(
              name: 'transactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'amountCents': _is.ParameterDescription(
              name: 'amountCents',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'transactionDate': _is.ParameterDescription(
              name: 'transactionDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'memo': _is.ParameterDescription(
              name: 'memo',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'flagColor': _is.ParameterDescription(
              name: 'flagColor',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .update(
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
        'setFlag': _is.MethodConnector(
          name: 'setFlag',
          params: {
            'transactionId': _is.ParameterDescription(
              name: 'transactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'flagColor': _is.ParameterDescription(
              name: 'flagColor',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .setFlag(
                        session,
                        params['transactionId'],
                        flagColor: params['flagColor'],
                      ),
        ),
        'transfer': _is.MethodConnector(
          name: 'transfer',
          params: {
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'amountCents': _is.ParameterDescription(
              name: 'amountCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'fromAccountId': _is.ParameterDescription(
              name: 'fromAccountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'toAccountId': _is.ParameterDescription(
              name: 'toAccountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'transactionDate': _is.ParameterDescription(
              name: 'transactionDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
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
        'listByAccount': _is.MethodConnector(
          name: 'listByAccount',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .listByAccount(
                        session,
                        params['accountId'],
                        params['budgetId'],
                      ),
        ),
        'toggleCleared': _is.MethodConnector(
          name: 'toggleCleared',
          params: {
            'transactionId': _is.ParameterDescription(
              name: 'transactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .toggleCleared(
                        session,
                        params['transactionId'],
                      ),
        ),
        'reconcileAccount': _is.MethodConnector(
          name: 'reconcileAccount',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .reconcileAccount(
                        session,
                        params['accountId'],
                        params['budgetId'],
                      ),
        ),
        'reconcileWithBalance': _is.MethodConnector(
          name: 'reconcileWithBalance',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'statementBalanceCents': _is.ParameterDescription(
              name: 'statementBalanceCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .reconcileWithBalance(
                        session,
                        params['accountId'],
                        params['budgetId'],
                        params['statementBalanceCents'],
                      ),
        ),
        'ageOfMoney': _is.MethodConnector(
          name: 'ageOfMoney',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .ageOfMoney(
                        session,
                        params['budgetId'],
                      ),
        ),
        'createSplit': _is.MethodConnector(
          name: 'createSplit',
          params: {
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'totalAmountCents': _is.ParameterDescription(
              name: 'totalAmountCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'transactionDate': _is.ParameterDescription(
              name: 'transactionDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'splits': _is.ParameterDescription(
              name: 'splits',
              type: _is.getType<List<_ii8zyh2l.SplitItem>>(),
              nullable: false,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
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
        'listSplits': _is.MethodConnector(
          name: 'listSplits',
          params: {
            'parentTransactionId': _is.ParameterDescription(
              name: 'parentTransactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .listSplits(
                        session,
                        params['parentTransactionId'],
                      ),
        ),
        'bulkImport': _is.MethodConnector(
          name: 'bulkImport',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'rows': _is.ParameterDescription(
              name: 'rows',
              type: _is.getType<List<_iyod81ld.ImportRow>>(),
              nullable: false,
            ),
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .bulkImport(
                        session,
                        params['budgetId'],
                        params['currencyCode'],
                        params['rows'],
                        accountId: params['accountId'],
                      ),
        ),
        'findDuplicates': _is.MethodConnector(
          name: 'findDuplicates',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'amountCents': _is.ParameterDescription(
              name: 'amountCents',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'transactionDate': _is.ParameterDescription(
              name: 'transactionDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .findDuplicates(
                        session,
                        params['budgetId'],
                        params['amountCents'],
                        params['transactionDate'],
                      ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'transactionId': _is.ParameterDescription(
              name: 'transactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .delete(
                        session,
                        params['transactionId'],
                      ),
        ),
      },
    );
    connectors['wallet'] = _is.EndpointConnector(
      name: 'wallet',
      endpoint: endpoints['wallet']!,
      methodConnectors: {
        'connectSolanaWallet': _is.MethodConnector(
          name: 'connectSolanaWallet',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'address': _is.ParameterDescription(
              name: 'address',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'label': _is.ParameterDescription(
              name: 'label',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'onBudget': _is.ParameterDescription(
              name: 'onBudget',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint)
                  .connectSolanaWallet(
                    session,
                    params['budgetId'],
                    params['address'],
                    label: params['label'],
                    onBudget: params['onBudget'],
                  ),
        ),
        'refreshSolanaWallet': _is.MethodConnector(
          name: 'refreshSolanaWallet',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'connectionId': _is.ParameterDescription(
              name: 'connectionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint)
                  .refreshSolanaWallet(
                    session,
                    params['budgetId'],
                    params['connectionId'],
                  ),
        ),
        'listWalletHoldings': _is.MethodConnector(
          name: 'listWalletHoldings',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'connectionId': _is.ParameterDescription(
              name: 'connectionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint)
                  .listWalletHoldings(
                    session,
                    params['budgetId'],
                    params['connectionId'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
