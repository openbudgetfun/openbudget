import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:openbudget_lints/src/rules/disallow_stateful_widgets_rule.dart';
import 'package:openbudget_lints/src/rules/enforce_pinned_app_dependencies_rule.dart';
import 'package:openbudget_lints/src/rules/enforce_theme_palette_colors_rule.dart';

final plugin = OpenBudgetPlugin();

class OpenBudgetPlugin extends Plugin {
  @override
  String get name => 'OpenBudget Lints';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(DisallowStatefulWidgetsRule())
      ..registerWarningRule(EnforcePinnedAppDependenciesRule())
      ..registerWarningRule(EnforceThemePaletteColorsRule());
  }
}
