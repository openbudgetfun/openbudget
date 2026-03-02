import 'dart:io';

final _textLiteralPattern = RegExp(
  r'''(?:Text|SelectableText)\(\s*(?:const\s*)?(['"])([^'"]*)\1''',
);

final _namedLiteralPattern = RegExp(
  r'''\b(?:label|title|hintText|labelText|helperText|tooltip|semanticLabel)\s*:\s*(?:const\s*)?(['"])([^'"]*)\1''',
);

void main() {
  final root = Directory.current;
  final sourceRoot = Directory(
    '${root.path}/openbudget_app/lib/src',
  );

  if (!sourceRoot.existsSync()) {
    stderr.writeln(
      'Missing source directory: ${sourceRoot.path}. Run from repo root.',
    );
    exitCode = 2;
    return;
  }

  final violations = <String>[];
  final files = sourceRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (line.contains('// l10n-ignore')) continue;

      for (final pattern in [_textLiteralPattern, _namedLiteralPattern]) {
        for (final match in pattern.allMatches(line)) {
          final literal = match.group(2) ?? '';
          if (_shouldIgnoreLiteral(literal)) continue;
          final relativePath = file.path.replaceFirst('${root.path}/', '');
          violations.add(
            '$relativePath:${index + 1}: hardcoded UI text "$literal"',
          );
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('No hardcoded UI text detected in openbudget_app/lib/src.');
    return;
  }

  stderr.writeln(
    'Found hardcoded UI text. Add strings to openbudget_app/lib/l10n/app_en.arb and use AppLocalizations.',
  );
  for (final violation in violations) {
    stderr.writeln(violation);
  }
  exitCode = 1;
}

bool _shouldIgnoreLiteral(String literal) {
  if (literal.trim().isEmpty) return true;
  if (literal.contains(r'$')) return true;
  if (RegExp(r'^[0-9]+$').hasMatch(literal)) return true;
  if (RegExp(r'^[^\w]+$').hasMatch(literal)) return true;
  return false;
}
