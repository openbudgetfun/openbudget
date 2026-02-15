import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Example endpoint that returns a greeting message.
class GreetingEndpoint extends Endpoint {
  /// Returns a personalized greeting message: "Hello {name}".
  Future<Greeting> hello(Session session, String name) async {
    return Greeting(
      message: 'Hello $name',
      author: 'Serverpod',
      timestamp: DateTime.now(),
    );
  }
}
