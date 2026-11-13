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
import 'package:openbudget_server/src/generated/budget/allocation_input.dart'
    as _inwbkajl;
import 'package:openbudget_server/src/generated/envelope_goals/envelope_goal_kind.dart'
    as _i16hg0wx;
import 'package:openbudget_server/src/generated/future_calls.dart' as _iwv90kfd;
import 'package:openbudget_server/src/generated/ledger/journal_line_input.dart'
    as _in0sxdux;
import 'package:openbudget_server/src/generated/reports/net_worth_granularity.dart'
    as _iwv93n42;
import 'package:openbudget_server/src/generated/reports/report_grouping.dart'
    as _i3o6dj87;
import 'package:openbudget_server/src/generated/transactions/import_row.dart'
    as _iyod81ld;
import 'package:openbudget_server/src/generated/transactions/transaction_flag.dart'
    as _iilgv4bx;
import 'package:openbudget_server/src/generated/transactions/transaction_input.dart'
    as _i87mxfy4;
import 'package:openbudget_server/src/generated/transactions/transaction_query.dart'
    as _iun6b2tc;
import 'package:openbudget_server/src/generated/transactions/transaction_status.dart'
    as _i54b59qp;
import 'package:openbudget_server/src/generated/transactions/transfer_input.dart'
    as _i7e3qnpf;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;

import '../accounts/account_endpoint.dart' as _izzfgwyn;
import '../agent/agent_endpoint.dart' as _i6aufbii;
import '../agent/agent_token_endpoint.dart' as _i3vp9qdi;
import '../auth/apple_idp_endpoint.dart' as _ilq63su8;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/google_idp_endpoint.dart' as _i71axiz0;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../billing/billing_endpoint.dart' as _irc9lmoc;
import '../budget/budget_endpoint.dart' as _iorb9x3p;
import '../categories/category_endpoint.dart' as _irthghnb;
import '../entities/entity_endpoint.dart' as _ib6f7fzy;
import '../entities/entity_stream.dart' as _il264xkw;
import '../envelope_goals/envelope_goal_endpoint.dart' as _i76paldx;
import '../envelopes/envelope_endpoint.dart' as _in6dn9dl;
import '../fx_rates/fx_rate_endpoint.dart' as _i7xoygut;
import '../institutions/institution_endpoint.dart' as _i9rhv37i;
import '../ledger/ledger_endpoint.dart' as _ia4une1r;
import '../payees/payee_endpoint.dart' as _i5rb0bcw;
import '../plaid/plaid_endpoint.dart' as _i9pkxqxw;
import '../recurring_transactions/recurring_transaction_endpoint.dart'
    as _ipwgw1dv;
