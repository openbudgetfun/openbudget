import 'dart:convert';
import 'dart:io';

import 'package:openbudget_server/src/agent/chat_completions_client.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  late HttpServer redirectTarget;
  late HttpServer origin;
  var targetRequests = 0;

  setUp(() async {
    targetRequests = 0;
    redirectTarget = await HttpServer.bind(InternetAddress.loopbackIPv4, 0)
      ..listen((request) async {
        targetRequests++;
        await request.drain<void>();
        request.response
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'followed', 'tool_calls': <Object>[]},
                },
              ],
              'usage': {
                'prompt_tokens': 1,
                'completion_tokens': 1,
                'prompt_tokens_details': {'cached_tokens': 0},
              },
            }),
          );
        await request.response.close();
      });
    origin = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    await origin.close(force: true);
    await redirectTarget.close(force: true);
  });

  for (final status in [HttpStatus.found, HttpStatus.temporaryRedirect]) {
    test('when the provider answers $status then the redirect is not '
        'followed and the call fails', () async {
      origin.listen((request) async {
        await request.drain<void>();
        request.response.statusCode = status;
        request.response.headers.set(
          HttpHeaders.locationHeader,
          'http://127.0.0.1:${redirectTarget.port}/v1/chat/completions',
        );
        await request.response.close();
      });

      final client = ChatCompletionsClient();

      await expectLater(
        client.complete(
          endpoint: Uri.parse(
            'http://127.0.0.1:${origin.port}/v1/chat/completions',
          ),
          apiKey: 'test-key',
          model: 'test-model',
          messages: const [
            {'role': 'user', 'content': 'hello'},
          ],
          tools: const [],
        ),
        throwsA(isA<AgentProviderException>()),
      );
      expect(targetRequests, 0);
    });
  }
}
