import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app source does not contain YNAB branding strings', () {
    final workingDir = Directory.current;
    final candidateLibDirs = [
      Directory('${workingDir.path}/openbudget_app/lib'),
      Directory('${workingDir.path}/lib'),
    ];

    final libDir = candidateLibDirs.firstWhere(
      (directory) => directory.existsSync(),
      orElse: () => throw StateError(
        'Unable to locate openbudget_app/lib from ${workingDir.path}',
      ),
    );

    final offenders = <String>[];
    final pattern = RegExp(r'\bynab\b', caseSensitive: false);
    final windowsSeparator = String.fromCharCode(92);

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final normalizedPath = entity.path.replaceAll(windowsSeparator, '/');
      if (normalizedPath.contains('/l10n/generated/')) continue;

      final contents = entity.readAsStringSync();
      if (pattern.hasMatch(contents)) {
        offenders.add(normalizedPath);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Found YNAB branding in shipped app source. Replace with OpenBudget language.\n${offenders.join('\n')}',
    );
  });
}
