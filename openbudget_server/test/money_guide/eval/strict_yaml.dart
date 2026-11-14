import 'package:yaml/yaml.dart';

/// Thrown when an eval file breaks its schema. The message names the file
/// location so a reviewer can fix the line.
final class EvalFormatException implements Exception {
  EvalFormatException(this.path, this.message);

  /// Where in the file the problem is, such as `questions[2].expect.tools`.
  final String path;

  final String message;

  @override
  String toString() => '$path: $message';
}

/// Parses [source] and returns its top-level map.
Map<String, Object?> parseYamlMap(String source, {required String name}) {
  final Object? parsed;
  try {
    parsed = loadYaml(source);
  } on YamlException catch (error) {
    throw EvalFormatException(name, 'not valid YAML: ${error.message}');
  }
  return asStringMap(parsed, name);
}

/// Reads [value] as a map with string keys, or throws naming [path].
Map<String, Object?> asStringMap(Object? value, String path) {
  if (value is! Map) {
    throw EvalFormatException(path, 'expected a map');
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw EvalFormatException(path, 'keys must be strings, got $key');
    }
    result[key] = entry.value;
  }
  return result;
}

/// Rejects any key of [map] that is not in [required] or [optional], and any
/// required key that is missing.
void checkKeys(
  Map<String, Object?> map,
  String path, {
  required Set<String> required,
  Set<String> optional = const {},
}) {
  for (final key in map.keys) {
    if (!required.contains(key) && !optional.contains(key)) {
      throw EvalFormatException(path, 'unknown key "$key"');
    }
  }
  for (final key in required) {
    if (!map.containsKey(key) || map[key] == null) {
      throw EvalFormatException(path, 'missing required key "$key"');
    }
  }
}

/// Reads a non-empty string.
String asString(Object? value, String path) {
  if (value is! String || value.trim().isEmpty) {
    throw EvalFormatException(path, 'expected a non-empty string');
  }
  return value;
}

/// Reads an integer.
int asInt(Object? value, String path) {
  if (value is! int) {
    throw EvalFormatException(path, 'expected an integer');
  }
  return value;
}

/// Reads a boolean.
bool asBool(Object? value, String path) {
  if (value is! bool) {
    throw EvalFormatException(path, 'expected true or false');
  }
  return value;
}

/// Reads a list of non-empty strings. A missing value is an empty list.
List<String> asStringList(Object? value, String path) {
  if (value == null) return const [];
  if (value is! List) {
    throw EvalFormatException(path, 'expected a list');
  }
  return [
    for (var index = 0; index < value.length; index++)
      asString(value[index], '$path[$index]'),
  ];
}

/// Reads a list of maps. A missing value is an empty list.
List<Map<String, Object?>> asMapList(Object? value, String path) {
  if (value is! List) {
    throw EvalFormatException(path, 'expected a list');
  }
  return [
    for (var index = 0; index < value.length; index++)
      asStringMap(value[index], '$path[$index]'),
  ];
}
