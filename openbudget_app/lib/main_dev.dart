import 'package:openbudget_app/src/app_bootstrap.dart';
import 'package:openbudget_app/src/config/app_environment.dart';

Future<void> main() async {
  await runOpenBudgetApp(AppFlavor.dev);
}