import '../reports/report_endpoint.dart' as _iqte9uvc;
import '../settings/settings_endpoint.dart' as _iy0sqmtu;
import '../tax/tax_endpoint.dart' as _i34kr7gr;
import '../transaction_rules/transaction_rule_endpoint.dart' as _i70s5v1k;
import '../transactions/transaction_endpoint.dart' as _if8xv4dr;
import '../wallets/wallet_endpoint.dart' as _i1ub0otr;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

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
      'budget': _iorb9x3p.BudgetEndpoint()
        ..initialize(
          server,
          'budget',
          null,
        ),
      'category': _irthghnb.CategoryEndpoint()
        ..initialize(
          server,
          'category',
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
      'ledger': _ia4une1r.LedgerEndpoint()
        ..initialize(
          server,
          'ledger',
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
      'report': _iqte9uvc.ReportEndpoint()
        ..initialize(
          server,
          'report',
          null,
        ),
      'settings': _iy0sqmtu.SettingsEndpoint()
        ..initialize(
          server,
          'settings',
          null,
        ),
      'tax': _i34kr7gr.TaxEndpoint()
        ..initialize(
          server,
          'tax',
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
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'kind': _is.ParameterDescription(
              name: 'kind',
              type: _is.getType<_ifz8weqz.AccountKind>(),
              nullable: false,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'balanceSource': _is.ParameterDescription(
              name: 'balanceSource',
              type: _is.getType<_ifz8weqz.AccountBalanceSource?>(),
              nullable: true,
            ),
            'onBudget': _is.ParameterDescription(
              name: 'onBudget',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'openingBalanceMinor': _is.ParameterDescription(
              name: 'openingBalanceMinor',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'openingDate': _is.ParameterDescription(
              name: 'openingDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'institutionId': _is.ParameterDescription(
              name: 'institutionId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
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
                    params['entityId'],
                    params['name'],
                    params['kind'],
                    params['currencyCode'],
                    balanceSource: params['balanceSource'],
                    onBudget: params['onBudget'],
                    openingBalanceMinor: params['openingBalanceMinor'],
                    openingDate: params['openingDate'],
                    institutionId: params['institutionId'],
                    note: params['note'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
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
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).list(
                    session,
                    params['entityId'],
                  ),
        ),
        'listAll': _is.MethodConnector(
          name: 'listAll',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _izzfgwyn.AccountEndpoint)
                  .listAll(session),
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
            'kind': _is.ParameterDescription(
              name: 'kind',
              type: _is.getType<_ifz8weqz.AccountKind?>(),
              nullable: true,
            ),
            'onBudget': _is.ParameterDescription(
              name: 'onBudget',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'institutionId': _is.ParameterDescription(
              name: 'institutionId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'clearInstitution': _is.ParameterDescription(
              name: 'clearInstitution',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
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
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).update(
                    session,
                    params['accountId'],
                    name: params['name'],
                    kind: params['kind'],
                    onBudget: params['onBudget'],
                    institutionId: params['institutionId'],
                    clearInstitution: params['clearInstitution'],
                    note: params['note'],
                    sortOrder: params['sortOrder'],
                  ),
        ),
        'reorder': _is.MethodConnector(
          name: 'reorder',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'accountIds': _is.ParameterDescription(
              name: 'accountIds',
              type: _is.getType<List<_is.UuidValue>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).reorder(
                    session,
                    params['entityId'],
                    params['accountIds'],
                  ),
        ),
        'close': _is.MethodConnector(
          name: 'close',
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
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).close(
                    session,
                    params['accountId'],
                  ),
        ),
        'reopen': _is.MethodConnector(
          name: 'reopen',
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
                  (endpoints['account'] as _izzfgwyn.AccountEndpoint).reopen(
                    session,
                    params['accountId'],
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
        'getBalances': _is.MethodConnector(
          name: 'getBalances',
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
              ) async => (endpoints['account'] as _izzfgwyn.AccountEndpoint)
                  .getBalances(
                    session,
                    params['accountId'],
                  ),
        ),
        'listValuations': _is.MethodConnector(
          name: 'listValuations',
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
              ) async => (endpoints['account'] as _izzfgwyn.AccountEndpoint)
                  .listValuations(
                    session,
                    params['accountId'],
                  ),
        ),
        'setValuation': _is.MethodConnector(
          name: 'setValuation',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'valuationDate': _is.ParameterDescription(
              name: 'valuationDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'valueMinor': _is.ParameterDescription(
              name: 'valueMinor',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _izzfgwyn.AccountEndpoint)
                  .setValuation(
                    session,
                    params['accountId'],
                    params['valuationDate'],
                    params['valueMinor'],
                    note: params['note'],
                  ),
        ),
        'deleteValuation': _is.MethodConnector(
          name: 'deleteValuation',
          params: {
            'valuationId': _is.ParameterDescription(
              name: 'valuationId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _izzfgwyn.AccountEndpoint)
                  .deleteValuation(
                    session,
                    params['valuationId'],
                  ),
        ),
      },
    );
    connectors['agent'] = _is.EndpointConnector(
      name: 'agent',
      endpoint: endpoints['agent']!,
      methodConnectors: {
        'listConversations': _is.MethodConnector(
          name: 'listConversations',
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
              ) async => (endpoints['agent'] as _i6aufbii.AgentEndpoint)
                  .listConversations(
                    session,
                    params['entityId'],
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
            'entityId': _is.ParameterDescription(
              name: 'entityId',
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
                    params['entityId'],
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
            'entityId': _is.ParameterDescription(
              name: 'entityId',
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
                params['entityId'],
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
    connectors['budget'] = _is.EndpointConnector(
      name: 'budget',
      endpoint: endpoints['budget']!,
      methodConnectors: {
        'getMonth': _is.MethodConnector(
          name: 'getMonth',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
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
                  (endpoints['budget'] as _iorb9x3p.BudgetEndpoint).getMonth(
                    session,
                    params['entityId'],
                    params['month'],
                  ),
        ),
        'setAllocations': _is.MethodConnector(
          name: 'setAllocations',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'allocations': _is.ParameterDescription(
              name: 'allocations',
              type: _is.getType<List<_inwbkajl.AllocationInput>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['budget'] as _iorb9x3p.BudgetEndpoint)
                  .setAllocations(
                    session,
                    params['entityId'],
                    params['month'],
                    params['allocations'],
                  ),
        ),
        'moveMoney': _is.MethodConnector(
          name: 'moveMoney',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'fromEnvelopeId': _is.ParameterDescription(
              name: 'fromEnvelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'toEnvelopeId': _is.ParameterDescription(
              name: 'toEnvelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'amountMinor': _is.ParameterDescription(
              name: 'amountMinor',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budget'] as _iorb9x3p.BudgetEndpoint).moveMoney(
                    session,
                    params['entityId'],
                    params['month'],
                    params['fromEnvelopeId'],
                    params['toEnvelopeId'],
                    params['amountMinor'],
                  ),
        ),
        'copyMonth': _is.MethodConnector(
          name: 'copyMonth',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'fromMonth': _is.ParameterDescription(
              name: 'fromMonth',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'toMonth': _is.ParameterDescription(
              name: 'toMonth',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['budget'] as _iorb9x3p.BudgetEndpoint).copyMonth(
                    session,
                    params['entityId'],
                    params['fromMonth'],
                    params['toMonth'],
                  ),
        ),
        'saveTemplate': _is.MethodConnector(
          name: 'saveTemplate',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['budget'] as _iorb9x3p.BudgetEndpoint)
                  .saveTemplate(
                    session,
                    params['entityId'],
                    params['month'],
                    params['name'],
                  ),
        ),
        'listTemplates': _is.MethodConnector(
          name: 'listTemplates',
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
              ) async => (endpoints['budget'] as _iorb9x3p.BudgetEndpoint)
                  .listTemplates(
                    session,
                    params['entityId'],
                  ),
        ),
        'getTemplateLines': _is.MethodConnector(
          name: 'getTemplateLines',
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
              ) async => (endpoints['budget'] as _iorb9x3p.BudgetEndpoint)
                  .getTemplateLines(
                    session,
                    params['templateId'],
                  ),
        ),
        'applyTemplate': _is.MethodConnector(
          name: 'applyTemplate',
          params: {
            'templateId': _is.ParameterDescription(
              name: 'templateId',
              type: _is.getType<_is.UuidValue>(),
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
              ) async => (endpoints['budget'] as _iorb9x3p.BudgetEndpoint)
                  .applyTemplate(
                    session,
                    params['templateId'],
                    params['month'],
                  ),
        ),
        'deleteTemplate': _is.MethodConnector(
          name: 'deleteTemplate',
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
              ) async => (endpoints['budget'] as _iorb9x3p.BudgetEndpoint)
                  .deleteTemplate(
                    session,
                    params['templateId'],
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
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
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
                    params['entityId'],
                    params['name'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
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
                  (endpoints['category'] as _irthghnb.CategoryEndpoint).list(
                    session,
                    params['entityId'],
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
                    isHidden: params['isHidden'],
                  ),
        ),
        'reorder': _is.MethodConnector(
          name: 'reorder',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
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
                    params['entityId'],
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
        'listSummaries': _is.MethodConnector(
          name: 'listSummaries',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['entity'] as _ib6f7fzy.EntityEndpoint)
                  .listSummaries(session),
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
        'exportData': _is.MethodConnector(
          name: 'exportData',
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
                  (endpoints['entity'] as _ib6f7fzy.EntityEndpoint).exportData(
                    session,
                    params['entityId'],
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
            'kind': _is.ParameterDescription(
              name: 'kind',
              type: _is.getType<_i16hg0wx.EnvelopeGoalKind>(),
              nullable: false,
            ),
            'amountMinor': _is.ParameterDescription(
              name: 'amountMinor',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'targetDate': _is.ParameterDescription(
              name: 'targetDate',
              type: _is.getType<DateTime?>(),
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
                        params['kind'],
                        params['amountMinor'],
                        targetDate: params['targetDate'],
                      ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
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
                  (endpoints['envelopeGoal'] as _i76paldx.EnvelopeGoalEndpoint)
                      .list(
                        session,
                        params['entityId'],
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
            'categoryId': _is.ParameterDescription(
              name: 'categoryId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'taxCategoryCode': _is.ParameterDescription(
              name: 'taxCategoryCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['envelope'] as _in6dn9dl.EnvelopeEndpoint).create(
                    session,
                    params['categoryId'],
                    params['name'],
                    note: params['note'],
                    taxCategoryCode: params['taxCategoryCode'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
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
                  (endpoints['envelope'] as _in6dn9dl.EnvelopeEndpoint).list(
                    session,
                    params['entityId'],
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
            'categoryId': _is.ParameterDescription(
              name: 'categoryId',
              type: _is.getType<_is.UuidValue?>(),
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
            'taxCategoryCode': _is.ParameterDescription(
              name: 'taxCategoryCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'clearTaxCategoryCode': _is.ParameterDescription(
              name: 'clearTaxCategoryCode',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'defaultLedgerAccountId': _is.ParameterDescription(
              name: 'defaultLedgerAccountId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'clearDefaultLedgerAccount': _is.ParameterDescription(
              name: 'clearDefaultLedgerAccount',
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
                    categoryId: params['categoryId'],
                    note: params['note'],
                    isHidden: params['isHidden'],
                    taxCategoryCode: params['taxCategoryCode'],
                    clearTaxCategoryCode: params['clearTaxCategoryCode'],
                    defaultLedgerAccountId: params['defaultLedgerAccountId'],
                    clearDefaultLedgerAccount:
                        params['clearDefaultLedgerAccount'],
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
              type: _is.getType<List<_is.UuidValue>>(),
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
            'reassignToEnvelopeId': _is.ParameterDescription(
              name: 'reassignToEnvelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
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
                    reassignToEnvelopeId: params['reassignToEnvelopeId'],
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
    connectors['ledger'] = _is.EndpointConnector(
      name: 'ledger',
      endpoint: endpoints['ledger']!,
      methodConnectors: {
        'enableLedger': _is.MethodConnector(
          name: 'enableLedger',
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
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .enableLedger(
                    session,
                    params['entityId'],
                  ),
        ),
        'listAccounts': _is.MethodConnector(
          name: 'listAccounts',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'includeArchived': _is.ParameterDescription(
              name: 'includeArchived',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .listAccounts(
                    session,
                    params['entityId'],
                    includeArchived: params['includeArchived'],
                  ),
        ),
        'createAccount': _is.MethodConnector(
          name: 'createAccount',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'type': _is.ParameterDescription(
              name: 'type',
              type: _is.getType<_ifz8weqz.LedgerAccountType>(),
              nullable: false,
            ),
            'systemRole': _is.ParameterDescription(
              name: 'systemRole',
              type: _is.getType<_ifz8weqz.LedgerSystemRole?>(),
              nullable: true,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'taxCategoryCode': _is.ParameterDescription(
              name: 'taxCategoryCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .createAccount(
                    session,
                    params['entityId'],
                    params['code'],
                    params['name'],
                    params['type'],
                    systemRole: params['systemRole'],
                    currencyCode: params['currencyCode'],
                    taxCategoryCode: params['taxCategoryCode'],
                  ),
        ),
        'archiveAccount': _is.MethodConnector(
          name: 'archiveAccount',
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
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .archiveAccount(
                    session,
                    params['accountId'],
                  ),
        ),
        'saveDraftJournal': _is.MethodConnector(
          name: 'saveDraftJournal',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'date': _is.ParameterDescription(
              name: 'date',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'lines': _is.ParameterDescription(
              name: 'lines',
              type: _is.getType<List<_in0sxdux.JournalLineInput>>(),
              nullable: false,
            ),
            'journalId': _is.ParameterDescription(
              name: 'journalId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'reference': _is.ParameterDescription(
              name: 'reference',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'narration': _is.ParameterDescription(
              name: 'narration',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'source': _is.ParameterDescription(
              name: 'source',
              type: _is.getType<_ifz8weqz.JournalSource>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .saveDraftJournal(
                    session,
                    params['entityId'],
                    params['date'],
                    params['lines'],
                    journalId: params['journalId'],
                    reference: params['reference'],
                    narration: params['narration'],
                    source: params['source'],
                  ),
        ),
        'deleteDraftJournal': _is.MethodConnector(
          name: 'deleteDraftJournal',
          params: {
            'journalId': _is.ParameterDescription(
              name: 'journalId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .deleteDraftJournal(
                    session,
                    params['journalId'],
                  ),
        ),
        'postJournal': _is.MethodConnector(
          name: 'postJournal',
          params: {
            'journalId': _is.ParameterDescription(
              name: 'journalId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['ledger'] as _ia4une1r.LedgerEndpoint).postJournal(
                    session,
                    params['journalId'],
                  ),
        ),
        'reverseJournal': _is.MethodConnector(
          name: 'reverseJournal',
          params: {
            'journalId': _is.ParameterDescription(
              name: 'journalId',
              type: _is.getType<_is.UuidValue>(),
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
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .reverseJournal(
                    session,
                    params['journalId'],
                    params['date'],
                  ),
        ),
        'listJournals': _is.MethodConnector(
          name: 'listJournals',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'fromDate': _is.ParameterDescription(
              name: 'fromDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'toDate': _is.ParameterDescription(
              name: 'toDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'cursor': _is.ParameterDescription(
              name: 'cursor',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .listJournals(
                    session,
                    params['entityId'],
                    fromDate: params['fromDate'],
                    toDate: params['toDate'],
                    limit: params['limit'],
                    cursor: params['cursor'],
                  ),
        ),
        'listJournalLines': _is.MethodConnector(
          name: 'listJournalLines',
          params: {
            'journalId': _is.ParameterDescription(
              name: 'journalId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .listJournalLines(
                    session,
                    params['journalId'],
                  ),
        ),
        'getLockDate': _is.MethodConnector(
          name: 'getLockDate',
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
                  (endpoints['ledger'] as _ia4une1r.LedgerEndpoint).getLockDate(
                    session,
                    params['entityId'],
                  ),
        ),
        'setLockDate': _is.MethodConnector(
          name: 'setLockDate',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'lockDate': _is.ParameterDescription(
              name: 'lockDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['ledger'] as _ia4une1r.LedgerEndpoint).setLockDate(
                    session,
                    params['entityId'],
                    params['lockDate'],
                  ),
        ),
        'trialBalance': _is.MethodConnector(
          name: 'trialBalance',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'asOf': _is.ParameterDescription(
              name: 'asOf',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .trialBalance(
                    session,
                    params['entityId'],
                    params['asOf'],
                  ),
        ),
        'listAuditEvents': _is.MethodConnector(
          name: 'listAuditEvents',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'before': _is.ParameterDescription(
              name: 'before',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ledger'] as _ia4une1r.LedgerEndpoint)
                  .listAuditEvents(
                    session,
                    params['entityId'],
                    before: params['before'],
                    limit: params['limit'],
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
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint).create(
                session,
                params['name'],
                params['entityId'],
              ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
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
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint).list(
                session,
                params['entityId'],
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
              ) async => (endpoints['payee'] as _i5rb0bcw.PayeeEndpoint)
                  .lastUsedEnvelopeId(
                    session,
                    params['payeeId'],
                    params['entityId'],
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
              ) async => (endpoints['plaid'] as _i9pkxqxw.PlaidEndpoint)
                  .createLinkToken(
                    session,
                    params['entityId'],
                  ),
        ),
        'exchangePublicToken': _is.MethodConnector(
          name: 'exchangePublicToken',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
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
                    params['entityId'],
                    params['publicToken'],
                  ),
        ),
        'syncConnection': _is.MethodConnector(
          name: 'syncConnection',
          params: {
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
                    params['connectionId'],
                  ),
        ),
        'listConnections': _is.MethodConnector(
          name: 'listConnections',
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
              ) async => (endpoints['plaid'] as _i9pkxqxw.PlaidEndpoint)
                  .listConnections(
                    session,
                    params['entityId'],
                  ),
        ),
        'removeConnection': _is.MethodConnector(
          name: 'removeConnection',
          params: {
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
                  .removeConnection(
                    session,
                    params['connectionId'],
                  ),
        ),
        'importSandboxAccounts': _is.MethodConnector(
          name: 'importSandboxAccounts',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
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
                    params['entityId'],
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
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'amountMinor': _is.ParameterDescription(
              name: 'amountMinor',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'frequency': _is.ParameterDescription(
              name: 'frequency',
              type: _is.getType<_ifz8weqz.RecurrenceFrequency>(),
              nullable: false,
            ),
            'nextDate': _is.ParameterDescription(
              name: 'nextDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'memo': _is.ParameterDescription(
              name: 'memo',
              type: _is.getType<String?>(),
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
                        params['accountId'],
                        params['description'],
                        params['amountMinor'],
                        params['frequency'],
                        params['nextDate'],
                        payeeId: params['payeeId'],
                        envelopeId: params['envelopeId'],
                        memo: params['memo'],
                        endDate: params['endDate'],
                      ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
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
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
                      .list(
                        session,
                        params['entityId'],
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
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'amountMinor': _is.ParameterDescription(
              name: 'amountMinor',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'frequency': _is.ParameterDescription(
              name: 'frequency',
              type: _is.getType<_ifz8weqz.RecurrenceFrequency?>(),
              nullable: true,
            ),
            'nextDate': _is.ParameterDescription(
              name: 'nextDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'clearPayee': _is.ParameterDescription(
              name: 'clearPayee',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'clearEnvelope': _is.ParameterDescription(
              name: 'clearEnvelope',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'memo': _is.ParameterDescription(
              name: 'memo',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'endDate': _is.ParameterDescription(
              name: 'endDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'clearEndDate': _is.ParameterDescription(
              name: 'clearEndDate',
              type: _is.getType<bool?>(),
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
                        accountId: params['accountId'],
                        description: params['description'],
                        amountMinor: params['amountMinor'],
                        frequency: params['frequency'],
                        nextDate: params['nextDate'],
                        payeeId: params['payeeId'],
                        clearPayee: params['clearPayee'],
                        envelopeId: params['envelopeId'],
                        clearEnvelope: params['clearEnvelope'],
                        memo: params['memo'],
                        endDate: params['endDate'],
                        clearEndDate: params['clearEndDate'],
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
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
                      .postDue(
                        session,
                        params['entityId'],
                      ),
        ),
        'countDue': _is.MethodConnector(
          name: 'countDue',
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
                  (endpoints['recurringTransaction']
                          as _ipwgw1dv.RecurringTransactionEndpoint)
                      .countDue(
                        session,
                        params['entityId'],
                      ),
        ),
      },
    );
    connectors['report'] = _is.EndpointConnector(
      name: 'report',
      endpoint: endpoints['report']!,
      methodConnectors: {
        'netWorth': _is.MethodConnector(
          name: 'netWorth',
          params: {
            'entityIds': _is.ParameterDescription(
              name: 'entityIds',
              type: _is.getType<List<_is.UuidValue>?>(),
              nullable: true,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'asOf': _is.ParameterDescription(
              name: 'asOf',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['report'] as _iqte9uvc.ReportEndpoint).netWorth(
                    session,
                    entityIds: params['entityIds'],
                    currencyCode: params['currencyCode'],
                    asOf: params['asOf'],
                  ),
        ),
        'netWorthHistory': _is.MethodConnector(
          name: 'netWorthHistory',
          params: {
            'fromDate': _is.ParameterDescription(
              name: 'fromDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'toDate': _is.ParameterDescription(
              name: 'toDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'granularity': _is.ParameterDescription(
              name: 'granularity',
              type: _is.getType<_iwv93n42.NetWorthGranularity>(),
              nullable: false,
            ),
            'entityIds': _is.ParameterDescription(
              name: 'entityIds',
              type: _is.getType<List<_is.UuidValue>?>(),
              nullable: true,
            ),
            'currencyCode': _is.ParameterDescription(
              name: 'currencyCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['report'] as _iqte9uvc.ReportEndpoint)
                  .netWorthHistory(
                    session,
                    params['fromDate'],
                    params['toDate'],
                    params['granularity'],
                    entityIds: params['entityIds'],
                    currencyCode: params['currencyCode'],
                  ),
        ),
        'spending': _is.MethodConnector(
          name: 'spending',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'fromMonth': _is.ParameterDescription(
              name: 'fromMonth',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'toMonth': _is.ParameterDescription(
              name: 'toMonth',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'grouping': _is.ParameterDescription(
              name: 'grouping',
              type: _is.getType<_i3o6dj87.ReportGrouping>(),
              nullable: false,
            ),
            'byMonth': _is.ParameterDescription(
              name: 'byMonth',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['report'] as _iqte9uvc.ReportEndpoint).spending(
                    session,
                    params['entityId'],
                    params['fromMonth'],
                    params['toMonth'],
                    params['grouping'],
                    params['byMonth'],
                  ),
        ),
        'monthSummaries': _is.MethodConnector(
          name: 'monthSummaries',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'fromMonth': _is.ParameterDescription(
              name: 'fromMonth',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'toMonth': _is.ParameterDescription(
              name: 'toMonth',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['report'] as _iqte9uvc.ReportEndpoint)
                  .monthSummaries(
                    session,
                    params['entityId'],
                    params['fromMonth'],
                    params['toMonth'],
                  ),
        ),
        'ageOfMoney': _is.MethodConnector(
          name: 'ageOfMoney',
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
                  (endpoints['report'] as _iqte9uvc.ReportEndpoint).ageOfMoney(
                    session,
                    params['entityId'],
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
    connectors['tax'] = _is.EndpointConnector(
      name: 'tax',
      endpoint: endpoints['tax']!,
      methodConnectors: {
        'getProfile': _is.MethodConnector(
          name: 'getProfile',
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
              ) async => (endpoints['tax'] as _i34kr7gr.TaxEndpoint).getProfile(
                session,
                params['entityId'],
              ),
        ),
        'saveProfile': _is.MethodConnector(
          name: 'saveProfile',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'jurisdiction': _is.ParameterDescription(
              name: 'jurisdiction',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'entityKind': _is.ParameterDescription(
              name: 'entityKind',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'profileJson': _is.ParameterDescription(
              name: 'profileJson',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['tax'] as _i34kr7gr.TaxEndpoint).saveProfile(
                    session,
                    params['entityId'],
                    params['jurisdiction'],
                    params['entityKind'],
                    params['profileJson'],
                  ),
        ),
        'listCategories': _is.MethodConnector(
          name: 'listCategories',
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
                  (endpoints['tax'] as _i34kr7gr.TaxEndpoint).listCategories(
                    session,
                    params['entityId'],
                  ),
        ),
        'setEnvelopeTaxCategory': _is.MethodConnector(
          name: 'setEnvelopeTaxCategory',
          params: {
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tax'] as _i34kr7gr.TaxEndpoint)
                  .setEnvelopeTaxCategory(
                    session,
                    params['envelopeId'],
                    code: params['code'],
                  ),
        ),
        'setLineTax': _is.MethodConnector(
          name: 'setLineTax',
          params: {
            'transactionLineId': _is.ParameterDescription(
              name: 'transactionLineId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'taxCategoryCode': _is.ParameterDescription(
              name: 'taxCategoryCode',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'clearTaxCategoryCode': _is.ParameterDescription(
              name: 'clearTaxCategoryCode',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'businessUsePercent': _is.ParameterDescription(
              name: 'businessUsePercent',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'salesTaxMinor': _is.ParameterDescription(
              name: 'salesTaxMinor',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tax'] as _i34kr7gr.TaxEndpoint).setLineTax(
                session,
                params['transactionLineId'],
                taxCategoryCode: params['taxCategoryCode'],
                clearTaxCategoryCode: params['clearTaxCategoryCode'],
                businessUsePercent: params['businessUsePercent'],
                salesTaxMinor: params['salesTaxMinor'],
              ),
        ),
        'getReport': _is.MethodConnector(
          name: 'getReport',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'startYear': _is.ParameterDescription(
              name: 'startYear',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tax'] as _i34kr7gr.TaxEndpoint).getReport(
                session,
                params['entityId'],
                startYear: params['startYear'],
              ),
        ),
        'getSummary': _is.MethodConnector(
          name: 'getSummary',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'startYear': _is.ParameterDescription(
              name: 'startYear',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tax'] as _i34kr7gr.TaxEndpoint).getSummary(
                session,
                params['entityId'],
                startYear: params['startYear'],
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
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'payeeId': _is.ParameterDescription(
              name: 'payeeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
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
                  (endpoints['transactionRule']
                          as _i70s5v1k.TransactionRuleEndpoint)
                      .create(
                        session,
                        params['entityId'],
                        params['payeeId'],
                        params['envelopeId'],
                      ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
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
                  (endpoints['transactionRule']
                          as _i70s5v1k.TransactionRuleEndpoint)
                      .list(
                        session,
                        params['entityId'],
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
            'envelopeId': _is.ParameterDescription(
              name: 'envelopeId',
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
                        envelopeId: params['envelopeId'],
                        enabled: params['enabled'],
                      ),
        ),
        'findMatchingEnvelope': _is.MethodConnector(
          name: 'findMatchingEnvelope',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
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
                        params['entityId'],
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
            'input': _is.ParameterDescription(
              name: 'input',
              type: _is.getType<_i87mxfy4.TransactionInput>(),
              nullable: false,
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
                        params['input'],
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
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<_iun6b2tc.TransactionQuery>(),
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
                        params['query'],
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
            'input': _is.ParameterDescription(
              name: 'input',
              type: _is.getType<_i87mxfy4.TransactionInput>(),
              nullable: false,
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
                        params['input'],
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
        'setStatus': _is.MethodConnector(
          name: 'setStatus',
          params: {
            'transactionIds': _is.ParameterDescription(
              name: 'transactionIds',
              type: _is.getType<List<_is.UuidValue>>(),
              nullable: false,
            ),
            'status': _is.ParameterDescription(
              name: 'status',
              type: _is.getType<_i54b59qp.TransactionStatus>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .setStatus(
                        session,
                        params['transactionIds'],
                        params['status'],
                      ),
        ),
        'setFlag': _is.MethodConnector(
          name: 'setFlag',
          params: {
            'transactionIds': _is.ParameterDescription(
              name: 'transactionIds',
              type: _is.getType<List<_is.UuidValue>>(),
              nullable: false,
            ),
            'flag': _is.ParameterDescription(
              name: 'flag',
              type: _is.getType<_iilgv4bx.TransactionFlag?>(),
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
                        params['transactionIds'],
                        params['flag'],
                      ),
        ),
        'createTransfer': _is.MethodConnector(
          name: 'createTransfer',
          params: {
            'input': _is.ParameterDescription(
              name: 'input',
              type: _is.getType<_i7e3qnpf.TransferInput>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .createTransfer(
                        session,
                        params['input'],
                      ),
        ),
        'updateTransfer': _is.MethodConnector(
          name: 'updateTransfer',
          params: {
            'transferId': _is.ParameterDescription(
              name: 'transferId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'input': _is.ParameterDescription(
              name: 'input',
              type: _is.getType<_i7e3qnpf.TransferInput>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .updateTransfer(
                        session,
                        params['transferId'],
                        params['input'],
                      ),
        ),
        'reconcile': _is.MethodConnector(
          name: 'reconcile',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'statementDate': _is.ParameterDescription(
              name: 'statementDate',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'statementBalanceMinor': _is.ParameterDescription(
              name: 'statementBalanceMinor',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'createAdjustment': _is.ParameterDescription(
              name: 'createAdjustment',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .reconcile(
                        session,
                        params['accountId'],
                        params['statementDate'],
                        params['statementBalanceMinor'],
                        params['createAdjustment'],
                      ),
        ),
        'importRows': _is.MethodConnector(
          name: 'importRows',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'rows': _is.ParameterDescription(
              name: 'rows',
              type: _is.getType<List<_iyod81ld.ImportRow>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['transaction'] as _if8xv4dr.TransactionEndpoint)
                      .importRows(
                        session,
                        params['accountId'],
                        params['rows'],
                      ),
        ),
        'findDuplicates': _is.MethodConnector(
          name: 'findDuplicates',
          params: {
            'accountId': _is.ParameterDescription(
              name: 'accountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'date': _is.ParameterDescription(
              name: 'date',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'amountMinor': _is.ParameterDescription(
              name: 'amountMinor',
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
                      .findDuplicates(
                        session,
                        params['accountId'],
                        params['date'],
                        params['amountMinor'],
                      ),
        ),
      },
    );
    connectors['wallet'] = _is.EndpointConnector(
      name: 'wallet',
      endpoint: endpoints['wallet']!,
      methodConnectors: {
        'connect': _is.MethodConnector(
          name: 'connect',
          params: {
            'entityId': _is.ParameterDescription(
              name: 'entityId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'network': _is.ParameterDescription(
              name: 'network',
              type: _is.getType<_ifz8weqz.WalletNetwork>(),
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
            'accountName': _is.ParameterDescription(
              name: 'accountName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['wallet'] as _i1ub0otr.WalletEndpoint).connect(
                    session,
                    params['entityId'],
                    params['network'],
                    params['address'],
                    label: params['label'],
                    accountName: params['accountName'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
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
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint).list(
                session,
                params['entityId'],
              ),
        ),
        'getForAccount': _is.MethodConnector(
          name: 'getForAccount',
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
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint)
                  .getForAccount(
                    session,
                    params['accountId'],
                  ),
        ),
        'sync': _is.MethodConnector(
          name: 'sync',
          params: {
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
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint).sync(
                session,
                params['walletId'],
              ),
        ),
        'listHoldings': _is.MethodConnector(
          name: 'listHoldings',
          params: {
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
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint)
                  .listHoldings(
                    session,
                    params['walletId'],
                  ),
        ),
        'listTransactions': _is.MethodConnector(
          name: 'listTransactions',
          params: {
            'walletId': _is.ParameterDescription(
              name: 'walletId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'before': _is.ParameterDescription(
              name: 'before',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint)
                  .listTransactions(
                    session,
                    params['walletId'],
                    before: params['before'],
                    limit: params['limit'],
                  ),
        ),
        'listTaxYearSummaries': _is.MethodConnector(
          name: 'listTaxYearSummaries',
          params: {
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
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint)
                  .listTaxYearSummaries(
                    session,
                    params['walletId'],
                  ),
        ),
        'updateTransactionMetadata': _is.MethodConnector(
          name: 'updateTransactionMetadata',
          params: {
            'walletTransactionId': _is.ParameterDescription(
              name: 'walletTransactionId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'category': _is.ParameterDescription(
              name: 'category',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'tags': _is.ParameterDescription(
              name: 'tags',
              type: _is.getType<List<String>?>(),
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
              ) async => (endpoints['wallet'] as _i1ub0otr.WalletEndpoint)
                  .updateTransactionMetadata(
                    session,
                    params['walletTransactionId'],
                    category: params['category'],
                    tags: params['tags'],
                    memo: params['memo'],
                  ),
        ),
        'disconnect': _is.MethodConnector(
          name: 'disconnect',
          params: {
            'walletId': _is.ParameterDescription(
              name: 'walletId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'deleteAccount': _is.ParameterDescription(
              name: 'deleteAccount',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['wallet'] as _i1ub0otr.WalletEndpoint).disconnect(
                    session,
                    params['walletId'],
                    deleteAccount: params['deleteAccount'],
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
