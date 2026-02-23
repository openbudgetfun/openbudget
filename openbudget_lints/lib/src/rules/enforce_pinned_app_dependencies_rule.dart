import 'dart:convert';

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart';

final class EnforcePinnedAppDependenciesRule extends AnalysisRule {
  EnforcePinnedAppDependenciesRule()
    : super(
        name: 'enforce_pinned_app_dependencies',
        description:
            'Require exact versions in openbudget_app dependencies section.',
      );

  static const LintCode code = LintCode(
    'enforce_pinned_app_dependencies',
    'openbudget_app dependency `{0}` must use an exact version. '
        'Do not use `^`, `>`, `>=`, or `~` constraints.',
    correctionMessage: 'Pin to an exact version, for example: `{0}: 1.2.3`.',
    severity: DiagnosticSeverity.WARNING,
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(
      this,
      _PinnedDependenciesVisitor(this, context),
    );
  }
}

final class _PinnedDependenciesVisitor extends SimpleAstVisitor<void> {
  _PinnedDependenciesVisitor(this.rule, this.context);

  static const String _appFolderName = 'openbudget_app';
  static const String _mainDartPath = 'lib/main.dart';
  static const String _pubspecPath = 'pubspec.yaml';

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final packageRoot = context.package?.root;
    final currentFile = context.currentUnit?.file;
    if (packageRoot == null || currentFile == null) {
      return;
    }
    if (packageRoot.shortName != _appFolderName) {
      return;
    }

    final pathContext = packageRoot.provider.pathContext;
    final anchorPath = pathContext.normalize(
      pathContext.join(packageRoot.path, _mainDartPath),
    );
    if (pathContext.normalize(currentFile.path) != anchorPath) {
      return;
    }

    for (final dependencyName in _PinnedDependenciesCache.readViolations(
      packageRoot,
    )) {
      rule.reportAtToken(node.beginToken, arguments: [dependencyName]);
    }
  }
}

final class _PinnedDependenciesCache {
  static const _constraintPattern = r':\s*[\^>~]';
  static final RegExp _unpinnedConstraintRegex = RegExp(_constraintPattern);

  static final Map<String, _CacheEntry> _cache = {};

  static List<String> readViolations(Folder packageRoot) {
    final pubspecFile = packageRoot.getChildAssumingFile(
      _PinnedDependenciesVisitor._pubspecPath,
    );
    if (!pubspecFile.exists) {
      return const [];
    }

    final cacheKey = packageRoot.path;
    final stamp = pubspecFile.modificationStamp;
    final cached = _cache[cacheKey];
    if (cached != null && cached.modificationStamp == stamp) {
      return cached.violations;
    }

    final violations = _extractViolations(pubspecFile.readAsStringSync());
    _cache[cacheKey] = _CacheEntry(stamp, violations);
    return violations;
  }

  static List<String> _extractViolations(String pubspecContent) {
    final lines = const LineSplitter().convert(pubspecContent);
    var inDependencies = false;
    final violations = <String>[];

    for (final line in lines) {
      if (!inDependencies) {
        if (line.startsWith('dependencies:')) {
          inDependencies = true;
        }
        continue;
      }

      if (line.isNotEmpty && !line.startsWith(' ')) {
        break;
      }

      if (line.trimLeft().startsWith('#')) {
        continue;
      }

      if (_unpinnedConstraintRegex.hasMatch(line)) {
        final dependencyName = line.split(':').first.trim();
        if (dependencyName.isNotEmpty) {
          violations.add(dependencyName);
        }
      }
    }

    return violations;
  }
}

final class _CacheEntry {
  const _CacheEntry(this.modificationStamp, this.violations);

  final int modificationStamp;
  final List<String> violations;
}
