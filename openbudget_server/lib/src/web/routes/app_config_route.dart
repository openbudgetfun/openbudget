import 'package:serverpod/serverpod.dart';

class AppConfigWidget extends JsonWidget {
  AppConfigWidget({required String apiUrl}) : super(object: {'apiUrl': apiUrl});
}

class AppConfigRoute extends WidgetRoute {
  AppConfigRoute({required ServerConfig apiConfig})
    : widget = AppConfigWidget(apiUrl: apiConfig.apiUrl.toString());

  final AppConfigWidget widget;

  @override
  Future<WebWidget> build(Session session, Request request) async => widget;
}

extension on ServerConfig {
  Uri get apiUrl =>
      Uri(scheme: publicScheme, host: publicHost, port: publicPort);
}
