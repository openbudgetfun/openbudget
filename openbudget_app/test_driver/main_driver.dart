import 'package:flutter_driver/driver_extension.dart';
import 'package:openbudget_app/src/app_bootstrap.dart';
import 'package:openbudget_app/src/config/app_environment.dart';

/// Driver-enabled entrypoint for mobile MCP screenshot capture workflows.
Future<void> main() async {
  enableFlutterDriverExtension();
  await runOpenBudgetApp(AppFlavor.dev);
}
