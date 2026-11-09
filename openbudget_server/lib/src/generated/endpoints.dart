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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:openbudget_server/src/generated/future_calls.dart' as _iwv90kfd;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;

import '../agent/agent_endpoint.dart' as _i6aufbii;
import '../agent/agent_token_endpoint.dart' as _i3vp9qdi;
import '../auth/apple_idp_endpoint.dart' as _ilq63su8;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/google_idp_endpoint.dart' as _i71axiz0;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../billing/billing_endpoint.dart' as _irc9lmoc;
import '../entities/entity_endpoint.dart' as _ib6f7fzy;
import '../entities/entity_stream.dart' as _il264xkw;
import '../envelope_goals/envelope_goal_endpoint.dart' as _i76paldx;
import '../envelopes/envelope_endpoint.dart' as _in6dn9dl;
import '../fx_rates/fx_rate_endpoint.dart' as _i7xoygut;
import '../institutions/institution_endpoint.dart' as _i9rhv37i;
import '../plaid/plaid_endpoint.dart' as _i9pkxqxw;
import '../settings/settings_endpoint.dart' as _iy0sqmtu;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'agent': _i6aufbii.AgentEndpoint()
        ..initialize(
          server,
          'agent',
          null,
        ),
      'agentToken': _i3vp9qdi.AgentTokenEndpoint()
        ..initialize(
          server,
          'agentToken',
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
      'billing': _irc9lmoc.BillingEndpoint()
        ..initialize(
          server,
          'billing',
          null,
        ),
      'entity': _ib6f7fzy.EntityEndpoint()
        ..initialize(
          server,
          'entity',
          null,
        ),
      'entityStream': _il264xkw.EntityStreamEndpoint()
        ..initialize(
          server,
          'entityStream',
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
      'plaid': _i9pkxqxw.PlaidEndpoint()
        ..initialize(
          server,
          'plaid',
          null,
        ),
      'settings': _iy0sqmtu.SettingsEndpoint()
        ..initialize(
          server,
          'settings',
          null,
        ),
    };
    connectors['agent'] = _is.EndpointConnector(
      name: 'agent',
      endpoint: endpoints['agent']!,
      methodConnectors: {
        'listConversations': _is.MethodConnector(
          name: 'listConversations',
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
              ) async => (endpoints['agent'] as _i6aufbii.AgentEndpoint)
                  .listConversations(
                    session,
                    params['budgetId'],
                  ),
        ),
        'getMessages': _is.MethodConnector(
          name: 'getMessages',
          params: {
            'conversationId': _is.ParameterDescription(
              name: 'conversationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['agent'] as _i6aufbii.AgentEndpoint).getMessages(
                    session,
                    params['conversationId'],
                  ),
        ),
        'deleteConversation': _is.MethodConnector(
          name: 'deleteConversation',
          params: {
            'conversationId': _is.ParameterDescription(
              name: 'conversationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['agent'] as _i6aufbii.AgentEndpoint)
                  .deleteConversation(
                    session,
                    params['conversationId'],
                  ),
        ),
        'getUsage': _is.MethodConnector(
          name: 'getUsage',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['agent'] as _i6aufbii.AgentEndpoint)
                  .getUsage(session),
        ),
        'saveProviderSettings': _is.MethodConnector(
          name: 'saveProviderSettings',
          params: {
            'baseUrl': _is.ParameterDescription(
              name: 'baseUrl',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'model': _is.ParameterDescription(
              name: 'model',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'apiKey': _is.ParameterDescription(
              name: 'apiKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['agent'] as _i6aufbii.AgentEndpoint)
                  .saveProviderSettings(
                    session,
                    params['baseUrl'],
                    params['model'],
                    params['apiKey'],
                  ),
        ),
        'getProviderSettings': _is.MethodConnector(
          name: 'getProviderSettings',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['agent'] as _i6aufbii.AgentEndpoint)
                  .getProviderSettings(session),
        ),
        'clearProviderSettings': _is.MethodConnector(
          name: 'clearProviderSettings',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['agent'] as _i6aufbii.AgentEndpoint)
                  .clearProviderSettings(session),
        ),
        'listProposals': _is.MethodConnector(
          name: 'listProposals',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'pendingOnly': _is.ParameterDescription(
              name: 'pendingOnly',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['agent'] as _i6aufbii.AgentEndpoint).listProposals(
                    session,
                    params['budgetId'],
                    pendingOnly: params['pendingOnly'],
                  ),
        ),
        'applyProposal': _is.MethodConnector(
          name: 'applyProposal',
          params: {
            'proposalId': _is.ParameterDescription(
              name: 'proposalId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['agent'] as _i6aufbii.AgentEndpoint).applyProposal(
                    session,
                    params['proposalId'],
                  ),
        ),
        'dismissProposal': _is.MethodConnector(
          name: 'dismissProposal',
          params: {
            'proposalId': _is.ParameterDescription(
              name: 'proposalId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['agent'] as _i6aufbii.AgentEndpoint)
                  .dismissProposal(
                    session,
                    params['proposalId'],
                  ),
        ),
        'chat': _is.MethodStreamConnector(
          name: 'chat',
          params: {
            'budgetId': _is.ParameterDescription(
              name: 'budgetId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'conversationId': _is.ParameterDescription(
              name: 'conversationId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'message': _is.ParameterDescription(
              name: 'message',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['agent'] as _i6aufbii.AgentEndpoint).chat(
                session,
                params['budgetId'],
                params['conversationId'],
                params['message'],
              ),
        ),
      },
    );
    connectors['agentToken'] = _is.EndpointConnector(
      name: 'agentToken',
      endpoint: endpoints['agentToken']!,
      methodConnectors: {
        'createAccessToken': _is.MethodConnector(
          name: 'createAccessToken',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'canPropose': _is.ParameterDescription(
              name: 'canPropose',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['agentToken'] as _i3vp9qdi.AgentTokenEndpoint)
                      .createAccessToken(
                        session,
                        params['name'],
                        params['canPropose'],
                      ),
        ),
        'listAccessTokens': _is.MethodConnector(
          name: 'listAccessTokens',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['agentToken'] as _i3vp9qdi.AgentTokenEndpoint)
                      .listAccessTokens(session),
        ),
        'revokeAccessToken': _is.MethodConnector(
          name: 'revokeAccessToken',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['agentToken'] as _i3vp9qdi.AgentTokenEndpoint)
                      .revokeAccessToken(
                        session,
                        params['id'],
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
    connectors['billing'] = _is.EndpointConnector(
      name: 'billing',
      endpoint: endpoints['billing']!,
      methodConnectors: {
        'getEntitlement': _is.MethodConnector(
          name: 'getEntitlement',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['billing'] as _irc9lmoc.BillingEndpoint)
                  .getEntitlement(session),
        ),
        'createStripeCheckout': _is.MethodConnector(
          name: 'createStripeCheckout',
          params: {
            'successUrl': _is.ParameterDescription(
              name: 'successUrl',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'cancelUrl': _is.ParameterDescription(
              name: 'cancelUrl',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['billing'] as _irc9lmoc.BillingEndpoint)
                  .createStripeCheckout(
                    session,
                    params['successUrl'],
                    params['cancelUrl'],
                  ),
        ),
        'createStripePortal': _is.MethodConnector(
          name: 'createStripePortal',
          params: {
            'returnUrl': _is.ParameterDescription(
              name: 'returnUrl',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['billing'] as _irc9lmoc.BillingEndpoint)
                  .createStripePortal(
                    session,
                    params['returnUrl'],
                  ),
        ),
        'getSolanaPlan': _is.MethodConnector(
          name: 'getSolanaPlan',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['billing'] as _irc9lmoc.BillingEndpoint)
                  .getSolanaPlan(session),
        ),
        'solanaSubscriptionChallenge': _is.MethodConnector(
          name: 'solanaSubscriptionChallenge',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['billing'] as _irc9lmoc.BillingEndpoint)
                  .solanaSubscriptionChallenge(session),
        ),
        'confirmSolanaSubscription': _is.MethodConnector(
          name: 'confirmSolanaSubscription',
          params: {
            'subscriberAddress': _is.ParameterDescription(
              name: 'subscriberAddress',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'message': _is.ParameterDescription(
              name: 'message',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signatureBase58': _is.ParameterDescription(
              name: 'signatureBase58',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['billing'] as _irc9lmoc.BillingEndpoint)
                  .confirmSolanaSubscription(
                    session,
                    params['subscriberAddress'],
                    params['message'],
                    params['signatureBase58'],
                  ),
        ),
      },
    );
    connectors['entity'] = _is.EndpointConnector(
      name: 'entity',
      endpoint: endpoints['entity']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'kind': _is.ParameterDescription(
              name: 'kind',
              type: _is.getType<_ifz8weqz.EntityKind>(),
              nullable: false,
            ),
            'countryCode': _is.ParameterDescription(
              name: 'countryCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'baseCurrencyCode': _is.ParameterDescription(
              name: 'baseCurrencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'timeZone': _is.ParameterDescription(
              name: 'timeZone',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'fiscalYearEndMonth': _is.ParameterDescription(
              name: 'fiscalYearEndMonth',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'fiscalYearEndDay': _is.ParameterDescription(
              name: 'fiscalYearEndDay',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'linkedPersonalEntityId': _is.ParameterDescription(
              name: 'linkedPersonalEntityId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['entity'] as _ib6f7fzy.EntityEndpoint).create(
                    session,
                    params['name'],
                    params['kind'],
                    params['countryCode'],
                    params['baseCurrencyCode'],
                    params['timeZone'],
                    fiscalYearEndMonth: params['fiscalYearEndMonth'],
                    fiscalYearEndDay: params['fiscalYearEndDay'],
                    linkedPersonalEntityId: params['linkedPersonalEntityId'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'includeArchived': _is.ParameterDescription(
              name: 'includeArchived',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['entity'] as _ib6f7fzy.EntityEndpoint).list(
                session,
                includeArchived: params['includeArchived'],
              ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['entity'] as _ib6f7fzy.EntityEndpoint).get(
                session,
                params['entityId'],
              ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'baseCurrencyCode': _is.ParameterDescription(
              name: 'baseCurrencyCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'timeZone': _is.ParameterDescription(
              name: 'timeZone',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'fiscalYearEndMonth': _is.ParameterDescription(
              name: 'fiscalYearEndMonth',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'fiscalYearEndDay': _is.ParameterDescription(
              name: 'fiscalYearEndDay',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'includeInNetWorth': _is.ParameterDescription(
              name: 'includeInNetWorth',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'linkedPersonalEntityId': _is.ParameterDescription(
              name: 'linkedPersonalEntityId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'clearLinkedPersonalEntity': _is.ParameterDescription(
              name: 'clearLinkedPersonalEntity',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'sortOrder': _is.ParameterDescription(
              name: 'sortOrder',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['entity'] as _ib6f7fzy.EntityEndpoint).update(
                    session,
                    params['entityId'],
                    name: params['name'],
                    baseCurrencyCode: params['baseCurrencyCode'],
                    timeZone: params['timeZone'],
                    fiscalYearEndMonth: params['fiscalYearEndMonth'],
                    fiscalYearEndDay: params['fiscalYearEndDay'],
                    includeInNetWorth: params['includeInNetWorth'],
                    linkedPersonalEntityId: params['linkedPersonalEntityId'],
                    clearLinkedPersonalEntity:
                        params['clearLinkedPersonalEntity'],
                    sortOrder: params['sortOrder'],
                  ),
        ),
        'archive': _is.MethodConnector(
          name: 'archive',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['entity'] as _ib6f7fzy.EntityEndpoint).archive(
                    session,
                    params['entityId'],
                  ),
        ),
        'unarchive': _is.MethodConnector(
          name: 'unarchive',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['entity'] as _ib6f7fzy.EntityEndpoint).unarchive(
                    session,
                    params['entityId'],
                  ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'confirmName': _is.ParameterDescription(
              name: 'confirmName',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['entity'] as _ib6f7fzy.EntityEndpoint).delete(
                    session,
                    params['entityId'],
                    params['confirmName'],
                  ),
        ),
      },
    );
    connectors['entityStream'] = _is.EndpointConnector(
      name: 'entityStream',
      endpoint: endpoints['entityStream']!,
      methodConnectors: {
        'watch': _is.MethodStreamConnector(
          name: 'watch',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['entityStream'] as _il264xkw.EntityStreamEndpoint)
                  .watch(
                    session,
                    params['entityId'],
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
        'quote': _is.MethodConnector(
          name: 'quote',
          params: {
            'fromCurrencyCode': _is.ParameterDescription(
              name: 'fromCurrencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'toCurrencyCode': _is.ParameterDescription(
              name: 'toCurrencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'date': _is.ParameterDescription(
              name: 'date',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['fxRate'] as _i7xoygut.FxRateEndpoint).quote(
                    session,
                    params['fromCurrencyCode'],
                    params['toCurrencyCode'],
                    params['date'],
                  ),
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
    connectors['settings'] = _is.EndpointConnector(
      name: 'settings',
      endpoint: endpoints['settings']!,
      methodConnectors: {
        'get': _is.MethodConnector(
          name: 'get',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['settings'] as _iy0sqmtu.SettingsEndpoint)
                  .get(session),
        ),
        'setReportingCurrency': _is.MethodConnector(
          name: 'setReportingCurrency',
          params: {
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
              ) async => (endpoints['settings'] as _iy0sqmtu.SettingsEndpoint)
                  .setReportingCurrency(
                    session,
                    params['currencyCode'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _iwv90kfd.FutureCalls();
  }
}
