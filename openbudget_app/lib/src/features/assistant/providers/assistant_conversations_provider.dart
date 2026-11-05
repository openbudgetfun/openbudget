import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assistant_conversations_provider.g.dart';

/// The conversations in one budget, newest first.
@riverpod
Future<List<AgentConversation>> assistantConversations(
  Ref ref,
  String budgetId,
) => ref.watch(assistantApiProvider).listConversations(budgetId);
