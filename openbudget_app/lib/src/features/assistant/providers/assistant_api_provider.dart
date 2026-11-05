import 'package:openbudget_app/src/features/assistant/api/assistant_api.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assistant_api_provider.g.dart';

/// The assistant API the app uses. Tests override this with a fake.
@riverpod
AssistantApi assistantApi(Ref ref) =>
    ServerpodAssistantApi(ref.watch(serverpodClientProvider).agent);
