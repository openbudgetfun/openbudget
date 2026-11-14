import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_usage_provider.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_proposals_screen.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_screen.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:patrol/patrol.dart';

import 'common/fake_assistant_api.dart';
import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

void main() {
  patrolWidgetTest(
    'More -> Money guide -> ask -> open sources -> apply a proposal',
    ($) async {
      final tester = $.tester;
      final api = FakeAssistantApi();
      const entityId = TestData.assistantEntityId;

      final container = ProviderContainer(
        overrides: [
          assistantApiProvider.overrideWith((ref) => api),
          assistantUsageProvider.overrideWith((ref) async => api.usage),
          entityDetailProvider.overrideWith(
            (ref, id) async => TestData.gbpEntity(
              id: entityId,
            ),
          ),
          taxProfileProvider.overrideWith((ref, id) async => null),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/budgets/$entityId/more',
        routes: [
          GoRoute(
            name: moreRoute,
            path: morePath,
            builder: (context, state) =>
                MoreScreen(entityId: state.pathParameters['entityId']!),
          ),
          GoRoute(
            name: assistantRoute,
            path: assistantPath,
            builder: (context, state) =>
                AssistantScreen(entityId: state.pathParameters['entityId']!),
            routes: [
              GoRoute(
                name: assistantProposalsRoute,
                path: 'proposals',
                builder: (context, state) => AssistantProposalsScreen(
                  entityId: state.pathParameters['entityId']!,
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpApp(
        const SizedBox.shrink(),
        container: container,
        router: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
      await tester.pumpAndSettle();

      final more = MoreTabPage(tester);
      expect(more.assistantTile, findsOneWidget);

      await tester.tap(more.assistantTile);
      await tester.pumpAndSettle();

      final assistant = AssistantPage(tester);
      expect(assistant.title, findsOneWidget);
      expect(assistant.emptyTitle, findsOneWidget);
      expect(assistant.disclaimer, findsOneWidget);
      expect(
        assistant.conversationsLeft(TestData.assistantConversationsLeft),
        findsOneWidget,
      );

      await assistant.ask(TestData.assistantQuestion);

      expect(api.chatMessages, [TestData.assistantQuestion]);
      expect(assistant.reply(TestData.assistantReply), findsOneWidget);
      expect(assistant.citationMark(1), findsOneWidget);
      expect(assistant.citationMark(2), findsOneWidget);
      expect(assistant.replyDisclaimer, findsOneWidget);
      expect(assistant.toolChip(TestData.assistantToolLabel), findsOneWidget);
      expect(
        assistant.proposalSummary(TestData.assistantProposalSummary),
        findsOneWidget,
      );

      await assistant.tapCitationMark(1);

      expect(assistant.sourcesSheet, findsOneWidget);
      expect(
        assistant.sourceTitle(TestData.assistantSourceTitle),
        findsOneWidget,
      );
      expect(
        assistant.sourceTitle(TestData.assistantTaxSourceTitle),
        findsOneWidget,
      );
      expect(assistant.secondaryBadge, findsOneWidget);
      expect(assistant.announcedBadge, findsOneWidget);

      await assistant.closeSourcesSheet();
      expect(assistant.sourcesSheet, findsNothing);

      await assistant.applyFirstProposal();

      expect(api.applyCalls, [TestData.assistantProposalId]);
      expect(assistant.appliedChip, findsOneWidget);

      // Guard: the flow must never build the production Serverpod client.
      // With the fixtures above missing, MoreScreen's books entry reads the
      // live budget and tax providers, so this fails instead of leaving a
      // request to api.openbudget.app in flight at teardown.
      expect(container.exists(serverpodClientProvider), isFalse);
    },
  );
}
