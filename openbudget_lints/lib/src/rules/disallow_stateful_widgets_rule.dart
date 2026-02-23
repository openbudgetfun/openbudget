import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:yaml/yaml.dart';

final class DisallowStatefulWidgetsRule extends AnalysisRule {
  DisallowStatefulWidgetsRule()
    : super(
        name: 'avoid_stateful_widgets',
        description: 'Disallow StatefulWidget-based classes in OpenBudget.',
      );

  static const LintCode code = LintCode(
    'avoid_stateful_widgets',
    'Stateful widgets are not allowed in OpenBudget. '
        'Use HookWidget, HookConsumerWidget, or StatelessWidget instead.',
    correctionMessage:
        'Replace this widget with a hook-based or stateless implementation.',
    severity: DiagnosticSeverity.WARNING,
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _DisallowStatefulWidgetsVisitor(
      this,
      _DisallowedClassNamesResolver.resolve(context),
    );
    registry
      ..addClassDeclaration(this, visitor)
      ..addClassTypeAlias(this, visitor);
  }
}

final class _DisallowStatefulWidgetsVisitor extends SimpleAstVisitor<void> {
  _DisallowStatefulWidgetsVisitor(this.rule, this.disallowedWidgetTypes)
    : allowedWidgetTypes = _alwaysAllowedWidgetTypes.difference(
        disallowedWidgetTypes,
      );

  static const Set<String> _alwaysAllowedWidgetTypes = {
    'HookWidget',
    'HookConsumerWidget',
    'ConsumerWidget',
    'StatelessWidget',
  };

  final AnalysisRule rule;
  final Set<String> disallowedWidgetTypes;
  final Set<String> allowedWidgetTypes;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _reportIfDisallowed(node.extendsClause?.superclass);
  }

  @override
  void visitClassTypeAlias(ClassTypeAlias node) {
    _reportIfDisallowed(node.superclass);
  }

  void _reportIfDisallowed(NamedType? superclass) {
    if (superclass == null) {
      return;
    }

    final type = superclass.type;
    if (type is InterfaceType && _isDisallowedOrStatefulDescendant(type)) {
      rule.reportAtNode(superclass);
      return;
    }

    final superclassName = superclass.name.lexeme;
    if (allowedWidgetTypes.contains(superclassName)) {
      return;
    }
    if (disallowedWidgetTypes.contains(superclassName)) {
      rule.reportAtNode(superclass);
    }
  }

  bool _isDisallowedOrStatefulDescendant(InterfaceType type) {
    final hierarchyTypeNames = <String>{};
    final directTypeName = type.element.name;
    if (directTypeName != null) {
      hierarchyTypeNames.add(directTypeName);
    }
    for (final supertype in type.allSupertypes) {
      final supertypeName = supertype.element.name;
      if (supertypeName != null) {
        hierarchyTypeNames.add(supertypeName);
      }
    }

    if (hierarchyTypeNames.any(allowedWidgetTypes.contains)) {
      return false;
    }
    if (hierarchyTypeNames.any(disallowedWidgetTypes.contains)) {
      return true;
    }
    return false;
  }
}

final class _DisallowedClassNamesResolver {
  static const String _analysisOptionsYaml = 'analysis_options.yaml';
  static const String _analysisOptionsYml = 'analysis_options.yml';
  static const String _pluginsKey = 'plugins';
  static const String _pluginName = 'openbudget_lints';
  static const String _disallowedClassesKey = 'disallowed_classes';

  static const Set<String> _defaults = {
    'StatefulWidget',
    'ConsumerStatefulWidget',
    'StatefulHookConsumerWidget',
  };

  static final Map<String, Set<String>> _cache = {};

  static Set<String> resolve(RuleContext context) {
    final packageRoot = context.package?.root;
    if (packageRoot == null) {
      return _defaults;
    }

    return _cache.putIfAbsent(packageRoot.path, () {
      final parsed = _tryReadConfiguredClassNames(packageRoot);
      return parsed ?? _defaults;
    });
  }

  static Set<String>? _tryReadConfiguredClassNames(Folder packageRoot) {
    final optionsFile = _analysisOptionsFile(packageRoot);
    if (optionsFile == null || !optionsFile.exists) {
      return null;
    }

    final yaml = loadYaml(optionsFile.readAsStringSync());
    if (yaml is! YamlMap) {
      return null;
    }

    final plugins = yaml[_pluginsKey];
    if (plugins is! YamlMap) {
      return null;
    }

    final pluginConfig = plugins[_pluginName];
    if (pluginConfig is! YamlMap) {
      return null;
    }

    final disallowedClasses = pluginConfig[_disallowedClassesKey];
    if (disallowedClasses is! YamlList) {
      return null;
    }

    final configuredNames = <String>{};
    for (final value in disallowedClasses) {
      if (value is String) {
        final className = value.trim();
        if (className.isNotEmpty) {
          configuredNames.add(className);
        }
      }
    }
    return configuredNames;
  }

  static File? _analysisOptionsFile(Folder packageRoot) {
    final yamlFile = packageRoot.getChildAssumingFile(_analysisOptionsYaml);
    if (yamlFile.exists) {
      return yamlFile;
    }

    final ymlFile = packageRoot.getChildAssumingFile(_analysisOptionsYml);
    if (ymlFile.exists) {
      return ymlFile;
    }

    return null;
  }
}
