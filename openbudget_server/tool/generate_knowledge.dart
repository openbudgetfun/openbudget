// Generates lib/src/money_guide/knowledge/knowledge_cards.g.dart from the
// Markdown cards in knowledge/, one file per card
// (docs/money-guide.md, sections 4.1 and 4.2).
//
// The Markdown files are the source of truth; this tool parses the front
// matter, validates every card against the format rules — including that
// every {{figure:id}} placeholder exists in the country pack for each
// listed tax year — and writes the cards as `const` Dart. CI runs --check
// and fails when the committed Dart has drifted from the cards.
//
//   dart run tool/generate_knowledge.dart          # write the constants
//   dart run tool/generate_knowledge.dart --check  # fail if stale
import 'dart:io';

import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';

void main(List<String> args) {
  final checkOnly = args.contains('--check');
  final root = Directory('knowledge');
  if (!root.existsSync()) {
    _fail('no knowledge/ directory; run from openbudget_server');
  }

  final files =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) {
    _fail('knowledge/ holds no Markdown cards');
  }

  final cards = <KnowledgeCard>[];
  for (final file in files) {
    try {
      cards.add(
        parseKnowledgeCardMarkdown(file.readAsStringSync(), path: file.path),
      );
    } on KnowledgeFormatException catch (error) {
      _fail(error.toString());
    }
  }

  final pathOfId = <String, String>{
    for (var i = 0; i < cards.length; i++) cards[i].id: files[i].path,
  };
  final issues = validateKnowledgeCards(cards);
  for (final issue in issues) {
    stderr.writeln(
      'generate_knowledge: ${pathOfId[issue.cardId] ?? '?'}: $issue',
    );
  }
  if (issues.isNotEmpty) {
    stderr.writeln(
      'generate_knowledge: ${issues.length} rule(s) broken across '
      '${cards.length} cards',
    );
    exit(2);
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Regenerate with: dart run tool/generate_knowledge.dart')
    ..writeln('//')
    ..writeln('// Source of truth: knowledge/<country>/<topic>/<card>.md,')
    ..writeln('// one file per card (docs/money-guide.md, sections 4.1')
    ..writeln('// and 4.2).')
    ..writeln()
    ..writeln("import 'package:openbudget_core/openbudget_core.dart';")
    ..writeln()
    ..writeln("import 'knowledge_card.dart';")
    ..writeln()
    ..writeln('/// Every knowledge card, in file-path order.')
    ..writeln(
      '/// A top-level final: the corpus is built once, on first use.',
    )
    ..writeln('final List<KnowledgeCard> knowledgeCards = <KnowledgeCard>[');
  for (final card in cards) {
    _writeCard(buffer, card);
  }
  buffer.writeln('];');

  const outputPath = 'lib/src/money_guide/knowledge/knowledge_cards.g.dart';
  final output = buffer.toString();
  final existing = File(outputPath);
  if (checkOnly) {
    if (!existing.existsSync() || existing.readAsStringSync() != output) {
      _fail(
        '$outputPath is out of date with knowledge/. '
        'Run `dart run tool/generate_knowledge.dart` and commit.',
      );
    }
    stdout.writeln(
      'knowledge_cards.g.dart is up to date (${cards.length} cards).',
    );
    return;
  }
  existing.writeAsStringSync(output);
  stdout.writeln('Generated $outputPath with ${cards.length} cards.');
}

void _writeCard(StringBuffer buffer, KnowledgeCard card) {
  buffer
    ..writeln('  KnowledgeCard(')
    ..writeln('    id: ${_literal(card.id)},')
    ..writeln('    countryCode: ${_literal(card.countryCode)},')
    ..writeln('    title: ${_literal(card.title)},')
    ..writeln('    topics: ${_stringList(card.topics)},')
    ..writeln(
      '    entityKinds: <EntityKind>[${card.entityKinds.map((kind) => 'EntityKind.${kind.name}').join(', ')}],',
    )
    ..writeln('    taxYears: <int>[${card.taxYears.join(', ')}],')
    ..writeln('    grade: TaxEvidenceGrade.${card.grade.name},')
    ..writeln('    verifiedOn: ${_dateLiteral(card.verifiedOn)},')
    ..writeln('    recheckBy: ${_dateLiteral(card.recheckBy)},')
    ..writeln('    perimeter: KnowledgePerimeter.${card.perimeter.name},')
    ..writeln('    needsEvidence: ${card.needsEvidence},')
    ..writeln('    announced: ${card.announced},')
    ..writeln('    keywords: ${_stringList(card.keywords)},');
  final skill = card.skill;
  if (skill != null) {
    buffer.writeln('    skill: ${_literal(skill)},');
  }
  buffer.writeln('    sources: <KnowledgeCardSource>[');
  for (final source in card.sources) {
    buffer
      ..writeln('      KnowledgeCardSource(')
      ..writeln('        title: ${_literal(source.title)},')
      ..writeln('        url: ${_uriLiteral(source.url)},')
      ..writeln('        grade: TaxEvidenceGrade.${source.grade.name},')
      ..writeln('      ),');
  }
  buffer
    ..writeln('    ],')
    ..writeln('    body: ${_literal(card.body)},')
    ..writeln('  ),');
}

String _stringList(List<String> values) =>
    "const <String>[${values.map(_literal).join(', ')}]";

String _dateLiteral(DateTime date) =>
    'DateTime.utc(${date.year}, ${date.month}, ${date.day})';

/// `Uri.parse` is not const, so a url is written as the const
/// `Uri.https(host, path)`; validation already rejects anything else.
String _uriLiteral(Uri url) =>
    'Uri.https(${_literal(url.host)}, ${_literal(url.path)})';

/// A Dart string literal, with newlines and tabs escaped so each card body
/// stays on one line.
String _literal(String value) =>
    '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll(r'$', r'\$').replaceAll('\n', r'\n').replaceAll('\r', r'\r').replaceAll('\t', r'\t')}"';

Never _fail(String message) {
  stderr.writeln('generate_knowledge: $message');
  exit(2);
}
