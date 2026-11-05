import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assistant_usage_provider.g.dart';

/// How much of the included assistant usage is left this month.
@riverpod
Future<AgentUsageView> assistantUsage(Ref ref) =>
    ref.watch(assistantApiProvider).getUsage();
