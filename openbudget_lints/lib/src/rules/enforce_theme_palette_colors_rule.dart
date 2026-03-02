import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

final class EnforceThemePaletteColorsRule extends AnalysisRule {
  EnforceThemePaletteColorsRule()
    : super(
        name: 'enforce_theme_palette_colors',
        description:
            'Require OpenBudgetPalette theme-aware color access in openbudget_app.',
      );

  static const LintCode code = LintCode(
    'enforce_theme_palette_colors',
    'Avoid hardcoded colors. Use OpenBudgetPalette.*For(theme) instead.',
    correctionMessage:
        'Replace hardcoded or direct palette constants with OpenBudgetPalette.*For(theme).',
    severity: DiagnosticSeverity.WARNING,
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _EnforceThemePaletteColorsVisitor(this, context);
    registry
      ..addInstanceCreationExpression(this, visitor)
      ..addPrefixedIdentifier(this, visitor)
      ..addPropertyAccess(this, visitor);
  }
}

final class _EnforceThemePaletteColorsVisitor extends SimpleAstVisitor<void> {
  _EnforceThemePaletteColorsVisitor(this.rule, this.context);

  static const String _appFolderName = 'openbudget_app';
  static const String _palettePath = 'lib/src/theme/openbudget_palette.dart';
  static const String _libPrefix = 'lib/';

  final AnalysisRule rule;
  final RuleContext context;

  bool get _shouldLintCurrentFile {
    final packageRoot = context.package?.root;
    final currentFile = context.currentUnit?.file;
    if (packageRoot == null || currentFile == null) {
      return false;
    }
    if (packageRoot.shortName != _appFolderName) {
      return false;
    }

    final pathContext = packageRoot.provider.pathContext;
    final relativePath = pathContext.relative(
      pathContext.normalize(currentFile.path),
      from: packageRoot.path,
    );

    if (!relativePath.startsWith(_libPrefix)) {
      return false;
    }
    if (relativePath == _palettePath) {
      return false;
    }
    return true;
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!_shouldLintCurrentFile) {
      return;
    }

    final typeName = node.constructorName.type.name.lexeme;
    if (typeName == 'Color') {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (!_shouldLintCurrentFile) {
      return;
    }

    if (node.prefix.name == 'Colors') {
      rule.reportAtNode(node);
      return;
    }

    if (node.prefix.name == 'OpenBudgetPalette' &&
        !node.identifier.name.endsWith('For')) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (!_shouldLintCurrentFile) {
      return;
    }

    final target = node.target;
    if (target is SimpleIdentifier && target.name == 'Colors') {
      rule.reportAtNode(node);
      return;
    }

    if (target is SimpleIdentifier &&
        target.name == 'OpenBudgetPalette' &&
        !node.propertyName.name.endsWith('For')) {
      rule.reportAtNode(node);
    }
  }
}
