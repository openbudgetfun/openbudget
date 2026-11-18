import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';

import 'strict_yaml.dart';

/// What a good reply does, per docs/money-guide.md, section 8.2.
enum GoldenBehaviour {
  /// Answers the question; passes when every other check passes.
  answer,

  /// Qualifies the answer: it says the source is secondary, unverified or
  /// announced.
  qualify,

  /// Declines, states its scope and quotes no currency amount.
  refuse,

  /// Names a professional from the country's signpost list.
  signpost,
}

/// What one golden question expects of a reply
/// (docs/money-guide.md, section 8.1, the `expect` block).
final class GoldenExpectation {
  const GoldenExpectation({
    required this.behaviour,
    this.tools = const [],
    this.cites = const [],
    this.mentions = const [],
    this.forbidden = const [],
    this.signposts = const [],
  });

  final GoldenBehaviour behaviour;

  /// Tools the model must call, in any order.
  final List<String> tools;

  /// Citation keys the reply must carry and that must resolve: knowledge
  /// card ids, or the `citeAs` of a tax tool result such as `report-2026`.
  final List<String> cites;

  /// Facts the reply must state, such as exact figures from the fixture.
  /// Thousands separators and spacing are normalised before matching.
  final List<String> mentions;

  /// Phrases the reply must not contain. The never-suggest wording is added
  /// automatically.
  final List<String> forbidden;

  /// Extra professionals a `signpost` reply may name, beyond the country's
  /// own signpost list.
  final List<String> signposts;
}

/// One golden question (docs/money-guide.md, section 8.1).
final class GoldenQuestion {
  const GoldenQuestion({
    required this.id,
    required this.ask,
    required this.expect,
    this.guardrail = false,
  });

  /// Unique within the file and prefixed with the file's country code, such
  /// as `gb-01`.
  final String id;

  /// What the user types.
  final String ask;

  /// A guardrail item passes only when all runs pass (section 8.3).
  final bool guardrail;

  final GoldenExpectation expect;
}

/// One golden file: the questions of a country, or of the universal layer,
/// all asked against one fixture entity.
final class GoldenFile {
  const GoldenFile({
    required this.country,
    required this.fixture,
    required this.questions,
  });

  /// Parses [source]. [name] labels errors, usually the file name.
  factory GoldenFile.parse(String source, {required String name}) {
    final root = parseYamlMap(source, name: name);
    checkKeys(
      root,
      name,
      required: {'country', 'fixture', 'questions'},
    );
    final country = asString(root['country'], '$name.country');
    final questions = [
      for (final (index, raw) in asMapList(
        root['questions'],
        '$name.questions',
      ).indexed)
        _parseQuestion(raw, '$name.questions[$index]'),
    ];
    if (questions.isEmpty) {
      throw EvalFormatException('$name.questions', 'must not be empty');
    }
    return GoldenFile(
      country: country,
      fixture: asString(root['fixture'], '$name.fixture'),
      questions: questions,
    );
  }

  /// An upper-case ISO country code, or [universalCountryCode].
  final String country;

  /// The id of the fixture entity in `fixtures/entities.yaml`.
  final String fixture;

  final List<GoldenQuestion> questions;
}

final RegExp _questionId = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

GoldenQuestion _parseQuestion(Map<String, Object?> raw, String path) {
  checkKeys(
    raw,
    path,
    required: {'id', 'ask', 'expect'},
    optional: {'guardrail'},
  );
  final id = asString(raw['id'], '$path.id');
  if (!_questionId.hasMatch(id)) {
    throw EvalFormatException('$path.id', 'must be lower-case kebab case');
  }
  final guardrail =
      raw.containsKey('guardrail') &&
      asBool(raw['guardrail'], '$path.guardrail');
  return GoldenQuestion(
    id: id,
    ask: asString(raw['ask'], '$path.ask'),
    guardrail: guardrail,
    expect: _parseExpectation(asStringMap(raw['expect'], '$path.expect'), path),
  );
}

GoldenExpectation _parseExpectation(Map<String, Object?> raw, String path) {
  final at = '$path.expect';
  checkKeys(
    raw,
    at,
    required: {'behaviour'},
    optional: {'tools', 'cites', 'mentions', 'forbidden', 'signposts'},
  );
  final behaviourName = asString(raw['behaviour'], '$at.behaviour');
  final behaviour = GoldenBehaviour.values
      .where((value) => value.name == behaviourName)
      .firstOrNull;
  if (behaviour == null) {
    throw EvalFormatException(
      '$at.behaviour',
      'must be one of ${GoldenBehaviour.values.map((v) => v.name).join(', ')}',
    );
  }
  return GoldenExpectation(
    behaviour: behaviour,
    tools: asStringList(raw['tools'], '$at.tools'),
    cites: asStringList(raw['cites'], '$at.cites'),
    mentions: asStringList(raw['mentions'], '$at.mentions'),
    forbidden: asStringList(raw['forbidden'], '$at.forbidden'),
    signposts: asStringList(raw['signposts'], '$at.signposts'),
  );
}
